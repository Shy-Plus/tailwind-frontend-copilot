# System Architecture and Maintenance Guide

## 1. Data Architecture

### Core data domains
- Skill artifact domain:
  - `dist/tailwind-frontend-copilot.skill`
  - release bundles and checksums
- Process-trace domain:
  - `task_plan.md`
  - `findings.md`
  - `progress.md`
- Verification domain:
  - `tailwind-skill-testbeds/` (fixtures)
  - `tailwind-skill-tests/` (outputs)
- Planning domain:
  - `docs/plans/`

### Data flow
1. Planning files define task scope and decisions.
2. Skill package is built and exported into `dist/`.
3. Scenario fixtures run and generate test artifacts.
4. Release assets are generated from `dist/` and published to GitHub Release.

## 2. Implementation Methods

- Keep changes small and traceable.
- Use deterministic CLI/script outputs for auditability.
- Maintain release assets in standard formats:
  - `.skill`
  - `.sha256`
  - `.tar.gz`

## 3. Maintenance Instructions

### Routine maintenance
- Update changelog per release.
- Regenerate checksum and bundle when artifact changes.
- Keep README and architecture doc aligned with actual structure.

### Validation checklist
- `git status` clean before release.
- `dist/tailwind-frontend-copilot.skill` exists.
- checksum and archive regenerated.
- tests/reports paths remain valid.

## 4. Usage Guidelines

- Use this repository as the canonical release surface for the skill package.
- Prefer GitHub Releases for end-user downloads.
- Keep process logs for reproducibility and future handoff.

## 5. Release and Package Policy

- Semantic release tag format: `vMAJOR.MINOR.PATCH`.
- Every release must include:
  - `.skill` package
  - `.sha256` checksum
  - `.tar.gz` bundle
- Release notes must summarize scope, verification status, and compatibility.

## 6. Change Management

For any material update:
1. Update this architecture file if structure/process changed.
2. Update `CHANGELOG.md`.
3. Regenerate release assets if `dist/` changed.
4. Publish or update GitHub Release.
