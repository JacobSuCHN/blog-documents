## 1.前后端知识图谱类比

![前后端知识图谱类比](https://image.jslog.net/online/a-25/2024/12/01/前后端知识图谱类比.svg)

- CICD
  - CICD是CI/CD的缩写，全称为“持续集成/持续交付”（Continuous Integration/Continuous Delivery）
    - 持续集成（CI）是指将多个开发者的代码变更集成到一个共享的主干（如代码仓库）中，并自动构建和测试这些变更的过程。这有助于发现和解决代码集成问题，保证代码质量和稳定性
    - 持续交付（CD）是指将CI的成果自动部署到生产环境或预生产环境中，使软件能够快速、可靠地交付给最终用户。CD包括持续部署、持续测试和持续监控等活动，以确保软件能够高效、准确地交付和运行
  - CICD的目标是提高软件交付的质量和效率，减少手动操作，缩短发布周期，降低风险和成本，并使开发团队能够更快地获得反馈和修复错误
  - 在软件行业，有许多CICD工具可供选择，例如：
    - 持续集成工具：Jenkins、Travis CI、CircleCI、GitLab CI等
    - 持续部署工具：Ansible、Puppet、Chef、SaltStack、AWS CodeDeploy等
    - 容器编排工具：Docker、Kubernetes、OpenShift等
    - 代码质量工具：SonarQube、Code Climate、Coverity、PMD等
    - 测试自动化工具：Selenium、Appium、TestComplete等
    - 监控工具：Nagios、Zabbix、ELK Stack等

## 2.后端学习内容概览

![内容概览](https://image.jslog.net/online/a-25/2024/12/01/内容概览.svg)

- RESTful API：也称为 RESTful Web 服务或 REST API；基于表示状态传输 (REST)，它是一种架构风格和经常用于 Web 服务开发的通信方法

  > [RESTful Web API 设计](https://learn.microsoft.com/zh-cn/azure/architecture/best-practices/api-design)
  >
  > [REST API 设计规范：最佳实践和示例](https://apifox.com/apiskills/rest-api-design-specification/)

## 3.编程范式

- FP：函数式编程
  - 确定的输入、输出
  - 引用透明，对IDE友好，易于理解
  - 主流vue/react的书写方式
- OOP：面向对象式编程
  - 抽象现实生活中的事务特征，对于理解友好
  - 封装性（高内聚低耦合）、继承性、多态性
  - Java、C#典型的面向对象式编程语言
- FRP：函数式响应编程
  - 适合需要对事件流进行复杂组合应用的场景
  - 响应式多在异步的场景
  - 典型案例：rxjs，广告推荐

## 4.面向切面编程AOP

- AOP特点
  - 扩展功能方便，不影响业务之间的逻辑
  - 逻辑集中管理
  - 更有利于代码复用

## 5.控制反转与依赖注入

- IoC：控制反转
  - 一种思想&设计模式
  - 一种面向对象编程的设计原则，用来减低计算机代码之间的耦合度；其基本思想是借助于”第三方“实现具有依赖关系的对象之间的解耦
- DI：依赖注入
  - IoC的具体实现
  - 一种IoC的设计模式，允许在类外创建依赖对象，并通过不同的方式将这些对象提供给类

## 6.MVC、DTO、DAO

- MVC：模型、试图、控制器

  ![MVC](https://image.jslog.net/online/a-25/2024/12/01/MVC.svg)

  - MVC是一种软件架构模式
  - Nestjs中的MVC
    - Nestjs通过模板库实现View层，常见：pug、hus、ejs等
    - Nestjs默认继承Express作为Web服务器，可以换成koa/fastify
    - Controller响应前端请求，Model是对应的具体数据库逻辑

- DTO：数据传输对象
  - 接受部分数据
  - 对数据进行筛选
  - 不对应实体
  - 属性小于等于实体
- DAO：数据访问对象
  - 对接数据库接口
  - 不暴露数据库内部信息
  - 对应实体

## 7.Nestjs核心概念

- Nestjs核心概念

  ![核心概念](https://image.jslog.net/online/a-25/2024/12/01/核心概念.svg)

  - Conreoller层负责处理请求、返回响应

  - Service层负责提供方法和操作，只包含业务逻辑

  - Data Access层负责方位数据库中的数据

- Nestjs生命周期

  ![生命周期](https://image.jslog.net/online/a-25/2024/12/01/生命周期.svg)

## 8.Nestjs用模块来组织代码

- Nestjs用模块来组织代码

  ![Modules_1](https://image.jslog.net/online/a-25/2024/12/01/Modules_1.png)

  - 使用Module来组织应用程序

  - @Modules装饰器来描述模块

  - 模块中有4大属性：imports，providers，controllers，exports

- 模块：功能模块、共享模块、全局模块、动态模块

  - 功能模块与共享模块是一回事
  - 全局模块通常应用在配置、数据库链接、日志上
  - 动态模块是在使用模块的时候才初始化