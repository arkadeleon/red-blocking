# MaCherie SwiftUI 全量迁移计划

## Summary

将当前 UIKit/storyboard 应用完整迁移为 SwiftUI 应用，minimum deployment target 升到 iOS 18，保持现有功能完整，但把导航、状态管理、播放器界面和可访问性升级到 SwiftUI / iOS 18 的原生实现方式。

当前基线已确认：
- 现有工程可成功 build（`xcodebuild -project MaCherie.xcodeproj -scheme MaCherie -destination 'generic/platform=iOS Simulator' build` 成功）。
- 当前功能主线是：角色列表 -> 招式树 -> 动画播放器。
- 数据当前实际以 YAML + Yams 驱动，JSON 是并存副本；本次按已定方案继续保留 YAML 作为真源。
- 播放器按已定方案做纯 SwiftUI 重写，不保留 UIKit 视图层作为过渡方案。

## Key Changes

### 1. App Shell 与工程结构

- 移除 `Main.storyboard` 入口，改为 `@main` 的 `MaCherieApp`。
- 保留 `LaunchScreen.storyboard`，删除 `UIMainStoryboardFile`、`@UIApplicationMain`、`AppDelegate` 中的 UI 装配逻辑。
- 工程配置统一升级：
  - `IPHONEOS_DEPLOYMENT_TARGET = 18.0`
  - Swift 语言版本升级到当前 Xcode 可用的 Swift 6.x
  - 移除不再需要的 UIKit-only 源文件、storyboard scene、旧导航动画器和交互返回控制器。
- 目录按 feature 重组，至少拆成：
  - `App`
  - `Features/Characters`
  - `Features/Moves`
  - `Features/MotionPlayer`
  - `Shared/Models`
  - `Shared/Services`
  - `Shared/Settings`

### 2. 导航与信息架构

- 根导航使用 `NavigationSplitView`，让 iPad 保持双栏体验，iPhone 自动折叠为 stack。
- 左栏为角色列表；右侧 detail 使用 `NavigationStack(path:)` 承载招式树的递进导航。
- 取消 UIKit 的自定义 push/pop 动画与手势返回，全部交给系统导航行为。
- 招式树改为显式路由模型，而不是在视图里直接塞下一层控制器数据。
- 新增内部路由类型：
  - `CharacterSelection`
  - `MoveNode`
  - `MoveDestination`（区分“下一层招式目录”和“播放器”）
- `navigationDestination(for:)` 统一注册一次，不混用旧式 destination API。

### 3. 数据模型与加载

- 保留 YAML + Yams 解析，不做 JSON 切换。
- 把当前同步散落在 `UIViewController` 里的读取逻辑收敛为服务层：
  - `CharacterRepository`
  - `MoveRepository`
  - `MotionRepository`
- `Character`、`CharacterMove.Section`、`CharacterMove`、`CharacterMove.Frames`、`MotionInfo` 整理到独立文件，每个类型单独成文件。
- 为 SwiftUI 列表/导航补齐稳定标识：
  - 角色模型 conform `Identifiable`
  - 招式节点建立稳定 id（基于 character + 路径）
- 所有 bundle 资源读取、YAML 解码、frame 数据读取统一从 service 层暴露，视图不直接碰 `Bundle.main`。

### 4. 状态管理与设置

- 用 `@Observable` + `@State` / `@Bindable` 重建状态流，不继续扩散 `ObservableObject` / `@Published`。
- 把 `UserDefaults` 的一组全局 key 封装为可观察设置模型：
  - `HitboxVisibilitySettings`
  - `HitboxColorSettings`
  - `PlaybackSettings`
- 这些设置由 app root 持有，通过环境下发给角色页、招式页、播放器页。
- 播放器状态拆成纯 SwiftUI 友好的模型：
  - `MotionPlayerModel`
  - `MotionPlaybackState`
  - `MotionFrameIndex`
- 所有 UI side effects（播放、暂停、seek、下载/加载）放进 model/service，不放在 `body` 里。

### 5. 角色列表与招式树界面

- 角色页使用 `List(selection:)`，在 regular width 下与 `NavigationSplitView` 联动。
- 背景角色图改为 SwiftUI detail 背景层，而不是插入导航控制器底层子视图。
- 招式页改成 sectioned `List`，按数据类型拆成独立 row view：
  - 普通可进入项
  - 纯数值明细项
  - 补充说明项
  - “モーション” 播放器入口项
- 行视图全部用 SwiftUI 原生组件，保证 Dynamic Type、多行文本、VoiceOver 标签正常。
- 不再复刻 `UITableViewCell` 类；四种 cell 全部被 SwiftUI row view 替代。

### 6. 动画播放器纯 SwiftUI 重写

- 播放器页面用 SwiftUI `sheet(item:)` 或导航跳转承载，不再依赖 `MotionPlayerViewController`。
- 渲染层用 SwiftUI `Canvas` 重写，不保留 `MotionPlayerLayer`。
- `Canvas` 负责：
  - 帧图像绘制
  - 各类 hitbox overlay
  - 基于设置的颜色与显隐
- 播放控制条改为 SwiftUI 原生控件：
  - 播放/暂停按钮
  - 前进/后退
  - frame slider
  - FPS 输入
  - 当前帧 / 总帧显示
- 双侧 hitbox 开关改成带文本标签的 `Toggle` / `Button` 风格控件，避免现有 icon-only checkbox 方案。
- 播放时序不再依赖多个 `Timer` 分散控制，统一由 `MotionPlayerModel` 管理单一时钟与状态切换。
- `MotionInfo.Frame.image` 不再把 `UIImage` 混进解码模型；图像缓存从数据模型中抽离到渲染/资源层。
- 如需预解码图片，使用缓存服务在加载阶段完成，避免 view body 内做重工作。

## Important Interface Changes

- 新增 `@main struct MaCherieApp: App`
- 新增 `@Observable` 类型：
  - `AppModel`
  - `CharacterListModel`
  - `MoveBrowserModel`
  - `MotionPlayerModel`
  - `HitboxVisibilitySettings`
  - `HitboxColorSettings`
  - `PlaybackSettings`
- 新增 repository/service 接口：
  - `CharacterRepository.loadCharacters() async throws -> [Character]`
  - `MoveRepository.loadSections(for character: Character) async throws -> [CharacterMove.Section]`
  - `MotionRepository.loadMotion(characterCode: String, skillCode: String) async throws -> MotionInfo`
- `MotionInfo` 调整为“解码数据”和“渲染资源”分离的结构；视图不直接持有 UIKit 图像状态。
- 删除旧入口/导航接口：
  - `AppDelegate` UI 装配职责
  - `CharactersViewController`
  - `CharacterMovesViewController`
  - `MotionPlayerViewController`
  - `PushAnimator`
  - `PopAnimator`
  - `PopInteractor`

## Test Plan

- 构建验证
  - iOS Simulator 下完整 build 成功。
  - storyboard 移除后工程仍可 archive/build。
- 数据验证
  - YAML 角色列表可完整解码。
  - 至少抽测 3 个角色的深层招式树可递归解码。
  - 至少抽测 3 个 `FrameData` JSON + PNG 组合可成功载入。
- 导航验证
  - iPhone：角色 -> 招式 -> 更深层招式 -> 播放器 全链路可走通。
  - iPad：`NavigationSplitView` 下切换角色时 detail 正常更新。
  - 深层返回路径保持正确，不出现重复 destination 注册问题。
- 播放器验证
  - 播放、暂停、前进、后退、拖动进度条、修改 FPS 均正常。
  - Hitbox 各类别显隐立即影响 `Canvas`。
  - 切换角色技能后播放器状态正确重置。
- 可访问性验证
  - Dynamic Type 下列表和说明文本不截断为不可读。
  - VoiceOver 可识别所有主要按钮与 hitbox 控件。
  - Reduce Motion 开启时不依赖自定义大幅位移动画。
- 设置持久化验证
  - 命中框显隐、颜色、FPS 在重启后保留。

## Assumptions

- 保持当前功能范围，不新增编辑、搜索、收藏或云同步。
- 保持 YAML + Yams 作为本次迁移后的正式数据链路。
- 保持现有资源文件命名与 bundle 组织方式，不做大规模资源重命名。
- 保持当前平台范围为 iPhone + iPad。
- 允许删除旧 UIKit 代码与 storyboard，而不是长期双栈并存。
- 若迁移中发现个别底层绘制细节无法 1:1 复刻，以“功能正确 + SwiftUI 原生 + iOS 18 API 优先”为准。
