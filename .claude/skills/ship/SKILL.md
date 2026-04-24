---
name: ship
description: Review local git changes, create a concise commit, and push the current branch to its tracked remote.
allowed-tools:
  - Bash(git status *)
  - Bash(git diff *)
  - Bash(git log *)
  - Bash(git branch *)
  - Bash(git rev-parse *)
  - Bash(git add *)
  - Bash(git commit *)
  - Bash(git push *)
  - Bash(ls *)
---

调用该技能时，请在当前仓库中执行以下工作流：

1. 使用 `git status`、`git diff --staged`、`git diff` 和最近的 `git log --oneline -5` 检查当前分支与工作区状态。
2. 总结发生了哪些改动，并起草一条能够反映这些改动目的的提交信息。
3. 如果没有可提交的改动，直接说明并停止。
4. 只暂存本次提交应包含的项目文件，避免误把密钥或无关文件加入提交。
5. 使用如下格式的 HEREDOC 提交信息创建一个新的提交：

```bash
git commit -m "$(cat <<'EOF'
<summary line>

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
EOF
)"
```

6. 将当前分支推送到它的 upstream remote。如果还没有配置 upstream，先确定当前分支名，再使用 `git push -u origin <branch>` 进行推送。
7. 报告最终的提交哈希和分支状态。

行为规则：
- 除非用户明确要求，否则不要 amend 已有提交。
- 除非用户明确要求，否则不要使用 `--no-verify`、`--force` 或其他绕过标志。
- 如果 pre-commit hook 失败，先检查失败原因；如果问题较直接，就修复后再创建一个新的提交。
- 如果 push 因为远端变更而被拒绝，停止并说明需要先 pull 还是 rebase。
- 保持回复简洁并以执行结果为导向。
