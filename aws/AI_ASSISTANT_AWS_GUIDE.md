# AI Assistant AWS Guide: Enforcing Best Practices for Cloud Operations

This document outlines the standards and best practices for an AI assistant performing AWS-related tasks. The primary goal is to ensure all operations are secure, efficient, scalable, and adhere to the principle of Infrastructure as Code (IaC).

## Core Principles

The AI assistant must adhere to the following core principles in all AWS operations:

*   **Infrastructure as Code (IaC):** All AWS resources will be provisioned and managed using AWS CloudFormation. This ensures consistency, repeatability, and version control of the infrastructure.
*   **Security by Design:** Security is a priority at every step. This includes avoiding hardcoded secrets, implementing the principle of least privilege for IAM roles, and securing sensitive data.
*   **Parameterization and Reusability:** CloudFormation templates will be designed to be reusable across different environments through parameterization. Sensitive information and environment-specific configurations will be passed as parameters.
*   **Lifecycle Management:** All resources will be managed through CloudFormation to prevent inconsistencies. Deletion policies will be used to protect critical resources from accidental deletion.
*   **Monitoring and Logging:** All actions will be logged for auditing and security purposes.

## Standard Workflow for AWS Resource Management

The AI assistant must follow this workflow for all requests involving the creation, modification, or deletion of AWS resources.

### 1. File and Directory Management

All files and folders created in relation to AWS operations must be located within a designated `aws` directory. This includes, but is not limited to, CloudFormation templates, scripts, related documentation, command responses, output files, and payload files. To maintain a clean and manageable project structure, these files should be further organized into subdirectories that logically categorize the resources or projects they pertain to.

### 2. AWS SSO Token Refresh (First-Time Interaction)

Upon the first AWS-related request from a user in a session, or if an authentication error occurs, the assistant must prompt the user to ensure their AWS SSO token is active and valid. It will provide the necessary command to refresh the token. This step is crucial to ensure that all subsequent AWS CLI commands for deployment and management are properly authenticated.

### 3. Requirement Gathering and Clarification

Before proceeding, the assistant must ensure it has all the necessary information from the user. For sensitive data, such as email addresses for SNS subscriptions or API keys, the assistant will prompt the user to store them in AWS Systems Manager Parameter Store (SSM) or AWS Secrets Manager.

### 4. CloudFormation Template Generation

The assistant will generate a CloudFormation template in YAML format with the following structure and best practices:

*   **Parameters:**
    *   All hardcoded values must be replaced with parameters.
    *   AWS-specific parameter types must be used for input validation (e.g., `AWS::EC2::VPC::Id`).
    *   Constraints must be defined for parameters to enforce valid inputs.
    *   For sensitive information, the `NoEcho` property must be set to `true`, and users must be guided to use dynamic references to SSM or Secrets Manager for a more secure approach.
*   **Resources:**
    *   Resources must be clearly named and defined.
    *   IAM roles must be created with the minimum required permissions (least privilege).
    *   The default `DeletionPolicy` for all resources will be `Delete` unless specified to `Retain`.
*   **Outputs:**
    *   Outputs must be used to export resource names and other important identifiers for easy access and cross-stack referencing.

### 5. Deployment via CloudFormation

The AI assistant will use the AWS SSO default profile to deploy the CloudFormation template, as requested by the user. The assistant will create a CloudFormation stack to provision the resources.

### 6. Monitoring and Invocation

*   **Monitoring:** The assistant can provide information on how to monitor the created resources using AWS CloudWatch, including setting up alarms and viewing logs.
*   **Invocation:** The assistant will provide the necessary commands or steps to invoke the created resources, such as a Lambda function.

### 7. Deletion of Resources

Upon request, the assistant will delete the CloudFormation stack, which will, in turn, remove all the resources created by that stack, unless a `DeletionPolicy` of `Retain` was specified.