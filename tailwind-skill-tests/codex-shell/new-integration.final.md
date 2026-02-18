## StackDetect
- 使用技能: tailwind-frontend-copilot（识别当前前端栈与集成切入点）
- 证据采集要点
  - Node/PM: node v25.2.1, npm 11.8.0, bun 1.3.8（未检测到 yarn/pnpm 锁文件）
  - 框架/构建: package.json 依赖含 `vite@5.4.0` 与 `react@18.3.1`，推断为 Vite + React 项目（零配置形态）
  - Tailwind 状态: 未发现 `tailwind.config.*` 或 `postcss.config.*`
  - 工程结构: 顶层存在 `src/App.jsx`，未检测到典型入口 `index.html` 或 `src/main.jsx`（Vite 可零配置运行，但后续需要放置全局样式引入点）
- 采集命令与关键输出（摘要）
  - `ls -la` → 有 `package.json`, `src/`
  - `node -v && npm -v && bun -v` → 分别为 v25.2.1 / 11.8.0 / 1.3.8
  - `cat package.json`（摘要）→ deps: react 18.3.1, vite 5.4.0；无 scripts、无 devDependencies
  - 结论: 目标栈为「Vite + React」，当前尚未接入 Tailwind/PostCSS，包管理器以 npm 为主（亦可切 bun）

## GateA
- 决策主题: 选择 Tailwind 版本与接入路径
- 选项
  - A1（推荐，稳健/LTS轨）: Tailwind CSS v3.4.x + PostCSS + Autoprefixer
    - 优点: 文档与社区范式成熟，Vite/React 兼容性好，所有脚手架流程稳定
    - 风险: 相比 v4 配置稍多（需要 postcss.config）
  - A2（前沿/更简）: Tailwind CSS v4
    - 优点: 更少配置，CSS-first 心智，构建链更轻
    - 风险: 与部分插件/工具链的兼容性需要逐项确认；迁移指南需严格对齐官方文档
- 本次建议: 采用 A1（v3.4 LTS）作为默认路径；A2 提供备选命令，按需切换

## GateB
- 决策主题: 构建工具与注入点
- 结论（基于证据）:
  - 构建工具: Vite 5（零配置）
  - 注入点策略: 在全局入口引入 `tailwind.css`
    - 若存在 `src/main.jsx` → 在 main.jsx 顶部 `import './styles/tailwind.css'`
    - 如暂仅有 `src/App.jsx` → 临时在 App.jsx 顶部引入，后续补齐 main.jsx 再迁移
- 包管理器策略:
  - 首选 npm（已就绪）；如需更快安装且可接受差异，可选择 bun 等价命令

## GateC
- 决策主题: 内容扫描范围、样式来源与主题扩展
- Content globs（Vite + React 常规）:
  - `content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}']`
- 样式组织:
  - 创建 `src/styles/tailwind.css`，仅含三行指令（base/components/utilities）
  - 与 UI 库并用时，保留 `preflight`，若与 Reset/Normalize 冲突再按需关闭
- 主题扩展:
  - 在 `tailwind.config.js` 的 `theme.extend` 统一放置色板、间距、字体
  - 预留 `plugins: []`，后续引入 forms/typography/aspect-ratio 等插件

## ImplementPlan
- 安装（A1: v3.4 LTS，npm）
  - `npm i -D tailwindcss@3 postcss autoprefixer`
  - `npx tailwindcss init -p`  # 生成 `tailwind.config.js` 与 `postcss.config.js`
- 配置（A1）
  - 编辑 `tailwind.config.js` → 设置:
    - `content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}']`
    - `theme: { extend: {} }`, `plugins: []`
  - 新建 `src/styles/tailwind.css`，写入:
    - `@tailwind base;`
    - `@tailwind components;`
    - `@tailwind utilities;`
  - 在入口处引入（择一）:
    - 如有 `src/main.jsx`: `import './styles/tailwind.css'`
    - 当前仅 `src/App.jsx`: 暂时在 `src/App.jsx` 顶部引入，后续再迁移到 main.jsx
- 脚本（便于启动/构建）
  - `npm pkg set scripts.dev=\"vite\"`
  - `npm pkg set scripts.build=\"vite build\"`
  - `npm pkg set scripts.preview=\"vite preview --port 4173\"`
- 运行与自验
  - `npm run dev` → 访问本地端口，创建任意元素并添加 `className=\"text-3xl font-bold underline\"` 验证
  - 如输出类名未生效，检查：入口是否引入 `tailwind.css`；content globs 是否覆盖到文件
- 备选（A2: v4，npm）—如按官方简化路径接入
  - `npm i -D tailwindcss@latest`
  - 新建 `src/styles/tailwind.css`，写入（v4 推荐语法同样保留三指令或使用 `@import "tailwindcss";` 的简单入口）
  - 新建/编辑 `tailwind.config.js`（如需自定义主题）并设置 `content` globs
  - 在入口引入 `import './styles/tailwind.css'`
  - 备注: v4 的 PostCSS 需求与插件形态不同于 v3；如项目已有 PostCSS 流程，优先对齐官方迁移文档再启用插件
- 文档更新（不改动文件，仅提供动作清单）
  - 在项目运维文档加入：依赖版本、接入步骤、scripts、常见问题（如 preflight/第三方组件库冲突处理）

## Rollback
- 卸载依赖（按所选版本回滚）
  - A1 回滚: `npm rm tailwindcss postcss autoprefixer`；删除 `tailwind.config.js`、`postcss.config.js`、`src/styles/tailwind.css` 的新增文件
  - A2 回滚: `npm rm tailwindcss`；删除 `tailwind.config.js`（如创建）与 `src/styles/tailwind.css`
- 入口还原
  - 去除入口文件中的 `import './styles/tailwind.css'`
- 脚本还原
  - 如不再使用 Vite 脚本: `npm pkg delete scripts.dev scripts.build scripts.preview`
- 验证回滚
  - 清理缓存与锁文件（如产生）并重新安装依赖：`rm -f package-lock.json && rm -rf node_modules && npm i`，确认页面无 Tailwind 样式生效