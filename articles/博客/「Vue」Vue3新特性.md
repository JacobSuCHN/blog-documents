## 响应式

- Vue2：Object.defineProperty

  ```js
  const initData = { value: 1 };
  const data = {};

  Object.keys(initData).forEach((key) => {
    Object.defineProperty(data, key, {
      get() {
        console.log("访问了", key);
        return initData[key];
      },
      set(v) {
        console.log("修改了", key);
        initData[key] = v;
      },
    });
  });

  console.log(data.value);
  // "访问了 value"
  // 1
  data.value = 2;
  // "修改了" "value"
  console.log(data.value);
  // "访问了" "value"
  // 2
  console.log(initData.value);
  // 2
  initData.newValue = 1;
  console.log(data);
  // {}
  console.log(initData);
  // { value: 2, newValue: 1 }
  ```

  - 问题：新增属性无法观测到
  - 解决：Vue2 使用 Vue.set 解决该问题；响应式对象添加一个属性，确保新的属性同样具有响应式，并且能够触发试图更新

  - Vue.set(target, key, value) / this.$set(target, key, value)

- Vue3：Proxy

  ```js
  const initData = { value: 1 };
  const proxy = new Proxy(initData, {
    get: function (target, key, receiver) {
      console.log("访问了", key);
      return Reflect.get(target, key, receiver);
    },
    set: function (target, key, value, receiver) {
      console.log("修改了", key);
      return Reflect.set(target, key, value, receiver);
    },
  });

  console.log(proxy.value);
  // "访问了 value"
  // 1
  proxy.value = 2;
  // "修改了" "value"
  console.log(proxy.value);
  // "访问了" "value"
  // 2
  console.log(initData.value);
  // 2
  initData.newDataVlue = 1;
  console.log(proxy);
  // { value: 2, newDataVlue: 1 }
  console.log(initData);
  // { value: 2, newDataVlue: 1 }
  console.log(proxy.newDataVlue);
  // "访问了" "newDataVlue"
  // 1
  proxy.newProxyValue = 3;
  // "修改了" "newProxyValue"
  console.log(proxy);
  // { value: 2, newDataVlue: 1, newProxyValue: 3 }
  console.log(initData);
  // { value: 2, newDataVlue: 1, newProxyValue: 3 }
  console.log(proxy.newProxyValue);
  // "访问了" "newProxyValue"
  // 3
  ```

  - 问题：proxy 不兼容 IE 浏览器

## 多实例

- Vue2：只允许挂载一个实例

  ```js
  const vm = new Vue({
    render: (h) => h(APP),
  });
  vm.$mount("#app");
  ```

- Vue3：允许挂载多个实例

  ```js
  const app1 = createApp({
    /* ... */
  });
  app1.mount("#container-1");

  const app2 = createApp({
    /* ... */
  });
  app2.mount("#container-2");
  ```

## 组合式 API

- 组合式 API (Composition API) ：是一系列 API 的集合

  - 涵盖了的 API

    - [响应式 API](https://cn.vuejs.org/api/reactivity-core.html)：例如 `ref()` 和 `reactive()`，使我们可以直接创建响应式状态、计算属性和侦听器
    - [生命周期钩子](https://cn.vuejs.org/api/composition-api-lifecycle.html)：例如 `onMounted()` 和 `onUnmounted()`，使我们可以在组件各个生命周期阶段添加逻辑
    - [依赖注入](https://cn.vuejs.org/api/composition-api-dependency-injection.html)：例如 `provide()` 和 `inject()`，使我们可以在使用响应式 API 时，利用 Vue 的依赖注入系统

  - 组合式 API 的优势

    - 更好的逻辑复用：组合式 API 最基本的优势是它使我们能够通过[组合函数](https://cn.vuejs.org/guide/reusability/composables.html)来实现更加简洁高效的逻辑复用

    - 更灵活的代码组织：组合式 API 能归并逻辑关注点，降低重构成本，更利于大型项目维护

      ![CompositionAPI](https://image.jslog.net/online/a-39/2024/12/25/CompositionAPI.png)

    - 更好的类型推导：组合式 API 与 TypeScript 兼容更好，利于类型推导

    - 更小的生产包体积：使用 `<script setup>` 搭配组合式 API 相较于选项式 API 更高效且对代码压缩更友好，因为模板被编译为与 `<script setup>` 代码同作用域的内联函数，允许直接访问变量而非通过 `this` 代理，从而便于压缩变量名

- setup

  - `setup()` 钩子是在组件中使用组合式 API 的入口（提供了统一入口）

    ```js
    export default {
      setup(props, context) {
        ...
      }
    }
    ```

    - `setup()` 自身并不含对组件实例的访问权，即在 `setup()` 中访问 `this`会是 `undefined`
    - `setup()` 应该*同步地*返回一个对象。唯一可以使用 `async setup()` 的情况是，该组件是 [Suspense](https://cn.vuejs.org/guide/built-ins/suspense.html) 组件的后裔

  - 参数`(props, context)`

    - props：用来接收 props 数据， `setup` 函数的 `props` 是响应式的，并且会在传入新的 props 时同步更新

      ```js
      export default {
        props: {
          title: String,
        },
        setup(props) {
          console.log(props.title);
        },
      };
      ```

      > 注意：如果你解构了 `props` 对象，解构出的变量将会丢失响应性

    - context： Setup 上下文对象

      ```js
      export default {
        setup(props, context) {
          // 透传 Attributes（非响应式的对象，等价于 $attrs）
          console.log(context.attrs);

          // 插槽（非响应式的对象，等价于 $slots）
          console.log(context.slots);

          // 触发事件（函数，等价于 $emit）
          console.log(context.emit);

          // 暴露公共属性（函数）
          console.log(context.expose);
        },
      };
      ```

      ```js
      // 该上下文对象是非响应式的，可以安全地解构
      export default {
        setup(props, { attrs, slots, emit, expose }) {
          ...
        }
      }
      ```

- ref 与 reactive

  - 从定义数据角度对比

    - ref 用来定义：基本类型数据
    - reactive 用来定义：对象（或数组）类型数据
    - 备注：ref 也可以用来定义对象（或数组）类型数据，它内部会自动通过 reactive 转为代理对象

  - 从使用角度对比
    - ref 定义的数据：操作数据需要.value，读取数据时模板中直接读取不需要.value
    - reactive 定义的数据：操作数据与读取数据均不需要.value

## 生命周期

![生命周期](https://image.jslog.net/online/a-39/2024/12/25/生命周期.png)

- renderTracked

  - 在一个响应式依赖被组件的渲染作用追踪后调用
  - 仅在开发模式下可用，且在服务器端渲染期间不会被调用

- renderTriggered ​
  - 在一个响应式依赖被组件触发了重新渲染之后调用
  - 仅在开发模式下可用，且在服务器端渲染期间不会被调用

## 异步组件

- 使用步骤

  - 异步引入组件

  - 使用 Suspense 包裹组件，并配置好 default 与 fallback

  ```js
  import { defineAsyncComponent } from "vue";
  const Child = defineAsyncComponent(() => import("./components/Child.vue"));
  ```

  ```html
  <template>
    <div class="app">
      <Suspense>
        <template v-slot:default>
          <Child />
        </template>
        <template v-slot:fallback>
          <h3>加载中.....</h3>
        </template>
      </Suspense>
    </div>
  </template>
  ```

- 异步组件的优势

  - 异步组件可以延迟加载组件以优化性能
  - 实现分包功能

## 内置组件

- Teleport

  - `<Teleport>` 是一个内置组件，它可以将一个组件内部的一部分模板“传送”到该组件的 DOM 结构外层的位置去

  - 使用

    ```html
    <button @click="open = true">Open Modal</button>

    <Teleport to="body">
      <div v-if="open" class="modal">
        <p>Hello from the modal!</p>
        <button @click="open = false">Close</button>
      </div>
    </Teleport>
    ```

    - `<Teleport>` 接收一个 `to` prop 来指定传送的目标
    - `to` 的值可以是一个 CSS 选择器字符串，也可以是一个 DOM 元素对象
    - 这段代码的作用就是告诉 Vue“把以下模板片段传送到 `body` 标签下

## 组合式函数 hooks

- 组合式函数(Composables) ：是一个利用 Vue 的组合式 API 来封装和复用有状态逻辑的函数

  - 通过自定义 Hook，可以将组件的状态与 UI 实现分离，虽然这个 api 和早期的 mixin 非常像，但是他的设计思想实在先进太多

- 鼠标跟踪器示例

  ```js
  // mouse.js
  import { ref, onMounted, onUnmounted } from "vue";

  // 按照惯例，组合式函数名以“use”开头
  export function useMouse() {
    // 被组合式函数封装和管理的状态
    const x = ref(0);
    const y = ref(0);

    // 组合式函数可以随时更改其状态。
    function update(event) {
      x.value = event.pageX;
      y.value = event.pageY;
    }

    // 一个组合式函数也可以挂靠在所属组件的生命周期上
    // 来启动和卸载副作用
    onMounted(() => window.addEventListener("mousemove", update));
    onUnmounted(() => window.removeEventListener("mousemove", update));

    // 通过返回值暴露所管理的状态
    return { x, y };
  }
  ```

  ```vue
  <script setup>
  import { useMouse } from "./mouse.js";

  const { x, y } = useMouse();
  </script>

  <template>Mouse position is at: {{ x }}, {{ y }}</template>
  ```

## 自定义指令

```html
<script setup>
  // 在模板中启用 v-focus
  const vFocus = {
    mounted: (el) => el.focus(),
  };
</script>

<template>
  <input v-focus />
</template>
```
