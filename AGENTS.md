# AGENTS.md

## Scope
This file defines the working contract for AI coding agents in this repository.

Project:
- Kino-App (Tagesabschluss)
- Stack: Flutter / Dart
- Repository: `kino_bar_app`
- Main branch: `master`

## Primary working mode
- Work only in small, controlled runs.
- One run = one clear focus.
- No side refactors.
- No architecture changes unless the run explicitly says so.

## Default lock
Unless a concrete run prompt is provided, agents must not:
- change code
- create or move files
- rename classes, files, widgets, or folders
- add packages or edit `pubspec.*`
- change build / platform / Pod / Gradle / Xcode / macOS config
- change persistence keys, JSON structures, storage contracts, or migration logic
- redesign UI outside the defined target area

Allowed without a run prompt:
- inspect code
- answer understanding questions
- point out risks or ambiguities
- propose a next mini-run

## Technical guardrails
- Internal money calculation stays in cents.
- Existing persistence keys must remain stable unless the run explicitly allows changes.
- No new dependencies unless explicitly approved.
- Changes must stay inside the target area defined by the run prompt.
- Keep naming pragmatic and stable.

## Run types
Supported run types:
- `standard` — normal UX / logic / local refactor in a clearly defined area
- `architecture` — structure / separation / extraction without functional redesign
- `documentation` — comments / docs only, no behavior change

## Behavior on ambiguity
If the prompt is unclear, incomplete, contradictory, or risky:
- stop
- do not make changes
- ask a concise clarification question or return a short diagnosis

## Git safety contract
If the agent is instructed to commit/push, it must first check repository state.
If any of the following appears, stop and report only a short diagnosis plus safe next steps:
- not on `master`
- detached HEAD
- unexpected staged or unstaged unrelated files
- unexpected deletes
- merge / rebase conflict state

Never run destructive cleanup commands automatically.
Examples of forbidden automatic actions:
- `git reset --hard`
- `git clean -fd`
- `git restore .`

## Output contract after a run
After a successful run, the agent should report:
- files actually changed
- how to test the change in 3 concise steps
- expected behavior for those tests
- whether `flutter analyze` is clean
- whether `flutter test` is green (if tests exist)

## Counter + changelog maintenance
After a successful committed run, the agent should also update:
- `.dev/run_counter.txt`
- `CHANGELOG.md`

## Response to this file when loaded into a fresh coding chat
Respond only with:

`Bereit. Warte auf Run-Prompt.`
