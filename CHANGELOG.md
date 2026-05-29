# Changelog

## [0.1.0-draft] - 2026-05-26
- Initial public release (pre-validation)
- Added: plugin/vibe-agent/skills/core-coordination/SKILL.md (95-line core rules)
- Added: plugin/vibe-agent/presets/my-setup.example.yaml (example resource config)
- Added: docs/operating-model-draft.md (1586-line full design document, pre-validation)
- Added: docs/reference-projects.md (borrowed patterns)
- Added: install.sh — automated installation script with --dry-run and --force
- Added: skills/ root directory for ecosystem compatibility (npx skills add)
- Status: pre-validation. Expects revision in Jun-Jul 2026 based on real use.

## [loading-paths-test] - 2026-05-28
- Added: docs/loading-paths.md — D8 装载路径实测结果
- Confirmed: Claude Code 加载 `~/.claude/skills/<name>/SKILL.md` (canary 验证)
- Confirmed: Codex 加载 `~/.codex/skills/<name>/SKILL.md` (codex exec 日志验证)
- Confirmed: Gemini CLI 有完整 skill 系统 (install/link/enable/disable)，推翻 D6 假设
- Confirmed: Gemini 安装路径 `~/.gemini/skills/<name>/SKILL.md`，共享路径 `~/.agents/skills/`
- Pending: 项目级路径 (`<project>/.claude/skills/` 等) 和 `~/.agents/skills/` 共享路径待新会话验证
- Added: tests/loading-paths/TEST-INSTRUCTIONS.md — 测试方法论
- Updated: install.sh — added Gemini CLI support (gemini skills install, fallback to cp)
- Updated: SKILL.md Gemini Note — reflect confirmed install mechanism
- Updated: DECISIONS.md D6 — Gemini skill system confirmed as most complete; D8 marked verified
- Updated: README.md — added Gemini install command
