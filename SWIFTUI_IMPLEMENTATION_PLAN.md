# MaCherie SwiftUI Implementation Plan

## Summary

这份文档是在 [`SWIFTUI_MIGRATION_PLAN.md`](./SWIFTUI_MIGRATION_PLAN.md) 基础上的具体实施计划，目标是把迁移拆成尽量小、可独立验证的 Phase。每个 Phase 都应满足以下要求：

- 改动范围单一，不同时处理太多子系统。
- 每个 Phase 结束后工程都可以成功 build。
- 每个 Phase 都有明确的完成标准和回归点。
- 优先先搭建新骨架，再逐步把旧 UIKit 功能迁进来，最后删除旧实现。

## Phase 0: Baseline Freeze

### Goal

记录迁移前基线，避免后续功能回归时缺少参照。

### Tasks

- 记录当前工程可 build 的命令与结果。
- 记录当前主流程：角色列表 -> 招式树 -> 动画播放器。
- 记录当前关键资源来源：
  - `CharacterData/*.yml`
  - `FrameData/*`
  - `Assets.xcassets`
- 记录当前配置基线：
  - iOS 13 deployment target
  - Swift 5.0
  - storyboard app lifecycle

### Done When

- 基线信息写入文档或提交说明中。
- 当前 UIKit 版本仍可完整 build。

### Verification

- `xcodebuild -project MaCherie.xcodeproj -scheme MaCherie -destination 'generic/platform=iOS Simulator' build`

### Baseline Snapshot (Recorded 2026-03-11)

- Build baseline
  - Command: `xcodebuild -project MaCherie.xcodeproj -scheme MaCherie -destination 'generic/platform=iOS Simulator' build`
  - Result: `BUILD SUCCEEDED`
  - Environment observed during baseline build:
    - Xcode build version `17C529`
    - iPhone Simulator SDK `26.2`
    - Swift Package dependency: `Yams` `5.3.1`
- Current UIKit flow
  - App launches from `Main.storyboard`, whose initial view controller is a `UISplitViewController`.
  - `@UIApplicationMain` `AppDelegate` configures the split view plus both navigation controller delegates.
  - Master flow starts in `CharactersViewController`, which decodes `CharacterData/Characters.yml` into `[Character]`.
  - Selecting a character loads `CharacterData/<character.next>` as YAML, decodes `[CharacterMove.Section]`, and passes the result to `CharacterMovesViewController`.
  - On iPad, the first character is preselected in `viewDidLoad()` and immediately drives the detail pane.
  - Selecting a row with `Presented.ViewController == "FramesPlayerViewController"` triggers `ShowMotionPlayer` and presents `MotionPlayerViewController`.
  - `MotionPlayerViewController` loads playback data from `FrameData/<characterCode>/<characterCode>_<skillCode>.json` and `FrameData/<characterCode>/<characterCode>_<skillCode>.png`.
- Current resource sources
  - `CharacterData/*.yml`: active runtime source for character list and move tree decoding in UIKit flow.
  - `FrameData/*`: per-character frame JSON + sprite PNG resources consumed by the motion player.
  - `Assets.xcassets`:
    - `Head/*.imageset` provides list icons via `Character.rowImage`
    - `Body/*.imageset` provides detail background art via `Character.nextBackgroundImage`
- Current configuration baseline
  - iOS deployment target: `13.0`
  - Swift language version: `5.0`
  - App lifecycle: storyboard-based UIKit
    - `UIMainStoryboardFile = Main`
    - `UILaunchStoryboardName = LaunchScreen`
    - `AppDelegate` owns startup and default `UserDefaults` registration

Phase 0 status: complete. The pre-migration UIKit app still builds successfully with the baseline command above.

## Phase 1: Raise Platform Baseline

### Goal

先把工程平台基线抬到 SwiftUI 迁移所需水平，但不改 UI 架构。

### Tasks

- 将 deployment target 提升到 iOS 18。
- 将 Swift 版本升级到当前 Xcode 可用的 Swift 6.x。
- 清理与新平台明显冲突的旧 build setting。
- 确认 Yams 依赖在新基线上仍可编译。

### Done When

- 工程在 iOS 18 + 新 Swift 版本下可 build。
- 旧 UIKit 应用仍可运行。

### Verification

- Debug simulator build 成功。
- 无新增编译错误。

## Phase 2: Introduce SwiftUI App Entry

### Goal

引入新的 SwiftUI app lifecycle，但暂时不删除旧 UIKit 页面。

### Tasks

- 新增 `MaCherieApp`。
- 引入根级 app model / settings 容器的最小骨架。
- 让 app 启动进入一个最小 SwiftUI root view。
- 保留 `LaunchScreen.storyboard`。
- 暂时允许 SwiftUI root 仅展示占位或桥接入口。

### Done When

- App 入口已从 storyboard 切到 SwiftUI。
- 工程不再依赖 `UIMainStoryboardFile` 启动。

### Verification

- App 能启动到 SwiftUI 根页面。
- 工程 build 成功。

## Phase 3: Extract Data Layer

### Goal

把 YAML 读取和 bundle 资源访问从 UIViewController 中剥离出来，先稳定数据层。

### Tasks

- 新增 `CharacterRepository`。
- 新增 `MoveRepository`。
- 新增 `MotionRepository`。
- 将现有 `Bundle.main` + `YAMLDecoder` 读取逻辑迁入 repository。
- 为 `Character`、`CharacterMove`、`MotionInfo` 整理独立文件。

### Done When

- UI 层不再直接读取 YAML 文件。
- 三类 repository 可以独立被调用。

### Verification

- 至少验证：
  - 角色列表 YAML 可解码
  - 一个角色招式树 YAML 可解码
  - 一个 motion JSON + PNG 可加载

## Phase 4: Introduce App Settings Models

### Goal

先把全局偏好设置抽象出来，为后续 SwiftUI 绑定做准备。

### Tasks

- 新增 `HitboxVisibilitySettings`。
- 新增 `HitboxColorSettings`。
- 新增 `PlaybackSettings`。
- 把现有 `UserDefaults` key 封装到这些模型里。
- 设计默认值注册位置，移出 `AppDelegate`。

### Done When

- 所有命中框显隐、颜色、FPS 的读写都能通过 settings model 完成。
- 不再需要散落的全局 key 使用方式作为主要接口。

### Verification

- 读写 `UserDefaults` 后能正确还原。
- 默认值与当前旧版本行为一致。

## Phase 5: Build Navigation Skeleton

### Goal

先把新导航骨架搭出来，不急着一次性替换所有页面。

### Tasks

- 新增根 `NavigationSplitView`。
- 新增 detail `NavigationStack(path:)`。
- 定义最小路由模型：
  - `CharacterSelection`
  - `MoveNode`
  - `MoveDestination`
- 在根视图中打通 selection 和 path 的基本状态流。

### Done When

- iPad 下能显示 split view 骨架。
- iPhone 下能退化成 stack。
- 新导航层不依赖 UIKit push/pop animator。

### Verification

- SwiftUI 根导航可运行。
- 路由 path 可以 push/pop 基础目的地。

## Phase 6: Implement Character List Screen

### Goal

先迁移第一层页面，完成“角色列表” SwiftUI 化。

### Tasks

- 新增 `CharacterListModel`。
- 新增 `CharacterListView`。
- 用 `List(selection:)` 展示角色数据。
- 将角色选中行为接入根导航状态。
- 处理 iPhone / iPad 两种选择行为差异。

### Done When

- 角色列表完全由 SwiftUI 呈现。
- 选择角色可以驱动 detail 更新。

### Verification

- 列表能展示全部角色。
- iPad 切换角色时 detail 状态同步更新。
- iPhone 点选角色后能进入下一层。

## Phase 7: Implement Move Browser Screen

### Goal

迁移第二层和更深层的招式树浏览能力。

### Tasks

- 新增 `MoveBrowserModel`。
- 新增 `MoveBrowserView`。
- 将 `CharacterMove.Section` 映射到 sectioned `List`。
- 为四类 row 建立独立 SwiftUI view：
  - 可进入项
  - 明细项
  - 补充说明项
  - 播放器入口项
- 用 `navigationDestination(for:)` 驱动深层招式树递进。

### Done When

- 多层招式树可用 SwiftUI 浏览。
- 不再依赖 `CharacterMovesViewController`。

### Verification

- 至少选 3 个角色做深层导航测试。
- “Next” 类型节点可持续下钻。
- “Presented” 类型节点能正确路由到播放器入口。

## Phase 8: Add Detail Background Presentation

### Goal

补回旧版 detail 背景角色图，但使用 SwiftUI 的表达方式。

### Tasks

- 将背景图状态与角色选择绑定。
- 在 detail 区域增加背景层。
- 确保列表内容、背景图、导航层级之间的层次关系正确。
- 处理横竖屏与不同 size class 下的表现。

### Done When

- 角色切换时 detail 背景图同步变化。
- 不再插 UIKit 子视图到导航控制器底层。

### Verification

- iPad detail 背景更新正确。
- iPhone 下不影响导航和滚动可读性。

## Phase 9: Implement Motion Data Pipeline

### Goal

在真正重写播放器 UI 前，先把 motion 播放数据和资源加载链路稳定下来。

### Tasks

- 重构 `MotionInfo`，让解码数据与图像缓存分离。
- 设计 `MotionFrameResource` 或等价抽象，避免模型直接持有 `UIImage`。
- 统一 motion 数据准备流程：
  - 读取 JSON
  - 读取帧图像
  - 组装可播放数据
- 处理加载失败和空数据场景。

### Done When

- 播放器所需数据可以在不依赖 UIKit view/controller 的情况下准备完成。
- Motion 数据模型适合 SwiftUI/Canvas 消费。

### Verification

- 任取 3 个技能可成功准备播放数据。
- 数据层单独调用不会触发 UI 依赖问题。

## Phase 10: Implement Motion Player Model

### Goal

先迁移播放器状态机，再迁移播放器界面。

### Tasks

- 新增 `MotionPlayerModel`。
- 重写播放状态管理：
  - play
  - pause
  - stop
  - seek
  - step forward/backward
- 用单一时钟机制替换多个 `Timer` 分散逻辑。
- 让 FPS 改动能即时影响播放速度。

### Done When

- 播放状态机不再依赖 `MotionPlayerViewController`。
- 模型可以在无 UIKit 视图前提下驱动帧推进。

### Verification

- 播放、暂停、seek、逐帧前后移动逻辑正确。
- 改 FPS 后帧推进速率正确。

## Phase 11: Implement Canvas Renderer

### Goal

先把最关键的视觉输出层迁到 SwiftUI。

### Tasks

- 新增基于 `Canvas` 的 motion 渲染 view。
- 绘制当前帧图像。
- 绘制 player 1 / player 2 各类 hitbox overlay。
- 让颜色和显隐直接绑定 settings model。
- 校验坐标缩放和画面比例与旧版一致。

### Done When

- `MotionPlayerLayer` 可被替代。
- 单帧显示和 hitbox 绘制结果正确。

### Verification

- 对比旧版视觉输出，确认图像与 hitbox 位置大体一致。
- 切换 hitbox 开关可实时刷新画面。

## Phase 12: Implement Motion Player Screen

### Goal

把完整播放器 UI 换成 SwiftUI 页面。

### Tasks

- 新增 `MotionPlayerView`。
- 接入：
  - 播放/暂停按钮
  - 前进/后退按钮
  - frame slider
  - 当前帧 / 总帧显示
  - FPS 输入
  - player1 / player2 hitbox controls
- 将当前“ShowMotionPlayer” 路由到新 SwiftUI 页面。

### Done When

- 播放器主功能全部在 SwiftUI 下可用。
- 不再依赖 `MotionPlayerViewController`。

### Verification

- 打开任意带 motion 的招式可进入播放器。
- 控件与渲染联动正确。
- 设置值在页面间切换后保持一致。

## Phase 13: Accessibility and UX Pass

### Goal

在功能迁移完成后集中处理 SwiftUI 版本的人机和可访问性质量。

### Tasks

- 校正所有按钮文本和 VoiceOver 标签。
- 确保 icon button 都有文本语义。
- 处理 Dynamic Type 下的多行文本显示。
- 检查 Reduce Motion 下的动画降级。
- 优化 iPad / iPhone 下列表和 detail 的视觉层次。

### Done When

- 主要页面通过基本可访问性检查。
- 新 SwiftUI UI 达到可用水位。

### Verification

- VoiceOver 扫读主要控件无明显缺失。
- 大字号下列表与说明文本仍可读。

## Phase 14: Remove Legacy UIKit UI

### Goal

在新功能链路稳定后删除旧 UIKit 表现层，避免双栈长期并存。

### Tasks

- 删除：
  - `AppDelegate` 中 UI 生命周期和 split view 逻辑
  - `CharactersViewController`
  - `CharacterMovesViewController`
  - `MotionPlayerViewController`
  - 相关 `UITableViewCell` 子类
  - `CharacterBackgroundView`
  - `PushAnimator`
  - `PopAnimator`
  - `PopInteractor`
  - `Main.storyboard`
- 清理 `Info.plist` 和 project file 中无用引用。

### Done When

- 工程只保留 SwiftUI UI 栈。
- 不再存在未使用的旧 storyboard / view controller 引用。

### Verification

- 全量 build 成功。
- grep 不再出现旧 UI 入口和 storyboard 依赖。

## Phase 15: Final Cleanup and Regression Pass

### Goal

做迁移收尾，保证代码结构和功能链路稳定。

### Tasks

- 清理未使用资源与过时注释。
- 校验每种主要导航路径。
- 统一文件组织、命名和 feature 目录。
- 补充必要的预览或开发辅助数据。
- 更新 README 或迁移说明。

### Done When

- 代码结构符合新架构。
- 迁移说明与工程现状一致。

### Verification

- 全量 build 成功。
- 主流程回归通过：
  - 角色列表
  - 招式树递进
  - 动画播放器
  - 设置持久化

## Recommended Execution Order

建议严格按以下顺序推进，不要跳 Phase：

1. Phase 0
2. Phase 1
3. Phase 2
4. Phase 3
5. Phase 4
6. Phase 5
7. Phase 6
8. Phase 7
9. Phase 8
10. Phase 9
11. Phase 10
12. Phase 11
13. Phase 12
14. Phase 13
15. Phase 14
16. Phase 15

## Commit Strategy

建议每个 Phase 单独一个 commit；如果某个 Phase 仍偏大，可以按以下原则继续拆分：

- 先提交“模型 / repository / settings”
- 再提交“视图骨架”
- 最后提交“页面接线与旧代码替换”

推荐做到：

- 一个 Phase 最多影响一个主功能面
- 一个 commit 结束后始终可 build
- 不把“新实现引入”和“旧实现删除”混在同一个超大提交里
