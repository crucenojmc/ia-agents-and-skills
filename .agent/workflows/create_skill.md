---
description: Workflow for creating new agent skills with mandatory discovery phase.
---

# Create New Agent Skill

Follow this workflow strictly to create a new skill. This workflow enforces the "Discovery First" protocol.

## 1. Discovery Phase (Mandatory)
// turbo
Before defining the new skill, you MUST search for existing solutions.

1.  Ask the user for the skill topic/keywords.
2.  Run the community search:
    ```bash
    ./skills/universal-skill-creator/scripts/search_community_skills.sh "<keywords>"
    ```
3.  Analyze the output. Does a similar skill exist?
    - **YES**: Ask user if they want to install it instead (`npx skills add...`).
    - **NO**: Proceed to Step 2.

## 2. Definition Phase
// turbo
Define reliability and scope.

1.  Ask: "Is this skill for a specific project feature or a general capability?"
2.  Ask: "Do we have valid reference code or documentation?"
3.  Draft the file structure:
    - `skills/<name>/SKILL.md`
    - `skills/<name>/assets/templates/`

## 3. Implementation Phase
1.  Create the directory:
    ```bash
    mkdir -p skills/<name>
    ```
2.  Use `universal-skill-creator` templates to write `SKILL.md`.
    - **CRITICAL**: Ensure you define a clear "Trigger" and "Persona".

## 4. Quality Assurance (Mandatory)
// turbo
Run the audit script to ensure the new skill complies with standards.

1.  Execute audit:
    ```bash
    ./skills/universal-skill-creator/scripts/audit_workspace.sh
    ```
2.  **Fix any warnings** reported by the script (e.g., missing specific headers in `SKILL.md`).
3.  Repeat until the audit returns "OK".

## 5. Verification & Registration
1.  Add the skill to `AGENTS.md`.
2.  Run the setup script to register it:
    ```bash
    ./setup.sh --all --global
    ```
3.  Notify the user of completion.
