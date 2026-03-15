# GearRecolor Release Checklist

Use this checklist for each public release.

## 1) Update addon metadata

- Bump `## Version` in `GearRecolor.toc`.
- Confirm `## Interface` matches current WoW Retail.
- Update `## Notes` if behavior changed.

## 2) Validate addon structure

Expected package shape:

```text
GearRecolor/
  GearRecolor.toc
  GearRecolor.lua
  README.md
  LICENSE
```

The zip must contain a top-level `GearRecolor` folder.

## 3) In-game test pass

- `/reload`
- Hover upgraded items from each available track.
- Verify colorized tooltip lines appear and no Lua errors fire.
- Run `/grc` and verify the chat legend colors match tooltip behavior.

## 4) Community quality gates

- No startup chat spam or intrusive UI.
- No Lua errors on login, reload, bags, character pane, and chat-linked items.
- Keep behavior narrow: only recolor upgrade track lines.
- Keep docs current (`README`) and version synchronized with `.toc`.
- Ensure repository links and issue tracker are valid.

## 5) Build zip for distribution

- Create `GearRecolor-<version>.zip`.
- Include only addon files (no local editor configs).

## 6) Publish to addon hosts

Primary options:

- CurseForge
- Wago Addons
- WoWInterface

If listed by your selected host/provider, updater clients (including WowUp) can discover updates automatically.

## 7) Create GitHub release (optional but recommended)

- Tag: `v<version>`
- Release title: `GearRecolor v<version>`
- Attach zip artifact.
- Paste short release notes.

## 8) Post-publish smoke test

- Install/update from a client (for example, WowUp).
- Confirm the reported version and in-game behavior match the release.
