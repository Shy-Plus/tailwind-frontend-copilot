# tailwind-frontend-copilot

Tailwind Frontend Copilot skill for Codex/OpenClaw.

This repository hosts the deliverables for the `tailwind-frontend-copilot` skill, including:
- skill package artifact (`.skill`)
- test fixtures and validation reports
- planning and maintenance documents
- release assets for direct download

## What This Skill Covers

- New Tailwind integration for frontend projects
- Maintenance and debugging for existing Tailwind projects
- Performance and style improvement workflows
- Tailwind v3 to v4 migration guidance with rollback strategy
- Human-in-the-loop gates (Gate A/B/C)

## Repository Structure

- `dist/`: packaged skill artifact and release package files
- `docs/plans/`: implementation plans
- `tailwind-skill-testbeds/`: test fixtures for scenario simulation
- `tailwind-skill-tests/`: test outputs and reports
- `task_plan.md`, `findings.md`, `progress.md`: process tracking artifacts
- `Everything-SDK/`: upstream SDK files retained from local workspace

## Quick Start

### 1) Download release asset

Use the latest release asset:
- `tailwind-frontend-copilot.skill`

### 2) Install into skill directories

Typical local locations:
- Codex: `~/.codex/skills/`
- OpenClaw: `~/Shy's AI BOX/OpenClaw/skills/`
- Shared source: `~/.agents/skills/`

### 3) Trigger phrases

- "接入 Tailwind"
- "升级 Tailwind v3 到 v4"
- "排查 class 不生效"

## Releases and Packages

This repo publishes:
- GitHub Release (versioned)
- raw `.skill` package
- checksum file (`.sha256`)
- bundled archive (`.tar.gz`)

## Development Notes

- Keep references modular and load on demand.
- Use deterministic scripts for stack detect/audit/index refresh.
- Re-run validation before release.

## License

MIT License.
