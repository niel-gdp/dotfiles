---
name: weekly-report
description: Draft and save Daniel Adamlu's weekly report — pulls this week's assigned items from the "[DSO] SRE Project & Cloud Board" (org GDP-ADMIN, project #372), splits them into Accomplishments (Done) and Next Actions (In Progress / In review), asks for the Issues section, and writes the result to ~/Weekly Reports/.
---

Produce the weekly report in the fixed format Daniel uses (see example below), sourced from project board #372 (`PVT_kwDOACQejc4A72uc`, org `GDP-ADMIN`), and save it to `~/Weekly Reports/`.

If `$ARGUMENTS` is non-empty, treat it as extra context (a note to fold into Issues, a correction to the date range, an item to add/exclude) and apply it in the relevant step below.

## 1. Compute the date range

Weeks run **Sunday–Saturday**. This skill is normally run on the Friday or Saturday of the week it's reporting on (not the week after) — so default to the Sunday–Saturday week containing today's date, even if that week isn't over yet. Format the range as `DD Month YYYY - DD Month YYYY` (e.g. `12 July 2026 - 18 July 2026`) for both the report title and the output filename.

## 2. Check for an existing report

Before fetching anything, check whether `~/Weekly Reports/<range-start> - <range-end>.md` already exists. If it does, this run is an **update**, not a fresh draft:

- Read the existing file — it's the baseline. Preserve any manual edits Daniel made (wording tweaks, reordered items, moved sections) that aren't contradicted by new board data.
- Fetch fresh data per step 3 below, then diff against what's already in the file: add bullets for items that are newly Done / newly In Progress / newly In review since the file was last saved, and reflect status changes (e.g. an item that moved from Next Actions to Accomplishments should move sections, not be duplicated in both).
- Don't regenerate sections that have no changes — leave them as-is rather than re-deriving wording that might now differ from what Daniel already approved.
- Call out in the confirmation step (step 6) specifically what's new or changed, so Daniel isn't re-reviewing the whole report from scratch.

If no file exists yet for this range, proceed normally as a fresh draft.

## 3. Fetch items from the board

Query only items assigned to Daniel — never pull the full board (it has thousands of items):

```
gh project item-list 372 --owner GDP-ADMIN --query "assignee:@me" --format json -L 200
```

This single fetch feeds both sections below, filtered differently:

- **Accomplishments** source: items with `status == "Done"` **and** whose `start Date` or `due Date` falls inside this week's Sunday–Saturday range:

  ```
  jq '[.items[] | select(.status == "Done") | select((.["due Date"] >= "<range-start>" and .["due Date"] <= "<range-end>")
                       or (.["start Date"] >= "<range-start>" and .["start Date"] <= "<range-end>"))]'
  ```

- **Next Actions** source: items with `status == "In Progress"` or `status == "In review"` — **exclude Backlog** — do not date-filter these. They represent everything actively being worked regardless of when they were started or were due.

  ```
  jq '[.items[] | select(.status == "In Progress" or .status == "In review")]'
  ```

Each item has: `content.title`, `content.url` (the SRE board issue), `content.body`, `status`, `projects` (client/project name), `start Date`, `due Date`.

`content.body` is a snapshot from whenever the issue was created/last edited — it can go stale if Daniel later posts a comment correcting or superseding it (e.g. swapping a doc/PR link, noting a plan changed). For every item that will actually appear in the report (i.e. after the Accomplishments/Next Actions filtering below), fetch its comments too and prefer the latest comment's info over the body when they conflict:

```
gh issue view <number> --repo <content.repository> --json body,comments
```

Don't skip this to save calls — the item counts per week are small, and a stale link (e.g. a cancelled doc that was replaced) is worse than the extra fetch.

## 4. Group and write bullets

Group both sections by the `projects` field value (e.g. "BCAF SumAHU", "OpenSandbox", "PPM") — this becomes a project sub-heading, matching the example format. **Every project sub-heading, in every section, must be bold** (`* **Project Name**`) — no exceptions, including "Operational". If an item's `projects` value is the generic `"Other Task"`, label that group **"Operational"** instead — unless the item's title/body clearly names a specific project (e.g. a title prefixed `[OpenSandbox]`), in which case group it under that real project instead of "Operational". Under each project heading, write one bullet per item using its title; pull any ticket/PR links out of `content.body` — Freshservice tickets (`support.gdplabs.id/a/tickets/...`) and PR links (`github.com/GDP-ADMIN/...`) — and attach them as sub-bullets or inline links the way the example does. Always check the body for a Freshservice ticket link even if a PR link is also present; include both when both exist. If an item's body has no useful links, just link the item's own board issue (`content.url`).

Keep the bullets terse and in the same voice as the example (verb-first: "Troubleshoot...", "Add...", "Deploy...") — don't pad items with generic filler.

### Formatting conventions (from Daniel's reference report)

- Bullets use `*`, nested two spaces per level. A project item can itself have sub-bullets (e.g. one bullet per distinct action taken on a multi-step issue).
- Freshservice ticket links: `[[Ticket] SR#<number>](<url>)` — always the literal `SR#` prefix before the ticket number, e.g. `[[Ticket] SR#723](https://support.gdplabs.id/a/tickets/723?current_tab=details)`.
- PR links: `[<repo>#<pr-number>](<url>)`, e.g. `[gl-sre-terraform#1417](https://github.com/GDP-ADMIN/gl-sre-terraform/pull/1417)`. No "PR" label text — the repo#number is self-explanatory.
- In **Accomplishments**, ticket/PR links are usually their own sub-bullet under the action line.
- In **Next Actions**, when an item continues a previously-linked PR/issue, the link is often inline at the end of the bullet in parentheses instead of a sub-bullet, e.g. "Continue the previously failed terragrunt apply on sending celery worker logs to SigNoz ([gl-sre-terraform#1432](...))". Use whichever reads more naturally for the sentence.
- An optional closing section, **`## Technology, Business, Communication, Leadership, Management & Marketing`**, sometimes appears — a link to an article Daniel read plus a one-line takeaway. This is never sourced from the board; only include it if Daniel supplies the content when asked in step 5. Don't fabricate or search for one.

### Generic example (structure to match, not real content)

```markdown
# [Weekly Report: Daniel Adamlu] <range-start> - <range-end>

## **Issues**

* <Plain-text blocker or concern, no link needed>
* <Another issue, can be a couple sentences of context>

## **Accomplishments**

* **<Project Name>**
  * <Verb-first action line>
    * [[Ticket] SR#<number>](<freshservice-url>)
    * [<repo>#<pr-number>](<github-pr-url>)
  * <Another action line with no link>
* **Operational**
  * <Verb-first action line for a generic/one-off task>
    * [<repo>#<pr-number>](<github-pr-url>)

## **Next Actions**

* **<Project Name>**
  * <Upcoming or continuing action line> ([<repo>#<pr-number>](<github-pr-url>))
  * <Another upcoming action line, no link>
```

## 5. Issues section

Look first at what's already been discussed in the current conversation this week (complaints, blockers, scope creep, anything issue-shaped). Then ask via `AskUserQuestion` (or a plain follow-up question) whether there's anything else to flag — free text, allow "nothing" / skip. Combine whatever surfaces into the `## Issues` section. Omit the section entirely if there's truly nothing (don't write a placeholder).

## 6. Draft and confirm

Assemble the full report:

```markdown
# [Weekly Report: Daniel Adamlu] <range-start> - <range-end>

## **Issues**
...

## **Accomplishments**
...

## **Next Actions**
...
```

Show the draft to Daniel for confirmation before saving — he may want to move an item between sections, tweak wording, or add something the board doesn't capture. If this is an update to an existing report (step 2), show just the new/changed bullets rather than the whole document, so Daniel can confirm quickly.

## 7. Save the file

Write the confirmed report to:

```
~/Weekly Reports/<range-start> - <range-end>.md
```

If the file already exists (update case), overwrite it with the merged content — don't create a second file or append a duplicate copy. Create the `~/Weekly Reports/` directory if it doesn't exist yet.

## 8. Report back

Confirm the file path, and briefly note anything that needed manual judgment (e.g. an item's project grouping was ambiguous, a link couldn't be found in the body, the Issues section came from conversation vs. direct ask).
