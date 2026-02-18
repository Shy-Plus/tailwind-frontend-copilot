# Task Plan: Tailwind Frontend Copilot Skill

## Goal
Build and deploy a production-ready `tailwind-frontend-copilot` skill with modular Tailwind references, helper scripts, packaging output, and verified Codex/OpenClaw visibility.

## Current Phase
Phase 5

## Phases

### Phase 1: Requirements & Discovery
- [x] Understand user intent
- [x] Identify constraints and fixed decisions
- [x] Confirm deployment rule (`skills.sh` ecosystem / `~/.agents/skills`)
- [x] Initialize planning files
- **Status:** complete

### Phase 2: Planning & Structure
- [x] Create writing-plans document in `docs/plans/`
- [x] Prepare skill folder layout and file inventory
- [x] Finalize references module map and script interfaces
- **Status:** complete

### Phase 3: Implementation
- [x] Generate skill skeleton with `init_skill.py`
- [x] Replace template with final `SKILL.md`
- [x] Author all required references files
- [x] Implement `detect-stack.sh`, `audit-tailwind.sh`, `refresh-tailwind-index.py`
- [x] Add system architecture maintenance document
- **Status:** complete

### Phase 4: Testing & Verification
- [x] Run each script on a real local path
- [x] Validate skill packaging with `package_skill.py`
- [x] Check global visibility with `skills ls -g`
- [x] Verify Codex/OpenClaw recognition and add symlinks if needed
- **Status:** complete

### Phase 5: Delivery
- [x] Record final outputs and verification evidence in `progress.md`
- [x] Confirm all phases complete and summarize deliverables
- [x] Hand off with changed files list and usage notes
- **Status:** complete

### Phase 6: Runtime Stabilization & Shell Regression
- [x] Stabilize Codex model defaults in effective `CODEX_HOME` config
- [x] Eliminate shell startup noise in `~/.bash_profile`
- [x] Re-run Codex scenario tests with shell enabled across 4 workflows
- [x] Record evidence in `tailwind-skill-tests/codex-shell/` and test report
- **Status:** complete

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| Skill name is `tailwind-frontend-copilot` | User explicitly locked this decision |
| Language is Chinese-led with English technical terms | Matches user preference and preserves technical accuracy |
| Coverage strategy is v4 core plus v3 migration | Balances modern default with legacy project maintenance |
| Human-in-loop uses Gate A/B/C | Prevents style and architecture drift in autonomous edits |
| Deployment source is `~/.agents/skills` | Matches local `skills` global workflow and cross-agent sharing |

## Errors Encountered
| Error | Resolution |
|-------|------------|
| `rg` over full home produced many protected-path permission warnings | Scoped searches to project/tool directories only |
| `package_skill.py` failed with `ModuleNotFoundError: yaml` | Installed `pyyaml` and reran packaging |
| `skills add` emptied local skill directory unexpectedly | Restored skill from packaged `.skill` artifact and revalidated files |
| Non-interactive login shell produced `.bash_profile` Conda export errors | Guarded Conda init to interactive shells and kept PATH assignment quoted |
