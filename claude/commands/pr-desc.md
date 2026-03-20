---
description: Generate a PR description markdown file from the branch's changes
user-invocable: true
---

# Generate PR description

Create a pull request description file by analyzing all changes on the current branch relative to the base branch.

## Steps

1. Determine the base branch (usually `master` or `main`).
2. Run `git log <base>..HEAD` and `git diff <base>...HEAD` to understand ALL changes on this branch.
3. Generate a PR description that fills in the template below. Replace the HTML comments with real content — do not leave the HTML comments in the output.
4. Write the file to `pr-descriptions/` in the repo root. Name it after the current branch (e.g. `pr-descriptions/my-feature.md`). Create the directory if it doesn't exist.
5. Show the user the generated content and the file path.

## Template

```markdown
## Context

<!-- **Why** are you making a change? What is the problem you're trying to solve? Be specific and thorough; a future engineer (maybe even future you) should be able to look at this PR and figure out exactly _why_ you made this change. -->

## Change

<!-- **What** are you actually changing? Explain it to a human, not necessarily in terms of code. Why did you choose the implementation that you did? What effects does this have? -->

## Testing

<!-- **How do you know** that your change effectively addresses the problem you are trying to solve? Specific details and screenshots are helpful. -->
```

## Guidelines

- In the output file, replace each HTML comment section with substantive content. Do NOT include the HTML comments themselves.
- Be specific and thorough in the Context section — explain the "why"
- In the Change section, explain at a human level, not just listing files changed
- In the Testing section, describe how the changes were tested or how they should be tested. If you're unsure, ask the user.
- In all cases, use what you've learned throughout the session to populate the PR description
- If the user provides additional context via arguments, incorporate it.

$ARGUMENTS
