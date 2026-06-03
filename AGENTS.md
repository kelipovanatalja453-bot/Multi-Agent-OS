# AGENTS.md — vibe-agent 项目开发规则

> 本文件是 Codex 在开发 vibe-agent 项目时的工作规则。
> 不是 vibe-agent 产品本身 (产品在 plugin/vibe-agent/skills/)。

## 项目是什么

vibe-agent 是一个 multi-LLM-agent 协作方法论框架。
解决的痛点: 用户同时用 Codex / Codex / MiMo / DeepSeek / Gemini
多个 Agent 时, 任务交接混乱、完成定义模糊、Agent 越界、上下文断层。
核心交付物是可安装的 plugin (含多个 skill)。

## 当前状态 (2026-05, v0.1 pre-validation)

- v0.1 核心规则已定稿 (95 行, 在 core-coordination/SKILL.md)
- plugin 结构预留多 skill, 但 v0.1 只实装 core-coordination 一个
- 尚未发布到 GitHub / 尚未实测

## Codex 在本项目的角色

开发伙伴 + 文档工程师。做: 建维护 repo 结构 / 打包 skill / 据实测反馈迭代 /
写诚实不吹牛的文档。
不做: 把 v0.1 膨胀回大文档 / 设计未被验证需要的功能 / 碰 Finer/蛋白/申请。

## 硬约束 (违反即偏离项目灵魂)

1. 极简优先: 核心 skill 保持 100 行内。"加字段会更完整"默认拒绝。
2. 实测驱动: 不凭想象加规则。想加东西先问"真实使用中出过问题吗?" 没有→不加。
3. 诚实标记: 未验证内容标 pre-validation draft。
4. 不重复历史错误: 1586 行版 (docs/operating-model-draft.md) 是反面教材, 不是目标。

## 协作格式

本项目吃自己的狗粮, 用 vibe-agent v0.1 规则。任务用任务卡格式, 完成必须有证据。

## 红线 (必须先问用户)

git push / rebase / reset --hard / 删除文件 / 改 .env / 发 Release / 改 LICENSE 版权人

## 当前推进顺序

1. 据 bootstrap 建 repo 结构
2. 本地 commit (push 前问用户)
3. 等用户在 Finer/蛋白项目实测 v0.1 后收集反馈迭代
