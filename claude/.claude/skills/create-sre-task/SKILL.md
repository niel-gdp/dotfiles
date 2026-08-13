---
name: create-sre-task
description: Create a new SRE task - files a GitHub issue in GDP-ADMIN/sre-gl-project and populates it on the SRE Project & Cloud Board (org project 372) - Status, Priority, Hours Estimation, Start/Due Date, T-Shirt Sizing, Team, Projects - and assigns it to you.
---

Create a task on the **"[DSO] SRE Project & Cloud Board"** (org `GDP-ADMIN`, project #372, node ID `PVT_kwDOACQejc4A72uc`). It always runs the same way, every time it's invoked, aside from the optional arguments below.

If `$ARGUMENTS` is non-empty, treat it as extra context supplied by the user alongside whatever's in the conversation (e.g. a ticket link, a note on scope, a detail the conversation doesn't cover). Fold it into the drafted body in step 1 — don't bolt it on as a raw dump; put it in whichever `##` section it naturally belongs to (or add one, e.g. `## Additional Context`, if it doesn't fit an existing section). If `$ARGUMENTS` is empty, proceed exactly as before.

## 1. Draft the title and body

Look at what's been discussed in the current conversation (a bug, an incident, a piece of work). Draft:

- A concise **Title**.
- A **body** using whatever `##` sections genuinely fit the task — don't force a fixed template. Only include a section if you can fill it with real, specific content from the conversation; never write filler or a placeholder like `- [ ] ...`. Examples of shapes to consider:
  - Bug/incident: `## What's happening?`, `## Why this happens` (root cause, if known), `## Workaround` (if one exists), `## Solution` / `## Proposed Fix`.
  - Feature/chore: `## Description`, `## Acceptance Criteria` (only with real, specific checkboxes).
  - A trivial one-liner ask: just a short `## Description` paragraph, nothing else.

If the conversation has nothing task-shaped to draw from (fresh/unrelated session), ask the user via `AskUserQuestion` what issue they want created, then draft the body from their answer using the same rules above.

When referencing a PR or issue from a **different** repo than `GDP-ADMIN/sre-gl-project` (e.g. a PR in `gl-sre-terraform`), always write it as `<owner>/<repo>#<number>` (e.g. `GDP-ADMIN/gl-sre-terraform#1599`) — include the owner/org, not just the repo name. GitHub only autolinks cross-repo references in the full `owner/repo#number` form; a bare `#<number>` auto-links to that number *within* `sre-gl-project` itself (wrong issue), and `repo#number` without the owner doesn't autolink at all (dead plain text).

Either way, surface the drafted title + body to the user for confirmation (e.g. in the text of one of the questions below, or as a standalone confirmation before proceeding) so they can redirect it before the issue is filed.

## 2. Ask the user (AskUserQuestion, dropdown-style)

Always ask these — never skip, never silently default:

- **Status**: Backlog / In Progress / In review / Done
- **Start Date**: Today / Yesterday / 2 days ago / Custom (custom → free-text YYYY-MM-DD via "Other")
- **Due Date**: Tomorrow / 2 days later / 7 days later / Custom (custom → free-text YYYY-MM-DD via "Other")
- **Priority**: P0 (High) / P1 (Medium) / P2 (Low)
- **T-Shirt Sizing**: Small (0-1 Days) / Medium (1-3 Days) / Large (1 Week) / X-Large (>1 Week)
- **Hours Estimation (time taken)**: ask "How long did/will this take?" as free text via "Other" (no plausible fixed dropdown options here, since duration varies task to task — offer 2-3 rough anchors like "15 minutes" / "1 hour" / "Custom" just so the question has options, but expect the real answer via "Other"). Accept any natural phrasing — e.g. `15 minutes`, `1 hour 30 minutes`, `45 min`, `2 hours` — and convert it to decimal hours yourself (15 minutes → 0.25, 1 hour 30 minutes → 1.5, 45 min → 0.75). Round to 2 decimal places.

Resolve relative date options to real `YYYY-MM-DD` dates at run time (based on today's date).

## 3. Fields Claude sets itself (never asked)

- **Team**: always `"Projects"` — fixed, no exceptions.
- **Projects**: match the drafted title/description against the option list in the reference table below (client/project names). Pick whichever option is clearly referenced or closest in meaning. If nothing plausibly matches, use **"Other Task"**. Mention the match in the final summary so the user can correct it if wrong.
- **Assignee**: always the current user (`@me`).

## 4. Create the issue

```
gh issue create --repo GDP-ADMIN/sre-gl-project --title "<title>" --body "<body>" --assignee "@me"
```

Capture the printed issue URL.

## 5. Add it to the project (idempotent)

```
gh project item-add 372 --owner GDP-ADMIN --url "<issue-url>" --format json
```

Capture `.id` from the JSON output as `ITEM_ID`. This is safe to run even if the repo's own `github-issue-processor` workflow also adds the issue to the project asynchronously — GitHub Projects de-dupes by content, so this won't create a duplicate item.

## 6. Set the project fields

For every field below, run:

```
gh project item-edit --id "$ITEM_ID" --project-id PVT_kwDOACQejc4A72uc --field-id <field-id> --single-select-option-id <option-id>
```

(or `--date <YYYY-MM-DD>` for Start/Due Date, `--number <N>` for Hours Estimation — see the "Type" column).

Always set: Status, Start Date, Due Date, Priority, T-Shirt Sizing, Team, Projects, Hours Estimation. None of these are optional or skippable.

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
| Djarum FED Sales | `edf05185` | Springboard | `3275d67d` |
| BCAF - Impostor | `fd881460` | korika | `0429ca2f` |
| Padma - PMS | `7c874093` | Lungo | `6eae7c46` |
| BCAL - Sentinel | `aa8a5739` | BCAF SumAHU | `3f7fb1be` |
| Kompit | `2f604ea7` | DasiJR | `70387ad0` |
| Other Task | `0f3dcf7d` | Latte-AI | `df0396b5` |
| GLAIR Vision | `99ad2c9b` | BCA | `b4b8601c` |
| Kaskus | `02349103` | Meemo | `566a000e` |
| Gloria | `fa056c65` | Glance | `1f4bb987` |
| Prosa | `82cfe0dc` | Winters | `521686ea` |
| Glair TSEL | `29ca03bb` | BNPL | `76f35373` |
| Jumpstart - Piccolo | `caec2bbd` | Special Project | `fdc86c2d` |
| Kumparan | `c35dacb4` | BCA - Degree | `06b4eb33` |
| BCAF - Tarico | `4e7a3cfd` | GLChat | `5110c47d` |
| Indonesiakaya | `5f873001` | POC Demo | `75c9df66` |
| Savoria Sire | `f1af89c9` | GL Connectors | `db71535b` |
| BCAF - Astari Healthcheck | `51271382` | Nexus | `03dc5dd6` |
| Mocha | `5bbe90c4` | langfuse | `907811f6` |
| Buzz | `5376f7b3` | CPI | `d4ac0d3f` |
| Kimia Farma | `e0b44036` | Savoria Planogram | `a1f1c682` |
| GSDP | `aeaca3e4` | Langflow | `8966ced3` |
| Endeus | `cf465766` | Binus | `5a1c3d2b` |
| BCALife | `acbfa8b7` | | |
| zkpass | `6cdde18d` | | |
| GIK | `62b3aec6` | | |
| Regtech SKK | `f11b2cbc` | | |
| AVA | `b1962c7f` | | |
| CCEP | `edf1eff7` | | |
| DorWay | `d5c93cc9` | | |
| Djarum Fraud | `8c64138e` | | |
| YMMI | `ca5f3f05` | | |

If the task clearly refers to a client/project not in this table (the board's option list may have grown since this file was written), fall back to "Other Task" rather than guessing at an option ID, and mention that in the final summary.

## 7. Fallback on drift

If any `item-edit` call fails because a field or option ID isn't found, the board has probably changed since this file was written. Re-run:

```
gh project field-list 372 --owner GDP-ADMIN --format json
```

to get fresh IDs, retry the failed edit once, and tell the user this file's reference table may need updating.

## 8. Report back

Print the issue URL and a short summary of every field that was set (Status, Priority, Dates, Sizing, Team, Projects match, Hours Estimation).
