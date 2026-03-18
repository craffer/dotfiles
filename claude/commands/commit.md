---
description: Commit staged/unstaged changes with a work item prefix
user-invocable: true
---

# Commit with work item

When creating a commit, follow these rules:

1. **Determine the work item**: The format is `@W-XXXXXXXX` (e.g. `@W-21653944`). Every commit message MUST start with the work item prefix. To find it:
   - First, check existing commits on the current feature branch — if they already contain a `@W-` prefix, reuse that same work item.
   - If no work item is found in existing commits, and the user didn't provide one, ask the user.

2. **Commit message format**: `@W-XXXXXXXX: <message>`
   - The first letter of `<message>` should be **lowercase**, unless it is a proper noun (e.g. a product name, class name, etc.)
   - Keep the message concise (1-2 sentences), focusing on the "why" not the "what"

3. **Example commit messages**:
   - `@W-21653944: fix null pointer when user has no email configured`
   - `@W-21653944: add Salesforce OAuth integration for login flow`
   - `@W-21653944: remove deprecated API endpoints`

4. Follow the standard commit workflow: check `git status`, `git diff`, draft the message, stage specific files, commit, and verify.

$ARGUMENTS
