## 混入 mixin

- 组件混入

  ```js
  const mixin = {
    created() {
      console.log("mixin created");
      console.log("[mixin log]message", this.message);
      this.sayHello();
    },
    methods: {
      sayHello() {
        console.log("mixin hello");
      },
    },
    data() {
      return {
        message: "mixin message",
      };
    },
  };

  export default {
    name: "App",
    mixins: [mixin],
    created() {
      console.log("created");
      console.log("[log]message", this.message);
      this.sayHello();
    },
    methods: {
      sayHello() {
        console.log("hello");
      },
    },
    data() {
      return {
        message: "mesage",
      };
    },
  };
  ```

- 全局混入

  ```js
  const mixin = {
    created() {
      console.log("global mixin created");
      console.log("[global mixin log]message", this.message);
    },
  };
  Vue.mixin(mixin);
  new Vue({
    render: (h) => h(App),
  }).$mount("#app");
  ```

- 选项合并

  - 上述代码控制台输出

    ```js
    // "global mixin created"
    // "[global mixin log]message" undefined
    // "mixin created"
    // "[mixin log]message" "mesage"
    // "hello"
    // "created"
    // "[log]message" "mesage"
    // "hello"
    ```

  - 当组件和混入对象含有同名选项时，这些选项将以恰当的方式进行“合并”
  - 数据对象在内部会进行递归合并，并在发生冲突时以组件数据优先
  - 同名钩子函数将合并为一个数组，因此都将被调用。另外，混入对象的钩子将在组件自身钩子之前调用
  - 值为对象的选项，例如 `methods`、`components` 和 `directives`，将被合并为同一个对象；两个对象键名冲突时，取组件对象的键值对
  - 注意：`Vue.extend()` 也使用同样的策略进行合并

- mixin 存在的问题

  - 命名冲突

    - 自定义合并混入策略`Vue.config.optionMergeStrategies`

  - 依赖不透明：换句话说，依赖不是局部声明式的
    - mixin 和使用它的组件之间没有层次关系
    - 不易维护

## 自定义指令 directive

- 钩子函数 (均为可选)

  - `bind`：只调用一次，初始化时调用
  - `unbind`：只调用一次，解绑时调用
  - `inserted`：被绑定元素插入父节点时调用 (仅保证父节点存在，但不一定已被插入文档中)
  - `update`：所在组件的 VNode 更新时调用，但是可能发生在其子 VNode 更新之前

  - `componentUpdated`：指令所在组件的 VNode 及其子 VNode 全部更新后调用。

- 钩子函数的参数

  - `el`：指令所绑定的元素，可以用来直接操作 DOM
  - `binding`：一个对象，包含以下 property
    - `name`：指令名，不包括 `v-` 前缀
    - `value`：指令的绑定值，例如：`v-my-directive="1 + 1"` 中，绑定值为 `2`
    - `oldValue`：指令绑定的前一个值，仅在 `update` 和 `componentUpdated` 钩子中可用。无论值是否改变都可用
    - `expression`：字符串形式的指令表达式。例如 `v-my-directive="1 + 1"` 中，表达式为 `"1 + 1"`
    - `arg`：传给指令的参数，可选。例如 `v-my-directive:foo` 中，参数为 `"foo"`
    - `modifiers`：一个包含修饰符的对象。例如：`v-my-directive.foo.bar` 中，修饰符对象为 `{ foo: true, bar: true }`
  - `vnode`：Vue 编译生成的虚拟节点
  - `oldVnode`：上一个虚拟节点，仅在 `update` 和 `componentUpdated` 钩子中可用

- 示例

  ```html
  <div id="hook-arguments-example" v-demo:foo.a.b="message"></div>
  ```

  ```js
  Vue.directive("demo", {
    bind: function (el, binding, vnode) {
      var s = JSON.stringify;
      el.innerHTML =
        "name: " +s(binding.name) +"<br>" +
        "value: " +s(binding.value) +"<br>" +
        "expression: " +s(binding.expression) +"<br>" +
        "argument: " +s(binding.arg) +"<br>" +
        "modifiers: " +s(binding.modifiers) +"<br>" +
        "vnode keys: " +Object.keys(vnode).join(", ");
    },
  });

  new Vue({
    el: "#hook-arguments-example",
    data: {
      message: "hello!",
    },
  });
  ```

  ```html
  <div id="hook-arguments-example">
    name: "demo"<br />
    value: "hello!"<br />
    expression: "message"<br />
    argument: "foo"<br />
    modifiers: {"a":true,"b":true}<br />
    vnode keys: tag, data, children, text, elm, ns, context, fnContext,
    fnOptions, fnScopeId, key, componentOptions, componentInstance, parent, raw,
    isStatic, isRootInsert, isComment, isCloned, isOnce, asyncFactory,
    asyncMeta, isAsyncPlaceholder
  </div>
  ```

## 插件 plugin

- 插件通常用来为 Vue 添加全局功能

- 常见插件的功能

  - 添加全局方法或者 property；如：[vue-custom-element](https://github.com/karol-f/vue-custom-element)
  - 添加全局资源：指令/过滤器/过渡等；如 [vue-touch](https://github.com/vuejs/vue-touch)
  - 通过全局混入来添加一些组件选项；如 [vue-router](https://github.com/vuejs/vue-router)
  - 添加 Vue 实例方法，通过把它们添加到 `Vue.prototype` 上实现
  - 一个库，提供自己的 API，同时提供上面提到的一个或多个功能；如 [vue-router](https://github.com/vuejs/vue-router)

- 使用插件

  ```js
  Vue.use(MyPlugin, { someOption: true });
  ```

- 开发插件

  ```js
  MyPlugin.install = function (Vue, options) {
    // 1. 添加全局方法或 property
    Vue.myGlobalMethod = function () {
      // 逻辑...
    }

    // 2. 添加全局资源
    Vue.directive('my-directive', {
      bind (el, binding, vnode, oldVnode) {
        // 逻辑...
      }
      ...
    })

    // 3. 注入组件选项
    Vue.mixin({
      created: function () {
        // 逻辑...
      }
      ...
    })

    // 4. 添加实例方法
    Vue.prototype.$myMethod = function (methodOptions) {
      // 逻辑...
    }
  }
  ```

## 过滤器 filter

- 过滤器：对数据进行格式化

- 使用

  ```html
  <!-- 在双花括号中 -->
  {{ message | capitalize }}

  <!-- 在 v-bind 中 -->
  <div v-bind:id="rawId | formatId"></div>
  ```

  - `capitalize` 过滤器函数将会收到 `message` 的值作为第一个参数
  - 过滤器函数总接收表达式的值 (之前的操作链的结果) 作为第一个参数

- 定义

  ```js
  export default {
    filters: {
      capitalize: function (value) {
        if (!value) return "";
        value = value.toString();
        return value.charAt(0).toUpperCase() + value.slice(1);
      },
    },
  };
  ```

  ```js
  Vue.filter("capitalize", function (value) {
    if (!value) return "";
    value = value.toString();
    return value.charAt(0).toUpperCase() + value.slice(1);
  });

  new Vue({
    // ...
  });
  ```

- 过滤器串联

  ```html
  {{ message | filterA | filterB }}
  ```

  - `filterA` 被定义为接收单个参数的过滤器函数，表达式 `message` 的值将作为参数传入到函数中
  - 然后继续调用同样被定义为接收单个参数的过滤器函数 `filterB`，将 `filterA` 的结果传递到 `filterB` 中

- 过滤器传参

  ```html
  {{ message | filterA('arg1', arg2) }}
  ```

  - `filterA` 被定义为接收三个参数的过滤器函数
  - 其中 `message` 的值作为第一个参数，普通字符串 `'arg1'` 作为第二个参数，表达式 `arg2` 的值作为第三个参数

## 插槽 slot

- 使用

  ```html
  <!-- BaseLayout -->
  <div class="container">
    <header>
      <!-- 具名插槽 -->
      <slot name="header"></slot>
    </header>
    <main>
      <!-- 默认插槽 -->
      <slot></slot>
    </main>
    <footer>
      <slot name="footer"></slot>
    </footer>
  </div>
  ```

  ```html
  <BaseLayout>
    <template v-slot:header>
      <h1>Here might be a page title</h1>
    </template>

    <p>A paragraph for the main content.</p>
    <p>And another one.</p>
    <!-- 等价于
    <template v-slot:default>
      <p>A paragraph for the main content.</p>
      <p>And another one.</p>
    </template> 
    -->

    <template v-slot:footer>
      <p>Here's some contact info</p>
    </template>
  </BaseLayout>
  ```

  ```html
  <div class="container">
    <header>
      <h1>Here might be a page title</h1>
    </header>
    <main>
      <p>A paragraph for the main content.</p>
      <p>And another one.</p>
    </main>
    <footer>
      <p>Here's some contact info</p>
    </footer>
  </div>
  ```

  - `v-slot` 只能添加在 `<template>`上

- 作用域插槽

  ```html
  <!-- CurrentUser -->
  <span>
    <slot name="name" :user="user"> {{ user.lastName }} </slot>
  </span>
  ```

  ```html
  <CurrentUser>
    <template v-slot:name="slotProps">
      {{ slotProps.user.firstName }}
    </template>
  </CurrentUser>
  ```
