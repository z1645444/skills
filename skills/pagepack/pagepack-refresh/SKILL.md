---
name: pagepack-refresh
description: Maintain an existing .codebase/ best practice pack. With a natural language description, investigates and fixes the targeted practice; without one, runs a health check (validate file references, detect drift via git). Edits files directly; review with git diff. Use when .codebase/ exists and needs updating.
---

# Pagepack Refresh

维护已有的 `.codebase/` best practice pack。直接编辑文件，无 patch 流程——`.codebase/` 是独立 git repo（main repo 已 ignore），`git -C .codebase diff` 就是审查层，用户不满意可 revert。

前置：`.codebase/` 不存在时，停止并引导用户改用 `pagepack-init`；存在但不是 git repo（无 `.git`）时，先在其中 `git init` 并把当前状态提交为初始版本，再继续。

注意：`.codebase/` 被 main repo ignore，rg 等搜索工具默认会跳过它。定位 practice 一律读 `README.md` 索引后按路径直接读取，不要依赖全局搜索。

## 模式选择

- 用户提供了自然语言描述（如 "edit modal 的总结不对，关闭逻辑变了"）→ **定向模式**。
- 未提供描述 → **体检模式**。用户显式要求"全量刷新"时，仍走体检模式，但把"增量找漂移"一步替换为对全部 practice 重新调查；引用校验、接入核对、更新基线照常执行。

## 定向模式（主用法）

1. **定位**：读 `.codebase/README.md` 索引，根据描述找到相关 practice 文件（可能不止一个）。
2. **调查**：重新阅读该 practice 的参考实现文件及同类实例的当前代码，核对 practice 中的 code block、注意事项、裁决是否与现状一致；描述中提到的具体问题优先核实。
3. **更新**：直接编辑 practice 文件。保持提炼式形态（通用骨架 code block、去业务噪音、显式裁决遗留写法、2–3 个参考实现）。若主流写法已变，更新 code block 并把旧写法降级为遗留裁决。
4. 若调查发现描述指向的 pattern 尚无 practice，新建对应文件并在 README 索引中登记。

## 体检模式

1. **引用校验（全量）**：遍历所有 practice 中的真实文件引用，逐一检查路径是否存在。失效引用：若文件是改名/移动，更新路径；若 pattern 实例整体消失，重查同类实例并替换引用。
2. **增量找漂移**：读 `.codebase/.baseline` 中记录的 main repo commit hash，在 main repo 执行 `git diff --name-only <hash>` 得到已提交与已跟踪文件的工作区变动，再用 `git ls-files --others --exclude-standard` 补上 untracked 的新文件；仅重新评估被这些文件波及的 practice，核对写法是否漂移、是否出现新的未覆盖 pattern。`.baseline` 缺失或 hash 已不在 main repo 历史中（如 rebase 重写）时，跳过增量检查并建议用户做一次全量刷新。
3. **接入核对**：确认 `AGENTS.md` / `CLAUDE.md` 中指向 `.codebase/README.md` 的引导文字仍在；缺失则输出引导文字（条件式措辞，见 `pagepack-init`）提醒用户补上（不直接改，除非用户要求）。
4. **更新基线**：体检结束后把 `.baseline` 更新为 main repo 当前 `git rev-parse HEAD`。定向模式不更新 baseline。

## 编辑约束

- 只做最小必要修改，不整体重写文件；用户手工润色过的措辞尽量保留。
- 新增/删除 practice 文件时同步更新 `README.md` 索引。
- 语言跟随该 practice 文件现有语言；新建文件跟随 pack 内其他 practice 的语言。

## 收尾汇报

逐条列出每处改动：哪个文件、改了什么、依据是什么（看了哪些真实文件、发现了什么变化）。未发现问题的检查项也简要说明。最后提醒用户审查：`git -C .codebase status` 总览全部变动（新建的 practice 文件是 untracked，只看 diff 会漏），`git -C .codebase diff` 看逐行改动；满意后在 nested repo 内自行 commit，不满意可 revert 后用更具体的描述再次 refresh。
