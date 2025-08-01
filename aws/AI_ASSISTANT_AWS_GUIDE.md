# AI Assistant AWS Guide: Enforcing Best Practices for Cloud Operations

This document outlines the standards and best practices for an AI assistant performing AWS-related tasks. The primary goal is to ensure all operations are secure, efficient, scalable, and adhere to the principle of Infrastructure as Code (IaC).

## Core Principles

The AI assistant must adhere to the following core principles in all AWS operations:

*   **Infrastructure as Code (IaC):** All AWS resources will be provisioned and managed using AWS CloudFormation. This ensures consistency, repeatability, and version control of the infrastructure.
*   **Security by Design:** Security is a priority at every step. This includes avoiding hardcoded secrets, implementing the principle of least privilege for IAM roles, and securing sensitive data.
*   **Parameterization and Reusability:** CloudFormation templates will be designed to be reusable across different environments through parameterization. Sensitive information and environment-specific configurations will be passed as parameters.
*   **Lifecycle Management:** All resources will be managed through CloudFormation to prevent inconsistencies. Deletion policies will be used to protect critical resources from accidental deletion.
*   **Monitoring and Logging:** All actions will be logged for auditing and security purposes.

## Service-Specific Best Practices

When generating CloudFormation templates, the assistant must apply these proven practices for the following services:

### AWS IAM Roles
*   **Principle of Least Privilege:** IAM policies must grant only the permissions required for the service to perform its task. Avoid wildcards (`*`) for actions or resources whenever possible. Always scope permissions to specific resource ARNs.
*   **Specific Trust Policies:** The `AssumeRolePolicyDocument` must be specific. It should only trust the AWS services that need to assume the role. Never use a broad principal like an entire AWS account without specific conditions.
*   **Inline vs. Managed Policies:** Prefer generating inline policies that are tightly coupled to the resource within the CloudFormation template. Use AWS-managed policies only when a broad set of standard permissions is genuinely required.

### AWS Lambda
*   **Specific Execution Role:** Each Lambda function must have its own dedicated IAM Role following the principle of least privilege.
*   **Configure Memory and Timeout:** Use default values for timeout and memory. Set memory and timeout based on the function's requirements to optimize cost.
*   **Environment Variables:** Never use environment variables **for secrets**. Guide the user to store secrets and configurations in AWS Secrets Manager and fetch them at runtime.

### AWS Step Functions
*   **State Machine Type:** Guide the user to choose the correct type: **Standard** for long-running, auditable workflows or **Express** for high-volume, short-duration event processing.
*   **Least Privilege IAM Role:** The state machine's IAM role must only have permissions to invoke the services defined in its states.
*   **Error Handling:** Implement `Retry` and `Catch` blocks within state definitions to build resilient workflows that can handle transient failures and exceptions gracefully.

### Amazon SNS
*   **Restrictive Topic Policies:** The SNS Topic Policy must restrict who can publish (`sns:Publish`) and subscribe. By default, only the account owner should have full access, with specific IAM roles or services granted publish permissions as needed.
*   **Subscription Filtering:** When subscribing a Lambda function or SQS queue, use a `FilterPolicy` to ensure the subscriber is only invoked for messages it cares about. This reduces cost and unnecessary compute.

### Amazon EventBridge Schedules
*   **Specific Invocation Role:** The schedule must use an IAM role with permission to invoke only its specific target (e.g., a single Lambda function or Step Function state machine).
*   **Cron Expression Generation:** Guide the user to describe the desired schedule in plain English (e.g., 'run every Tuesday at 10 AM'). The assistant will then generate the corresponding cron expression (e.g., `cron(0 10 ? * TUE *)`) for the schedule.
*   **Retry Policy:** Configure a retry policy for the schedule's target. This ensures that if the target invocation fails, the event is not lost and can be retried or analyzed.
*   **Flexible Time Windows:** For non-critical, recurring tasks, suggest using a flexible time window to distribute invocations, which can help avoid resource contention.

### AWS CloudFormation
*   **Use Change Sets for Updates:** For any stack update, the assistant must generate and present a Change Set first. The deployment should only proceed after the user reviews and approves the changes. This prevents unintended resource modifications.
*   **Enable Stack Policies:** For critical infrastructure (e.g., production databases, IAM roles), recommend applying a Stack Policy to prevent accidental updates or deletions of those resources.
*   **Drift Detection:** Inform the user about running CloudFormation Drift Detection to ensure the deployed infrastructure has not been manually altered outside of CloudFormation, thus maintaining the integrity of IaC.

## Standard Workflow for AWS Resource Management

### 1. File and Directory Management

All files and folders created in relation to AWS operations must be located within a designated `aws` directory. This includes, but is not limited to, CloudFormation templates, scripts, related documentation, command responses, output files, and payload files.

### 2. AWS SSO Token Refresh (First-Time Interaction)

Upon the first AWS-related request from a user in a session, or if an authentication error occurs, the assistant must prompt the user to ensure their AWS SSO token is active and valid.

### 3. Requirement Gathering and Clarification

Before proceeding, the assistant must ensure it has all the necessary information from the user, guiding them to use the AWS Secrets Manager to store and fetch sensitive data and environment configurations.

### 4. CloudFormation Template Generation

The assistant will generate a CloudFormation template in YAML format, applying all relevant principles and service-specific best practices outlined above.

### 5. Deployment via CloudFormation

The assistant will use the AWS SSO default profile to deploy the CloudFormation template, guiding the user to create a stack or a change set as appropriate.

### 6. Monitoring and Invocation

*   **Monitoring:** The assistant can provide information on how to monitor the created resources using AWS CloudWatch, including setting up alarms and viewing logs.
*   **Invocation:** For invoking a Lambda function, first refer to the `aws lambda invoke help` documentation. The command should save the input payload in a file and write the output to another file both of which should be located within the `aws` directory.

    **Example Command:**
    ```bash
    aws lambda invoke --function-name YOUR_FUNCTION_NAME --payload file://aws/payload.json aws/response.json
    ```

### 7. Deletion of Resources

Upon request, the assistant will delete the CloudFormation stack, which will, in turn, remove all the resources created by that stack, unless a `DeletionPolicy` of `Retain` was specified.