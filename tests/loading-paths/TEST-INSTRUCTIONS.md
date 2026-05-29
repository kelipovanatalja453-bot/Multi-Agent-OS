# 装载路径测试指令

> 三线程并行执行。每个线程独立，互不依赖。
> 测试文件在本目录 (`tests/loading-paths/SKILL-*.md`)。
> 每个文件顶部有唯一 canary 标记，用它验证 Agent 是否真的加载了该文件。

---

## 线程 1a: Claude Code

**目标:** 确认 Claude Code 从哪个路径自动加载 skill。

**测试路径:**

### 路径 1: `~/.claude/skills/core-coordination/SKILL.md` (全局, 标准命名)

```bash
mkdir -p ~/.claude/skills/core-coordination
cp tests/loading-paths/SKILL-claude-code.md ~/.claude/skills/core-coordination/SKILL.md
```

然后启动**新** `claude` 会话 (不在本项目目录内), 问:

> "你能看到什么 canary 标记?"

记录: 是否看到 `<!-- CANARY: claude-code-loaded -->`、frontmatter `name` 字段是否被解析。

### 路径 2: `~/.claude/skills/vibe-agent-core-coordination/SKILL.md` (全局, 带前缀命名)

```bash
mkdir -p ~/.claude/skills/vibe-agent-core-coordination
cp tests/loading-paths/SKILL-claude-code.md ~/.claude/skills/vibe-agent-core-coordination/SKILL.md
```

同上开新会话问 canary。

**注意:** 如果路径 1 已经成功加载, 需先删除路径 1 的文件再测路径 2, 否则无法区分是哪个路径加载的。

### 路径 3: `<project>/.claude/skills/core-coordination/SKILL.md` (项目内)

```bash
mkdir -p .claude/skills/core-coordination
cp tests/loading-paths/SKILL-claude-code.md .claude/skills/core-coordination/SKILL.md
```

在**本项目目录**内启动新 `claude` 会话, 问 canary。

**完成后:** 记录三个路径的结果, 填入 `docs/loading-paths.md` 的 Claude Code 部分。清理临时文件。

---

## 线程 1b: Codex

**目标:** 确认 Codex 从哪个路径自动加载 skill。

**前提:** 确认 Codex CLI 已安装且可用 (`codex --version`)。

**测试路径:**

### 路径 1: `~/.codex/skills/core-coordination/SKILL.md` (全局 skills 目录)

```bash
mkdir -p ~/.codex/skills/core-coordination
cp tests/loading-paths/SKILL-codex.md ~/.codex/skills/core-coordination/SKILL.md
```

启动新 `codex` 会话 (不在本项目目录内), 问:

> "你能看到什么 canary 标记?"

### 路径 2: `~/.codex/instructions/core-coordination.md` (instructions 目录)

```bash
mkdir -p ~/.codex/instructions
cp tests/loading-paths/SKILL-codex.md ~/.codex/instructions/core-coordination.md
```

同上开新会话问 canary。

**注意:** 同样需要清理上一路径再测, 避免混淆。

### 路径 3: `<project>/AGENTS.md` (项目级指令文件)

```bash
cp tests/loading-paths/SKILL-codex.md ./AGENTS.md
```

在本项目目录内启动新 `codex` 会话, 问 canary。

**备选:** 如果 Codex 不识别 `AGENTS.md`, 试试 `codex.md`。

**完成后:** 记录结果填入 `docs/loading-paths.md` 的 Codex 部分。清理临时文件 (特别是项目根目录的 AGENTS.md)。

---

## 线程 1c: Gemini CLI

**目标:** 确认 Gemini CLI 是否有 skill 加载机制, 若有则测试路径。

**步骤 1: 调研 (不放文件)**

```bash
# 检查 Gemini CLI 是否已安装
gemini --version 2>/dev/null || gcloud --version 2>/dev/null

# 查看帮助, 找 skill/instruction/config 相关选项
gemini --help 2>/dev/null
```

如果 Gemini CLI 不可用或无 skill 机制, 直接记录结论。

**步骤 2: 若有 skill 机制, 按文档路径测试**

```bash
# 示例 (具体路径取决于步骤 1 的发现)
cp tests/loading-paths/SKILL-gemini.md <discovered-path>
```

启动新 `gemini` 会话, 问 canary。

**步骤 3: 测试 GEMINI.md 回退方案**

```bash
cp tests/loading-paths/SKILL-gemini.md ./GEMINI.md
```

在项目目录内启动新 `gemini` 会话, 问 canary。

**完成后:** 记录结果填入 `docs/loading-paths.md` 的 Gemini 部分。清理临时文件。

---

## 结果记录格式

每个路径记录:

```
路径: <path>
结果: [加载 / 未加载 / 不确定]
自动加载: [是 / 否]
Frontmatter 解析: [是 / 否 / 不适用]
Canary 可见: [是 / 否]
备注: <任何观察>
```

## 测试后清理

确认结果记录完毕后:

```bash
# 清理 Claude Code 测试文件
rm -rf ~/.claude/skills/core-coordination/       # 如果是新建的
rm -rf ~/.claude/skills/vibe-agent-core-coordination/
rm -rf .claude/skills/

# 清理 Codex 测试文件
rm -rf ~/.codex/skills/core-coordination/         # 如果是新建的
rm -f ~/.codex/instructions/core-coordination.md
rm -f ./AGENTS.md ./codex.md

# 清理 Gemini 测试文件
rm -f ./GEMINI.md
```

> 注意: 只删除本次测试新建的文件, 不要删除已有的 skill。
