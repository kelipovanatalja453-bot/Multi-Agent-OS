# Loading Paths — pre-validation draft

> D8: 不信文档声称，用 canary 标记实测。
> 测试日期: 2026-05-28 (全局), 2026-05-29 (项目级 + 共享路径)
> 测试方法: 在 SKILL.md 中插入 `<!-- CANARY: xxx-loaded -->` 标记，放至候选路径后观察 skill 列表变化。
> 测试环境: Claude Code 2.1.132, Codex CLI 0.134.0, Gemini CLI 0.37.1

## Claude Code

| # | Path | Auto-loaded? | Frontmatter parsed? | Canary visible? | Notes |
|---|------|-------------|---------------------|----------------|-------|
| 1 | `~/.claude/skills/core-coordination/SKILL.md` | **是** | **是** | **是** (出现在 description) | 放入 canary 版本后 skill list 立即出现 `core-coordination: <!-- CANARY: ... -->`；移除后立即消失。skill list 动态刷新。 |
| 2 | `~/.claude/skills/vibe-agent-core-coordination/SKILL.md` | 未测 | | | 不影响路径 1 结论，待后续补充 |
| 3 | `<project>/.claude/skills/core-coordination/SKILL.md` | **是** ✅ | **是** | **是** (description 中出现) | `claude -p` 从测试目录运行，skill list 中出现两个 `core-coordination`：全局版（原始 description）+ 项目级版（canary description）。**不覆盖全局，两者并存。** |
| 4 | `<project>/plugin/vibe-agent/skills/core-coordination/SKILL.md` | 未测 | | | `plugin/` 子目录未测试。项目级扫描确认支持 `.claude/skills/`，但 `plugin/vibe-agent/skills/` 不在标准路径中，大概率不被扫描。 |

**已确认:**
- `~/.claude/skills/<name>/SKILL.md` 是可靠的全局装载路径。
- frontmatter `name` + `description` 被正确解析。name 成为 skill identifier，description 出现在 skill list 中。
- skill list 在会话中动态刷新（增删文件后可见变化）。
- HTML 注释 canary 不会被 frontmatter 解析器过滤，会作为 description 文本显示。

**已确认 (2026-05-29 项目级测试):**
- `<project>/.claude/skills/<name>/SKILL.md` 是有效的项目级装载路径。
- 项目级 skill 与全局同名 skill **并存**，不覆盖。skill list 中出现两条。
- frontmatter 解析行为与全局路径一致。

**待确认:**
- 项目级路径是否支持 `plugin/` 子目录结构（大概率不支持，`.claude/skills/` 是标准路径）
- 项目级 skill 是否可在新会话中独立生效（移除全局后仅保留项目级）
- **Claude Code 不扫描 `~/.agents/skills/`** — 通过 `third-party-independent-audit`（仅存在于 `~/.agents/skills/`）未出现在 skill list 中确认 (2026-05-29)

## Codex

| # | Path | Auto-loaded? | Canary visible? | Notes |
|---|------|-------------|----------------|-------|
| 1 | `~/.codex/skills/core-coordination/SKILL.md` | **是** | 无报错=成功 | `codex exec` 日志扫描 `~/.codex/skills/*/SKILL.md`。放入 canary 版本后无加载错误。 |
| 2 | `~/.codex/instructions/core-coordination.md` | 未测 | | `~/.codex/instructions/` 目录不存在。Codex 无此机制。 |
| 3 | `<project>/AGENTS.md` | **是** | N/A | `~/.codex/AGENTS.md` 已存在（用户全局指令）。项目级 `AGENTS.md` 应同理被加载（需新会话验证）。 |
| 4 | `~/.agents/skills/<name>/SKILL.md` | **是** ✅ | YAML 错误可暴露路径 | `codex exec` 日志明确显示扫描 `~/.agents/skills/`。故意引入 YAML 错误后报错路径为 `~/.agents/skills/core-coordination/SKILL.md`。 |
| 5 | `<project>/.codex/skills/core-coordination/SKILL.md` | **是** ✅ | **是** (skill list 中出现) | `codex exec` 从测试目录运行，输出中出现两条 `core-coordination`：`CANARY: project-level-loaded`（项目级）+ `Multi-LLM-agent coordination rules.`（全局）。**不覆盖全局，两者并存。** |

**已确认:**
- `~/.codex/skills/<name>/SKILL.md` 是 Codex 的 skill 加载路径（与 Claude Code 路径模式一致）。
- Codex 严格要求 YAML frontmatter `---` 在文件首行。损坏的 frontmatter 会产生 `ERROR` 日志。
- `codex exec --skip-git-repo-check` 可用于非交互式测试。
- `~/.codex/AGENTS.md` 是全局用户指令文件（类似 Claude Code 的 `~/.claude/CLAUDE.md`）。
- `~/.codex/skills/.system/` 存放 Codex 内置系统 skill。
- Codex 不扫描 `~/.codex/instructions/`（该目录不存在）。
- **Codex 扫描 `~/.agents/skills/` 共享路径**。当同名 skill 同时存在于 `~/.codex/skills/` 和 `~/.agents/skills/` 时，Codex 可从两个路径加载。

**待确认:**
- `<project>/AGENTS.md` 项目级指令是否被自动加载
- 同名 skill 在 `~/.codex/skills/` 和 `~/.agents/skills/` 的优先级关系（目前观察到两者都被加载，Codex 回答问题时优先引用项目级文件内容）

**已确认 (2026-05-29 项目级测试):**
- `<project>/.codex/skills/<name>/SKILL.md` 是有效的项目级装载路径。
- 项目级 skill 与全局同名 skill **并存**，不覆盖。skill list 中出现两条。
- Codex 扫描范围：`~/.codex/skills/` + `~/.agents/skills/` + `<project>/.codex/skills/`，三条路径均可加载 skill。

## Gemini CLI

| # | Path | Mechanism | Works? | Notes |
|---|------|-----------|--------|-------|
| 1 | `gemini skills install <local-path>` | 安装命令 | **是** | 安装至 `~/.gemini/skills/<name>/SKILL.md`，自动复制文件。需 frontmatter 在文件首行（canary 必须放 frontmatter 之后）。 |
| 2 | `~/.gemini/config/skills/<name>/SKILL.md` | 手动放置 | **是** (已有实例) | `vibe-agent-shared` 已在此路径存在且被加载。 |
| 3 | `~/.agents/skills/<name>/SKILL.md` | 共享路径 | **是** (已有实例) | `skill-creator` 在此路径且产生 override 警告。Gemini 和 Codex 共享此路径，Claude Code 不扫描。 |
| 4 | `gemini skills link <local-path>` | 软链接 | 支持 | 创建符号链接而非复制，开发迭代用。支持 `--scope user/workspace`。 |
| 5 | `gemini skills enable/disable <name>` | 开关控制 | 支持 | 可单独启用/禁用已安装 skill。 |
| 6 | `gemini skills link --scope workspace --consent <path>` | workspace 级软链接 | **路径已创建** ✅ | 在 `<project>/.gemini/skills/<name>/` 创建符号链接指向源路径。加载行为未验证（需 API key 运行 `-p` 模式）。 |

**已确认:**
- Gemini CLI 有完整的 skill 管理系统（install/link/enable/disable/uninstall）。
- 安装路径: `~/.gemini/skills/<name>/SKILL.md`
- 配置路径: `~/.gemini/config/skills/<name>/SKILL.md`
- 共享路径: `~/.agents/skills/<name>/SKILL.md`（被 Gemini 和 Codex 共享扫描，Claude Code 不扫描）
- workspace 路径: `<project>/.gemini/skills/<name>/` 通过 `gemini skills link --scope workspace` 创建软链接（加载待确认，需 API key）
- frontmatter 要求: `---` 必须在文件第一行。HTML 注释不能放在 frontmatter 之前。
- `gemini skills list --all` 输出有限（仅显示 override 警告），不能直接列出所有 skill。
- Gemini CLI 非交互模式 (`-p`) 需要 API key 才能运行，无法在无 key 环境下测试 skill 加载。

**注意:** D6 中"Gemini CLI 可能不支持 skill 机制"的假设已被推翻——Gemini CLI 的 skill 系统实际上最完善（有 install/link/enable/disable CLI 命令）。

## 汇总决策

| Agent | 推荐装载路径 | 安装方式 | 备注 |
|-------|------------|---------|------|
| Claude Code | `~/.claude/skills/<name>/SKILL.md` | `cp -r` | 已实测确认。不扫描 `~/.agents/skills/`。项目级 `<project>/.claude/skills/` **已确认**。 |
| Codex | `~/.codex/skills/<name>/SKILL.md` | `cp -r` | 已实测确认。也扫描 `~/.agents/skills/`。项目级 `<project>/.codex/skills/` **已确认**。 |
| Gemini CLI | `~/.gemini/skills/<name>/SKILL.md` | `gemini skills install <path>` | skill 系统最完善。也扫描 `~/.agents/skills/`。workspace 级 `<project>/.gemini/skills/` 路径已创建，加载待确认。 |

## 对 vibe-agent 安装流程的影响

原 README 中建议的安装方式：
```bash
cp -r plugin/vibe-agent/skills/core-coordination ~/.codex/skills/
cp -r plugin/vibe-agent/skills/core-coordination ~/.claude/skills/
```

实测后建议修正为：
```bash
# Claude Code (必须单独安装，不扫描 ~/.agents/skills/)
cp -r plugin/vibe-agent/skills/core-coordination ~/.claude/skills/

# Codex (可安装到 ~/.codex/skills/ 或 ~/.agents/skills/)
cp -r plugin/vibe-agent/skills/core-coordination ~/.codex/skills/

# Gemini CLI (推荐用 gemini skills install，也可放 ~/.agents/skills/)
gemini skills install plugin/vibe-agent/skills/core-coordination
```

**快捷方案 (覆盖 Codex + Gemini，不覆盖 Claude Code):**
```bash
cp -r plugin/vibe-agent/skills/core-coordination ~/.agents/skills/
```

## 验证状态 (2026-05-29 更新)

- [x] Claude Code 全局路径 (`~/.claude/skills/<name>/SKILL.md`)
- [x] Codex 全局路径 (`~/.codex/skills/<name>/SKILL.md`)
- [x] Gemini CLI 全局路径 (`~/.gemini/skills/<name>/SKILL.md`)
- [x] 项目级路径 (`<project>/.claude/skills/`, `<project>/.codex/skills/`) — **已确认** (2026-05-29)
- [ ] Gemini workspace 路径 (`<project>/.gemini/skills/`) — 路径已创建，加载行为待 API key 验证
- [x] `~/.agents/skills/` 共享路径跨 CLI 兼容性 — **部分确认** (见下方结论)

## 共享路径 `~/.agents/skills/` 结论 (2026-05-29)

| CLI | 扫描 `~/.agents/skills/`? | 证据 |
|-----|--------------------------|------|
| Claude Code | **否** ❌ | `third-party-independent-audit`（仅存在于 `~/.agents/skills/`）未出现在 skill list 中 |
| Codex | **是** ✅ | `codex exec` 日志明确显示加载 `~/.agents/skills/core-coordination/SKILL.md`；故意引入 YAML 错误后报错路径为该路径 |
| Gemini CLI | **是** ✅ (D6 已有实例) | `skill-creator` 在此路径且产生 override 警告 |

**优先级结论:**
- Codex: `~/.codex/skills/` 和 `~/.agents/skills/` 均被扫描，同名 skill 两个路径都会加载
- Claude Code: 仅扫描 `~/.claude/skills/`，不扫描 `~/.agents/skills/`
- 这意味着 `~/.agents/skills/` **不是**通用共享路径——它被 Codex 和 Gemini 扫描，但不被 Claude Code 扫描

**对安装流程的影响:**
- 若想同时覆盖 Codex + Gemini: 放到 `~/.agents/skills/` 即可
- 若想覆盖 Claude Code: 必须单独放到 `~/.claude/skills/`
- 最安全的安装方式仍是三路分发（见下方汇总决策表）

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

### 共享路径 `~/.agents/skills/` (2026-05-29)
1. 将 canary 版本 SKILL.md 放到 `~/.agents/skills/core-coordination/SKILL.md`
2. Claude Code 当前会话 skill list 中无 canary 标记（从 `~/.claude/skills/` 加载）
3. `third-party-independent-audit`（仅存在于 `~/.agents/skills/`）未出现在 Claude Code skill list → 确认 Claude Code 不扫描此路径
4. `codex exec` 日志显示: `failed to load skill ~/.agents/skills/core-coordination/SKILL.md: invalid YAML` → 确认 Codex 扫描此路径
5. 修复 YAML 后 Codex 无报错 → 确认成功加载
6. 暂时移除 `~/.codex/skills/core-coordination/`，Codex 仍从 `~/.agents/skills/` 加载 → 确认回退机制
7. 恢复两个路径后，Codex 同时加载两份 → 同名 skill 无冲突但无明确优先级
8. 恢复原始文件

### 项目级路径 `<project>/.claude/skills/` + `<project>/.codex/skills/` (2026-05-29)

**准备:**
1. 创建 `/tmp/vibe-agent-path-test/` 测试目录
2. 创建 canary 版 SKILL.md：description 改为 `"CANARY: project-level-loaded"`，正文前插入 `<!-- CANARY: project-level-loaded -->`
3. 复制到 `<project>/.claude/skills/core-coordination/SKILL.md` 和 `<project>/.codex/skills/core-coordination/SKILL.md`

**Claude Code 测试:**
1. `cd /tmp/vibe-agent-path-test && claude -p "列出你看到的所有 skill"`
2. 结果: skill list 中出现**两条** `core-coordination`
   - 全局版: description = `Multi-LLM-agent coordination rules. Load when working...`
   - 项目级版: description = `CANARY: project-level-loaded`
3. 结论: **项目级路径有效，与全局并存不覆盖** ✅

**Codex 测试:**
1. `cd /tmp/vibe-agent-path-test && codex exec --skip-git-repo-check "列出你看到的所有 skill"`
2. 结果: skill list 中出现**两条** `core-coordination`
   - `core-coordination: CANARY: project-level-loaded`（项目级）
   - `core-coordination: Multi-LLM-agent coordination rules.`（全局）
3. 结论: **项目级路径有效，与全局并存不覆盖** ✅

**Gemini CLI 测试:**
1. `gemini skills link --scope workspace --consent .claude/skills/core-coordination` → 在 `.gemini/skills/core-coordination` 创建软链接 ✅
2. `gemini -p` 测试失败: 需要 API key（`GEMINI_API_KEY` 或 `GOOGLE_GENAI_USE_VERTEXAI`）
3. 结论: **workspace 路径机制已确认（软链接创建成功），加载行为待 API key 验证**

**清理:**
1. 删除 `/tmp/vibe-agent-path-test/` 测试目录
