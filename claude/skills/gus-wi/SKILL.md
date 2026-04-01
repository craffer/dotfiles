---
name: gus-wi
description: Look up or create GUS Work Items for the current user. Use this skill whenever the user asks about their work items, sprint tasks, what's in their sprint, what WIs are assigned to them, GUS tickets, wants to check sprint progress, or wants to create/add a new work item or GUS ticket. Trigger on phrases like "show my WIs", "what's in my sprint", "my GUS tickets", "sprint items", "what am I working on", "create a WI", "add a work item", "log a ticket in GUS".
allowed-tools: Bash(sf *)
---

# GUS Work Items

Look up or create ADM_Work__c records in GUS, assigned to the current user.

## Step 0: Detect GUS org and current user (always do this first)

```bash
sf org list --json | python3 -c "
import json,sys
orgs = json.load(sys.stdin)['result']['nonScratchOrgs']
o = next(o for o in orgs if 'gus.my.salesforce.com' in o.get('instanceUrl',''))
print(o['username'])
"
```

Use the printed username as `<GUS_ORG>`. Then get the user's Salesforce ID:

```bash
sf data query --query "SELECT Id FROM User WHERE Username = '<GUS_ORG>'" \
  --target-org <GUS_ORG> --json | python3 -c "
import json,sys; print(json.load(sys.stdin)['result']['records'][0]['Id'])
"
```

---

## Listing work items

Query work items in active sprints. The ±3 day window handles sprint transitions gracefully:

```bash
sf data query \
  --query "SELECT Id, Name, Subject__c, Status__c, Sprint_Name__c, Story_Points__c, Type__c FROM ADM_Work__c WHERE Assignee__c = '<USER_ID>' AND Type__c != 'Test Failure' AND Sprint__c IN (SELECT Id FROM ADM_Sprint__c WHERE Start_Date__c <= NEXT_N_DAYS:3 AND End_Date__c >= LAST_N_DAYS:3) ORDER BY Sprint_Name__c, Status__c" \
  --target-org <GUS_ORG> --json | python3 -c "
import json, sys
records = json.load(sys.stdin)['result']['records']
sprint = None
for r in records:
    s = r.get('Sprint_Name__c') or 'No Sprint'
    if s != sprint:
        sprint = s
        print(f'\nSprint: {s}')
    pts = f\" {int(r['Story_Points__c'])}pt\" if r.get('Story_Points__c') else ''
    url = f\"https://gus.lightning.force.com/lightning/r/ADM_Work__c/{r['Id']}/view\"
    print(f\"  {r['Name']}  [{r['Status__c']}]  {r.get('Type__c','')}{pts}  {r['Subject__c']}\")
    print(f\"    {url}\")
print(f'\nTotal: {len(records)} items')
"
```

**Why exclude Test Failures?** Auto-assigned test failure items create noise. Show them only if asked (drop the `Type__c != 'Test Failure'` filter).

If empty, widen to `LAST_N_DAYS:14` — the user may be between sprints.

### Listing variations

**Specific sprint** — `Sprint_Timeframe__c LIKE '2026.04a%'`

**All open items** — drop Sprint filter, add `Status__c NOT IN ('Closed', 'Duplicate', 'Not Reproducible', 'Will Not Fix')`

**Another user** — look up their ID via `SELECT Id FROM User WHERE Username = '...'`

---

## Creating a work item

When the user wants to create a WI, collect:

1. **Subject** — required, from the user
2. **Description** (`Details__c`) — required, from the user
3. **Story Points** (`Story_Points__c`) — required, ask the user
4. **Type** — default `User Story` unless the user specifies otherwise; other common values: `Bug`, `Spike`.
5. **Sprint** — default to the current sprint (see below)
6. **Product Tag + Scrum Team** — infer from the user's recent WIs (see below)

### Infer product tag, scrum team, and current sprint from recent history

One query gets defaults for everything — avoids asking the user for IDs they shouldn't need to know:

```bash
sf data query \
  --query "SELECT Product_Tag__c, Product_Tag_Name__c, Scrum_Team__c, Scrum_Team_Name__c FROM ADM_Work__c WHERE Assignee__c = '<USER_ID>' AND Product_Tag__c != null ORDER BY LastModifiedDate DESC LIMIT 5" \
  --target-org <GUS_ORG> --json | python3 -c "
import json, sys
from collections import Counter
records = json.load(sys.stdin)['result']['records']
teams = Counter((r['Scrum_Team__c'], r['Scrum_Team_Name__c'], r['Product_Tag__c'], r['Product_Tag_Name__c']) for r in records)
(tid, tname, ptid, ptname), _ = teams.most_common(1)[0]
print(f'team_id={tid} team={tname} tag_id={ptid} tag={ptname}')
"
```

Use the most relevant or most common team/tag as defaults. If ambiguous, confirm with the user.

### Find the current sprint for that team

```bash
sf data query \
  --query "SELECT Id, Name, Start_Date__c, End_Date__c FROM ADM_Sprint__c WHERE Scrum_Team__c = '<SCRUM_TEAM_ID>' AND End_Date__c >= TODAY ORDER BY Start_Date__c ASC LIMIT 3" \
  --target-org <GUS_ORG> --json | python3 -c "
import json, sys
from datetime import date
records = json.load(sys.stdin)['result']['records']
today = date.today().isoformat()
for r in records:
    active = r['Start_Date__c'] <= today <= r['End_Date__c']
    print(f\"{'* ' if active else '  '}{r['Id']}  {r['Name']}  ({r['Start_Date__c']} -> {r['End_Date__c']})\")
"
```

Pick the one marked `*` (active today). If none is active, use the next upcoming one and tell the user.

### RecordTypeId (required — controls icon and layout in UI)

`RecordTypeId` is separate from `Type__c` and must be set explicitly. Default to User Story:

| Type | RecordTypeId |
|---|---|
| User Story | `0129000000006gDAAQ` |
| Bug | `012T00000004MUHIA2` |

For Bugs only, GUS also requires `Found_in_Build__c`, `Impact__c`, `Frequency__c`, and `Priority__c`. Ask the user for appropriate values, or use these N/A-equivalent defaults if they don't care:

| Field | ID | Display name |
|---|---|---|
| `Found_in_Build__c` | `a06T0000001Vew6IAC` | None |
| `Impact__c` | `a0O900000004EF4EAM` | Minor Feature |
| `Frequency__c` | `a0L9000000000uuEAA` | Rarely |
| `Priority__c` | `a0F900000008jfdEAA` | P4 |

Note: Priority does **not** auto-populate via API — it must be set explicitly.

For Bugs, ask the user for appropriate Impact and Frequency values (or look up IDs via `SELECT Id, Name FROM ADM_Impact__c ORDER BY Name`).

### Create the record

```bash
sf data create record --sobject ADM_Work__c \
  --values "Subject__c='<subject>' Details__c='<description>' Story_Points__c=<points> Type__c='User Story' RecordTypeId='0129000000006gDAAQ' Status__c='New' Assignee__c='<USER_ID>' Sprint__c='<SPRINT_ID>' Product_Tag__c='<PRODUCT_TAG_ID>' Scrum_Team__c='<SCRUM_TEAM_ID>'" \
  --target-org <GUS_ORG> --json | python3 -c "
import json, sys
r = json.load(sys.stdin)
print(r['result']['id'])
"
```

Then fetch the W-number:

```bash
sf data query \
  --query "SELECT Name FROM ADM_Work__c WHERE Id = '<ID_FROM_CREATE>'" \
  --target-org <GUS_ORG> --json | python3 -c "
import json, sys; print(json.load(sys.stdin)['result']['records'][0]['Name'])
"
```

### Confirm creation

```
✓ Created W-XXXXXXX: <subject>
  Sprint:  <Sprint_Name__c>
  Type:    <Type__c>
  URL: https://gus.lightning.force.com/lightning/r/ADM_Work__c/<Id>/view
```
