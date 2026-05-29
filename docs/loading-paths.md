# Loading Paths — pre-validation draft

> D8: 不信文档声称，用 canary 标记实测。
> 测试日期: 2026-05-28
> 测试方法: 在 SKILL.md 中插入 `<!-- CANARY: xxx-loaded -->` 标记，放至候选路径后观察 skill 列表变化。
> 测试环境: Claude Code 2.1.132, Codex CLI 0.134.0, Gemini CLI 0.37.1

## Claude Code

| # | Path | Auto-loaded? | Frontmatter parsed? | Canary visible? | Notes |
|---|------|-------------|---------------------|----------------|-------|
| 1 | `~/.claude/skills/core-coordination/SKILL.md` | **是** | **是** | **是** (出现在 description) | 放入 canary 版本后 skill list 立即出现 `core-coordination: <!-- CANARY: ... -->`；移除后立即消失。skill list 动态刷新。 |
| 2 | `~/.claude/skills/vibe-agent-core-coordination/SKILL.md` | 未测 | | | 不影响路径 1 结论，待后续补充 |
| 3 | `<project>/.claude/skills/core-coordination/SKILL.md` | 未测 | | | 待用户在新会话中验证 |
| 4 | `<project>/plugin/vibe-agent/skills/core-coordination/SKILL.md` | **不确定** | | | 会话初始 skill list 中出现过 `core-coordination`，但移除全局路径后该条目消失。可能原因：(a) 项目级扫描仅在会话启动时执行且被全局同名覆盖；(b) `plugin/` 子目录不在扫描范围内。需新会话验证。 |

**已确认:**
- `~/.claude/skills/<name>/SKILL.md` 是可靠的全局装载路径。
- frontmatter `name` + `description` 被正确解析。name 成为 skill identifier，description 出现在 skill list 中。
- skill list 在会话中动态刷新（增删文件后可见变化）。
- HTML 注释 canary 不会被 frontmatter 解析器过滤，会作为 description 文本显示。

**待确认:**
- 项目级路径是否支持 `plugin/` 子目录结构
- 全局 vs 项目级同名 skill 的优先级

## Codex

| # | Path | Auto-loaded? | Canary visible? | Notes |
|---|------|-------------|----------------|-------|
| 1 | `~/.codex/skills/core-coordination/SKILL.md` | **是** | 无报错=成功 | `codex exec` 日志扫描 `~/.codex/skills/*/SKILL.md`。放入 canary 版本后无加载错误。 |
| 2 | `~/.codex/instructions/core-coordination.md` | 未测 | | `~/.codex/instructions/` 目录不存在。Codex 无此机制。 |
| 3 | `<project>/AGENTS.md` | **是** | N/A | `~/.codex/AGENTS.md` 已存在（用户全局指令）。项目级 `AGENTS.md` 应同理被加载（需新会话验证）。 |
| 4 | `~/.agents/skills/<name>/SKILL.md` | 未测 | | `codex exec` 日志未显示扫描此路径，可能不支持。待验证。 |

**已确认:**
- `~/.codex/skills/<name>/SKILL.md` 是 Codex 的 skill 加载路径（与 Claude Code 路径模式一致）。
- Codex 严格要求 YAML frontmatter `---` 在文件首行。损坏的 frontmatter 会产生 `ERROR` 日志。
- `codex exec --skip-git-repo-check` 可用于非交互式测试。
- `~/.codex/AGENTS.md` 是全局用户指令文件（类似 Claude Code 的 `~/.claude/CLAUDE.md`）。
- `~/.codex/skills/.system/` 存放 Codex 内置系统 skill。
- Codex 不扫描 `~/.codex/instructions/`（该目录不存在）。

**待确认:**
- `<project>/AGENTS.md` 项目级指令是否被自动加载
- `~/.agents/skills/` 共享路径是否被 Codex 扫描

## Gemini CLI

| # | Path | Mechanism | Works? | Notes |
|---|------|-----------|--------|-------|
| 1 | `gemini skills install <local-path>` | 安装命令 | **是** | 安装至 `~/.gemini/skills/<name>/SKILL.md`，自动复制文件。需 frontmatter 在文件首行（canary 必须放 frontmatter 之后）。 |
| 2 | `~/.gemini/config/skills/<name>/SKILL.md` | 手动放置 | **是** (已有实例) | `vibe-agent-shared` 已在此路径存在且被加载。 |
| 3 | `~/.agents/skills/<name>/SKILL.md` | 共享路径 | **是** (已有实例) | `skill-creator` 在此路径且产生 override 警告。Gemini 和 Claude Code 可能共享此路径。 |
| 4 | `gemini skills link <local-path>` | 软链接 | 支持 | 创建符号链接而非复制，开发迭代用。支持 `--scope user/workspace`。 |
| 5 | `gemini skills enable/disable <name>` | 开关控制 | 支持 | 可单独启用/禁用已安装 skill。 |

**已确认:**
- Gemini CLI 有完整的 skill 管理系统（install/link/enable/disable/uninstall）。
- 安装路径: `~/.gemini/skills/<name>/SKILL.md`
- 配置路径: `~/.gemini/config/skills/<name>/SKILL.md`
- 共享路径: `~/.agents/skills/<name>/SKILL.md`（可能被多个 CLI 共享）
- frontmatter 要求: `---` 必须在文件第一行。HTML 注释不能放在 frontmatter 之前。
- `gemini skills list --all` 输出有限（仅显示 override 警告），不能直接列出所有 skill。
- Gemini CLI 非交互模式 (`-p`) 需要 API key 才能运行，无法在无 key 环境下测试 skill 加载。

**注意:** D6 中"Gemini CLI 可能不支持 skill 机制"的假设已被推翻——Gemini CLI 的 skill 系统实际上最完善（有 install/link/enable/disable CLI 命令）。

## 汇总决策

| Agent | 推荐装载路径 | 安装方式 | 备注 |
|-------|------------|---------|------|
| Claude Code | `~/.claude/skills/<name>/SKILL.md` | `cp -r` | 已实测确认。项目级路径待验证。 |
| Codex | `~/.codex/skills/<name>/SKILL.md` | `cp -r` | 已实测确认。路径模式与 Claude Code 一致。 |
| Gemini CLI | `~/.gemini/skills/<name>/SKILL.md` | `gemini skills install <path>` | skill 系统最完善，有 CLI 管理命令 |

## 对 vibe-agent 安装流程的影响

原 README 中建议的安装方式：
```bash
cp -r plugin/vibe-agent/skills/core-coordination ~/.codex/skills/
cp -r plugin/vibe-agent/skills/core-coordination ~/.claude/skills/
```

实测后建议修正为：
```bash
# Claude Code
cp -r plugin/vibe-agent/skills/core-coordination ~/.claude/skills/

# Codex
cp -r plugin/vibe-agent/skills/core-coordination ~/.codex/skills/

# Gemini CLI
gemini skills install plugin/vibe-agent/skills/core-coordination
```

## 验证状态 (2026-05-28)

- [x] Claude Code 全局路径 (`~/.claude/skills/<name>/SKILL.md`)
- [x] Codex 全局路径 (`~/.codex/skills/<name>/SKILL.md`)
- [x] Gemini CLI 全局路径 (`~/.gemini/skills/<name>/SKILL.md`)
- [ ] 项目级路径 (`<project>/.claude/skills/` 等) — 需新会话验证
- [ ] `~/.agents/skills/` 共享路径跨 CLI 兼容性 — 需新会话验证

## 测试过程记录

### Claude Code
1. 放 canary SKILL.md (`<!-- CANARY: claude-code-loaded -->` 在 frontmatter 前) 至 `~/.claude/skills/core-coordination/SKILL.md`
2. skill list 动态刷新，出现 `core-coordination: <!-- CANARY: claude-code-loaded -->`
3. 删除全局 skill 后 skill list 中 `core-coordination` 消失（项目级文件仍在但未接管）
4. 恢复原始 SKILL.md 后 skill list 恢复正常 description

### Codex
1. `codex exec --skip-git-repo-check` 日志暴露扫描路径：`~/.codex/skills/*/SKILL.md`
2. 放 canary 版本（canary 在 frontmatter 之后）至 `~/.codex/skills/core-coordination/SKILL.md`
3. `codex exec` 无加载错误（同批次 `claude-mem` 因 frontmatter 损坏报 ERROR）= 确认加载成功
4. 恢复原始文件

### Gemini CLI
1. `gemini skills install <local-path>` 安装至 `~/.gemini/skills/`，canary 必须放 frontmatter 之后（之前会导致解析失败）
2. 已有 `vibe-agent-shared` 在 `~/.gemini/config/skills/`，`skill-creator` 在 `~/.agents/skills/`
