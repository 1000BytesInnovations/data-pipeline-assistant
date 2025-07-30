import json
import os

import requests
from dotenv import load_dotenv
from requests.auth import HTTPBasicAuth

# Load environment variables from .env file in the jira directory
load_dotenv(dotenv_path="jira/.env")

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
        project_key: The Jira project key (e.g., "SCPLAN").

    Returns:
        A list of stories from the project.
    """
    api_url = f"{JIRA_BASE_URL}/rest/api/3/search"

    # Use JQL (Jira Query Language) to search for issues in the project
    # that are of type 'Story', not done, and assigned to the current user.
    jql_query = f'project = "{project_key}" AND issuetype = Story AND status != "Done" AND assignee = "{JIRA_USER_EMAIL}" ORDER BY created DESC'

    params = {
        "jql": jql_query,
        "fields": "summary,status,description",  # Specify which fields to return
    }

    print(f"Fetching stories for project: {project_key}...")
    try:
        response = session.get(api_url, params=params)
        response.raise_for_status()  # Raises an exception for bad responses (4xx or 5xx)
        data = response.json()
        return data.get("issues", [])
    except requests.exceptions.RequestException as e:
        print(f"Error fetching Jira stories: {e}")
        if hasattr(e, "response") and e.response is not None:
            print(f"Response content: {e.response.text}")
        return None


def save_stories_to_file(stories, filename="jira/jira_stories.json"):
    """
    Saves the fetched stories to a JSON file.

    Args:
        stories: A list of stories to save.
        filename: The name of the file to save the stories to.
    """
    # Ensure the directory exists
    os.makedirs(os.path.dirname(filename), exist_ok=True)

    with open(filename, "w") as f:
        json.dump(stories, f, indent=4)
    print(f"\nSuccessfully saved {len(stories)} stories to {filename}")


def save_selected_story_details(story, filename="jira/selected_story_details.json"):
    """
    Saves the details of the selected story to a JSON file.

    Args:
        story: The selected story object.
        filename: The name of the file to save the details to.
    """
    details = {
        "key": story.get("key"),
        "summary": story.get("fields", {}).get("summary"),
        "description": story.get("fields", {}).get("description"),
    }

    with open(filename, "w") as f:
        json.dump(details, f, indent=4)
    print(f"\nSuccessfully saved details for story {details['key']} to {filename}")


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
        print("Could not fetch stories. Please check your credentials and project key.")
    else:
        # Save all fetched stories to a file
        save_stories_to_file(stories)

        # 3. Interactive selection
        print("\n--- Available Jira Stories ---")
        for i, story in enumerate(stories):
            # The issue key is in story['key']
            # The summary is in story['fields']['summary']
            print(f"{i + 1}. [{story['key']}] {story['fields']['summary']}")

        selected_index = int(input("\nSelect a story to use: ")) - 1
        selected_story = stories[selected_index]

        story_key = selected_story["key"]
        story_summary = selected_story["fields"]["summary"]

        print(f"\nYou selected: {story_key} - {story_summary}")

        # Save the details of the selected story
        save_selected_story_details(selected_story)

        # 4. Format for data pipeline assistant
        formatted_story = f"JIRA_STORY={story_key}\nJIRA_SUMMARY={story_summary}"

        print("\n--- Formatted for Data Pipeline Assistant ---")
        print(formatted_story)
