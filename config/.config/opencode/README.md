# OpenCode Blueprint Workflow

This directory contains the configuration for **Blueprint Mode**, a structured development workflow designed to bridge the gap between initial ideas, technical planning, and final implementation.

## 🚀 Quick Start

1.  **Initialize**: Start a new feature or task with `/blueprint "My new feature"`. This creates a new blueprint file in `.blueprints/`.
2.  **Plan**: Architect your solution. The `@blueprint-manager` will help you define the technical approach and checklist.
3.  **Execute**: Implement your changes. Use the Build agent and update the checklist via `@blueprint-manager`.
4.  **Review**: Run `/review` to get a holistic report on your session's changes from the `@code-reviewer`.
5.  **Complete**: Finalize the implementation summary and mark the status as `completed`.

---

## 🔄 The Blueprint Lifecycle

Blueprints follow a strict progression to ensure intent is preserved and quality is maintained:

### 1. Capture (`capture`)
- **Goal**: Preserve the original "Source of Truth" for the change.
- **Agent**: `@blueprint-manager` records notes in the **Idea** section.
- **Rule**: The Idea section becomes immutable once the status moves to `planning`.

### 2. Planning (`planning`)
- **Goal**: Define the "How" before the "What".
- **Action**: Outline architectural decisions, affected components, and execution tasks.
- **Output**: A populated **Plan** section and a structured **Execution** checklist.

### 3. Execution (`executing`)
- **Goal**: Implement the feature while tracking progress.
- **Action**: Use the main agent to write code while delegating checklist updates to `@blueprint-manager`.
- **Checkpoint**: Run `/review` holistically to verify the implementation before moving to the next stage.

### 4. Completion (`completed`)
- **Goal**: Document the final state.
- **Action**: Finalize the **Implementation Summary**, note any **Deviations** from the plan, and record the **Code Review** findings.

---

## 🤖 Specialized Agents

### `@blueprint-manager`
The "Librarian" of the project. It has exclusive permissions to modify the `.blueprints/` directory. It converts notes to blueprints, updates checklists, and generates project state reports.

### `@code-reviewer`
The "Architect". It uses high-reasoning models (Claude 4.5 Opus) to analyze your changes. It is a **read-only** agent that focuses on:
- **Simplicity**: Flagging over-engineered or complex logic.
- **Security**: Identifying potential vulnerabilities.
- **Hygiene**: Strictly enforcing "why" over "what" comments and flagging **numbered steps** in comments.

---

## 🛠 Commands

### `/blueprint [ARGUMENTS]`
Activates Blueprint Mode for the session.
- **No Args**: Lists active blueprints and current status.
- **With Args**: Starts a new blueprint or focuses on an existing one related to the prompt.

### `/review [PATH]`
Triggers a holistic review of all changes made during the session or feature branch.
- **Protocol**: It provides a Markdown report and **stops**. It will never auto-implement changes.
- **Safety**: Suggests using `/plan` if you wish to have the agent assist in addressing findings.

---

## 📜 Best Practices

- **Idea Integrity**: Never modify the **Idea** section once implementation begins. It serves as your historical record of intent.
- **Delegation**: Always use the `Task` tool to delegate blueprint updates to `@blueprint-manager`.
- **Comment Hygiene**: Avoid numbered steps (1, 2, 3) in code comments. Explain *why* something is done, not *how*.
- **Review First**: Always run `/review` before marking a blueprint as `completed`.
