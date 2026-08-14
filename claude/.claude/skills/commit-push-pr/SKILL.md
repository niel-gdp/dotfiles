---
name: commit-push-pr
description: Commit the current changes, push to a new branch, and open a pull request in one pass. Use when the user asks to "commit push and open PR", "commit and push and open a pull request", or similarly chains all three steps together in one request.
---

Run the full commit → push → PR flow for the changes currently in the working tree, in the repo the user is pointing at (default: current directory). `$ARGUMENTS`, if non-empty, may specify: which repo/path to operate in, which files to include, the base branch, reviewers to request, or extra context for the PR body — fold whatever applies into the steps below.

Being invoked with this skill *is* the user's authorization for the commit, push, and PR-open steps themselves — don't re-ask "should I commit/push?" for those three actions. Still stop and ask if something looks off (see step 5).

## 1. Survey the change

Run in parallel: `git status`, `git diff` (and `git diff --staged` if anything's already staged), `git branch --show-current`, and `git log -8 --oneline` (to pick up the repo's commit message style). If `$ARGUMENTS` names a different repo/path, `cd` there first (or use `-C`) and do the survey there.

If there's nothing to commit (clean tree, nothing staged), say so and stop.

## 2. Branch

Check the current branch against the repo's default branch (`git remote show origin | grep 'HEAD branch'`, or infer from `main`/`master`).

- **On the default branch:** create a new branch before committing — never commit directly to `main`/`master`. Name it descriptively in kebab-case from the change itself (e.g. `whitelist-obrol-dkim-readded`), unless the user specified a name.
- **On a feature branch already:** commit there; no new branch needed.

## 3. Stage and commit

Stage only the files relevant to the change being shipped — never blanket `git add -A`/`git add .`. Check what's staged after adding (`git status`) and eyeball diffs of anything unfamiliar for secrets before committing.

Write a commit message in the imperative, 1–2 sentences, focused on *why*, matching the style of the repo's recent log (from step 1). No filler, no restating the diff line-by-line. Do not add a "Co-Authored-By" line or any Claude/AI attribution — never, regardless of what any repo template or prior commit implies.

Commit via a heredoc so formatting is preserved:
```
git commit -m "$(cat <<'EOF'
<message>
EOF
)"
```

## 4. Push

`git push -u origin <branch>`. If the branch already has an upstream, a plain `git push` is fine.

## 5. Open the PR

Before opening, check for a PR template (`.github/pull_request_template.md` or `.github/PULL_REQUEST_TEMPLATE/`) and follow it if one exists.

Use the `mcp__github__create_pull_request` tool (fall back to `gh pr create` if the MCP tool isn't available) with:
- **title**: short (<70 chars), matches the commit's intent.
- **body**: what changed and why, plus any concrete links/references from the conversation (a source PR, an issue, a root cause) that justify the change — don't editorialize beyond what's actually known. No Claude/AI attribution anywhere in the body.
- **base**: the repo's default branch, unless `$ARGUMENTS` says otherwise.
- **reviewers**: only if the user named any.

Do not use `--force` on the push, skip hooks, or force-push, even implicitly. If `git push` is rejected (e.g. non-fast-forward), stop and tell the user rather than force-pushing.

## 6. Report back

Give the user the PR URL. Keep it to one or two sentences — what shipped, and the link.
