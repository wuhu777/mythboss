# CLAUDE.md

本文件为 Claude Code（claude.ai/code）在本仓库中工作时提供指引。

## 项目概览

本仓库是一个内部英文名为 `wishqu`、对外中文名为“我是区”的 Godot 4.6 2D 动作游戏原型。

代码库目前仍处于原型早期阶段。现在已经包含基础 Godot 项目清单、一个运行中的主场景，以及一个最小可移动的玩家占位角色。优先进行小而可运行的改动，确保项目始终可以在编辑器中正常打开。

## 常用命令

### 在 Godot 中打开项目
在 Godot 编辑器中打开 `project.godot`。

当前搭建阶段本地可执行文件目录：

```bash
"D:/environment/Godot_v4.6.2-stable_win64.exe/"
```

常用可执行文件：

```bash
"D:/environment/Godot_v4.6.2-stable_win64.exe/Godot_v4.6.2-stable_win64.exe"
"D:/environment/Godot_v4.6.2-stable_win64.exe/Godot_v4.6.2-stable_win64_console.exe"
```

### 从命令行运行项目

```bash
"D:/environment/Godot_v4.6.2-stable_win64.exe/Godot_v4.6.2-stable_win64.exe" --path "D:/workspace/ai/mythboss"
```

这会从 `project.godot` 中配置的启动场景启动项目。

### 验证当前可运行入口
目前还没有单独的构建流水线；主要验证方式是确认项目可以打开并运行。

- 在编辑器中：使用 **Run Project**。
- 从 CLI：运行上面的命令。

### 测试与 lint
当前仓库中还没有接入测试框架、单测命令或 lint 配置。

在这里记录测试或 lint 命令之前，先确认相关框架已经实际加入项目。

## 架构

### 运行时入口
- `project.godot` 是权威的项目清单文件。
- `run/main_scene` 设置为 `res://scenes/main.tscn`。
- 项目当前目标为 Godot 4.6，并在桌面端和移动端都使用 `gl_compatibility` 渲染器。

### 当前场景结构
- `scenes/main.tscn` 是当前主要运行场景。
- 根节点是 `Node2D` 类型的 `Main`。
- `Main` 下当前接入了一个 `CharacterBody2D` 类型的 `Player` 节点。
- `Player` 目前带有基础移动脚本、一个 `CollisionShape2D`，以及一个 `Polygon2D` 占位可视图形。

### 仓库结构
- `scenes/` 当前包含主场景。
- `scripts/` 已开始用于放置玩法脚本，目前包含 `scripts/player.gd`。
- `assets/` 预留为未来资源目录，但当前尚未实际投入使用。
- `icon.svg` 是 `project.godot` 引用的项目图标。

## 本仓库的工作约定

- 默认使用 GDScript，除非用户明确指定 C#。
- 始终保持项目在编辑器中可运行；避免做出会破坏启动流程的半成品场景或脚本接线。
- 以小型纵向切片的方式构建原型，并确保它们始终能从 `main.tscn` 进入。
- 当前优先级仍是核心玩家循环：玩家控制 → 战斗交互 → 敌人/Boss 行为 → 镜头/UI。
- 当项目新增真实脚本、autoload、测试工具、导出配置，或出现更多有实际意义的运行时场景时，更新此文件。
