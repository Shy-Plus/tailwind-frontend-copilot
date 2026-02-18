## Baseline
- 明确现状与边界
  - Tailwind v3 版本与依赖：`tailwindcss`, `postcss`, `autoprefixer`, 构建工具（Vite/Webpack/Next/Nuxt）、Node 版本。
  - 入口样式与指令：是否使用 `@tailwind base; @tailwind components; @tailwind utilities;`，是否有自定义 `@layer`、`@apply`、`@config`。
  - 配置覆盖点：`tailwind.config.{js,ts}` 中的 `content`、`theme.extend`、`plugins`、`safelist`、`darkMode`、`corePlugins`、`prefix`、`important`。
  - 周边插件与约束：官方插件（forms/typography/aspect-ratio/line-clamp）、UI 库（shadcn/ui、Headless UI、DaisyUI）、类名生成器（clsx/cva）、CSS Modules、SCSS、预处理器。
  - 产品面基线：关键页面/组件清单、暗色模式、RTL/国际化、可访问性用例、关键交互与视觉快照（截图或 Storybook 参考）。
  - 体量与性能：当前 CSS 产物大小、首屏关键路径（关键 CSS/动态导入）、构建时长与缓存策略（CI Cache）。

- 基线产物（不执行，仅建议生成）
  - 依赖快照：`cat package.json` 与 `cat package-lock.json|pnpm-lock.yaml|yarn.lock`。
  - 构建产物大小：记录 `dist/assets/*.css` 体积。
  - 关键页面截图列表与验收脚本（E2E/视觉 diff 的计划占位）。

## GateA
- “能升级不回退”的先决条件
  - 依赖可升级且无已知冲突：所有 Tailwind 官方插件均有 v4 兼容版本；第三方 UI 库未强依赖 v3 内部实现。
  - 配置可解析：`tailwind.config.*` 不包含私有 Hook/自定义解析器；`content` 覆盖所有模板文件（避免类名丢失）。
  - 构建链路清晰：PostCSS 插件顺序明确（Tailwind 在 Nesting/Autoprefixer 前后的一致性策略已确认）。
  - 回滚通道畅通：锁文件+标签基线已保存；切换 v3 的步骤简单可复现。
  - 覆盖率与用例：关键路径有至少“冒烟级”校验清单（页面能开、暗色可切、表单可用、滚动/吸附/断点生效）。

- 通过标准（示例）
  - 本地构建成功，产物可预览；样式灾难级回归为 0；关键页面打开无明显布局错乱。
  - CSS 体积变动在可接受阈值（例如 ≤ +10% 或有理性解释的减少/增加）。

## MigrationSteps
- 策略概览
  - 分两阶段迁移，先“兼容升级”，后“原生 v4 化”。第一阶段尽量不触及业务样式与原子类；第二阶段再引入 v4 新特性（如更简的入口、主题令牌、工程优化）。
  - 严格小步快跑，每步可随时回滚。

- 阶段一：兼容升级（保持 v3 用法，切换到 v4 引擎）
  1) 升级依赖（不执行，仅示例）
     - npm: `npm i -D tailwindcss@^4 postcss@latest autoprefixer@latest`
     - pnpm: `pnpm add -D tailwindcss@^4 postcss@latest autoprefixer@latest`
     - yarn: `yarn add -D tailwindcss@^4 postcss@latest autoprefixer@latest`
  2) 保留原入口指令与配置
     - 继续使用现有 `src/styles/tailwind.css` 中的 `@tailwind base; @tailwind components; @tailwind utilities;`。
     - 保留 `tailwind.config.*` 的 `content/theme.extend/plugins/safelist` 等设置，先不重构为 v4 新式主题写法。
  3) 构建链路校验
     - 确认 PostCSS 管线顺序稳定（通常：`tailwindcss` -> `autoprefixer`），若有 `postcss-nesting`/`cssnano`，检查先后是否影响类生成。
  4) 冒烟测试与修复清单
     - 断点与容器：`container`、`sm/md/lg/xl/2xl` 等是否生效；自定义断点是否被识别。
     - 暗色模式：`dark:` 变体是否运作（基于 `class` 或 `media`）；`html`/`body` 切换策略保持不变。
     - 表单/富文本：`@tailwindcss/forms`、`@tailwindcss/typography` 是否有版本适配提示；必要时同步升级插件。
     - 任意值/变体：`[var(--x)]`、`before:content-['*']`、`supports-[...]`、`data-[state=open]:...` 等语法仍能生成。
     - Safelist 与动态类：正则/字符串 safelist 是否覆盖运行期拼接类（`cva/clsx` 输出）。

- 阶段二：原生 v4 化（采用 v4 推荐心智模型与工程化）
  5) 入口样式简化（渐进替换）
     - 将入口文件中的三条 `@tailwind` 指令替换为更简的 v4 入口（建议以一个分支/PR单独完成），并验证预设层是否等价生成。
     - 若项目大量使用自定义 `@layer`，先保留，待主题令牌落地后再收敛。
  6) 主题与设计令牌（选择性）
     - 将 `theme.extend.colors/spacing/fontSize/...` 中稳定的设计值沉淀为 CSS 变量（例如 `:root { --brand: #... }`），原子类通过任意值或映射复用，逐步减少深层 `extend`。
     - 为团队编写“令牌→类名”对照表（色板/间距/阴影/圆角/排版），消除同义多写。
  7) 插件与生态
     - 升级官方插件到 v4 兼容版本；对第三方插件逐个验证（替换为官方能力或移除不必要插件）。
  8) 产物与性能
     - 记录 CSS 体积、未使用类的清理策略（依赖完整 `content` 扫描）；必要时引入构建缓存与按需路由切分策略。
  9) 文档与规约
     - 更新团队样式规范：类名优先级、`@apply`使用边界、暗色策略、动态类生成约束、令牌使用优先级。
     - 为常见组件（按钮/输入/卡片/排版区块）输出 v4 推荐实现样例，替换零散局部风格。

## Rollback
- 触发条件
  - 构建失败且 2 小时内无法修复；关键页面出现 P0 视觉/交互问题；CSS 体积骤增导致首屏性能恶化且无临时缓解手段。

- 一键回退（不执行，仅示例）
  - 还原锁文件与依赖：`git restore package.json` 与 `git checkout <lockfile> && npm i|pnpm i|yarn install --frozen-lockfile`
  - 还原入口样式与配置：`git restore src/styles/tailwind.css tailwind.config.* postcss.config.*`
  - 打回分支：`git reset --hard <GateA前的tag/commit>` 并重新发布 v3 产物。

- 数据保全
  - 保留失败构建日志与差异截图；记录问题定位摘要（受影响页面、类名、插件、配置项）以供后续热修复与再升级。

## ReleaseGateC
- 放行标准
  - 构建稳定：本地与 CI 均可无缓存冷构建通过；CSS 体积变动在阈值内或有清晰收益说明。
  - 视觉对齐：关键页面逐项对拍通过；暗色/高对比度/可访问性用例通过冒烟。
  - 功能验证：交互无回归（Hover/Focus/Active/Disabled/Data/Group/Peer 变体）；动态类生成全覆盖。
  - 文档完备：README/内网手册已更新到 v4 工作流，包含“如何写类”、“如何加令牌”、“如何排查未生成样式”。
  - 监控就绪：发布后 24–72 小时内留守观测渠道（错误上报、工单、性能看板），准备热修策略。

- 发布后动作
  - 合并“原生 v4 化”剩余事项到迭代计划（主题令牌推广、组件库替换、插件清理）。
  - 设立“样式债务”看板：跟踪 legacy 类/自定义层/重复色值，按周清偿。