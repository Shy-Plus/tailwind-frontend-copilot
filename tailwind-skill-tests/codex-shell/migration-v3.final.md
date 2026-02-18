## Baseline
- 项目结构与版本
  - package.json: tailwindcss ^3.4.13, postcss ^8.4.47, autoprefixer ^10.4.20（依赖而非 devDependencies），无框架/构建工具声明。文件: package.json:1
  - Tailwind 配置：最小化 v3 配置，content 指向 `./src/**/*.{js,jsx,ts,tsx}`，无 theme 扩展、无插件。文件: tailwind.config.js:1
  - PostCSS：使用 `tailwindcss` 与 `autoprefixer` 插件。文件: postcss.config.js:1
  - 样式入口：仅有 `src/index.css`，包含 v3 典型指令 `@tailwind base; @tailwind components; @tailwind utilities;`。文件: src/index.css:1
- 代码用法扫描（证据）
  - 未检出任何 `class=`/`className=`、`clsx/cva/cn/tw` 等动态类串用法（空结果）。
  - 仅检出 `@tailwind` 指令三行：src/index.css:1-3
- 基线结论
  - 这是一个“最小 v3 + PostCSS 管线”的试验仓，无第三方 Tailwind 插件、无自定义 theme、无复杂类名来源，迁移面非常小，可直接按 v4 最小范式落地。

## Risks
- 扫描来源切换风险：v4 推荐用 `@source`（CSS 内）替代 v3 `content`（tailwind.config.js），若遗漏路径会导致样式未生成。
- 指令模型变化：`@tailwind base/components/utilities` → `@import "tailwindcss";`，若后续有自定义 layer 覆盖，需验证顺序；当前仓库无该情况，风险低。
- 配置收敛风险：删除 `tailwind.config.js` 后，历史 theme/插件配置将失效；当前无配置，风险低。
- 工具链兼容性：仍使用 PostCSS 时需确保 `postcss`/`autoprefixer` 版本与 v4 兼容（当前版本新，通常可用）。
- 动态类名潜在问题：若将来引入运行时拼接类名，v4 依旧无法推断，需要 safelist 或显式枚举。

## GateA
- 迁移范围
  - 仅升级到 Tailwind v4，采用 CSS 内 `@import "tailwindcss";` 与 `@source`，移除 v3 专属 `tailwind.config.js` 中的 `content` 用法。
- 令牌与模式
  - 当前无自定义 token；暂不引入 `@theme`；Dark mode 策略保持默认（不在本次变更内）。
- 构建与输出
  - 以 Tailwind CLI 验证输出（无框架）；输出产物 `dist/tailwind.css` 作为校验依据。
- 回滚边界
  - 回滚到 v3：还原 package.json 的 tailwindcss 版本、恢复 `src/index.css` 的三段 `@tailwind` 指令、恢复 `tailwind.config.js`。

## MigrationSteps
- 建立安全分支
  - `git switch -c chore/migrate-tailwind-v4`
- 升级依赖（最小变更，保留 PostCSS 管线）
  - npm: `npm i -D tailwindcss@latest && npm i -D postcss@latest autoprefixer@latest`
  - 说明：将 Tailwind/构建链放入 devDependencies，避免生产安装体积。
- CSS 指令迁移（v3 → v4）
  - 将 `src/index.css` 的三行 `@tailwind base/components/utilities` 替换为：`@import "tailwindcss";`
  - 在同一文件顶端或紧随其后，新增 v4 扫描来源：`@source "./src/**/*.{js,jsx,ts,tsx}";`
  - 如后续需要 token，再引入：`@theme { /* 自定义tokens */ }`（本次不改动）
- 配置文件收敛
  - 暂时保留 `postcss.config.js` 不变（tailwindcss + autoprefixer）。
  - 移除 `tailwind.config.js`（当前无有效配置；若需保守，可先重命名 `tailwind.config.js.bak`，观察无回归后再删除）。
- 生成与验证（本地快速验证）
  - 生成产物：`npx tailwindcss -i ./src/index.css -o ./dist/tailwind.css --minify`
  - 校验点：
    - 命令退出码为 0，`dist/tailwind.css` 文件存在且非空。
    - CSS 体积合理（包含基础层与常用工具类）；无报错/警告堆栈。
- 文档更新
  - 在 `references/90-system-architecture-maintenance.md` 追加：组件样式来源、构建命令、v4 指令与 `@source` 路径约定。

## Rollback
- 代码回滚
  - `git restore --source=HEAD~1 src/index.css postcss.config.js tailwind.config.js package.json`
  - 或直接回到迁移前分支：`git switch -`，再 `git branch -D chore/migrate-tailwind-v4`
- 依赖回滚
  - 将 package.json 中 `tailwindcss` 版本还原到 `^3.4.13`，并执行 `npm i`
- 构建验证（回滚后）
  - `npx tailwindcss -i ./src/index.css -o ./dist/tailwind.css --minify` 应继续成功，且样式与迁移前一致

## GateC
- 验收清单
  - 构建通过：`npx tailwindcss -i ./src/index.css -o ./dist/tailwind.css` 成功且无错误。
  - 产物存在：`dist/tailwind.css` 非空，包含基础层与实用类。
  - 覆盖一致：当前仓库无页面/组件，验证范围以产物可生成为准；如后续加入页面，再补充可视回归对比。
  - 文档同步：已更新 `references/90-system-architecture-maintenance.md` 的构建与样式章节。
- 放行条件
  - 扫描来源 `@source` 与未来代码组织约定已确认。
  - 无遗留 v3 专属配置依赖（已去除 tailwind.config.js 的 content 责任）。