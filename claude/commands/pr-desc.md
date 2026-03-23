---
description: Generate a PR description markdown file from the branch's changes
user-invocable: true
---

# Generate PR description

Create a pull request description file by analyzing all changes on the current branch relative to the base branch.

## Steps

1. Determine the base branch (usually `master` or `main`).
2. Determine the current branch name and the expected output file path: `pr-descriptions/<branch-name>.md` in the repo root.
3. Check if that file already exists. If it does, read its current contents — you will update it rather than generate from scratch.
4. Run `git log <base>..HEAD` and `git diff <base>...HEAD` to understand ALL changes on this branch.
5. Generate (or update) a PR description using the template below. Replace the HTML comments with real content — do not leave the HTML comments in the output. If an existing description was found, preserve and incorporate any content the user has already written, updating or expanding sections as appropriate based on the current diff.
6. Write the file to `pr-descriptions/` in the repo root. Create the directory if it doesn't exist.
7. Show the user the generated content and the file path.

## Template

```markdown
## Context

<!-- Why is this change being made? -->

## Change

<!-- What is actually changing? -->

## Testing

<!-- How was this tested? -->
```

## Voice & Style

Write like you're explaining this to a teammate at a whiteboard. The author of this PR description is a real human engineer — it should read like one wrote it. Study these patterns carefully:

### Be conversational and direct
- Use first person naturally: "I am from a team that...", "Our team has...", "I would like to..."
- Express real opinions: "seems kind of dumb", "I hope we don't have to use these!", "I would call that a success!"
- Use casual but precise language. Don't sanitize personality out of the writing.
- NEVER use corporate/AI fluff. No "this PR aims to enhance...", no "leveraging", no "streamline". Just say what it does.
- Contractions are fine. Sentence fragments are fine if they're clear.

### Context section — make it personal and specific
- Explain YOUR situation. Why do YOU need this? What problem did YOU hit? Not abstract requirements — your actual experience.
- Narrate your investigation when relevant: "So, why does our Docker build take so long? We can drill into this, too, and fix it."
- Link to relevant resources inline: Quip docs, Slack threads, other PRs, Confluence pages, dashboards. Don't just reference them — link them.
- If there's a work item or prior art, mention it naturally: "Way back in May 2024, after being inspired by a customer presentation, I created W-15906032..."
- Be honest about uncertainty: "I believe this PR should fix that", "I believe the root cause is..."

### Change section — explain it to a human
- Lead with what the change DOES at a human level, not what files changed.
- When the implementation has interesting decisions, explain why you chose your approach, especially when alternatives exist: "I opted to introduce a new class instead of extending the existing one; since the partition discovery logic is different..."
- Use subheadings within the Change section when there are multiple logical parts.
- Call out what this change does NOT do: "As-is this does not yet provide any failover capabilities... It only sets up the DNS records themselves"
- If there's follow-up work, list it with checkboxes showing what's done and what's pending.

### Testing section — show your work with evidence
- Include REAL console output from actual test runs, not hypothetical examples.
- Include real links to test runs, dashboard comparisons, Airflow DAG runs, etc.
- Use comparison tables (before/after) when showing improvements.
- Use `<details>` blocks for verbose output that's useful but not the primary evidence.
- Include screenshots when they help.
- Be honest about testing gaps: "I'm not sure how we can test this before merge", "we'll have to merge this in before we can do further testing"
- If there are testing TODOs, list them with checkboxes and update them with **EDIT:** annotations as they're completed.

### Formatting patterns
- Use fenced code blocks with language tags for commands and output.
- Use `<details><summary>` for long output that's supplementary.
- Use tables for structured comparisons.
- Link generously — other PRs, docs, Slack threads, dashboards, gists.
- Use **bold** for emphasis and `backticks` for identifiers/commands.
- Bullet points over paragraphs when listing things.
- Checkbox lists (`- [x]` / `- [ ]`) for next steps and testing TODOs.

### What to AVOID
- Generic filler: "This PR introduces improvements to..."
- Restating the title in the first line of Context.
- Listing every file changed — explain the logical change instead.
- Overly formal or stiff tone. This should NOT read like a specification.
- Empty platitudes in place of real testing evidence.
- Hedging everything — be direct about what you know and honest about what you don't.
- Em-dashes, quick-lists, over-bolding.

## Content Guidelines

- In the output file, replace each HTML comment section with substantive content. Do NOT include the HTML comments themselves.
- In all cases, use what you've learned throughout the session to populate the PR description.
- If the user provides additional context via arguments, incorporate it.
- If you don't have enough information for a thorough Testing section (e.g., you haven't seen test runs), ask the user rather than making things up. It's better to write "TODO: add testing details" than to fabricate evidence.

$ARGUMENTS
