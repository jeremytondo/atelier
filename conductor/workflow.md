# Project Workflow

## Guiding Principles

1. **The Plan is the Source of Truth:** All work must be tracked in `plan.md`.
2. **The Tech Stack is Deliberate:** Changes to the tech stack must be documented in `tech-stack.md` *before* implementation.
3. **Consistency & Portability:** Every script and configuration change must work across macOS, Arch Linux, and Ubuntu.
4. **No-Folding Symlinking:** Maintain `~/.config` as a physical directory; individual symlinks are required.
5. **Non-Interactive & CI-Aware:** Prefer non-interactive commands for installation and automation.

## Task Workflow

All tasks follow a strict lifecycle:

### Standard Task Workflow

1. **Select Task:** Choose the next available task from `plan.md` in sequential order.
2. **Mark In Progress:** Before beginning work, edit `plan.md` and change the task from `[ ]` to `[~]`.
3. **Implement:** Write the scripts or configure the dotfiles as specified in the task.
4. **ShellCheck (Mandatory):** For all shell scripts, run `shellcheck` and fix all reported issues.
5. **Verify Compatibility:** Test the changes on at least one supported platform (local or devcontainer).
6. **Commit Code Changes:**
   - Stage all changes related to the task.
   - Propose a clear, concise commit message.
   - Perform the commit.
7. **Attach Task Summary with Git Notes:**
   - **Step 7.1: Get Commit Hash:** `git log -1 --format="%H"`
   - **Step 7.2: Draft Note Content:** Task name, summary of changes, modified files, and "why".
   - **Step 7.3: Attach Note:** `git notes add -m "<note content>" <commit_hash>`
8. **Record Task Commit SHA:**
   - Update `plan.md` status from `[~]` to `[x]` and append the 7-character commit hash.
9. **Commit Plan Update:**
   - Stage `plan.md` and commit with `conductor(plan): Mark task '<Task Name>' as complete`.

### Phase Completion Protocol

**Trigger:** Executed after a task completes a phase in `plan.md`.

1. **Announce Protocol Start:** Inform the user the phase is complete.
2. **Verify Compatibility:** Ensure the new functionality works as intended.
3. **Manual Verification:** Provide the user with a step-by-step verification plan for the phase.
4. **Await User Feedback:** Pause and wait for the user to confirm with "yes" or provide feedback.
5. **Create Checkpoint Commit:** `git commit --allow-empty -m "conductor(checkpoint): Checkpoint end of Phase X"`.
6. **Record Checkpoint SHA:** Update the phase heading in `plan.md` with `[checkpoint: <sha>]`.
7. **Commit Plan Update:** `git commit -m "conductor(plan): Mark phase '<PHASE NAME>' as complete"`.

## Quality Gates

Before marking any task complete, verify:

- [ ] `shellcheck` passes with no errors.
- [ ] Scripts are portable (macOS/Linux).
- [ ] No hardcoded paths (use `$HOME` or relative paths).
- [ ] Stow commands use `--no-folding`.
- [ ] Machine-specific logic uses `~/.zshrc.local`.
- [ ] Implementation notes added to `plan.md`.

## Definition of Done

A task is complete when:

1. Code implemented to specification.
2. No ShellCheck errors.
3. Changes verified on supported platforms.
4. Changes committed and Git Note attached.
5. `plan.md` updated and commit created.