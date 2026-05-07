# GitHub Issue Templates

This document describes how Arboretum organizes issues in GitHub and the
templates that support that process.

Each time these templates are updated, update this README alongside them.

## Why we have templates

Templates exist for two reasons:

1. **Compliance.** Every issue must capture security, privacy, authorization,
   and consent impact. Templates make this a required field rather than a
   convention that erodes over time. The blank-issue template is
   [disabled](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/configuring-issue-templates-for-your-repository#configuring-the-template-chooser)
   in [`config.yml`](./config.yml) so engineers cannot bypass this.
2. **Stakeholder rollup.** Templates assign a GitHub Issue Type
   (`Feature` / `Bug` / `Task`) consistent with our
   [conventional commit](https://www.conventionalcommits.org) prefixes. That
   classification drives the project board's views, so stakeholders can see
   how engineering work rolls up to the features tracked in the
   [Notion Product Roadmap](https://www.notion.so/Product-Roadmap-Backlog-22412964fe5f80129b3cfd848a4cf623).

## Templates

| Template | Issue Type | When to use | Closed by PR with prefix |
|---|---|---|---|
| [`feature.yml`](./feature.yml) | `Feature` | Work that delivers part of a roadmap feature | `feat(...)` |
| [`bug.yml`](./bug.yml) | `Bug` | Something is broken | `fix(...)` |
| [`task.yml`](./task.yml) | `Task` | Engineering work not tied to a roadmap feature (refactors, infra, CI, perf, docs, tests) | `chore`, `refactor`, `perf`, `build`, `ci`, `docs`, `test`, `style`, `revert` |
| [`tracking.yml`](./tracking.yml) | `Feature` (with `tracking` label) | Bridge issue mirroring a Notion roadmap feature; child work attaches as sub-issues | n/a — closed when all child issues are closed |

Templates use [GitHub's form schema](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-githubs-form-schema).
The form's input renders into the body of the GitHub issue.

## How to create an issue

### From the browser

Click "New issue" in the repo, pick the template, fill it out.

### From the `gh` CLI

The terminal flow (`gh issue create -T <name>`) does **not** support YAML
issue forms. Use `--web` to open the browser pre-selected to the right form:

```bash
gh issue create --web --template feature.yml
gh issue create --web --template bug.yml
gh issue create --web --template task.yml
gh issue create --web --template tracking.yml
```

## How issues roll up to features

1. Product defines features in the
   [Notion Product Roadmap](https://www.notion.so/Product-Roadmap-Backlog-22412964fe5f80129b3cfd848a4cf623).
2. Engineering creates one **tracking issue** per Notion feature using the
   `tracking.yml` template. The tracking issue links to the Notion page; the
   Notion page embeds the tracking issue so PM sees live engineering progress.
3. Engineers file `feature.yml` or `bug.yml` issues for the work that
   delivers (or fixes) that feature, and attach them as sub-issues of the
   relevant tracking issue at triage time.
4. `task.yml` issues are not attached to any tracking issue — they represent
   ongoing engineering investment that is visible to stakeholders as its own
   category on the project board.

The triage queue on the project board surfaces any `Feature` or `Bug` issue
that lacks a parent tracking issue, so nothing falls through.

## Template ordering

Templates appear in the chooser in alphabetical order by filename. Filenames
are intentionally bare (no numeric prefix) so they read cleanly when passed
to `gh --template <name>.yml`.
