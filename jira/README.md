# Jira Integration Setup

This document provides instructions on how to set up the Jira integration for the data pipeline assistant.

## How to Generate a Jira API Token

To connect to Jira, you need to use your email address and an API token. Follow these steps to create a token:

1. **Log in to your Atlassian account**: Go to [https://id.atlassian.com/manage-profile/security](https://id.atlassian.com/manage-profile/security).
2. **Navigate to API tokens**: In the security settings, find and click on **API tokens**.
3. **Create a new token**: Click on **Create API token**.
4. **Name your token**: Give your token a descriptive name (e.g., "data-pipeline-assistant-token") and click **Create**.
5. **Copy your token**: A new token will be generated. **Copy it immediately**, as you will not be able to see it again.

## Environment Configuration

1. **Create a `.env` file**: In this `jira` directory, create a new file named `.env`.
2. **Add your credentials**: Copy the content from `.env.example` and paste it into your new `.env` file.
3. **Fill in your details**:
   - `JIRA_USER_EMAIL`: Your Atlassian account email address.
   - `JIRA_API_TOKEN`: The API token you just created.
   - `JIRA_BASE_URL`: The base URL of your Jira instance (e.g., `https://your-domain.atlassian.net`).
   - `JIRA_PROJECT_KEY`: The key of the Jira project you want to fetch stories from (e.g., `SCPLAN`).

Your `.env` file should look like this:

```
# Jira Integration with API Token
JIRA_USER_EMAIL=your_email@example.com
JIRA_API_TOKEN=your_jira_api_token
JIRA_BASE_URL=https://cbi-docs.atlassian.net
JIRA_PROJECT_KEY=SCPLAN
```

Once you have completed these steps, you can run the `jira_integration.py` script to fetch and select Jira stories.
