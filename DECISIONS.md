# DECISIONS.md — vibe-agent 关键设计决策记录

> 已做出的决策和理由。每条"已定, 不要再推翻除非有新证据"。

## D1: 极简优先, 拒绝过度设计
核心规则保持 95 行。曾有 1586 行版本, 信息密度低没人遵守。
看起来完整但没人遵守 = 零。

## D2: 三大痛点排序 (决定加什么字段)
- B 完成模糊 (最痛): 都说完成了但效果没实现
- E 任务孤岛 (其次): 做完不知道下一步
- A 信息断层 (再次): 转发时接收方缺上下文
- D/C/F (ownership/上下文丢失/责任归因) 暂不优先, 没出问题前不加字段

## D3: skill/plugin 形态, 不做全局宪法
做成可安装 plugin, 不写入 ~/.codex/AGENTS.md 等全局配置。
理由: 全局配置污染所有项目 + 无法被别人 clone + 触及工程纪律红线。

## D4: 人肉转发, 不做自动化 orchestration
Agent 输出转发请求, 用户手动 copy-paste 转发。
不做自动转发/自动审阅路由/通信总线。自动化要 2-3 个月, 没这个预算。
人工转发 <5 分钟/天, 且人工质检是 feature。

## D5: 能力档位表 (含 Gemini)
- S: Claude on Claude Code 原生 / GPT-5 on Codex / Gemini on Gemini CLI (审计特长)
- A: Codex 执行 / MiMo on Claude Code / DeepSeek on Claude Code
- B: DeepSeek API / GLM API
- 模型+框架组合决定档位, 不只看模型名

## D6: Gemini skill 机制 (已验证)
Gemini CLI 的 skill 系统实际上最完善 (有 install/link/enable/disable CLI 命令)。
安装路径: `~/.gemini/skills/<name>/SKILL.md`。
安装方式: `gemini skills install <local-path>` (自动复制) 或 `gemini skills link <local-path>` (符号链接, 开发用)。
frontmatter 要求: `---` 必须在文件首行。
原始假设"Gemini 可能不支持 skill"已被 2026-05-28 实测推翻。

## D7: pre-validation draft 状态
当前所有内容标 pre-validation。1586 行版作反面教材保留并加 banner。
实测发生在 2026 年 6-7 月的 Finer + 蛋白项目中。

## D8: 装载路径经验验证 (已完成)
不信文档声称, 用测试标记实测每个 CLI 真实加载哪个文件/skill。写入前强制步骤。
实测结果 (2026-05-28): 见 `docs/loading-paths.md`。三端全部确认。
- Claude Code: `~/.claude/skills/<name>/SKILL.md` 已确认
- Codex: `~/.codex/skills/<name>/SKILL.md` 已确认（路径模式与 Claude Code 一致）
- Gemini CLI: `gemini skills install` + `~/.gemini/skills/<name>/SKILL.md` 已确认 (D6 假设被推翻)

## D9: plugin 结构预留, 内容极简
用 plugin 形态 (支持多 skill), 但 v0.1 只实装 1 个 core-coordination skill。
适配性通过 preset config 实现, 不做"通用适配引擎"。
presets/ 先只有作者自己的配置作范例。
可视化 v0.1 只做 README 内 Mermaid 图, 不做独立 landing page。
警告: "为适配所有人而设计通用系统" 是 1586 行死法的变体, 严禁。
