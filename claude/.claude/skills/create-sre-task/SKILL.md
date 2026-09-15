---
name: create-sre-task
description: Create a new SRE task - files a GitHub issue in GDP-ADMIN/sre-gl-project and populates it on the SRE Project & Cloud Board (org project 372) - Status, Priority, Hours Estimation, Start/Due Date, T-Shirt Sizing, Team, Projects - and assigns it to you. If an existing sre-gl-project issue link or number is given, updates that issue with a comment instead of creating a new one.
---

Create a task on the **"[DSO] SRE Project & Cloud Board"** (org `GDP-ADMIN`, project #372, node ID `PVT_kwDOACQejc4A72uc`). It always runs the same way, every time it's invoked, aside from the optional arguments below.

If `$ARGUMENTS` is non-empty, treat it as extra context supplied by the user alongside whatever's in the conversation (e.g. a ticket link, a note on scope, a detail the conversation doesn't cover). Fold it into the drafted body in step 1 — don't bolt it on as a raw dump; put it in whichever `##` section it naturally belongs to (or add one, e.g. `## Additional Context`, if it doesn't fit an existing section). If `$ARGUMENTS` is empty, proceed exactly as before.

## 0. Detect create vs. update

Check `$ARGUMENTS` (and the conversation, if the user references it there instead) for a link or number pointing at an **existing** `GDP-ADMIN/sre-gl-project` issue — e.g. `https://github.com/GDP-ADMIN/sre-gl-project/issues/4514`, `GDP-ADMIN/sre-gl-project#4514`, or a bare number the user clearly means as "that issue" (confirm with the user if a bare number is ambiguous rather than guessing). A reference to an issue in some *other* repo doesn't count — this only applies to `sre-gl-project` issues, since that's the repo this skill files into.

- **Found** → this is an **update**. Skip drafting a new title/body in step 1; instead pull the existing issue for context (`gh issue view <number> --repo GDP-ADMIN/sre-gl-project`) and go to the update path in steps 1 and 4.
- **Not found** → this is a **create**, proceed exactly as documented below.

## 1. Draft the content

**Create path** (no existing issue found in step 0): Look at what's been discussed in the current conversation (a bug, an incident, a piece of work). Draft:

- A concise **Title**.
- A **body** using whatever `##` sections genuinely fit the task — don't force a fixed template. Only include a section if you can fill it with real, specific content from the conversation; never write filler or a placeholder like `- [ ] ...`. Examples of shapes to consider:
  - Bug/incident: `## What's happening?`, `## Why this happens` (root cause, if known), `## Workaround` (if one exists), `## Solution` / `## Proposed Fix`.
  - Feature/chore: `## Description`, `## Acceptance Criteria` (only with real, specific checkboxes).
  - A trivial one-liner ask: just a short `## Description` paragraph, nothing else.

If the conversation has nothing task-shaped to draw from (fresh/unrelated session), ask the user via `AskUserQuestion` what issue they want created, then draft the body from their answer using the same rules above.

**Update path** (existing issue found in step 0): the issue's title/body stay as they are — don't rewrite them. Instead draft a **comment** summarizing what's new since the issue was last touched (progress made, what changed, current status/blockers), based on what's been discussed in this conversation. Same content rules as above: only real, specific detail, no filler. Skip this entirely if `$ARGUMENTS` or the conversation already hands you the exact comment text to post verbatim — don't re-draft what the user already wrote.

When referencing a PR or issue from a **different** repo than `GDP-ADMIN/sre-gl-project` (e.g. a PR in `gl-sre-terraform`), always write it as `<owner>/<repo>#<number>` (e.g. `GDP-ADMIN/gl-sre-terraform#1599`) — include the owner/org, not just the repo name. GitHub only autolinks cross-repo references in the full `owner/repo#number` form; a bare `#<number>` auto-links to that number *within* `sre-gl-project` itself (wrong issue), and `repo#number` without the owner doesn't autolink at all (dead plain text).

Either way, surface the drafted title + body (or comment) to the user for confirmation (e.g. in the text of one of the questions below, or as a standalone confirmation before proceeding) so they can redirect it before anything is posted.

## 2. Ask the user (AskUserQuestion, dropdown-style)

Always ask these four — never skip, never silently default. This applies on both the create and update paths: even when updating an existing issue, its Status/dates/etc. may have genuinely changed since it was filed, so re-ask rather than assuming the old values still hold.

- **Status**: Backlog / In Progress / In review / Done
- **Start Date**: Today / Yesterday / 2 days ago / Custom (custom → free-text YYYY-MM-DD via "Other")
- **Due Date**: Tomorrow / 2 days later / 7 days later / Custom (custom → free-text YYYY-MM-DD via "Other")
- **Priority**: P0 (High) / P1 (Medium) / P2 (Low)

**T-Shirt Sizing** and **Hours Estimation** size/time an actual work session, so whether to ask depends on the path:

- **Create path**: always ask both — never skip.
- **Update path**: ask both only if this session involved real work (progress, a fix, an investigation) reflected in the drafted comment. Skip both entirely — don't ask, don't touch either field in step 6 — if the update is purely informational (e.g. adding a reference/ticket link, a note, a typo correction) with no work session to size or time. State plainly which case applies before proceeding, so the user can override if they'd rather log time for it anyway.

When asked:

- **T-Shirt Sizing**: Small (0-1 Days) / Medium (1-3 Days) / Large (1 Week) / X-Large (>1 Week)
- **Hours Estimation (time taken)**: ask "How long did/will this take?" as free text via "Other" (no plausible fixed dropdown options here, since duration varies task to task — offer 2-3 rough anchors like "15 minutes" / "1 hour" / "Custom" just so the question has options, but expect the real answer via "Other"). Accept any natural phrasing — e.g. `15 minutes`, `1 hour 30 minutes`, `45 min`, `2 hours` — and convert it to decimal hours yourself (15 minutes → 0.25, 1 hour 30 minutes → 1.5, 45 min → 0.75). Round to 2 decimal places. **On the update path**, this question means "how long did *this additional* session take" — the answer gets added on top of the field's current value (fetched in step 6), not used to replace it.

Resolve relative date options to real `YYYY-MM-DD` dates at run time (based on today's date).

## 3. Fields Claude sets itself (never asked)

- **Team**: always `"Projects"` — fixed, no exceptions.
- **Projects**: match against the option list in the reference table below (client/project names) — on the create path, match the drafted title/description; on the update path, match the existing issue's title/body (fetched in step 0). Pick whichever option is clearly referenced or closest in meaning. If nothing plausibly matches, use **"Other Task"**. Mention the match in the final summary so the user can correct it if wrong.
- **Assignee**: always the current user (`@me`) — create path only; don't reassign an existing issue on the update path unless the user asks.

## 4. Create the issue, or comment on the existing one

**Create path:**

```
gh issue create --repo GDP-ADMIN/sre-gl-project --title "<title>" --body "<body>" --assignee "@me"
```

Capture the printed issue URL.

**Update path:** don't create anything. Post the comment drafted in step 1 to the existing issue instead:

```
gh issue comment <number> --repo GDP-ADMIN/sre-gl-project --body "<comment>"
```

Use the existing issue's URL (from step 0) as `<issue-url>` in step 5.

## 5. Add it to the project (idempotent)

```
gh project item-add 372 --owner GDP-ADMIN --url "<issue-url>" --format json
```

Capture `.id` from the JSON output as `ITEM_ID`. This is safe to run even if the repo's own `github-issue-processor` workflow also adds the issue to the project asynchronously — GitHub Projects de-dupes by content, so this won't create a duplicate item. On the update path this is also how you get `ITEM_ID` for an issue that's already on the board — it returns the existing item instead of creating a new one.

## 6. Set the project fields

On the update path, if T-Shirt Sizing / Hours Estimation were asked (per step 2), first read the item's current field values (e.g. `gh project item-list 372 --owner GDP-ADMIN --format json` filtered to `ITEM_ID`, or a GraphQL `node(id: ...)` query) so you can add the new Hours Estimation answer on top of the existing number rather than overwriting it.

For every field below, run:

```
gh project item-edit --id "$ITEM_ID" --project-id PVT_kwDOACQejc4A72uc --field-id <field-id> --single-select-option-id <option-id>
```

(or `--date <YYYY-MM-DD>` for Start/Due Date, `--number <N>` for Hours Estimation — see the "Type" column).

Always set: Status, Start Date, Due Date, Priority, Team, Projects. None of these are optional or skippable. Set T-Shirt Sizing and Hours Estimation too, unless step 2 determined this is a purely informational update path with no work session — in that case leave both fields untouched.

### Field reference table

| Field | Field ID | Type |
|---|---|---|
| Status | `PVTSSF_lADOACQejc4A72uczgwB3_Q` | single-select |
| Priority | `PVTSSF_lADOACQejc4A72uczgwB3_8` | single-select |
| Hours Estimation | `PVTF_lADOACQejc4A72uczgwB4AI` | number |
| Start Date | `PVTF_lADOACQejc4A72uczgwB4AM` | date |
| Due Date | `PVTF_lADOACQejc4A72uczgwB4AQ` | date |
| T-Shirt Sizing | `PVTSSF_lADOACQejc4A72uczgwB4AU` | single-select |
| Team | `PVTSSF_lADOACQejc4A72uczgwB4R0` | single-select |
| Projects | `PVTSSF_lADOACQejc4A72uczgwowZ4` | single-select |

### Status options

| Name | Option ID |
|---|---|
| Backlog | `f75ad846` |
| Ready | `61e4505c` (not offered by this skill's question, but exists on the board) |
| In Progress | `47fc9ee4` |
| In review | `df73e18b` |
| Done | `98236657` |

### Priority options

| Name | Option ID |
|---|---|
| P0 (High) | `79628723` |
| P1 (Medium) | `0a877460` |
| P2 (Low) | `da944a9c` |

### T-Shirt Sizing options

| Name | Option ID |
|---|---|
| Small (0-1 Days) | `aee0b5a7` |
| Medium (1-3 Days) | `2c89b3b4` |
| Large (1 Week) | `4f72ddf0` |
| X-Large (>1 Week) | `2169ca06` |

### Team options

| Name | Option ID |
|---|---|
| Cloud | `f3a9b6b0` |
| Projects | `3726fae4` (always used by this skill) |

### Projects options

| Name | Option ID | Name | Option ID |
|---|---|---|---|
| Djarum FED Sales | `f18afe32` | Lungo | `e70572a4` |
| BCAF - Impostor | `c6772d9b` | BCAF SumAHU | `c8cb5364` |
| Padma - PMS | `b69f634e` | DasiJR | `7ffe2642` |
| BCAL - Sentinel | `f314b362` | Latte-AI | `8915d154` |
| Kompit | `800c6cd3` | BCA | `0bdbe9c9` |
| Other Task | `ea9241d8` | Meemo | `d15ec20f` |
| GLAIR Vision | `1092c752` | Glance | `412a29eb` |
| Kaskus | `3f0814ae` | Winters | `417ad7a8` |
| Gloria | `98e3063d` | BNPL | `ff740691` |
| Prosa | `3dce023e` | Special Project | `61f60981` |
| Glair TSEL | `dd28687f` | BCA - Degree | `1ae3f053` |
| Jumpstart - Piccolo | `1983d0a5` | GLChat | `6f4e7752` |
| Kumparan | `e109bf75` | POC Demo | `adc011a3` |
| BCAF - Tarico | `927816be` | GL Connectors | `5a7b3d5c` |
| Indonesiakaya | `f0ac40fb` | Nexus | `1cfdca39` |
| Savoria Sire | `2224fd81` | langfuse | `597b7743` |
| BCAF - Astari Healthcheck | `fe63df13` | CPI | `5aba0b6d` |
| Mocha | `aa44bc90` | Savoria Planogram | `512714a2` |
| Buzz | `8402105d` | Langflow | `478aa957` |
| Kimia Farma | `835fa50a` | Binus | `5df9c5c0` |
| GSDP | `68ef118e` | auto-rec | `6bc53eb0` |
| Endeus | `8c156133` | Github access | `f6c552b1` |
| BCALife | `460e5e4d` | HCI | `ce480dd1` |
| zkpass | `3391bf5c` | [AWS] Cloud Permission | `e18105f1` |
| GIK | `188c2de1` | GCP Permission | `1cbde2c4` |
| Regtech SKK | `c9efb723` | OpenSandbox | `bd9fb066` |
| AVA | `22b03620` | [SaaS] Access | `6177d360` |
| CCEP | `b8ea0d3a` | Healtcheck ICR Static + QD | `0789fb9f` |
| DorWay | `dd60a300` | Agentic Engineering Workflows | `813d7ab4` |
| Djarum Fraud | `b46ca4a9` | SRE Copilot | `979bba82` |
| YMMI | `209b9560` | E2B | `1daf9c55` |
| Springboard | `9b5e1595` | [Azure] Cloud Permission | `5a32358a` |
| korika | `68b1c2de` | [GCP] Cloud Permission | `455ab868` |

If the task clearly refers to a client/project not in this table (the board's option list may have grown since this file was written), fall back to "Other Task" rather than guessing at an option ID, and mention that in the final summary.

## 7. Fallback on drift

If any `item-edit` call fails because a field or option ID isn't found, the board has probably changed since this file was written. Re-run:

```
gh project field-list 372 --owner GDP-ADMIN --format json
```

to get fresh IDs, retry the failed edit once, and tell the user this file's reference table may need updating.

## 8. Report back

Print the issue URL and a short summary of every field that was set (Status, Priority, Dates, Team, Projects match, and Sizing/Hours Estimation if they were set). On the update path, say explicitly that this updated an existing issue via comment rather than creating a new one; note the new cumulative Hours Estimation total if it was updated, or state that Sizing/Hours Estimation were left unchanged because this was a purely informational update.
