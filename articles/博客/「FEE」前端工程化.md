## 工程化体系

- 前端工程化

  - 前端工程化 = 前端 + 软件工程
  - 前端工程化 = 将工程方法系统化地应用到前端开发中
  - 前端工程化 = 系统、严谨、可量化的方法开发、运营和维护前端应用程序
  - 前端工程化 = 基于业务诉求，梳理出最符合当前需要的架构设计
  - 软件工程：将工程方法系统化地软件工程应用到软件开发中
  - 工程方法：以系统、严谨、可量化的方法开发、运营和维护软件
  - 整个前端研发周期当中，我们可以干预的行为

- 前端工程化发展

  - 前后端分离：B/S 架构兴起，有了前后端之分
  - 模块化：随着前端复杂度上升，模块复用、实践规范重要性提升
  - 自动化：CI CD 研发平台，管理&简化前端开发过程，前端框架、自动化、构建系统应运而生
  - 智能化：AI 平台
  - 最佳实践：基于行业内最佳实践，开箱即用的框架（dva）、工具体系逐渐建立起来
  - 好、快、稳：依赖 vite、esm、wasm、低代码等能力

- 脚手架能力

  ![研发流程](https://image.jslog.net/online/a-46/2025/01/05/研发流程.png)

  - 通过更多的规范，约束开发人员研发流程
  - 狭义：命令行
  - 广义：约束
  - 准备阶段
    - 主要体现在项目初始化阶段
    - 技术选型
    - 代码规范
      - 分支管理规范
      - 项目初始资源规范
      - UI 规范
      - 物料市场规范
  - 开发阶段
    - 开发、打包流程
    - 本地 mock 服务
    - 代码质量
    - 单元测试&E2E 测试
  - 发布流程
    - git commit 规范
    - changeLog 规范
    - 打包构建
    - 部署、验收

- 体验度量

  - 定义一些指标，衡量当前系统是否好用
  - 埋点：用户行为统计
  - 性能：Performance API

- 研发效能流程

  ![规范流程](https://image.jslog.net/online/a-46/2025/01/05/规范流程.png)

  - 研发效能定义：团队能够持续地为用户产生有效价值的效率，包括有效性（Effectiveness）、效率（Efficiency）和可持续性（Sustainability）三个方面。简单来说，就是能否长期、高效地交付出有价值的产品

- 稳定性建设

  ![稳定性建设流程](https://image.jslog.net/online/a-46/2025/01/05/稳定性建设流程.png)

## npm 详解

- package.json

  ![package.json](https://image.jslog.net/online/a-46/2025/01/05/package.json.jpeg)

- 查看包版本：`npm view xxx`
- peerDependencies：用于指定你正在开发的模块所依赖的版本以及用户安装的依赖包版本的兼容性
- resolutions：锁包

- 版本升级
  - 升级补丁版本号：`npm version patch`
  - 升级次版本号：`npm version minor`
  - 升级主版本号：`npm version major`
  - 版本工具：semver

## 打包工具对比

- yarn npm 问题

  - 慢
  - 体积大
  - 扁平化（幽灵依赖）

- pnpm
  - 快
  - 体积小
  - 非扁平化
  - pnpm store（.pnpm）

## 前端仓库管理对比

- Multirepo
- Monorepo：nx、rushstack、turbopack、pnpm
