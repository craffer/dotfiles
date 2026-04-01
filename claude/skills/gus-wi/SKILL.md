---
name: gus-wi
description: Look up or create GUS Work Items for the current user. Use this skill whenever the user asks about their work items, sprint tasks, what's in their sprint, what WIs are assigned to them, GUS tickets, wants to check sprint progress, or wants to create/add a new work item or GUS ticket. Trigger on phrases like "show my WIs", "what's in my sprint", "my GUS tickets", "sprint items", "what am I working on", "create a WI", "add a work item", "log a ticket in GUS".
allowed-tools: Bash(sf *)
---

# GUS Work Items

Look up or create ADM_Work__c records in GUS, assigned to the current user.

## Step 0: Detect GUS org and current user (always do this first)

Find the GUS org by matching `gus.my.salesforce.com` in the connected orgs list:

```bash
sf org list --json
```

Extract the `username` of the matching org — use it as `<GUS_ORG>` in all subsequent commands. Then get the user's Salesforce ID:

```bash
sf data query \
  --query "SELECT Id, Name FROM User WHERE Username = '<GUS_ORG>'" \
  --target-org <GUS_ORG> --json
```

---

## Listing work items

Query work items in active sprints. The ±3 day window handles sprint transitions gracefully:

```bash
sf data query \
  --query "SELECT Id, Name, Subject__c, Status__c, Sprint_Name__c, Sprint_Timeframe__c, Story_Points__c, Type__c, Scrum_Team_Name__c FROM ADM_Work__c WHERE Assignee__c = '<USER_ID>' AND Type__c != 'Test Failure' AND Sprint__c IN (SELECT Id FROM ADM_Sprint__c WHERE Start_Date__c <= NEXT_N_DAYS:3 AND End_Date__c >= LAST_N_DAYS:3) ORDER BY Sprint_Timeframe__c, Status__c" \
  --target-org <GUS_ORG> --json
```

**Why exclude Test Failures?** Auto-assigned test failure items create a lot of noise. Show them only if the user asks (drop the `Type__c != 'Test Failure'` filter).

If empty, widen to `LAST_N_DAYS:14` — the user may be between sprints.

### Display format

Group by sprint:

```
Sprint: <Sprint_Name__c>

  W-XXXXXXX  [Status]    [Type]   [Xpt]   Subject
  W-XXXXXXX  [Status]    [Type]           Subject

Total: N work items  (+ M test failures hidden — ask to see them)
```

- Omit `[Xpt]` if all story points are null
- Link each item: `https://gus.lightning.force.com/lightning/r/ADM_Work__c/<Id>/view`

### Listing variations

**Specific sprint** — `Sprint_Timeframe__c LIKE '2026.04a%'`

**All open items** — drop Sprint filter, add `Status__c NOT IN ('Closed', 'Duplicate', 'Not Reproducible', 'Will Not Fix')`

**Another user** — look up their ID via `SELECT Id FROM User WHERE Username = '...'`

---

## Creating a work item

When the user wants to create a WI, collect:

1. **Subject** — required, from the user
2. **Type** — default `User Story`; other common values: `Bug`, `Spike`
3. **Sprint** — default to the current sprint (see below)
4. **Product Tag + Scrum Team** — infer from the user's recent WIs (see below)
5. **Story Points** — optional, ask only if the user mentions it

### Find the current sprint

Query upcoming sprints for the team and let the user confirm if ambiguous:

```bash
sf data query \
  --query "SELECT Id, Name, Start_Date__c, End_Date__c FROM ADM_Sprint__c WHERE Scrum_Team__c = '<SCRUM_TEAM_ID>' AND End_Date__c >= TODAY ORDER BY Start_Date__c ASC LIMIT 3" \
  --target-org <GUS_ORG> --json
```

Pick the sprint whose `Start_Date__c <= TODAY <= End_Date__c`. If none is active, pick the next upcoming one and tell the user.

### Infer product tag and scrum team from recent history

Check the user's most recent WIs to suggest sensible defaults — avoids asking for IDs the user shouldn't need to know:

```bash
sf data query \
  --query "SELECT Product_Tag__c, Product_Tag_Name__c, Scrum_Team__c, Scrum_Team_Name__c FROM ADM_Work__c WHERE Assignee__c = '<USER_ID>' AND Product_Tag__c != null ORDER BY LastModifiedDate DESC LIMIT 5" \
  --target-org <GUS_ORG> --json
```

Use the most frequently appearing product tag + scrum team as the default. If multiple teams appear equally, ask the user to confirm.

### Create the record

```bash
sf data create record --sobject ADM_Work__c \
  --values "Subject__c='<subject>' Type__c='<type>' Status__c='New' Assignee__c='<USER_ID>' Sprint__c='<SPRINT_ID>' Product_Tag__c='<PRODUCT_TAG_ID>' Scrum_Team__c='<SCRUM_TEAM_ID>'" \
  --target-org <GUS_ORG> --json
```

Then fetch the W-number:

```bash
sf data query \
  --query "SELECT Name FROM ADM_Work__c WHERE Id = '<ID_FROM_CREATE>'" \
  --target-org <GUS_ORG> --json
```

### Confirm creation

```
✓ Created W-XXXXXXX: <subject>
  Sprint:  <Sprint_Name__c>
  Type:    <Type__c>
  URL: https://gus.lightning.force.com/lightning/r/ADM_Work__c/<Id>/view
```
