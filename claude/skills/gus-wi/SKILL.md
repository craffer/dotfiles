---
name: gus-wi
description: Look up GUS Work Items assigned to the current user in the current sprint. Use this skill whenever the user asks about their work items, sprint tasks, what's in their sprint, what WIs are assigned to them, GUS tickets, or wants to check their current sprint progress. Trigger on phrases like "show my WIs", "what's in my sprint", "my GUS tickets", "sprint items", "what am I working on".
allowed-tools: Bash(sf *)
---

# GUS Work Items – Current Sprint

Looks up ADM_Work__c records assigned to the current user that are in their active sprint(s).

## Steps

### 1. Detect the GUS org and current user

Find the GUS org by looking for `gus.my.salesforce.com` in the connected orgs list:

```bash
sf org list --json
```

Extract the `username` of the org whose `instanceUrl` contains `gus.my.salesforce.com`. Use that username as `<GUS_TARGET_ORG>` in all subsequent commands. Then look up the Salesforce User ID:

```bash
sf data query \
  --query "SELECT Id, Name FROM User WHERE Username = '<GUS_TARGET_ORG>'" \
  --target-org <GUS_TARGET_ORG> --json
```

### 2. Query work items in the current sprint

Use a subquery to find active sprints. The ±3 day window handles sprint transitions gracefully (sprint boundary just passed, or sprint started today):

```bash
sf data query \
  --query "SELECT Id, Name, Subject__c, Status__c, Sprint_Name__c, Sprint_Timeframe__c, Story_Points__c, Type__c, Scrum_Team_Name__c FROM ADM_Work__c WHERE Assignee__c = '<USER_ID>' AND Type__c != 'Test Failure' AND Sprint__c IN (SELECT Id FROM ADM_Sprint__c WHERE Start_Date__c <= NEXT_N_DAYS:3 AND End_Date__c >= LAST_N_DAYS:3) ORDER BY Sprint_Timeframe__c, Status__c" \
  --target-org <GUS_TARGET_ORG> --json
```

**Why exclude Test Failures?** Auto-generated test failure work items are bulk-assigned and create a lot of noise. They're shown separately if the user asks.

If results are empty, try widening to `LAST_N_DAYS:14` to check whether items exist but are between sprints.

### 3. Display results

Group by sprint, then show a compact table:

```
Sprint: <Sprint_Name__c>                         (<Sprint_Timeframe__c>)

  W-XXXXXXX  [Status]         [Type]   [Xpt]   Subject
  W-XXXXXXX  [Status]         [Type]           Subject

Total: N work items  (+ M test failures not shown — say "show test failures" to see them)
```

- Omit the `[Xpt]` column if all story points are null
- Include GUS URL for each item: `https://gus.lightning.force.com/lightning/r/ADM_Work__c/<Id>/view`
- If the user asks about test failures, run the same query without the `Type__c != 'Test Failure'` filter

## Variations

**Specific sprint** — if the user names a sprint (e.g. "2026.04a items"), filter by:
```
Sprint_Timeframe__c LIKE '2026.04a%'
```

**All open items regardless of sprint** — drop the Sprint filter and add:
```
Status__c NOT IN ('Closed', 'Duplicate', 'Not Reproducible', 'Will Not Fix')
```

**Another user** — look up their User ID via `SELECT Id FROM User WHERE Username = '...'` against `<GUS_TARGET_ORG>` and substitute it for `<USER_ID>`.
