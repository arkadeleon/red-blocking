# CharacterListView 街霸 3.3 选人盘改造计划

- Date: 2026-03-12
- Status: Implemented
- Scope: `CharacterListView` 及其紧邻导航与布局支撑

## Summary

- 把 `CharacterListView` 从系统 `List` 改成自定义街机选人盘：顶部单人居中、6 行三列、底部保留 `Gill` 单独占位，整体按参考图高还原。
- 保留现有数据仓储和右侧 detail 流程，只重做左侧选择界面的视觉与交互；iPad 继续双栏联动，iPhone 继续点选后进入 detail。
- 不新增外部资源；使用现有 `Head` 头像资源、SwiftUI 渐变、遮罩、描边完成橙黑背景、黑色圆盘、像素头像和选中高亮。

## Key Changes

- 新增一组内部布局类型：
  - `CharacterRosterLayout`：固定描述参考图的行列结构与默认选中角色。
  - `CharacterRosterRow`：表示一行的槽位数组。
  - `CharacterRosterSlot`：区分可选角色槽位和 `Gill` 装饰占位槽位。
- `CharacterListView` 改为 `ScrollView + VStack` 的手工排布，不再使用 `List(selection:)`。
- 每个角色槽位改成自定义 `Button` 子视图，统一行为为“设置选中角色”。
- 头像按钮需要具备：
  - `Image(...).interpolation(.none)`，保留像素感。
  - 黑色圆盘底、圆形裁切、轻微阴影。
  - 选中态使用外环描边、缩放、抬升、亮度提升，而不是只靠颜色。
  - `accessibilityLabel`、`isSelected` trait、最小可点区域 44pt。
- 背景改成街霸 3.3 风格的层叠背景：
  - 橙黄到深棕/黑的斜向渐变。
  - 额外暗角和右侧压暗层，模拟参考图纵深。
  - 去掉 grouped/list 背景和 section chrome。
- `CharacterListModel` 调整为按 `CharacterRosterLayout` 的显示顺序决定默认选中角色，而不是仓储返回顺序。
- `NavigationRootView` 增加 `preferredCompactColumn` 状态并传给 `CharacterListView` 的激活回调：
  - regular width：仅更新选中角色，detail 同步刷新。
  - compact width：更新选中角色后切到 `.detail`，补回原 `List/NavigationLink` 在折叠导航下的自动跳转能力。
- `NavigationDetailView` 的空状态文案从 “sidebar” 改成 “select board” 语义，避免新视觉下文案失真。
- 视图拆分保持简洁，每个类型独立文件，至少拆成：
  - 主容器
  - 选人盘
  - 角色按钮
  - Gill 占位视图
  - 背景视图

## Test Plan

- iPad 纵向和横向：首屏自动选中布局里的第一个可玩角色，点击任意头像后右侧 detail 立即切换。
- iPhone 紧凑宽度：保持同一选人盘结构缩放显示，点击任意头像后切到 detail；返回后还能继续在选人盘重新选角。
- 视觉校验：顶部单槽、底部 Gill 占位、6 行三列中段布局完整，橙黑背景和黑色圆盘风格接近参考图，不出现系统 `List` 样式残留。
- 状态校验：错误态和空态仍显示 `ContentUnavailableView`，不会渲染出空白选人盘。
- 可访问性校验：VoiceOver 能读出角色名和“已选中”状态；Gill 占位不触发导航；Reduce Motion 下若有动画则退化为轻量 opacity/scale。

## Assumptions

- 角色顺序以用户提供的参考图为准，不使用当前 YAML 或仓储顺序。
- `Gill` 本次仅作为底部装饰占位，不新增角色数据，也不补新头像资源。
- 左侧只做“头像盘”，不加入额外名字板或完整信息区；角色详情仍由现有 detail 区承担。
- 这次不扩展测试基础设施；验证以预览和模拟器/真机手测为主，必要时只补最小范围的纯模型顺序断言。
