{{
    config(
        materialized='table'
    )
}}

with source_initial_data_stage as (
    -- Logic from command 3, which populates the I$_X_PERSON_POSITION table for the first insert
    select distinct
        'EDW.X_PERSON_DIST_RTLR' as DATA_SRC,
        X_PERSON_POSITION_VW.PERSON_ID,
        X_PERSON_POSITION_VW.POSITION_ID,
        X_PERSON_POSITION_VW.BU_POSITION_ID,
        CASE
            WHEN X_PRIMARY_PERSON_POSITION_VW.POSITION_ID IS NULL
                OR X_PRIMARY_PERSON_POSITION_VW.POSITION_ID IN (
                    SELECT sub_x.POSITION_ID
                    FROM STG_EDW.X_PERSON_POSITION_VW sub_x
                    JOIN STG_EDW.X_PRIMARY_PERSON_POSITION_VW sub_xppp
                        ON sub_x.POSITION_ID = sub_xppp.POSITION_ID
                        AND sub_x.PERSON_ID = sub_xppp.PERSON_ID
                )
            THEN X_PRIMARY_PERSON_POSITION_VW.PERSON_ID
            ELSE NULL
        END as PRIMARY_PERSON_ID
    from STG_EDW.X_PERSON_POSITION_VW X_PERSON_POSITION_VW
    LEFT OUTER JOIN STG_EDW.X_PRIMARY_PERSON_POSITION_VW X_PRIMARY_PERSON_POSITION_VW
        ON X_PERSON_POSITION_VW.POSITION_ID = X_PRIMARY_PERSON_POSITION_VW.POSITION_ID
    where (1=1)
),
x_person_position_first_insert as (
    -- Represents the data inserted into STG_EDW.X_PERSON_POSITION after command 5
    select
        DATA_SRC,
        PERSON_ID,
        POSITION_ID,
        BU_POSITION_ID,
        PRIMARY_PERSON_ID,
        SYSDATE() as CREATE_DT,
        '{{ target.user }}' as CREATE_BY,
        '{{ this.name }}' as CREATE_PGM,
        SYSDATE() as UPDATE_DT,
        '{{ target.user }}' as UPDATE_BY,
        '{{ this.name }}' as UPDATE_PGM
    from source_initial_data_stage
),
source_exception_data_part1_stage as (
    -- Logic from command 9 (first part of UNION), which populates the I$_X_PERSON_POSITION table
    -- References `x_person_position_first_insert` to capture the state of STG_EDW.X_PERSON_POSITION after the first insert
    select
        X_PERSON_EXCPN_ROLE.PERSON_ID,
        CASE X_PERSON_EXCPN_ROLE.EXCPN_POSITION_ID
            WHEN 0 THEN X_PERSON_EXCPN_ROLE.REPLN_POSITION_ID
            ELSE X_PERSON_EXCPN_ROLE.EXCPN_POSITION_ID
        END as POSITION_ID,
        CASE X_PERSON_EXCPN_ROLE.EXCPN_POSITION_ID
            WHEN 0 THEN X_PERSON_POSITION.BU_POSITION_ID
            ELSE X_PERSON_EXCPN_ROLE.REPLN_POSITION_ID
        END as BU_POSITION_ID,
        CASE X_PERSON_EXCPN_ROLE.EXCPN_POSITION_ID
            WHEN 0 THEN X_PERSON_POSITION.PRIMARY_PERSON_ID
            ELSE NULL
        END as PRIMARY_PERSON_ID
    from EDW.X_PERSON_EXCPN_ROLE X_PERSON_EXCPN_ROLE
    INNER JOIN x_person_position_first_insert X_PERSON_POSITION
        ON X_PERSON_EXCPN_ROLE.REPLN_POSITION_ID = X_PERSON_POSITION.POSITION_ID
    INNER JOIN EDW.L_PERSON_ROLE L_PERSON_ROLE
        ON X_PERSON_EXCPN_ROLE.PERSON_ROLE_ID = L_PERSON_ROLE.PERSON_ROLE_ID
        AND L_PERSON_ROLE.PERSON_ROLE_CD <> 'DRAFT'
        AND L_PERSON_ROLE.INACTIVE_FLAG = 'N'
    LEFT OUTER JOIN x_person_position_first_insert X_PERSON_POSITION_DUP
        ON X_PERSON_EXCPN_ROLE.PERSON_ID = X_PERSON_POSITION_DUP.PERSON_ID
    where (1=1)
    And (X_PERSON_POSITION_DUP.DATA_SRC IS NULL AND X_PERSON_EXCPN_ROLE.PERSON_ID <> 0)
),
source_exception_data_part2_stage as (
    -- Logic from command 9 (second part of UNION), which populates the I$_X_PERSON_POSITION table
    -- References `x_person_position_first_insert` to capture the state of STG_EDW.X_PERSON_POSITION after the first insert
    select
        X_PERSON_EXCPN_ROLE.PERSON_ID,
        X_PERSON_EXCPN_ROLE.EXCPN_POSITION_ID as POSITION_ID,
        X_PRIMARY_PERSON_POSITION_VW.POSITION_ID as BU_POSITION_ID,
        null as PRIMARY_PERSON_ID
    from EDW.X_PERSON_EXCPN_ROLE X_PERSON_EXCPN_ROLE
    INNER JOIN EDW.L_PERSON_POSITION L_PERSON_POSITION
        ON X_PERSON_EXCPN_ROLE.EXCPN_POSITION_ID = L_PERSON_POSITION.POSITION_ID
        AND L_PERSON_POSITION.HIER_LEVEL_CD = 'DRAFT'
        AND L_PERSON_POSITION.ACTIVE_FLAG = 'Y'
    CROSS JOIN STG_EDW.X_PRIMARY_PERSON_POSITION_VW X_PRIMARY_PERSON_POSITION_VW
    LEFT OUTER JOIN x_person_position_first_insert X_PERSON_POSITION_DUP
        ON X_PERSON_EXCPN_ROLE.PERSON_ID = X_PERSON_POSITION_DUP.PERSON_ID
    where (1=1)
    And (X_PRIMARY_PERSON_POSITION_VW.PERSON_ROLE_CD = 'NR_BEER_ONVP'
        AND X_PERSON_POSITION_DUP.DATA_SRC IS NULL
        AND X_PERSON_EXCPN_ROLE.PERSON_ID <> 0)
),
x_person_position_second_insert as (
    -- Combines both parts of the second I$_X_PERSON_POSITION population (command 9)
    -- and applies audit columns for insertion into STG_EDW.X_PERSON_POSITION (command 10)
    select
        'EDW.X_PERSON_EXCPN_ROLE' as DATA_SRC,
        PERSON_ID,
        POSITION_ID,
        BU_POSITION_ID,
        PRIMARY_PERSON_ID,
        SYSDATE() as CREATE_DT,
        '{{ target.user }}' as CREATE_BY,
        '{{ this.name }}' as CREATE_PGM,
        SYSDATE() as UPDATE_DT,
        '{{ target.user }}' as UPDATE_BY,
        '{{ this.name }}' as UPDATE_PGM
    from source_exception_data_part1_stage
    union all
    select
        'EDW.X_PERSON_EXCPN_ROLE' as DATA_SRC,
        PERSON_ID,
        POSITION_ID,
        BU_POSITION_ID,
        PRIMARY_PERSON_ID,
        SYSDATE() as CREATE_DT,
        '{{ target.user }}' as CREATE_BY,
        '{{ this.name }}' as CREATE_PGM,
        SYSDATE() as UPDATE_DT,
        '{{ target.user }}' as UPDATE_BY,
        '{{ this.name }}' as UPDATE_PGM
    from source_exception_data_part2_stage
)
-- Final SELECT statement for the materialized table STG_EDW.X_PERSON_POSITION
-- This combines all data that would be in the table after both insert operations
select * from x_person_position_first_insert
union all
select * from x_person_position_second_insert
