# Tailwind Frontend Copilot Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create, validate, package, and deploy a cross-agent `tailwind-frontend-copilot` skill for Codex and OpenClaw with modular Tailwind knowledge, deterministic helper scripts, and human-in-loop gates.

**Architecture:** Keep one source-of-truth skill folder under `~/.agents/skills/tailwind-frontend-copilot`, with lean workflow instructions in `SKILL.md` and deep knowledge split into references files. Add shell/python helper scripts for stack detection, Tailwind audit, and docs index refresh. Validate by script runs, package build, and visibility checks.

**Tech Stack:** Markdown skills, Bash, Python 3, Tailwind CSS docs (v4.1 baseline), `skills` CLI, `skill-creator` helper scripts.

---

### Task 1: Initialize Planning Files and Session Memory

**Files:**
- Modify: `/Users/suhongyi/Shy's AI BOX/Shy-Dev/Tools/task_plan.md`
- Modify: `/Users/suhongyi/Shy's AI BOX/Shy-Dev/Tools/findings.md`
- Modify: `/Users/suhongyi/Shy's AI BOX/Shy-Dev/Tools/progress.md`

**Step 1: Run session catchup**

Run: `python3 /Users/suhongyi/.agents/skills/planning-with-files/scripts/session-catchup.py "/Users/suhongyi/Shy's AI BOX/Shy-Dev/Tools"`
Expected: returns catchup report or exits cleanly.

**Step 2: Initialize planning files**

Run: `bash /Users/suhongyi/.agents/skills/planning-with-files/scripts/init-session.sh tailwind-frontend-copilot`
Expected: `task_plan.md`, `findings.md`, `progress.md` exist.

**Step 3: Populate phase/goal/decisions**

Write goal, fixed constraints, and current phase to all 3 files.

**Step 4: Verify file presence**

Run: `ls -la task_plan.md findings.md progress.md`
Expected: all files listed.

### Task 2: Create Writing-Plans Execution Document

**Files:**
- Create: `/Users/suhongyi/Shy's AI BOX/Shy-Dev/Tools/docs/plans/2026-02-18-tailwind-frontend-copilot.md`

**Step 1: Announce writing-plans usage**

Output: `I'm using the writing-plans skill to create the implementation plan.`
Expected: statement appears before plan creation.

**Step 2: Write required plan header**

Include exact header format from writing-plans skill (`Goal`, `Architecture`, `Tech Stack`).

**Step 3: Add bite-sized tasks**

Include exact paths, commands, and expected outputs for:
- script testing
- skill validation
- package build
- deployment visibility checks

**Step 4: Verify plan render**

Run: `sed -n '1,120p' docs/plans/2026-02-18-tailwind-frontend-copilot.md`
Expected: header and first tasks render correctly.

### Task 3: Create Skill Skeleton

**Files:**
- Create: `/Users/suhongyi/.agents/skills/tailwind-frontend-copilot/SKILL.md`
- Create: `/Users/suhongyi/.agents/skills/tailwind-frontend-copilot/scripts/`
- Create: `/Users/suhongyi/.agents/skills/tailwind-frontend-copilot/references/`

**Step 1: Initialize skill directory**

Run: `python3 /Users/suhongyi/.agent-skill-packs/anthropics-skills/skills/skill-creator/scripts/init_skill.py tailwind-frontend-copilot --path /Users/suhongyi/.agents/skills`
Expected: directory and template files are generated.

**Step 2: Remove placeholder artifacts**

Delete generated example files not needed for final skill.

**Step 3: Verify skeleton layout**

Run: `find /Users/suhongyi/.agents/skills/tailwind-frontend-copilot -maxdepth 2 -type f | sort`
Expected: only real deliverable files remain.

### Task 4: Implement SKILL.md Workflow Core

**Files:**
- Modify: `/Users/suhongyi/.agents/skills/tailwind-frontend-copilot/SKILL.md`

**Step 1: Define frontmatter trigger precision**

Set:
- `name: tailwind-frontend-copilot`
- `description:` include explicit triggers (setup, migration, maintenance, style matching, debugging).

**Step 2: Add 4-entry workflow decision tree**

Implement fixed entries:
- New integration
- Existing project maintenance
- Performance/style improvement
- v3 to v4 migration

**Step 3: Embed human gates**

Add Gate A/B/C checkpoints with explicit user confirmation requirements.

**Step 4: Link reference modules**

Map each workflow path to specific `references/*.md` files and scripts.

### Task 5: Build Modular Tailwind Knowledge Base

**Files:**
- Create: `/Users/suhongyi/.agents/skills/tailwind-frontend-copilot/references/00-official-sources-index.md`
- Create: `/Users/suhongyi/.agents/skills/tailwind-frontend-copilot/references/10-core-v4.md`
- Create: `/Users/suhongyi/.agents/skills/tailwind-frontend-copilot/references/20-v3-to-v4-migration.md`
- Create: `/Users/suhongyi/.agents/skills/tailwind-frontend-copilot/references/30-stack-nextjs.md`
- Create: `/Users/suhongyi/.agents/skills/tailwind-frontend-copilot/references/31-stack-vite-react.md`
- Create: `/Users/suhongyi/.agents/skills/tailwind-frontend-copilot/references/39-stack-vue-nuxt-svelte.md`
- Create: `/Users/suhongyi/.agents/skills/tailwind-frontend-copilot/references/40-style-matching-playbook.md`
- Create: `/Users/suhongyi/.agents/skills/tailwind-frontend-copilot/references/50-human-in-the-loop-gates.md`
- Create: `/Users/suhongyi/.agents/skills/tailwind-frontend-copilot/references/60-maintenance-debugging.md`
- Create: `/Users/suhongyi/.agents/skills/tailwind-frontend-copilot/references/70-architecture-differences-matrix.md`
- Create: `/Users/suhongyi/.agents/skills/tailwind-frontend-copilot/references/90-system-architecture-maintenance.md`

**Step 1: Create index first**

Include doc URLs, last verified date, and guidance on when to open each module.

**Step 2: Author architecture matrix**

Compare:
- build pipeline
- content scanning
- SSR/RSC implications
- CSS Modules `@reference`
- upgrade path
- common failures

**Step 3: Author style matching playbook**

Enforce three-mode strategy:
- inherit existing design system
- incremental evolution
- full visual reset (Gate B approval required)

**Step 4: Verify reference coverage**

Run: `ls -1 /Users/suhongyi/.agents/skills/tailwind-frontend-copilot/references`
Expected: all required files exist.

### Task 6: Implement Helper Scripts

**Files:**
- Create: `/Users/suhongyi/.agents/skills/tailwind-frontend-copilot/scripts/detect-stack.sh`
- Create: `/Users/suhongyi/.agents/skills/tailwind-frontend-copilot/scripts/audit-tailwind.sh`
- Create: `/Users/suhongyi/.agents/skills/tailwind-frontend-copilot/scripts/refresh-tailwind-index.py`

**Step 1: Implement `detect-stack.sh`**

Requirements:
- accept `repo_path`
- detect framework/build system by files and `package.json`
- output machine-readable JSON summary

**Step 2: Implement `audit-tailwind.sh`**

Requirements:
- detect Tailwind usage/config version
- flag risky patterns (dynamic classes, bad content globs, migration gaps)
- output concise report with actions

**Step 3: Implement `refresh-tailwind-index.py`**

Requirements:
- fetch Tailwind docs index/sitemap
- regenerate a local index section deterministically
- preserve idempotency

**Step 4: Make scripts executable and lint-light check**

Run: `chmod +x .../detect-stack.sh .../audit-tailwind.sh`
Expected: shell scripts executable.

### Task 7: Validate Scripts and Package

**Files:**
- Modify: `/Users/suhongyi/Shy's AI BOX/Shy-Dev/Tools/progress.md`

**Step 1: Run each script once on real path**

Run:
- `.../detect-stack.sh "/Users/suhongyi/Shy's AI BOX/Shy-Dev/Tools"`
- `.../audit-tailwind.sh "/Users/suhongyi/Shy's AI BOX/Shy-Dev/Tools"`
- `python3 .../refresh-tailwind-index.py`

Expected: each command exits 0 and prints usable output.

**Step 2: Package skill**

Run: `python3 /Users/suhongyi/.agent-skill-packs/anthropics-skills/skills/skill-creator/scripts/package_skill.py /Users/suhongyi/.agents/skills/tailwind-frontend-copilot "/Users/suhongyi/Shy's AI BOX/Shy-Dev/Tools/dist"`
Expected: `dist/tailwind-frontend-copilot.skill` created.

**Step 3: Verify package artifact**

Run: `ls -la "/Users/suhongyi/Shy's AI BOX/Shy-Dev/Tools/dist/tailwind-frontend-copilot.skill"`
Expected: file exists with non-zero size.

### Task 8: Verify Cross-Agent Visibility and Finalize

**Files:**
- Modify: `/Users/suhongyi/Shy's AI BOX/Shy-Dev/Tools/progress.md`
- Modify: `/Users/suhongyi/Shy's AI BOX/Shy-Dev/Tools/task_plan.md`

**Step 1: Check global skill visibility**

Run: `skills ls -g`
Expected: skill visible in global list (or documented if not indexed by CLI registry).

**Step 2: Enforce Codex/OpenClaw visibility**

If absent:
- create symlink in `~/.codex/skills/`
- create symlink in `~/Shy's AI BOX/OpenClaw/skills/`

**Step 3: Re-check presence**

Run:
- `ls -la ~/.codex/skills | rg tailwind-frontend-copilot`
- `ls -la ~/Shy's\ AI\ BOX/OpenClaw/skills | rg tailwind-frontend-copilot`
Expected: symlinks exist and point to `~/.agents/skills/tailwind-frontend-copilot`.

**Step 4: Complete phase statuses and delivery notes**

Mark all phases complete and record test results, errors, and final artifact paths.
