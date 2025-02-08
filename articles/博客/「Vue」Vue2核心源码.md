## 前置基础

- Flow：Flow 是 facebook 出品的 JavaScript 静态类型检查工具。Vue2 的源码利用了 Flow 做了静态类型检查，也就是文件顶部出现的`/* @flow */`

- 分析源码时，可以忽略环境变量判断（例：`process.env.NODE_ENV !== 'production'`）

- 数据驱动：Vue.js 一个核心思想是数据驱动

  - 指视图是由数据驱动生成的，即对视图的修改不会直接操作 DOM，而通过修改数据

  - 优势

    - 简化了代码量

    - 代码逻辑清晰，利于维护

  - Vue 采用模板语法来声明式的将数据渲染为 DOM

    ```html
    <div id="app">{{ message }}</div>
    ```

    ```js
    var app = new Vue({
      el: "#app",
      data: {
        message: "Hello Vue!",
      },
    });
    ```

    ```html
    <div id="app">Hello Vue!</div>
    ```

- VDOM

  - 浏览器的 DOM 标准非常复杂，频繁更新 DOM 会产生一定的性能问题

    ```js
    const div = document.createElement("div");
    let str = "";
    for (const key in div) str += key + " ";
    ```

  - Virtual DOM：用一个原生的 JS 对象去描述一个 DOM 节点

## 源码目录结构

```sh
vue
├── .circleci # ci配置
├── .github # github文件
├── benchmarks # 模板
├── dist
├── examples # 展示效果
├── flow  # 类型声明
│   ├── compiler.js # 编译相关
│   ├── component.js # 组件数据结构
│   ├── global-api.js # Global API 结构
│   ├── modules.js # 第三方库定义
│   ├── options.js # 选项相关
│   ├── ssr.js # 服务端渲染相关
│   ├── vnode.js # 虚拟 node 相关
│   └── weex.js
├── packages
│   ├── vue-server-renderer # 服务端渲染
│   ├── vue-template-compiler # 模板编译
│   ├── weex-template-compiler
│   └── weex-vue-framework
├── scripts # package.json scripts执行脚本
│   ├── git-hooks
│   ├── alias.js
│   ├── build.js
│   ├── config.js
│   ├── feature-flags.js
│   ├── gen-release-note.js
│   ├── get-weex-version.js
│   ├── release-weex.sh
│   ├── release.sh
│   └── verify-commit-msg.js
├── src
│   ├── compiler # 编译相关
│   ├── core # 核心代码
│   │   ├── components
│   │   ├── global-api
│   │   ├── instance
│   │   ├── observer
│   │   ├── util
│   │   ├── vdom
│   │   ├── config.js
│   │   └── index.js
│   ├── platforms # 不同平台的支持
│   │   ├── web
│   │   └── weex
│   ├── server # 服务端渲染
│   ├── sfc # .vue 文件解析
│   └── shared # 共享代码
├── test # 测试用例
├── types # 导出的类型声明
├── .babelrc.js
├── .editorconfig
├── .eslintignore
├── .eslintrc.js
├── .flowconfig # Flow 的配置文件
├── .gitignore
├── BACKERS.md
├── LICENSE
├── README.md
├── package.json
└── yarn.lock
```

- [vue/src/compiler](https://github.com/vuejs/vue/tree/2.6/src/compiler)
  - 包含 Vue.js 所有编译相关的代码
  - 功能：模板解析成 ast 语法树、ast 语法树优化、代码生成等
- [vue/src/core](https://github.com/vuejs/vue/tree/2.6/src/core)
  - 包含 Vue.js 的核心代码
  - 组成：内置组件、全局 API 封装，Vue 实例化、观察者、虚拟 DOM、工具函数等
- [vue/src/platform](https://github.com/vuejs/vue/tree/2.6/src/platform)
  - Vue.js 的入口
  - 2 个入口：分别打包成运行在 web 上和 weex 上的 Vue.js
- [vue/src/server](https://github.com/vuejs/vue/tree/2.6/src/server)
  - 包含服务端渲染相关的逻辑（Vue.js 2.0 支持服务端渲染）
- [vue/src/sfc](https://github.com/vuejs/vue/tree/2.6/src/sfc)
  - 功能：把 .vue 文件内容解析成一个 JavaScript 的对象
- [vue/src/shared](https://github.com/vuejs/vue/tree/2.6/src/shared)
  - 包含浏览器端的 Vue.js 和服务端的 Vue.js 共享的工具方法

## Vue 源码构建

- Vue.js 源码是基于 [Rollup](https://github.com/rollup/rollup) 构建的，它的构建相关配置都在 scripts 目录下

- [vue/package.json](https://github.com/vuejs/vue/blob/2.6/package.json)：构建脚本

  ```json
  "build": "node scripts/build.js",
  "build:ssr": "npm run build -- web-runtime-cjs,web-server-renderer",
  "build:weex": "npm run build -- weex",
  ```

  - `node scripts/build.js`：构建 Vue.js
  - `build:ssr`与`build:weex`是在`build`基础上添加环境参数

- [vue/scripts/build.js](https://github.com/vuejs/vue/blob/2.6/scripts/build.js#L7)

  ```js
  if (!fs.existsSync("dist")) {
    fs.mkdirSync("dist");
  }

  let builds = require("./config").getAllBuilds();

  // filter builds via command line arg
  if (process.argv[2]) {
    const filters = process.argv[2].split(",");
    builds = builds.filter((b) => {
      return filters.some(
        (f) => b.output.file.indexOf(f) > -1 || b._name.indexOf(f) > -1
      );
    });
  } else {
    // filter out weex builds by default
    builds = builds.filter((b) => {
      return b.output.file.indexOf("weex") === -1;
    });
  }

  build(builds);
  ```

  - 先从配置文件读取配置，再通过命令行参数对构建配置做过滤，由此构建出不同用途的 Vue.js

- [vue/scripts/config.js](https://github.com/vuejs/vue/blob/2.6/scripts/config.js#L38)

  ```js
  const builds = {
    // Runtime only (CommonJS). Used by bundlers e.g. Webpack & Browserify
    "web-runtime-cjs-dev": {
      entry: resolve("web/entry-runtime.js"),
      dest: resolve("dist/vue.runtime.common.dev.js"),
      format: "cjs",
      env: "development",
      banner,
    },
    "web-runtime-cjs-prod": {
      entry: resolve("web/entry-runtime.js"),
      dest: resolve("dist/vue.runtime.common.prod.js"),
      format: "cjs",
      env: "production",
      banner,
    },
    // Runtime+compiler CommonJS build (CommonJS)
    "web-full-cjs-dev": {
      entry: resolve("web/entry-runtime-with-compiler.js"),
      dest: resolve("dist/vue.common.dev.js"),
      format: "cjs",
      env: "development",
      alias: { he: "./entity-decoder" },
      banner,
    },
    "web-full-cjs-prod": {
      entry: resolve("web/entry-runtime-with-compiler.js"),
      dest: resolve("dist/vue.common.prod.js"),
      format: "cjs",
      env: "production",
      alias: { he: "./entity-decoder" },
      banner,
    },
    // Runtime only ES modules build (for bundlers)
    "web-runtime-esm": {
      entry: resolve("web/entry-runtime.js"),
      dest: resolve("dist/vue.runtime.esm.js"),
      format: "es",
      banner,
    },
    // Runtime+compiler ES modules build (for bundlers)
    "web-full-esm": {
      entry: resolve("web/entry-runtime-with-compiler.js"),
      dest: resolve("dist/vue.esm.js"),
      format: "es",
      alias: { he: "./entity-decoder" },
      banner,
    },
    // Runtime+compiler ES modules build (for direct import in browser)
    "web-full-esm-browser-dev": {
      entry: resolve("web/entry-runtime-with-compiler.js"),
      dest: resolve("dist/vue.esm.browser.js"),
      format: "es",
      transpile: false,
      env: "development",
      alias: { he: "./entity-decoder" },
      banner,
    },
    // Runtime+compiler ES modules build (for direct import in browser)
    "web-full-esm-browser-prod": {
      entry: resolve("web/entry-runtime-with-compiler.js"),
      dest: resolve("dist/vue.esm.browser.min.js"),
      format: "es",
      transpile: false,
      env: "production",
      alias: { he: "./entity-decoder" },
      banner,
    },
    // runtime-only build (Browser)
    "web-runtime-dev": {
      entry: resolve("web/entry-runtime.js"),
      dest: resolve("dist/vue.runtime.js"),
      format: "umd",
      env: "development",
      banner,
    },
    // runtime-only production build (Browser)
    "web-runtime-prod": {
      entry: resolve("web/entry-runtime.js"),
      dest: resolve("dist/vue.runtime.min.js"),
      format: "umd",
      env: "production",
      banner,
    },
    // Runtime+compiler development build (Browser)
    "web-full-dev": {
      entry: resolve("web/entry-runtime-with-compiler.js"),
      dest: resolve("dist/vue.js"),
      format: "umd",
      env: "development",
      alias: { he: "./entity-decoder" },
      banner,
    },
    // Runtime+compiler production build  (Browser)
    "web-full-prod": {
      entry: resolve("web/entry-runtime-with-compiler.js"),
      dest: resolve("dist/vue.min.js"),
      format: "umd",
      env: "production",
      alias: { he: "./entity-decoder" },
      banner,
    },
    // Web compiler (CommonJS).
    "web-compiler": {
      entry: resolve("web/entry-compiler.js"),
      dest: resolve("packages/vue-template-compiler/build.js"),
      format: "cjs",
      external: Object.keys(
        require("../packages/vue-template-compiler/package.json").dependencies
      ),
    },
    // Web compiler (UMD for in-browser use).
    "web-compiler-browser": {
      entry: resolve("web/entry-compiler.js"),
      dest: resolve("packages/vue-template-compiler/browser.js"),
      format: "umd",
      env: "development",
      moduleName: "VueTemplateCompiler",
      plugins: [node(), cjs()],
    },
    // Web server renderer (CommonJS).
    "web-server-renderer-dev": {
      entry: resolve("web/entry-server-renderer.js"),
      dest: resolve("packages/vue-server-renderer/build.dev.js"),
      format: "cjs",
      env: "development",
      external: Object.keys(
        require("../packages/vue-server-renderer/package.json").dependencies
      ),
    },
    "web-server-renderer-prod": {
      entry: resolve("web/entry-server-renderer.js"),
      dest: resolve("packages/vue-server-renderer/build.prod.js"),
      format: "cjs",
      env: "production",
      external: Object.keys(
        require("../packages/vue-server-renderer/package.json").dependencies
      ),
    },
    "web-server-renderer-basic": {
      entry: resolve("web/entry-server-basic-renderer.js"),
      dest: resolve("packages/vue-server-renderer/basic.js"),
      format: "umd",
      env: "development",
      moduleName: "renderVueComponentToString",
      plugins: [node(), cjs()],
    },
    "web-server-renderer-webpack-server-plugin": {
      entry: resolve("server/webpack-plugin/server.js"),
      dest: resolve("packages/vue-server-renderer/server-plugin.js"),
      format: "cjs",
      external: Object.keys(
        require("../packages/vue-server-renderer/package.json").dependencies
      ),
    },
    "web-server-renderer-webpack-client-plugin": {
      entry: resolve("server/webpack-plugin/client.js"),
      dest: resolve("packages/vue-server-renderer/client-plugin.js"),
      format: "cjs",
      external: Object.keys(
        require("../packages/vue-server-renderer/package.json").dependencies
      ),
    },
    // Weex runtime factory
    "weex-factory": {
      weex: true,
      entry: resolve("weex/entry-runtime-factory.js"),
      dest: resolve("packages/weex-vue-framework/factory.js"),
      format: "cjs",
      plugins: [weexFactoryPlugin],
    },
    // Weex runtime framework (CommonJS).
    "weex-framework": {
      weex: true,
      entry: resolve("weex/entry-framework.js"),
      dest: resolve("packages/weex-vue-framework/index.js"),
      format: "cjs",
    },
    // Weex compiler (CommonJS). Used by Weex's Webpack loader.
    "weex-compiler": {
      weex: true,
      entry: resolve("weex/entry-compiler.js"),
      dest: resolve("packages/weex-template-compiler/build.js"),
      format: "cjs",
      external: Object.keys(
        require("../packages/weex-template-compiler/package.json").dependencies
      ),
    },
  };
  ```

  - `builds`对象列举了 Vue.js 构建的配置（遵循 Rollup 构建规则）

    - `entry`：构建的入口 JS 文件地址
    - `dest`：构建后的 JS 文件地址
    - `format`：构建的格式（cjs、es、umd）

  - 以 `web-runtime-cjs-dev`配置为例，它的 entry 是 `resolve('web/entry-runtime.js')`

    - [vue/scripts/config.js](https://github.com/vuejs/vue/blob/2.6/scripts/config.js#L28)

      ```js
      const aliases = require("./alias");
      const resolve = (p) => {
        const base = p.split("/")[0];
        if (aliases[base]) {
          return path.resolve(aliases[base], p.slice(base.length + 1));
        } else {
          return path.resolve(__dirname, "../", p);
        }
      };
      ```

      - resolve 函数：参数 p 通过 / 分割成数组，取数组第一个元素设为 base
        - 在此例中，参数 p 是 web/entry-runtime.js，那么 base 则为 web
        - base 并不是真实路径，其借助了别名

    - [vue/scripts/alias](https://github.com/vuejs/vue/blob/2.6/scripts/alias#L1)

      ```js
      const path = require("path");

      const resolve = (p) => path.resolve(__dirname, "../", p);

      module.exports = {
        vue: resolve("src/platforms/web/entry-runtime-with-compiler"),
        compiler: resolve("src/compiler"),
        core: resolve("src/core"),
        shared: resolve("src/shared"),
        web: resolve("src/platforms/web"),
        weex: resolve("src/platforms/weex"),
        server: resolve("src/server"),
        sfc: resolve("src/sfc"),
      };
      ```

      - aliases[base] = path.resolve(\_\_dirname, '../src/platforms/web')

    - `resolve('web/entry-runtime.js')`返回的路径为`vue/src/platforms/web/entry-runtime.js`

    - `web-runtime-cjs-dev` 配置对应的入口文件就找到了，它经过 Rollup 的构建打包后，最终会在 dist 目录下生成 `dist/vue.runtime.common.dev.js`

- Runtime Only VS Runtime + Compiler

  - `Runtime Only`：需要借助 webpack 的 `vue-loader`加载器 把`.vue`文件编译成 js（性能更好）

  - `Runtime + Compiler`：运行时直接编译成 render 函数

    ```js
    // 需要编译器的版本
    new Vue({
      template: "<div>{{ hi }}</div>",
    });
    
    // 这种情况不需要
    new Vue({
      render(h) {
        return h("div", this.hi);
      },
    });
    ```

## Vue 入口

- 以`Runtime-Only`构建出来的 Vue.js，它的入口是[vue/src/platforms/web/entry-runtime.js](https://github.com/vuejs/vue/blob/2.6/src/platforms/web/entry-runtime.js#L1)

  ```js
  /* @flow */

  import Vue from "./runtime/index";

  export default Vue;
  ```

- `import Vue from 'vue'`：从这个入口执行代码来初始化 Vue，Vue 来源为`import Vue from './runtime/index'`，入口在[vue/src/platforms/web/runtime/index.js](https://github.com/vuejs/vue/blob/2.6/src/platforms/web/runtime/index.js)

- [vue/src/platforms/web/runtime/index.js](https://github.com/vuejs/vue/blob/2.6/src/platforms/web/runtime/index.js)

  ```js
  /* @flow */

  import Vue from "core/index";
  import config from "core/config";
  import { extend, noop } from "shared/util";
  import { mountComponent } from "core/instance/lifecycle";
  import { devtools, inBrowser } from "core/util/index";

  import {
    query,
    mustUseProp,
    isReservedTag,
    isReservedAttr,
    getTagNamespace,
    isUnknownElement,
  } from "web/util/index";

  import { patch } from "./patch";
  import platformDirectives from "./directives/index";
  import platformComponents from "./components/index";

  // install platform specific utils
  Vue.config.mustUseProp = mustUseProp;
  Vue.config.isReservedTag = isReservedTag;
  Vue.config.isReservedAttr = isReservedAttr;
  Vue.config.getTagNamespace = getTagNamespace;
  Vue.config.isUnknownElement = isUnknownElement;

  // install platform runtime directives & components
  extend(Vue.options.directives, platformDirectives);
  extend(Vue.options.components, platformComponents);

  // install platform patch function
  Vue.prototype.__patch__ = inBrowser ? patch : noop;

  // public mount method
  Vue.prototype.$mount = function (
    el?: string | Element,
    hydrating?: boolean
  ): Component {
    el = el && inBrowser ? query(el) : undefined;
    return mountComponent(this, el, hydrating);
  };

  // devtools global hook
  /* istanbul ignore next */
  if (inBrowser) {
    setTimeout(() => {
      if (config.devtools) {
        if (devtools) {
          devtools.emit("init", Vue);
        } else if (
          process.env.NODE_ENV !== "production" &&
          process.env.NODE_ENV !== "test"
        ) {
          console[console.info ? "info" : "log"](
            "Download the Vue Devtools extension for a better development experience:\n" +
              "https://github.com/vuejs/vue-devtools"
          );
        }
      }
      if (
        process.env.NODE_ENV !== "production" &&
        process.env.NODE_ENV !== "test" &&
        config.productionTip !== false &&
        typeof console !== "undefined"
      ) {
        console[console.info ? "info" : "log"](
          `You are running Vue in development mode.\n` +
            `Make sure to turn on production mode when deploying for production.\n` +
            `See more tips at https://vuejs.org/guide/deployment.html`
        );
      }
    }, 0);
  }

  export default Vue;
  ```

  - `import Vue from 'core/index'`：入口为[vue/src/core/index.js](https://github.com/vuejs/vue/blob/2.6/src/core/index.js)

  - 此处 core 设置了别名，由[vue/.flowconfig](https://github.com/vuejs/vue/blob/2.6/.flowconfig)配置

    ```ini
    [ignore]
    .*/node_modules/.*
    .*/test/.*
    .*/scripts/.*
    .*/examples/.*
    .*/benchmarks/.*
  
    [include]
  
    [libs]
    flow
  
    [options]
    unsafe.enable_getters_and_setters=true
    module.name_mapper='^compiler/\(.*\)$' -> '<PROJECT_ROOT>/src/compiler/\1'
    module.name_mapper='^core/\(.*\)$' -> '<PROJECT_ROOT>/src/core/\1'
    module.name_mapper='^shared/\(.*\)$' -> '<PROJECT_ROOT>/src/shared/\1'
    module.name_mapper='^web/\(.*\)$' -> '<PROJECT_ROOT>/src/platforms/web/\1'
    module.name_mapper='^weex/\(.*\)$' -> '<PROJECT_ROOT>/src/platforms/weex/\1'
    module.name_mapper='^server/\(.*\)$' -> '<PROJECT_ROOT>/src/server/\1'
    module.name_mapper='^entries/\(.*\)$' -> '<PROJECT_ROOT>/src/entries/\1'
    module.name_mapper='^sfc/\(.*\)$' -> '<PROJECT_ROOT>/src/sfc/\1'
    suppress_comment= \\(.\\|\n\\)*\\$flow-disable-line
    ```

- [vue/src/core/index.js](https://github.com/vuejs/vue/blob/2.6/src/core/index.js)

  ```js
  import Vue from "./instance/index";
  import { initGlobalAPI } from "./global-api/index";
  import { isServerRendering } from "core/util/env";
  import { FunctionalRenderContext } from "core/vdom/create-functional-component";
  
  initGlobalAPI(Vue);
  
  Object.defineProperty(Vue.prototype, "$isServer", {
    get: isServerRendering,
  });
  
  Object.defineProperty(Vue.prototype, "$ssrContext", {
    get() {
      /* istanbul ignore next */
      return this.$vnode && this.$vnode.ssrContext;
    },
  });
  
  // expose FunctionalRenderContext for ssr runtime helper installation
  Object.defineProperty(Vue, "FunctionalRenderContext", {
    value: FunctionalRenderContext,
  });
  
  Vue.version = "__VERSION__";
  
  export default Vue;
  ```

  - `import Vue from './instance/index'`：引入了 Vue，入口为[vue/src/core/instance/index.js](https://github.com/vuejs/vue/blob/2.6/src/core/instance/index.js)
  - `initGlobalAPI(Vue)`：初始化全局 Vue API

## Vue

- [vue/src/core/instance/index.js](https://github.com/vuejs/vue/blob/2.6/src/core/instance/index.js)

  ```js
  import { initMixin } from "./init";
  import { stateMixin } from "./state";
  import { renderMixin } from "./render";
  import { eventsMixin } from "./events";
  import { lifecycleMixin } from "./lifecycle";
  import { warn } from "../util/index";

  function Vue(options) {
    if (process.env.NODE_ENV !== "production" && !(this instanceof Vue)) {
      warn("Vue is a constructor and should be called with the `new` keyword");
    }
    this._init(options);
  }

  initMixin(Vue);
  stateMixin(Vue);
  eventsMixin(Vue);
  lifecycleMixin(Vue);
  renderMixin(Vue);

  export default Vue;
  ```

- `Vue`实际上就是一个用 `Function`实现的类

- 为何 `Vue`不用 ES6 的 `Class`去实现呢？

  - `xxxMixin(Vue)`：`Vue`当参数传入，为`Vue`的`prototype`上扩展方法
  - Vue 按功能把这些扩展分散到多个模块中去实现，而不是在一个模块里实现所有，这种方式是用`Class 难以实现的
  - 非常方便代码的维护和管理

## initGlobalAPI

- `initGlobalAPI(Vue)`中`initGlobalAPI`来源于[vue\src\core\global-api\index.js](https://github.com/vuejs/vue/blob/2.6/src\core\global-api\index.js)

  ```js
  /* @flow */
  
  import config from "../config";
  import { initUse } from "./use";
  import { initMixin } from "./mixin";
  import { initExtend } from "./extend";
  import { initAssetRegisters } from "./assets";
  import { set, del } from "../observer/index";
  import { ASSET_TYPES } from "shared/constants";
  import builtInComponents from "../components/index";
  import { observe } from "core/observer/index";
  
  import {
    warn,
    extend,
    nextTick,
    mergeOptions,
    defineReactive,
  } from "../util/index";
  
  export function initGlobalAPI(Vue: GlobalAPI) {
    // config
    const configDef = {};
    configDef.get = () => config;
    if (process.env.NODE_ENV !== "production") {
      configDef.set = () => {
        warn(
          "Do not replace the Vue.config object, set individual fields instead."
        );
      };
    }
    Object.defineProperty(Vue, "config", configDef);
  
    // exposed util methods.
    // NOTE: these are not considered part of the public API - avoid relying on
    // them unless you are aware of the risk.
    Vue.util = {
      warn,
      extend,
      mergeOptions,
      defineReactive,
    };
  
    Vue.set = set;
    Vue.delete = del;
    Vue.nextTick = nextTick;
  
    // 2.6 explicit observable API
    Vue.observable = <T>(obj: T): T => {
      observe(obj);
      return obj;
    };
  
    Vue.options = Object.create(null);
    ASSET_TYPES.forEach((type) => {
      Vue.options[type + "s"] = Object.create(null);
    });
  
    // this is used to identify the "base" constructor to extend all plain-object
    // components with in Weex's multi-instance scenarios.
    Vue.options._base = Vue;
  
    extend(Vue.options.components, builtInComponents);
  
    initUse(Vue);
    initMixin(Vue);
    initExtend(Vue);
    initAssetRegisters(Vue);
  }
  ```

  - 在 Vue 上扩展一些全局方法的定义
  - 注意：`Vue.util`暴露的方法最好不要依赖，因为它可能经常会发生变化，是不稳定的

## new Vue

- [vue/src/core/instance/index.js](https://github.com/vuejs/vue/blob/2.6/src/core/instance/index.js#L8)

  ```js
  function Vue(options) {
    if (process.env.NODE_ENV !== "production" && !(this instanceof Vue)) {
      warn("Vue is a constructor and should be called with the `new` keyword");
    }
    this._init(options);
  }
  ```

  - Vue 通过 new 关键字初始化后调用 `this._init` 方法

## \_init

- `_init`该方法在`initMixin(Vue)`时注入到 `prototype`上，在 [vue/src/core/instance/init.js](https://github.com/vuejs/vue/blob/2.6/src/core/instance/init.js)中定义

  ```js
  export function initMixin(Vue: Class<Component>) {
    Vue.prototype._init = function (options?: Object) {
      const vm: Component = this;
      // a uid
      vm._uid = uid++;

      let startTag, endTag;
      /* istanbul ignore if */
      if (process.env.NODE_ENV !== "production" && config.performance && mark) {
        startTag = `vue-perf-start:${vm._uid}`;
        endTag = `vue-perf-end:${vm._uid}`;
        mark(startTag);
      }

      // a flag to avoid this being observed
      vm._isVue = true;
      // merge options
      if (options && options._isComponent) {
        // optimize internal component instantiation
        // since dynamic options merging is pretty slow, and none of the
        // internal component options needs special treatment.
        initInternalComponent(vm, options);
      } else {
        vm.$options = mergeOptions(
          resolveConstructorOptions(vm.constructor),
          options || {},
          vm
        );
      }
      /* istanbul ignore else */
      if (process.env.NODE_ENV !== "production") {
        initProxy(vm);
      } else {
        vm._renderProxy = vm;
      }
      // expose real self
      vm._self = vm;
      initLifecycle(vm);
      initEvents(vm);
      initRender(vm);
      callHook(vm, "beforeCreate");
      initInjections(vm); // resolve injections before data/props
      initState(vm);
      initProvide(vm); // resolve provide after data/props
      callHook(vm, "created");

      /* istanbul ignore if */
      if (process.env.NODE_ENV !== "production" && config.performance && mark) {
        vm._name = formatComponentName(vm, false);
        mark(endTag);
        measure(`vue ${vm._name} init`, startTag, endTag);
      }

      if (vm.$options.el) {
        vm.$mount(vm.$options.el);
      }
    };
  }
  ```

- Vue 初始化：合并配置，初始化生命周期，初始化事件中心，初始化渲染，初始化 `data`、`props`、`computed`、`watcher`等

- 在初始化的最后，检测`vm.$options`到如果有 `el` 属性，则调用 `vm.$mount`方法挂载 `vm`，挂载的目标就是把模板渲染成最终的 DOM

## $mount

- Vue 中通过`$mount` 实例方法挂载 `vm`，`$mount` 方法在多个文件中都有定义（`$mount` 的实现是和平台、构建方式都相关）

  - [vue/src/platforms/web/entry-runtime-with-compiler.js](https://github.com/vuejs/vue/blob/2.6/src/platforms/web/entry-runtime-with-compiler.js)
  - [vue/src/platforms/web/runtime/index.js](https://github.com/vuejs/vue/blob/2.6/src/platforms/web/runtime/index.js)
  - [vue/src/platforms/weex/runtime/index.js](https://github.com/vuejs/vue/blob/2.6/src/platforms/weex/runtime/index.js)

- [vue/src/platforms/web/entry-runtime-with-compiler.js](https://github.com/vuejs/vue/blob/2.6/src/platforms/web/entry-runtime-with-compiler.js#L17)

  ```js
  const mount = Vue.prototype.$mount;
  Vue.prototype.$mount = function (
    el?: string | Element,
    hydrating?: boolean
  ): Component {
    el = el && query(el);

    /* istanbul ignore if */
    if (el === document.body || el === document.documentElement) {
      process.env.NODE_ENV !== "production" &&
        warn(
          `Do not mount Vue to <html> or <body> - mount to normal elements instead.`
        );
      return this;
    }

    const options = this.$options;
    // resolve template/el and convert to render function
    if (!options.render) {
      let template = options.template;
      if (template) {
        if (typeof template === "string") {
          if (template.charAt(0) === "#") {
            template = idToTemplate(template);
            /* istanbul ignore if */
            if (process.env.NODE_ENV !== "production" && !template) {
              warn(
                `Template element not found or is empty: ${options.template}`,
                this
              );
            }
          }
        } else if (template.nodeType) {
          template = template.innerHTML;
        } else {
          if (process.env.NODE_ENV !== "production") {
            warn("invalid template option:" + template, this);
          }
          return this;
        }
      } else if (el) {
        template = getOuterHTML(el);
      }
      if (template) {
        /* istanbul ignore if */
        if (
          process.env.NODE_ENV !== "production" &&
          config.performance &&
          mark
        ) {
          mark("compile");
        }

        const { render, staticRenderFns } = compileToFunctions(
          template,
          {
            outputSourceRange: process.env.NODE_ENV !== "production",
            shouldDecodeNewlines,
            shouldDecodeNewlinesForHref,
            delimiters: options.delimiters,
            comments: options.comments,
          },
          this
        );
        options.render = render;
        options.staticRenderFns = staticRenderFns;

        /* istanbul ignore if */
        if (
          process.env.NODE_ENV !== "production" &&
          config.performance &&
          mark
        ) {
          mark("compile end");
          measure(`vue ${this._name} compile`, "compile", "compile end");
        }
      }
    }
    return mount.call(this, el, hydrating);
  };
  ```

  - 缓存原型上的` $mount`方法，再重新定义该方法

  - 限制 `el` 不能挂载在 `body`、`html` 根节点上

  - 如果没有定义 `render`方法，则会把 `el` 或者 `template`字符串转换成 `render`方法

    > 在 Vue 2.0 版本中，所有 Vue 的组件的渲染最终都需要 render 方法
    >
    > 无论用单文件 .vue 方式开发，还是编写 el 或者 template 属性，最终都会转换成 render 方法

  - 根据生成的 `template`函数，执行在线编译的过程，调用 `compileToFunctions` 方法

  - 最后，调用原先原型上的 `$mount` 方法挂载

- 原先原型上的 `$mount` 方法在[vue/src/platforms/web/runtime/index.js](https://github.com/vuejs/vue/blob/2.6/src/platforms/web/runtime/index.js#L36)中定义

  > 之所以这么设计完全是为了复用，因为它是可以被`Runtime Only`版本的 Vue 直接使用的

  ```js
  // public mount method
  Vue.prototype.$mount = function (
    el?: string | Element,
    hydrating?: boolean
  ): Component {
    el = el && inBrowser ? query(el) : undefined;
    return mountComponent(this, el, hydrating);
  };
  ```

  - `$mount` 方法支持传入 2 个参数
  - `el`：表示挂载的元素，可以是字符串，也可以是 DOM 对象，如果是字符串在浏览器环境下会调用 query 方法转换成 DOM 对象
  - `hydrating`：和服务端渲染相关，在浏览器环境下不需要传第二个参数
  - `$mount` 方法实际上会去调用 `mountComponent`方法，定义在[vue/src/core/instance/lifecycle.js](https://github.com/vuejs/vue/blob/2.6/src/core/instance/lifecycle.js)

- [vue/src/core/instance/lifecycle.js](https://github.com/vuejs/vue/blob/2.6/src/core/instance/lifecycle.js#L141)

  ```js
  export function mountComponent(
    vm: Component,
    el: ?Element,
    hydrating?: boolean
  ): Component {
    vm.$el = el;
    if (!vm.$options.render) {
      vm.$options.render = createEmptyVNode;
      if (process.env.NODE_ENV !== "production") {
        /* istanbul ignore if */
        if (
          (vm.$options.template && vm.$options.template.charAt(0) !== "#") ||
          vm.$options.el ||
          el
        ) {
          warn(
            "You are using the runtime-only build of Vue where the template " +
              "compiler is not available. Either pre-compile the templates into " +
              "render functions, or use the compiler-included build.",
            vm
          );
        } else {
          warn(
            "Failed to mount component: template or render function not defined.",
            vm
          );
        }
      }
    }
    callHook(vm, "beforeMount");
  
    let updateComponent;
    /* istanbul ignore if */
    if (process.env.NODE_ENV !== "production" && config.performance && mark) {
      updateComponent = () => {
        const name = vm._name;
        const id = vm._uid;
        const startTag = `vue-perf-start:${id}`;
        const endTag = `vue-perf-end:${id}`;
  
        mark(startTag);
        const vnode = vm._render();
        mark(endTag);
        measure(`vue ${name} render`, startTag, endTag);
  
        mark(startTag);
        vm._update(vnode, hydrating);
        mark(endTag);
        measure(`vue ${name} patch`, startTag, endTag);
      };
    } else {
      updateComponent = () => {
        vm._update(vm._render(), hydrating);
      };
    }
  
    // we set this to vm._watcher inside the watcher's constructor
    // since the watcher's initial patch may call $forceUpdate (e.g. inside child
    // component's mounted hook), which relies on vm._watcher being already defined
    new Watcher(
      vm,
      updateComponent,
      noop,
      {
        before() {
          if (vm._isMounted && !vm._isDestroyed) {
            callHook(vm, "beforeUpdate");
          }
        },
      },
      true /* isRenderWatcher */
    );
    hydrating = false;
  
    // manually mounted instance, call mounted on self
    // mounted is called for render-created child components in its inserted hook
    if (vm.$vnode == null) {
      vm._isMounted = true;
      callHook(vm, "mounted");
    }
    return vm;
  }
  ```

  - 核心：先实例化一个渲染`Watcher`，在它的回调函数中调用 `updateComponent` 方法，在此方法中调用 `vm._render` 方法先生成虚拟 Node，最终调用 `vm._update` 更新 DOM
  - `Watcher`作用
    - 初始化的时候会执行回调函数
    - 当 `vm` 实例中监测数据发生变化时执行回调函数
  - 函数最后判断当根节点 `vm.$vnode` 为 `null`时，执行 `mount`初始化

## render

- Vue 的 `_render` 方法是实例的一个私有方法，它用来把实例渲染成一个虚拟 Node，它定义在 [vue/src/core/instance/render.js](https://github.com/vuejs/vue/blob/2.6/src/core/instance/render.js)中

- 在[vue/src/core/instance/render.js](https://github.com/vuejs/vue/blob/2.6/src/core/instance/render.js#L69)中，执行`renderMixin`，注入到`Vue.prototype`上

  ```js
  Vue.prototype._render = function (): VNode {
    const vm: Component = this;
    const { render, _parentVnode } = vm.$options;

    if (_parentVnode) {
      vm.$scopedSlots = normalizeScopedSlots(
        _parentVnode.data.scopedSlots,
        vm.$slots,
        vm.$scopedSlots
      );
    }

    // set parent vnode. this allows render functions to have access
    // to the data on the placeholder node.
    vm.$vnode = _parentVnode;
    // render self
    let vnode;
    try {
      // There's no need to maintain a stack because all render fns are called
      // separately from one another. Nested component's render fns are called
      // when parent component is patched.
      currentRenderingInstance = vm;
      vnode = render.call(vm._renderProxy, vm.$createElement);
    } catch (e) {
      handleError(e, vm, `render`);
      // return error render result,
      // or previous vnode to prevent render error causing blank component
      /* istanbul ignore else */
      if (process.env.NODE_ENV !== "production" && vm.$options.renderError) {
        try {
          vnode = vm.$options.renderError.call(
            vm._renderProxy,
            vm.$createElement,
            e
          );
        } catch (e) {
          handleError(e, vm, `renderError`);
          vnode = vm._vnode;
        }
      } else {
        vnode = vm._vnode;
      }
    } finally {
      currentRenderingInstance = null;
    }
    // if the returned array contains only a single node, allow it
    if (Array.isArray(vnode) && vnode.length === 1) {
      vnode = vnode[0];
    }
    // return empty vnode in case the render function errored out
    if (!(vnode instanceof VNode)) {
      if (process.env.NODE_ENV !== "production" && Array.isArray(vnode)) {
        warn(
          "Multiple root nodes returned from render function. Render function " +
            "should return a single root node.",
          vm
        );
      }
      vnode = createEmptyVNode();
    }
    // set parent
    vnode.parent = _parentVnode;
    return vnode;
  };
  ```

  - 最关键的是 `render`方法的调用，在之前的 `mounte`方法的实现中，会把 `template`编译成 `render`方法

  - `vnode = render.call(vm._renderProxy, vm.$createElement);`

    - `render`函数中的 `createElement`方法就是 `vm.$createElement` 方法

    - `vm.$createElement`的方法在`initRender`（[vue/src/core/instance/render.js](https://github.com/vuejs/vue/blob/2.6/src/core/instance/render.js#L19)）中定义

      ```js
      export function initRender(vm: Component) {
        vm._vnode = null; // the root of the child tree
        vm._staticTrees = null; // v-once cached trees
        const options = vm.$options;
        const parentVnode = (vm.$vnode = options._parentVnode); // the placeholder node in parent tree
        const renderContext = parentVnode && parentVnode.context;
        vm.$slots = resolveSlots(options._renderChildren, renderContext);
        vm.$scopedSlots = emptyObject;
        // bind the createElement fn to this instance
        // so that we get proper render context inside it.
        // args order: tag, data, children, normalizationType, alwaysNormalize
        // internal version is used by render functions compiled from templates
        vm._c = (a, b, c, d) => createElement(vm, a, b, c, d, false);
        // normalization is always applied for the public version, used in
        // user-written render functions.
        vm.$createElement = (a, b, c, d) => createElement(vm, a, b, c, d, true);

        // $attrs & $listeners are exposed for easier HOC creation.
        // they need to be reactive so that HOCs using them are always updated
        const parentData = parentVnode && parentVnode.data;

        /* istanbul ignore else */
        if (process.env.NODE_ENV !== "production") {
          defineReactive(
            vm,
            "$attrs",
            (parentData && parentData.attrs) || emptyObject,
            () => {
              !isUpdatingChildComponent && warn(`$attrs is readonly.`, vm);
            },
            true
          );
          defineReactive(
            vm,
            "$listeners",
            options._parentListeners || emptyObject,
            () => {
              !isUpdatingChildComponent && warn(`$listeners is readonly.`, vm);
            },
            true
          );
        } else {
          defineReactive(
            vm,
            "$attrs",
            (parentData && parentData.attrs) || emptyObject,
            null,
            true
          );
          defineReactive(
            vm,
            "$listeners",
            options._parentListeners || emptyObject,
            null,
            true
          );
        }
      }
      ```

    - `vm.$createElement`和`vm._c`均调用了`createElement`，`createElement`是创建 `VNode` 的核心方法

    - `vm._c` 在编译生成的 `render` 函数中调用

    - `vm.$createElement` 则用于用户自定义 `render` 函数

      ```js
      render: function (createElement) {
        return createElement('div', {
           attrs: {
              id: 'app'
            },
        }, this.message)
      }
      ```

- VDOM：在 Vue.js 中，Virtual DOM 是用 `VNode`这么一个 `Class`去描述，它定义在 [vue/src/core/vdom/vnode.js](https://github.com/vuejs/vue/blob/2.6/src/core/vdom/vnode.js#L3)

  ```js
  export default class VNode {
    tag: string | void;
    data: VNodeData | void;
    children: ?Array<VNode>;
    text: string | void;
    elm: Node | void;
    ns: string | void;
    context: Component | void; // rendered in this component's scope
    key: string | number | void;
    componentOptions: VNodeComponentOptions | void;
    componentInstance: Component | void; // component instance
    parent: VNode | void; // component placeholder node
  
    // strictly internal
    raw: boolean; // contains raw HTML? (server only)
    isStatic: boolean; // hoisted static node
    isRootInsert: boolean; // necessary for enter transition check
    isComment: boolean; // empty comment placeholder?
    isCloned: boolean; // is a cloned node?
    isOnce: boolean; // is a v-once node?
    asyncFactory: Function | void; // async component factory function
    asyncMeta: Object | void;
    isAsyncPlaceholder: boolean;
    ssrContext: Object | void;
    fnContext: Component | void; // real context vm for functional nodes
    fnOptions: ?ComponentOptions; // for SSR caching
    devtoolsMeta: ?Object; // used to store functional render context for devtools
    fnScopeId: ?string; // functional scope id support
  
    constructor(
      tag?: string,
      data?: VNodeData,
      children?: ?Array<VNode>,
      text?: string,
      elm?: Node,
      context?: Component,
      componentOptions?: VNodeComponentOptions,
      asyncFactory?: Function
    ) {
      this.tag = tag;
      this.data = data;
      this.children = children;
      this.text = text;
      this.elm = elm;
      this.ns = undefined;
      this.context = context;
      this.fnContext = undefined;
      this.fnOptions = undefined;
      this.fnScopeId = undefined;
      this.key = data && data.key;
      this.componentOptions = componentOptions;
      this.componentInstance = undefined;
      this.parent = undefined;
      this.raw = false;
      this.isStatic = false;
      this.isRootInsert = true;
      this.isComment = false;
      this.isCloned = false;
      this.isOnce = false;
      this.asyncFactory = asyncFactory;
      this.asyncMeta = undefined;
      this.isAsyncPlaceholder = false;
    }
  
    // DEPRECATED: alias for componentInstance for backwards compat.
    /* istanbul ignore next */
    get child(): Component | void {
      return this.componentInstance;
    }
  }
  ```

  - 实际上 Vue.js 中 Virtual DOM 是借鉴了一个开源库 [snabbdom](https://github.com/snabbdom/snabbdom) 的实现，然后加入了一些 Vue.js 本身的东西

## createElement

- Vue.js 利用 `createElement`方法创建 `VNode`，它定义在[vue/src/core/vdom/create-element.js](https://github.com/vuejs/vue/blob/2.6/src/core/vdom/create-element.js#L26)

  ```js
  // wrapper function for providing a more flexible interface
  // without getting yelled at by flow
  export function createElement(
    context: Component,
    tag: any,
    data: any,
    children: any,
    normalizationType: any,
    alwaysNormalize: boolean
  ): VNode | Array<VNode> {
    if (Array.isArray(data) || isPrimitive(data)) {
      normalizationType = children;
      children = data;
      data = undefined;
    }
    if (isTrue(alwaysNormalize)) {
      normalizationType = ALWAYS_NORMALIZE;
    }
    return _createElement(context, tag, data, children, normalizationType);
  }

  export function _createElement(
    context: Component,
    tag?: string | Class<Component> | Function | Object,
    data?: VNodeData,
    children?: any,
    normalizationType?: number
  ): VNode | Array<VNode> {
    if (isDef(data) && isDef((data: any).__ob__)) {
      process.env.NODE_ENV !== "production" &&
        warn(
          `Avoid using observed data object as vnode data: ${JSON.stringify(
            data
          )}\n` + "Always create fresh vnode data objects in each render!",
          context
        );
      return createEmptyVNode();
    }
    // object syntax in v-bind
    if (isDef(data) && isDef(data.is)) {
      tag = data.is;
    }
    if (!tag) {
      // in case of component :is set to falsy value
      return createEmptyVNode();
    }
    // warn against non-primitive key
    if (
      process.env.NODE_ENV !== "production" &&
      isDef(data) &&
      isDef(data.key) &&
      !isPrimitive(data.key)
    ) {
      if (!__WEEX__ || !("@binding" in data.key)) {
        warn(
          "Avoid using non-primitive value as key, " +
            "use string/number value instead.",
          context
        );
      }
    }
    // support single function children as default scoped slot
    if (Array.isArray(children) && typeof children[0] === "function") {
      data = data || {};
      data.scopedSlots = { default: children[0] };
      children.length = 0;
    }
    if (normalizationType === ALWAYS_NORMALIZE) {
      children = normalizeChildren(children);
    } else if (normalizationType === SIMPLE_NORMALIZE) {
      children = simpleNormalizeChildren(children);
    }
    let vnode, ns;
    if (typeof tag === "string") {
      let Ctor;
      ns = (context.$vnode && context.$vnode.ns) || config.getTagNamespace(tag);
      if (config.isReservedTag(tag)) {
        // platform built-in elements
        if (
          process.env.NODE_ENV !== "production" &&
          isDef(data) &&
          isDef(data.nativeOn) &&
          data.tag !== "component"
        ) {
          warn(
            `The .native modifier for v-on is only valid on components but it was used on <${tag}>.`,
            context
          );
        }
        vnode = new VNode(
          config.parsePlatformTagName(tag),
          data,
          children,
          undefined,
          undefined,
          context
        );
      } else if (
        (!data || !data.pre) &&
        isDef((Ctor = resolveAsset(context.$options, "components", tag)))
      ) {
        // component
        vnode = createComponent(Ctor, data, context, children, tag);
      } else {
        // unknown or unlisted namespaced elements
        // check at runtime because it may get assigned a namespace when its
        // parent normalizes children
        vnode = new VNode(tag, data, children, undefined, undefined, context);
      }
    } else {
      // direct component options / constructor
      vnode = createComponent(tag, data, context, children);
    }
    if (Array.isArray(vnode)) {
      return vnode;
    } else if (isDef(vnode)) {
      if (isDef(ns)) applyNS(vnode, ns);
      if (isDef(data)) registerDeepBindings(data);
      return vnode;
    } else {
      return createEmptyVNode();
    }
  }
  ```

  - `_createElement` 参数
    - `context`：`VNode`的上下文环境， `Component`类型，定义在 [vue/flow/component.js](https://github.com/vuejs/vue/blob/2.6/flow/component.js)
    - `tag`：标签，字符串或`Component`
    - `data`：`VNode` 的数据，`VNodeData` 类型，定义在 [vue/flow/vnode.js](https://github.com/vuejs/vue/blob/2.6/flow/vnode.js)
    - `children`：当前 `VNode` 的子节点，任意类型，需要被==规范==为标准的`VNode` 数组
    - `normalizationType`：子节点规范的类型，类型不同规范的方法也就不一样，主要参考 `render` 函数是编译生成还是用户自定义

- `children`的规范化

  - Virtual DOM 实际上是一个树状结构，每一个 `VNode` 可能会有若干个子节点，子节点应该也是 `VNode` 类型

  - `_createElement` 接收的`children`是任意类型的，需要将其规范成 `VNode` 类型

  - 根据 `normalizationType`，分别调用了 `normalizeChildren(children) `和 `simpleNormalizeChildren(children) `方法，定义在[vue/src/core/vdom/helpers/normalize-children.js](https://github.com/vuejs/vue/blob/2.6/src/core/vdom/helpers/normalize-children.js#L18)

    ```js
    export function simpleNormalizeChildren(children: any) {
      for (let i = 0; i < children.length; i++) {
        if (Array.isArray(children[i])) {
          return Array.prototype.concat.apply([], children);
        }
      }
      return children;
    }

    export function normalizeChildren(children: any): ?Array<VNode> {
      return isPrimitive(children)
        ? [createTextVNode(children)]
        : Array.isArray(children)
        ? normalizeArrayChildren(children)
        : undefined;
    }
    ```

  - `simpleNormalizeChildren`

    - 调用场景：`render`函数是编译生成

    - 理论上编译生成的 `children`都已经是 `VNode`类型的，但函数式组件返回的是一个数组而不是一个根节点，所以会通过 `Array.prototype.concat`方法把整个 `children`数组打平，让它的深度只有一层

  - `normalizeChildren`

    - 调用场景：`render` 函数是用户自定义和编译 `slot`、`v-for` 产生嵌套数组

    - `render` 函数是用户自定义：当` children` 只有一个节点的时候，Vue.js 从接口层面允许用户把 `children`写成基础类型用来创建单个简单的文本节点，此时会调用 `createTextVNode` 创建一个文本节点的`VNode`，定义在[vue\src\core\vdom\vnode.js](https://github.com/vuejs/vue/blob/2.6/src\core\vdom\vnode.js#L81)

      ```js
      export function createTextVNode(val: string | number) {
        return new VNode(undefined, undefined, undefined, String(val));
      }
      ```

    - 编译 `slot`、`v-for` 产生嵌套数组：调用 `normalizeArrayChildren` 方法，定义在 [vue/src/core/vdom/helpers/normalize-children.js](https://github.com/vuejs/vue/blob/2.6/src/core/vdom/helpers/normalize-children.js#L43)

      ```js
      function normalizeArrayChildren(
        children: any,
        nestedIndex?: string
      ): Array<VNode> {
        const res = [];
        let i, c, lastIndex, last;
        for (i = 0; i < children.length; i++) {
          c = children[i];
          if (isUndef(c) || typeof c === "boolean") continue;
          lastIndex = res.length - 1;
          last = res[lastIndex];
          //  nested
          if (Array.isArray(c)) {
            if (c.length > 0) {
              c = normalizeArrayChildren(c, `${nestedIndex || ""}_${i}`);
              // merge adjacent text nodes
              if (isTextNode(c[0]) && isTextNode(last)) {
                res[lastIndex] = createTextVNode(last.text + (c[0]: any).text);
                c.shift();
              }
              res.push.apply(res, c);
            }
          } else if (isPrimitive(c)) {
            if (isTextNode(last)) {
              // merge adjacent text nodes
              // this is necessary for SSR hydration because text nodes are
              // essentially merged when rendered to HTML strings
              res[lastIndex] = createTextVNode(last.text + c);
            } else if (c !== "") {
              // convert primitive to vnode
              res.push(createTextVNode(c));
            }
          } else {
            if (isTextNode(c) && isTextNode(last)) {
              // merge adjacent text nodes
              res[lastIndex] = createTextVNode(last.text + c.text);
            } else {
              // default key for nested array children (likely generated by v-for)
              if (
                isTrue(children._isVList) &&
                isDef(c.tag) &&
                isUndef(c.key) &&
                isDef(nestedIndex)
              ) {
                c.key = `__vlist${nestedIndex}_${i}__`;
              }
              res.push(c);
            }
          }
        }
        return res;
      }
      ```

      - `normalizeArrayChildren`参数
        - `children`：表规范的子节点
        - `nestedIndex`：嵌套的索引
      - `normalizeArrayChildren` 逻辑
      - 遍历 `children`，获得单个节点 `c`，对 `c` 的类型判断
      - 如果`c`是 `undefined` 或布尔值，则跳过该节点，不进行任何处理
      - 如果`c`是数组类型，则递归调用 `normalizeArrayChildren`
        - 如果递归处理后的子节点数组的第一个节点是文本节点，并且结果数组 `res` 的最后一个节点也是文本节点，则将这两个文本节点合并为一个文本节点，并更新结果数组
        - 将递归处理后的子节点数组中的所有节点（除了可能已合并的第一个文本节点）添加到结果数组中
      - 如果`c`是基础类型，检查结果数组 `res` 的最后一个节点
        - 如果最后一个节点是文本节点，则将当前原始值与最后一个文本节点的文本合并为一个新的文本节点，并更新结果数组
        - 如果当前原始值不是空字符串，则将其转换为一个文本节点，并添加到结果数组中
      - 如果当前子节点 `c` 不是数组或基础类型，则检查它是否是一个文本节点，并且结果数组 `res` 的最后一个节点也是文本节点
        - 如果是，则合并这两个文本节点为一个新的文本节点，并更新结果数组
        - 如果不是，则检查当前子节点是否是由 `v-for` 指令生成的虚拟列表的一部分（通过检查 `children._isVList` 属性），并且没有指定 `key` 属性。如果是这种情况，则为当前子节点生成一个默认的 `key` 值
      - 注意：在遍历的过程中，如果存在两个连续的文本节点，会把它们合并成一个文本节点
      - 结果：`children` 变为`VNode`的单节点或者数组

- `VNode`的构建

  - 规范完 `children`后，需要创建一个 `VNode` 实例（ [vue/src/core/vdom/create-element.js](https://github.com/vuejs/vue/blob/2.6/src/core/vdom/create-element.js#L95)）

    ```js
    let vnode, ns;
    if (typeof tag === "string") {
      let Ctor;
      ns = (context.$vnode && context.$vnode.ns) || config.getTagNamespace(tag);
      if (config.isReservedTag(tag)) {
        // platform built-in elements
        if (
          process.env.NODE_ENV !== "production" &&
          isDef(data) &&
          isDef(data.nativeOn) &&
          data.tag !== "component"
        ) {
          warn(
            `The .native modifier for v-on is only valid on components but it was used on <${tag}>.`,
            context
          );
        }
        vnode = new VNode(
          config.parsePlatformTagName(tag),
          data,
          children,
          undefined,
          undefined,
          context
        );
      } else if (
        (!data || !data.pre) &&
        isDef((Ctor = resolveAsset(context.$options, "components", tag)))
      ) {
        // component
        vnode = createComponent(Ctor, data, context, children, tag);
      } else {
        // unknown or unlisted namespaced elements
        // check at runtime because it may get assigned a namespace when its
        // parent normalizes children
        vnode = new VNode(tag, data, children, undefined, undefined, context);
      }
    } else {
      // direct component options / constructor
      vnode = createComponent(tag, data, context, children);
    }
    ```

  - 判断`tag`

    - 如果是 `string`类型，则接着判断如果是内置的一些节点，则直接创建一个普通 `VNode`
    - 如果是为已注册的组件名，则通过`createComponent`创建一个组件类型的`VNode`，否则创建一个未知的标签的`VNode`
    - 如果是 `tag`一个 `Component `类型，则直接调用 `createComponent` 创建一个组件类型的 `VNode `节点

## \_update

- Vue 的`_update` 是实例的一个私有方法

  - 调用的时机为首次渲染和数据更新

  - `_update` 方法的作用是把 `VNode` 渲染成真实的 DOM，定义在[vue/src/core/instance/lifecycle.js](https://github.com/vuejs/vue/blob/2.6/src/core/instance/lifecycle.js#L59)

  ```js
  Vue.prototype._update = function (vnode: VNode, hydrating?: boolean) {
    const vm: Component = this;
    const prevEl = vm.$el;
    const prevVnode = vm._vnode;
    const restoreActiveInstance = setActiveInstance(vm);
    vm._vnode = vnode;
    // Vue.prototype.__patch__ is injected in entry points
    // based on the rendering backend used.
    if (!prevVnode) {
      // initial render
      vm.$el = vm.__patch__(vm.$el, vnode, hydrating, false /* removeOnly */);
    } else {
      // updates
      vm.$el = vm.__patch__(prevVnode, vnode);
    }
    restoreActiveInstance();
    // update __vue__ reference
    if (prevEl) {
      prevEl.__vue__ = null;
    }
    if (vm.$el) {
      vm.$el.__vue__ = vm;
    }
    // if parent is an HOC, update its $el as well
    if (vm.$vnode && vm.$parent && vm.$vnode === vm.$parent._vnode) {
      vm.$parent.$el = vm.$el;
    }
    // updated hook is called by the scheduler to ensure that children are
    // updated in a parent's updated hook.
  };
  ```

  - `_update` 的核心就是调用`vm.__patch__`方法，在 web 平台中它定义在 [vue/src/platforms/web/runtime/index.js](https://github.com/vuejs/vue/blob/2.6/src/platforms/web/runtime/index.js#L34)

    ```js
    Vue.prototype.__patch__ = inBrowser ? patch : noop;
    ```

  - 在 web 平台上，是否是服务端渲染也会对这个方法产生影响

    - 在服务端渲染中，没有真实的浏览器 DOM 环境，所以不需要把 VNode 最终转换成 DOM，因此是一个空函数
    - 在浏览器端渲染中，它指向了 `patch` 方法，它定义在[vue/src/platforms/web/runtime/patch.js](https://github.com/vuejs/vue/blob/2.6/src/platforms/web/runtime/patch.js)

    ```js
    /* @flow */
  
    import * as nodeOps from "web/runtime/node-ops";
    import { createPatchFunction } from "core/vdom/patch";
    import baseModules from "core/vdom/modules/index";
    import platformModules from "web/runtime/modules/index";
  
    // the directive module should be applied last, after all
    // built-in modules have been applied.
    const modules = platformModules.concat(baseModules);
  
    export const patch: Function = createPatchFunction({ nodeOps, modules });
    ```

    - 调用 `createPatchFunction` 方法的返回值
    - `createPatchFunction`接收一个对象，包含 `nodeOps`参数和 `modules`参数
      - `nodeOps`封装了一系列 DOM 操作的方法
      - `modules`定义了一些模块的钩子函数的实现

- `createPatchFunction`定义在[vue/src/core/vdom/patch.js](https://github.com/vuejs/vue/blob/2.6/src/core/vdom/patch.js#L60)

  ```js
  const hooks = ["create", "activate", "update", "remove", "destroy"];

  export function createPatchFunction(backend) {
    let i, j;
    const cbs = {};

    const { modules, nodeOps } = backend;

    for (i = 0; i < hooks.length; ++i) {
      cbs[hooks[i]] = [];
      for (j = 0; j < modules.length; ++j) {
        if (isDef(modules[j][hooks[i]])) {
          cbs[hooks[i]].push(modules[j][hooks[i]]);
        }
      }
    }

    // ...

    return function patch(oldVnode, vnode, hydrating, removeOnly) {
      if (isUndef(vnode)) {
        if (isDef(oldVnode)) invokeDestroyHook(oldVnode);
        return;
      }

      let isInitialPatch = false;
      const insertedVnodeQueue = [];

      if (isUndef(oldVnode)) {
        // empty mount (likely as component), create new root element
        isInitialPatch = true;
        createElm(vnode, insertedVnodeQueue);
      } else {
        const isRealElement = isDef(oldVnode.nodeType);
        if (!isRealElement && sameVnode(oldVnode, vnode)) {
          // patch existing root node
          patchVnode(oldVnode, vnode, insertedVnodeQueue, removeOnly);
        } else {
          if (isRealElement) {
            // mounting to a real element
            // check if this is server-rendered content and if we can perform
            // a successful hydration.
            if (oldVnode.nodeType === 1 && oldVnode.hasAttribute(SSR_ATTR)) {
              oldVnode.removeAttribute(SSR_ATTR);
              hydrating = true;
            }
            if (isTrue(hydrating)) {
              if (hydrate(oldVnode, vnode, insertedVnodeQueue)) {
                invokeInsertHook(vnode, insertedVnodeQueue, true);
                return oldVnode;
              } else if (process.env.NODE_ENV !== "production") {
                warn(
                  "The client-side rendered virtual DOM tree is not matching " +
                    "server-rendered content. This is likely caused by incorrect " +
                    "HTML markup, for example nesting block-level elements inside " +
                    "<p>, or missing <tbody>. Bailing hydration and performing " +
                    "full client-side render."
                );
              }
            }
            // either not server-rendered, or hydration failed.
            // create an empty node and replace it
            oldVnode = emptyNodeAt(oldVnode);
          }

          // replacing existing element
          const oldElm = oldVnode.elm;
          const parentElm = nodeOps.parentNode(oldElm);

          // create new node
          createElm(
            vnode,
            insertedVnodeQueue,
            // extremely rare edge case: do not insert if old element is in a
            // leaving transition. Only happens when combining transition +
            // keep-alive + HOCs. (#4590)
            oldElm._leaveCb ? null : parentElm,
            nodeOps.nextSibling(oldElm)
          );

          // update parent placeholder node element, recursively
          if (isDef(vnode.parent)) {
            let ancestor = vnode.parent;
            const patchable = isPatchable(vnode);
            while (ancestor) {
              for (let i = 0; i < cbs.destroy.length; ++i) {
                cbs.destroy[i](ancestor);
              }
              ancestor.elm = vnode.elm;
              if (patchable) {
                for (let i = 0; i < cbs.create.length; ++i) {
                  cbs.create[i](emptyNode, ancestor);
                }
                // #6513
                // invoke insert hooks that may have been merged by create hooks.
                // e.g. for directives that uses the "inserted" hook.
                const insert = ancestor.data.hook.insert;
                if (insert.merged) {
                  // start at index 1 to avoid re-invoking component mounted hook
                  for (let i = 1; i < insert.fns.length; i++) {
                    insert.fns[i]();
                  }
                }
              } else {
                registerRef(ancestor);
              }
              ancestor = ancestor.parent;
            }
          }

          // destroy old node
          if (isDef(parentElm)) {
            removeVnodes(parentElm, [oldVnode], 0, 0);
          } else if (isDef(oldVnode.tag)) {
            invokeDestroyHook(oldVnode);
          }
        }
      }

      invokeInsertHook(vnode, insertedVnodeQueue, isInitialPatch);
      return vnode.elm;
    };
  }
  ```

  - `createPatchFunction`内部定义了一系列的辅助方法，最终返回了一个 `patch`方法，这个方法就赋值给了 `vm._update` 函数里调用的 `vm.__patch__`

  - `patch`参数

    - `oldVnode`：旧的 VNode 节点，它也可以不存在或者是一个 DOM 对象
    - `vnode`：执行 \_render 后返回的 VNode 的节点
    - `hydrating`：是否是服务端渲染
    - `removeOnly`：是给`transition-group`用的

  ```js
  // 示例
  var app = new Vue({
    el: "#app",
    render: function (createElement) {
      return createElement(
        "div",
        {
          attrs: {
            id: "app",
          },
        },
        this.message
      );
    },
    data: {
      message: "Hello Vue!",
    },
  });
  ```

  - `vm.$el = vm.__patch__(vm.$el, vnode, hydrating, false)`

  - `vnode` 对应的是调用 `render`函数的返回值

  - `hydrating`在非服务端渲染情况下为 `false`

  - `removeOnly`为 `false`

  - 示例中为首次渲染，在执行 `patch`函数时传入的 `vm.$el` 对应的是`id`为`app`的 DOM 对象，对应的是在 `index.html`模板中的 `<div id="app">`（`vm.$el`的赋值是在之前 `mountComponent`函数做的）

    ```js
    const isRealElement = isDef(oldVnode.nodeType);
    if (!isRealElement && sameVnode(oldVnode, vnode)) {
      // patch existing root node
      patchVnode(oldVnode, vnode, insertedVnodeQueue, removeOnly);
    } else {
      if (isRealElement) {
        // mounting to a real element
        // check if this is server-rendered content and if we can perform
        // a successful hydration.
        if (oldVnode.nodeType === 1 && oldVnode.hasAttribute(SSR_ATTR)) {
          oldVnode.removeAttribute(SSR_ATTR);
          hydrating = true;
        }
        if (isTrue(hydrating)) {
          if (hydrate(oldVnode, vnode, insertedVnodeQueue)) {
            invokeInsertHook(vnode, insertedVnodeQueue, true);
            return oldVnode;
          } else if (process.env.NODE_ENV !== "production") {
            warn(
              "The client-side rendered virtual DOM tree is not matching " +
                "server-rendered content. This is likely caused by incorrect " +
                "HTML markup, for example nesting block-level elements inside " +
                "<p>, or missing <tbody>. Bailing hydration and performing " +
                "full client-side render."
            );
          }
        }
        // either not server-rendered, or hydration failed.
        // create an empty node and replace it
        oldVnode = emptyNodeAt(oldVnode);
      }
  
      // replacing existing element
      const oldElm = oldVnode.elm;
      const parentElm = nodeOps.parentNode(oldElm);
  
      // create new node
      createElm(
        vnode,
        insertedVnodeQueue,
        // extremely rare edge case: do not insert if old element is in a
        // leaving transition. Only happens when combining transition +
        // keep-alive + HOCs. (#4590)
        oldElm._leaveCb ? null : parentElm,
        nodeOps.nextSibling(oldElm)
      );
    }
    ```

    - 传入的 `oldVnode`实际上是一个 DOM， `isRealElement`为 `true`

    - `isRealElement`为 `true`则通过 `emptyNodeAt`方法把 `oldVnode`转换成 `VNode`对象

    - 再调用 `createElm`方法，其定义在[vue/src/core/vdom/patch.js](https://github.com/vuejs/vue/blob/2.6/src/core/vdom/patch.js#L125)

- `createElm`

  ```js
  function createElm(
    vnode,
    insertedVnodeQueue,
    parentElm,
    refElm,
    nested,
    ownerArray,
    index
  ) {
    if (isDef(vnode.elm) && isDef(ownerArray)) {
      // This vnode was used in a previous render!
      // now it's used as a new node, overwriting its elm would cause
      // potential patch errors down the road when it's used as an insertion
      // reference node. Instead, we clone the node on-demand before creating
      // associated DOM element for it.
      vnode = ownerArray[index] = cloneVNode(vnode);
    }
  
    vnode.isRootInsert = !nested; // for transition enter check
    if (createComponent(vnode, insertedVnodeQueue, parentElm, refElm)) {
      return;
    }
  
    const data = vnode.data;
    const children = vnode.children;
    const tag = vnode.tag;
    if (isDef(tag)) {
      if (process.env.NODE_ENV !== "production") {
        if (data && data.pre) {
          creatingElmInVPre++;
        }
        if (isUnknownElement(vnode, creatingElmInVPre)) {
          warn(
            "Unknown custom element: <" +
              tag +
              "> - did you " +
              "register the component correctly? For recursive components, " +
              'make sure to provide the "name" option.',
            vnode.context
          );
        }
      }
  
      vnode.elm = vnode.ns
        ? nodeOps.createElementNS(vnode.ns, tag)
        : nodeOps.createElement(tag, vnode);
      setScope(vnode);
  
      /* istanbul ignore if */
      if (__WEEX__) {
        // in Weex, the default insertion order is parent-first.
        // List items can be optimized to use children-first insertion
        // with append="tree".
        const appendAsTree = isDef(data) && isTrue(data.appendAsTree);
        if (!appendAsTree) {
          if (isDef(data)) {
            invokeCreateHooks(vnode, insertedVnodeQueue);
          }
          insert(parentElm, vnode.elm, refElm);
        }
        createChildren(vnode, children, insertedVnodeQueue);
        if (appendAsTree) {
          if (isDef(data)) {
            invokeCreateHooks(vnode, insertedVnodeQueue);
          }
          insert(parentElm, vnode.elm, refElm);
        }
      } else {
        createChildren(vnode, children, insertedVnodeQueue);
        if (isDef(data)) {
          invokeCreateHooks(vnode, insertedVnodeQueue);
        }
        insert(parentElm, vnode.elm, refElm);
      }
  
      if (process.env.NODE_ENV !== "production" && data && data.pre) {
        creatingElmInVPre--;
      }
    } else if (isTrue(vnode.isComment)) {
      vnode.elm = nodeOps.createComment(vnode.text);
      insert(parentElm, vnode.elm, refElm);
    } else {
      vnode.elm = nodeOps.createTextNode(vnode.text);
      insert(parentElm, vnode.elm, refElm);
    }
  }
  ```

  - `createElm` 通过虚拟节点创建真实的 DOM 并插入到它的父节点中

  - `createComponent`方法目的是尝试创建子组件，在当前示例它的返回值为`false`

    - 接下来判断 `vnode`是否包含 `tag`，如果包含，对 `tag`的合法性在非生产环境下做校验，是否是一个合法标签；然后再去调用平台 DOM 的操作去创建一个占位符元素（ns：nameSpace）

      ```js
      vnode.elm = vnode.ns
        ? nodeOps.createElementNS(vnode.ns, tag)
        : nodeOps.createElement(tag, vnode);
      ```

  - 接下来调用`createChildren`（定义在[vue/src/core/vdom/patch.js](https://github.com/vuejs/vue/blob/2.6/src/core/vdom/patch.js#L284)）方法遍历`createElm`并创建子元素

    ```js
    function createChildren(vnode, children, insertedVnodeQueue) {
      if (Array.isArray(children)) {
        if (process.env.NODE_ENV !== "production") {
          checkDuplicateKeys(children);
        }
        for (let i = 0; i < children.length; ++i) {
          createElm(
            children[i],
            insertedVnodeQueue,
            vnode.elm,
            null,
            true,
            children,
            i
          );
        }
      } else if (isPrimitive(vnode.text)) {
        nodeOps.appendChild(
          vnode.elm,
          nodeOps.createTextNode(String(vnode.text))
        );
      }
    }
    ```

  - 接着再调用 `invokeCreateHooks`（定义在[vue/src/core/vdom/patch.js](https://github.com/vuejs/vue/blob/2.6/src/core/vdom/patch.js#L304)）方法，执行所有的 `create`的钩子，并把 `vnode` `push`到 `insertedVnodeQueue`

    ```js
    function invokeCreateHooks(vnode, insertedVnodeQueue) {
      for (let i = 0; i < cbs.create.length; ++i) {
        cbs.create[i](emptyNode, vnode);
      }
      i = vnode.data.hook; // Reuse variable
      if (isDef(i)) {
        if (isDef(i.create)) i.create(emptyNode, vnode);
        if (isDef(i.insert)) insertedVnodeQueue.push(vnode);
      }
    }
    ```

  - 最后调用 `insert`方法把 DOM 插入到父节点中，因为是递归调用，子元素会优先调用 `insert`，所以整个 `VNode` 树节点的插入顺序是先子后父

    ```js
    function insert(parent, elm, ref) {
      if (isDef(parent)) {
        if (isDef(ref)) {
          if (nodeOps.parentNode(ref) === parent) {
            nodeOps.insertBefore(parent, elm, ref);
          }
        } else {
          nodeOps.appendChild(parent, elm);
        }
      }
    }
    ```

    - `insert` 调用 `nodeOps`（[vue/src/platforms/web/runtime/node-ops.js](https://github.com/vuejs/vue/blob/2.6/src/platforms/web/runtime/node-ops.js#L29)）上的方法， 把子节点插入到父节点中

      ```js
      export function insertBefore(
        parentNode: Node,
        newNode: Node,
        referenceNode: Node
      ) {
        parentNode.insertBefore(newNode, referenceNode);
      }
    
      export function appendChild(node: Node, child: Node) {
        node.appendChild(child);
      }
      ```

  - 在 `createElm` 过程中，如果 `VNode`节点不包含 `tag`，则它有可能是一个注释或者纯文本节点，可以直接插入到父元素中

    - 示例中，最内层就是一个文本 `VNode`，它的 `text` 值取的 `this.message` 的 `Hello Vue!`

  - 首次渲染我们调用了 `createElm`方法，传入的 `parentElm`是 `oldVnode.elm` 的父元素

    ```js
    const oldElm = oldVnode.elm;
    const parentElm = nodeOps.parentNode(oldElm);
    createElm(
      vnode,
      insertedVnodeQueue,
      oldElm._leaveCb ? null : parentElm,
      nodeOps.nextSibling(oldElm)
    );
    ```

    - 实例中是 `id` 为 `#app` `div` 的父元素，也就是 `body`
    - 实际上整个过程就是递归创建了一个完整的 DOM 树并插入到 `body`上

  - 最后，我们根据之前递归 `createElm `生成的`VNode`插入顺序队列，执行相关的 `insert`钩子函数

## Vue 渲染流程

![Vue渲染](https://image.jslog.net/online/a-42/2024/12/28/Vue渲染.svg)
