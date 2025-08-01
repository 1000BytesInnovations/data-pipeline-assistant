import json
import os

import requests
from dotenv import load_dotenv
from requests.auth import HTTPBasicAuth

# Load environment variables from .env file in the jira directory
# Get the directory of the current script
script_dir = os.path.dirname(os.path.abspath(__file__))
env_path = os.path.join(script_dir, ".env")
load_dotenv(dotenv_path=env_path)

# --- Jira API Token Configuration ---
JIRA_USER_EMAIL = os.getenv("JIRA_USER_EMAIL")
JIRA_API_TOKEN = os.getenv("JIRA_API_TOKEN")
JIRA_BASE_URL = os.getenv("JIRA_BASE_URL")
JIRA_PROJECT_KEY = os.getenv("JIRA_PROJECT_KEY")


def get_jira_session():
    """
    Creates a session with Jira using API Token authentication.
    """
    session = requests.Session()
    session.auth = HTTPBasicAuth(JIRA_USER_EMAIL, JIRA_API_TOKEN)
    session.headers.update({"Accept": "application/json"})
    return session


def get_kanban_stories(session, project_key):
    """
    Fetches issues for a given project using the Jira API.

    Args:
        session: An authenticated requests session.
        project_key: The Jira project key (e.g., "KAN").

    Returns:
        A list of issues from the project.
    """
    api_url = f"{JIRA_BASE_URL}/rest/api/3/search"

    # Use JQL (Jira Query Language) to search for issues in the project
    # Include Task, Epic, and Story types, exclude Subtasks, and filter by assignee
    jql_query = f'project = "{project_key}" AND issuetype in (Task, Epic, Story) AND assignee = "{JIRA_USER_EMAIL}" ORDER BY created DESC'

    params = {
        "jql": jql_query,
        "fields": "summary,status,description,issuetype,assignee",  # Specify which fields to return
    }

    print(f"Fetching issues for project: {project_key}...")
    try:
        response = session.get(api_url, params=params)
        response.raise_for_status()  # Raises an exception for bad responses (4xx or 5xx)
        data = response.json()
        issues = data.get("issues", [])
        print(f"Found {len(issues)} issues assigned to you")
        return issues
    except requests.exceptions.RequestException as e:
        print(f"Error fetching Jira issues: {e}")
        if hasattr(e, "response") and e.response is not None:
            print(f"Response status code: {e.response.status_code}")
            print(f"Response content: {e.response.text}")
        return None


def extract_text_from_adf(adf_content):
    """
    Extracts plain text from Atlassian Document Format (ADF) content.

    Args:
        adf_content: The ADF JSON structure from Jira description

    Returns:
        Plain text string extracted from the ADF content
    """
    if not adf_content or not isinstance(adf_content, dict):
        return ""

    text_parts = []

    def extract_text_recursive(content):
        if isinstance(content, dict):
            if content.get("type") == "text":
                text_parts.append(content.get("text", ""))
            elif content.get("type") == "hardBreak":
                text_parts.append("\n")
            elif "content" in content:
                for item in content["content"]:
                    extract_text_recursive(item)
        elif isinstance(content, list):
            for item in content:
                extract_text_recursive(item)

    if "content" in adf_content:
        extract_text_recursive(adf_content["content"])

    # Join text parts and clean up extra whitespace
    text = "".join(text_parts)
    # Replace multiple consecutive newlines with double newline
    import re

    text = re.sub(r"\n\s*\n\s*\n+", "\n\n", text)
    # Replace non-breaking spaces with regular spaces
    text = text.replace("\u00a0", " ")
    # Strip leading/trailing whitespace
    text = text.strip()

    return text


def save_stories_to_file(stories, filename="jira_stories.json"):
    """
    Saves the fetched issues to a JSON file.

    Args:
        stories: A list of issues to save.
        filename: The name of the file to save the issues to.
    """
    with open(filename, "w") as f:
        json.dump(stories, f, indent=4)
    print(f"\nSuccessfully saved {len(stories)} issues to {filename}")


def save_selected_story_details(story, filename="selected_story_details.json"):
    """
    Saves the details of the selected issue to a JSON file.

    Args:
        story: The selected issue object.
        filename: The name of the file to save the details to.
    """
    # Extract description from ADF format
    raw_description = story.get("fields", {}).get("description", {})
    plain_description = extract_text_from_adf(raw_description)

    details = {
        "key": story.get("key"),
        "summary": story.get("fields", {}).get("summary"),
        "description": plain_description,
        "raw_description": raw_description,  # Keep the original format as well
        "issuetype": story.get("fields", {}).get("issuetype", {}).get("name"),
        "status": story.get("fields", {}).get("status", {}).get("name"),
    }

    with open(filename, "w") as f:
        json.dump(details, f, indent=4)
    print(f"\nSuccessfully saved details for issue {details['key']} to {filename}")
    print(
        f"Description preview: {plain_description[:200]}..."
        if len(plain_description) > 200
        else f"Description: {plain_description}"
    )


def list_accessible_projects(session):
    """
    Lists all projects accessible to the authenticated user.
    """
    api_url = f"{JIRA_BASE_URL}/rest/api/3/project"
    print("Fetching accessible projects...")
    try:
        response = session.get(api_url)
        response.raise_for_status()
        projects = response.json()
        return projects
    except requests.exceptions.RequestException as e:
        print(f"Error fetching projects: {e}")
        return None


if __name__ == "__main__":
    # --- Example Usage ---

    # 1. Get authenticated session
    jira_session = get_jira_session()

    # List available projects to help with debugging
    available_projects = list_accessible_projects(jira_session)
    if available_projects:
        print("\n--- Available Projects ---")
        for proj in available_projects:
            print(f"- {proj['key']}: {proj['name']}")
        print("--------------------------\n")

    # 2. Fetch stories from a project
    if not JIRA_PROJECT_KEY:
        print("Error: JIRA_PROJECT_KEY is not set in your .env file.")
        exit(1)
    stories = get_kanban_stories(jira_session, JIRA_PROJECT_KEY)

    if not stories:
        print("Could not fetch issues. Please check your credentials and project key.")
    else:
        # Save all fetched issues to a file
        save_stories_to_file(stories)

        # 3. Interactive selection
        print("\n--- Available Jira Issues ---")
        for i, story in enumerate(stories):
            # The issue key is in story['key']
            # The summary is in story['fields']['summary']
            issue_type = story["fields"]["issuetype"]["name"]
            print(
                f"{i + 1}. [{story['key']}] {issue_type}: {story['fields']['summary']}"
            )

        selected_index = int(input("\nSelect an issue to use: ")) - 1
        selected_story = stories[selected_index]

        story_key = selected_story["key"]
        story_summary = selected_story["fields"]["summary"]

        print(f"\nYou selected: {story_key} - {story_summary}")

        # Save the details of the selected issue
        save_selected_story_details(selected_story)

        # 4. Format for data pipeline assistant
        formatted_story = f"JIRA_STORY={story_key}\nJIRA_SUMMARY={story_summary}"

        print("\n--- Formatted for Data Pipeline Assistant ---")
        print(formatted_story)
