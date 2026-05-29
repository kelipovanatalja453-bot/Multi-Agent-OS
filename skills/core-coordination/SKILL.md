---
name: core-coordination
description: Multi-LLM-agent coordination rules. Load when working in a project
  that uses multiple AI coding agents (Codex, Claude Code, MiMo, DeepSeek,
  Gemini) and needs consistent capability tiers, stop conditions, task cards,
  handoff requests, and evidence-bound completion. Triggers on multi-agent
  collaboration, task delegation between agents, or a request for an agent to
  declare its identity/tier.
---

# vibe-agent core-coordination (v0.1)
# 所有 Agent 共享的协作规则。开工前必读。

## Part 1: 你是谁
每次会话第一句必须声明:
> 我是 [Framework] 上的 [Model]，档位 [S/A/B]，本任务我[做/不做]，理由 [...]

## Part 2: 能力档位表
**S 级** (架构判断 / 跨模块推理 / 复杂决策):
- Claude on Claude Code 原生
- GPT-5 on Codex
- Gemini on Gemini CLI (特长: 长上下文扫描 / 文档一致性 / 全项目审计)

**A 级** (工程执行 / 本地验证 / 单模块实现):
- Codex (执行模式)
- MiMo on Claude Code
- DeepSeek on Claude Code

**B 级** (批量 / 低风险 / 单文件):
- DeepSeek API direct
- GLM API direct

## Part 3: 必须停止并输出"转发请求"的场景
符合任一条立刻停止, 输出转发请求, 不继续执行:
1. 修改超过 3 个文件 (除非任务卡明确允许)
2. 触及 schemas / contracts / 数据库结构
3. 任务描述含: 重构 / 架构 / 设计 / 跨模块 / pipeline / 整体优化
4. 触及任务卡的 forbidden files
5. 触及红线 (见 Part 7)
6. 档位不匹配 (你是 A 级遇到 S 级任务)
7. 你不确定该不该干

**"输出转发请求" = 工作结束, 等用户处理。禁止边输出边继续干活。**

## Part 4: 转发请求格式 (强制)
```
# 转发请求
## 发送方: [Framework] / [Model] / [档位]
## 任务原文: [一句话]
## 我做到哪一步: [简述, 未开始就写"未开始"]
## 卡在哪: [具体, 对照 Part 3 哪一条]
## 建议转给: [目标 Framework + Model], 理由 [1 行]
## 给目标的任务卡: [用 Part 5 格式]
## 完成后建议谁审阅: [Agent / 用户 / 不需要], 理由 [1 行]
## 我接下来: [等结果 / 终止 / 继续做其他子任务]
```

## Part 5: 任务卡格式 (强制)
```
# 任务: [一句话, ≤20 字]
## 在哪: 属于 [大目标] / 下一步预告 [...]
## 给谁: [目标 Agent]
## 接收方需要知道: 文件 [...] / 当前状态 [1-2 行]
## 应该做的: 1. ... 2. ...
## 完成 =: 证据 checklist (可粘贴/截图/链接) + 验证命令
## 失败时: 阻塞条件
```

## Part 6: 回报格式 (强制)
```
# 回报: [一句话]
## 状态: [完成 / 部分完成 / 阻塞]
## 证据: - [✅] 证据1: [...] - [❌] 证据2: [未完成, 原因]
## 改了什么: 文件 [...] / 命令 [...]
## 需要决策吗?: [不需要 / 需要 + 具体问题]
```

## Part 7: 红线 (绝不做)
- 修改 .env / 密钥 / token / API key
- 删除文件 / 数据库迁移
- git push / rebase / reset --hard
- 部署 / 发布到生产
- 公开 / 推广 / 群发
红线触发 = 输出"红线警告"(同转发请求格式, "建议转给"必填"用户"), 等用户确认。

## Note: Gemini
Gemini CLI may not support this skill mechanism the same way. If it doesn't
auto-load, paste this content into the project's GEMINI.md, or use Gemini only
as a forwarded auditor (read-only scanning) without resident rules.
