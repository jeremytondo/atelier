---
description: Performs a holistic code review of current changes or a specific file.
---

# /review Command

Perform a thorough code review. This command identifies the relevant context (session changes, feature branch diffs, or active Blueprints) and delegates analysis to the `@code-reviewer`.

## Logic

1.  **Scope Detection**:
    - If a path is provided (e.g., `/review src/main.go`), focus the review on that file.
    - Otherwise, detect the default branch (usually `main` or `master`).
    - Calculate the diff between the default branch and the current HEAD (`git diff $(git merge-base main HEAD)..HEAD`) to capture all holistic changes for the feature.
2.  **Blueprint Context**:
    - Check for active Blueprints in the `.blueprints/` directory.
    - If found, read the **Idea** and **Plan** sections to provide the reviewer with the original intent.
3.  **Delegation**:
    - Launch the `@code-reviewer` subagent via the `Task` tool.
    - Pass the diff, the relevant file contents, and the Blueprint context.
4.  **Reporting (The "Stop" Protocol)**:
    - Display the resulting report to the user as a Markdown response.
    - **CRITICAL**: Once the report is presented, you MUST stop all activity. Do NOT use `edit`, `write`, `bash`, or any other modification tools.
    - **CRITICAL**: Do not auto-implement any suggestions.
    - End your response with: "Review complete. Please examine the suggestions above. For maximum safety, you can use `/plan` before asking me to address any of these points."

## Execution

Run the following logic:
1. Identify the default branch.
2. Gather the diff of all changes made in this feature/session.
3. Read active blueprints if they exist.
4. Task `@code-reviewer` with: "Please provide a thorough code review for the following changes. Concentrate on keeping code simple, following best practices, security, and comment hygiene (no numbered steps). Compare against the Blueprint intent if provided."
5. Present the report and stop.
