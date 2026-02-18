# Findings & Decisions

## Requirements
- Build a new skill: `tailwind-frontend-copilot`
- Use `planning-with-files` and `writing-plans` in the workflow
- Keep `SKILL.md` lean and move deep content into modular references
- Include helper scripts:
  - `scripts/detect-stack.sh <repo_path>`
  - `scripts/audit-tailwind.sh <repo_path>`
  - `scripts/refresh-tailwind-index.py`
- Add architecture maintenance documentation:
  - `references/90-system-architecture-maintenance.md`
- Package to `.skill` and verify local visibility for Codex/OpenClaw

## Research Findings
- Local `skills` CLI is installed and supports global skills listing via `skills ls -g`.
- Global skill hub path on this machine is `~/.agents/skills`.
- Codex has `~/.codex/skills` directory and OpenClaw has `~/Shy's AI BOX/OpenClaw/skills`.
- Existing reports in local memory describe cross-platform linking through `~/.agents/skills`.
- Tailwind official docs now redirect `/docs` to `/docs/installation/using-vite`; references should always pin explicit URLs.
- `https://tailwindcss.com/sitemap.xml` returns 404 in current environment; index refresh must crawl docs links rather than rely on sitemap.

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| Keep source of truth in `~/.agents/skills/tailwind-frontend-copilot` | Single source for both Codex and OpenClaw |
| Use single-level references files with TOC sections | Progressive disclosure and maintainability |
| Add deterministic scripts with text output | Easy for agents to chain and for humans to audit |
| Track `last verified date` in official sources index | Keeps docs freshness explicit |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| No literal `skills.sh` script found in active paths | Follow actual installed `skills` CLI behavior plus existing environment conventions |
| `skills add` from local path cleared skill contents unexpectedly | Recovered the skill directory from packaged artifact in `dist/` and revalidated |
| Codex agent-link status not fully reflected by `skills ls -g -a codex` for this custom skill | Kept explicit symlink in `~/.codex/skills` and verified path-level visibility |

## Resources
- Tailwind docs root: https://tailwindcss.com/docs/
- Skill creator script path: `/Users/suhongyi/.agent-skill-packs/anthropics-skills/skills/skill-creator/scripts`
- Planning with files path: `/Users/suhongyi/.agents/skills/planning-with-files`
- Official directives: https://tailwindcss.com/docs/functions-and-directives
- Upgrade guide: https://tailwindcss.com/docs/upgrade-guide
- Next.js guide: https://tailwindcss.com/docs/installation/framework-guides/nextjs
- Vite guide: https://tailwindcss.com/docs/installation/using-vite
- Nuxt guide: https://tailwindcss.com/docs/installation/framework-guides/nuxtjs
- SvelteKit guide: https://tailwindcss.com/docs/installation/framework-guides/sveltekit
- Compatibility: https://tailwindcss.com/docs/compatibility

## Runtime Findings (2026-02-19)
- `CODEX_HOME` points to `/Users/suhongyi/Shy's AI BOX/Codex CLI/.codex`, so this config is the effective Codex runtime source.
- Default `gpt-5.3-codex` is not available for current account; setting `model = "gpt-5"` in config eliminates repeated reconnect/model-not-found failures.
- `.bash_profile` noise root cause is Conda activation output with single-quoted PATH values; PATH currently includes an apostrophe-containing path (`Shy's AI BOX`), which breaks exported shell code in non-interactive login shells.
- Guarding Conda init to interactive shells and quoting PATH assignment removed startup stderr pollution for Codex shell tool calls.
- Shell-enabled Codex regression (4 scenarios) passed with explicit output artifacts under:
  - `/Users/suhongyi/Shy's AI BOX/Shy-Dev/Tools/tailwind-skill-tests/codex-shell/`
