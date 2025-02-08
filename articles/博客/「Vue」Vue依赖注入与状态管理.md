## 依赖注入

- Vue2

  - 类型

    - `provide：Object | () => Object`
    - `inject：Array<string> | { [key: string]: string | Symbol | Object }`
    - `provide / inject`一起使用，以允许一个祖先组件向其所有子孙后代注入一个依赖，不论组件层次有多深，并在其上下游关系成立的时间里始终生效

  - `provide` 选项应该是一个对象或返回一个对象的函数；该对象包含可注入其子孙的 `property`

  - `inject` 选项应该是

    - 一个字符串数组，或
    - 一个对象，对象的 `key` 是本地的绑定名，`value` 是
      - 在可用的注入内容中搜索用的 `key`(字符串或 `Symbol`)，或
      - 一个对象，该对象的：
        - `from property` 是在可用的注入内容中搜索用的 key (字符串或 Symbol)
        - `default property` 是降级情况下使用的 value

    > 提示：provide 和 inject 绑定并不是可响应的，这是刻意为之的；然而，如果传入了一个可监听的对象，那么其对象的 property 还是可响应的

  - 示例

    ```js
    // 父级组件提供 'foo'
    var Provider = {
      provide: {
        foo: "bar",
      },
      // ...
    };
    
    // 子组件注入 'foo'
    var Child = {
      inject: ["foo"],
      created() {
        console.log(this.foo); // => "bar"
      },
      // ...
    };
    ```

- Vue3

  - `provide()`：提供一个值，可以被后代组件注入

    - 类型

      ```ts
      function provide<T>(key: InjectionKey<T> | string, value: T): void;
      ```

    - 详细信息

      - `provide()` 接受两个参数：第一个参数是要注入的 key，可以是一个字符串或者一个 symbol，第二个参数是要注入的值
      - 与注册生命周期钩子的 API 类似，`provide()` 必须在组件的 `setup()` 阶段同步调用

    - 示例

      ```vue
      <script setup>
      import { ref, provide } from "vue";
      import { countSymbol } from "./injectionSymbols";
      
      // 提供静态值
      provide("path", "/project/");
      
      // 提供响应式的值
      const count = ref(0);
      provide("count", count);
      
      // 提供时将 Symbol 作为 key
      provide(countSymbol, count);
      </script>
      ```

  - `inject()`：注入一个由祖先组件或整个应用 (通过 `app.provide()`) 提供的值

    - 类型

      ```ts
      // 没有默认值
      function inject<T>(key: InjectionKey<T> | string): T | undefined;
      
      // 带有默认值
      function inject<T>(key: InjectionKey<T> | string, defaultValue: T): T;
      
      // 使用工厂函数
      function inject<T>(
        key: InjectionKey<T> | string,
        defaultValue: () => T,
        treatDefaultAsFactory: true
      ): T;
      ```

    - 详细信息

      - 第一个参数是注入的 `key`

        - Vue 会遍历父组件链，通过匹配 `key` 来确定所提供的值
        - 如果父组件链上多个组件对同一个 `key` 提供了值，那么离得更近的组件将会“覆盖”链上更远的组件所提供的值
        - 如果没有能通过 `key` 匹配到值，`inject()` 将返回 `undefined`，除非提供了一个默认值

      - 第二个参数是可选的，即在没有匹配到 `key` 时使用的默认值
        - 第二个参数也可以是一个工厂函数，用来返回某些创建起来比较复杂的值
        - 在这种情况下，必须将 `true` 作为第三个参数传入，表明这个函数将作为工厂函数使用，而非值本身
      - 与注册生命周期钩子的 API 类似，`inject()` 必须在组件的 `setup()` 阶段同步调用

    - 示例：假设有一个父组件已经提供了一些值，如前面 `provide()` 的例子中所示

      ```vue
      <script setup>
      import { inject } from "vue";
      import { countSymbol } from "./injectionSymbols";
      
      // 注入不含默认值的静态值
      const path = inject("path");
      
      // 注入响应式的值
      const count = inject("count");
      
      // 通过 Symbol 类型的 key 注入
      const count2 = inject(countSymbol);
      
      // 注入一个值，若为空则使用提供的默认值
      const bar = inject("path", "/default-path");
      
      // 注入一个值，若为空则使用提供的函数类型的默认值
      const fn = inject("function", () => {});
      
      // 注入一个值，若为空则使用提供的工厂函数
      const baz = inject("factory", () => new ExpensiveObject(), true);
      </script>
      ```

## 状态管理

- 状态管理

  - 理论上来说，每一个 Vue 组件实例都已经在“管理”它自己的响应式状态了

    ```vue
    <script setup>
    import { ref } from "vue";
    
    // 状态
    const count = ref(0);
    
    // 动作
    function increment() {
      count.value++;
    }
    </script>
    
    <!-- 视图 -->
    <template>{{ count }}</template>
    ```

    - 它是一个独立的单元，由以下几个部分组成

      - **状态**：驱动整个应用的数据源

      - **视图**：对**状态**的一种声明式映射

      - **交互**：状态根据用户在**视图**中的输入而作出相应变更的可能方式

    ![state-flow](https://image.jslog.net/online/a-41/2024/12/28/state-flow.png)

  - 当我们有**多个组件共享一个共同的状态**时

    - 多个视图可能都依赖于同一份状态
      - 将共享状态“提升”到共同的祖先组件上去，再通过 props 传递下来
      - 然而在深层次的组件树结构中这么做的话，很快就会使得代码变得繁琐冗长；这会导致另一个问题 Prop 逐级透传问题
    - 来自不同视图的交互也可能需要更改同一份状态
      - 经常会直接通过模板引用获取父/子实例或者通过触发的事件尝试改变和同步多个状态的副本
      - 但这些模式的健壮性都不甚理想，很容易就会导致代码难以维护

  - 状态管理：一个更简单直接的解决方案是抽取出组件间的共享状态，放在一个全局单例中来管理；这样我们的组件树就变成了一个大的“视图”，而任何位置上的组件都可以访问其中的状态或触发动作

- Vuex

  - state：存放状态数据的地方，其中数据是响应式的，数据改变对应组件的数据也会跟新改变，禁止直接改变 state 中的数据否则数据无法被调试工具监测；State 单一状态树，存储的是基本数据

  - getters：Getter 是从 State 中派生出来的，可理解为属于 store 的计算属性对 State 进行加工之后派生出来的数据，和 computed 的计算属性一样，getter 的返回的值会根据它的依赖进行缓存处理，而且只有当它的依赖值发生变化改变的时候才会被重新计算

  - mutations：装着处理数据逻辑方法的集合体，Mutation 是提交修改的数据，从而改变 state 中数据的方法；通过使用 store.commit 方法更改 state 的存储状态，mutation 必须是同步函数

  - actions：提交 mutations，Action 与 mutations 功能类似，但是 Action 提交的是 Mutation 从而修改数据，而不是直接改变状态；还可以包含任何异步操作，一般用于存在异步操作命令的需求中

  - modules：当 store 过于臃肿时，可使用 modules 将 store 分割成模块，每个模块中都有自己的 state、getter、mutations、actions 以及嵌套子模块（从上到下进行同样方式的分割）

  - 示例

    ```js
    import Vue from 'vue'
    import Vuex from 'vuex'
    
    Vue.use(Vuex)
    
    const store = new Vuex.Store({
      state: {
        count: 0
      },
     getters: {
        tenTimesCount(state){
          return state.count*10
        }
      }
      mutations: {
        increment (state) {
          state.count++
        }
      },
      actions: {
        increment (context) {
          context.commit('increment')
        }
      }
    })
    ```

    ```js
    new Vue({
      el: "#app",
      store,
    });
    ```

    ```js
    methods: {
      increment() {
        this.$store.commit('increment')
        console.log(this.$store.state.count)
      }
    }
    ```

- Pinia

  - State

    - 在大多数情况下，`state` 都是 `store`的核心；通常会先定义能代表他们 APP 的 `state`

    - 在 Pinia 中，`state` 被定义为一个返回初始状态的函数；使得 Pinia 可以同时支持服务端和客户端

      ```js
      import { defineStore } from "pinia";
      
      const useStore = defineStore("storeId", {
        // 为了完整类型推理，推荐使用箭头函数
        state: () => {
          return {
            // 所有这些属性都将自动推断出它们的类型
            count: 0,
            name: "Eduardo",
            isAdmin: true,
            items: [],
            hasChanged: true,
          };
        },
      });
      ```

      ```ts
      interface State {
        userList: UserInfo[];
        user: UserInfo | null;
      }
      
      const useStore = defineStore("storeId", {
        state: (): State => {
          return {
            userList: [],
            user: null,
          };
        },
      });
      
      interface UserInfo {
        name: string;
        age: number;
      }
      ```

    - 访问 `state`

      - 默认情况下，可以通过 `store` 实例访问 `state`，直接对其进行读写

        ```js
        const store = useStore();
        
        store.count++;
        ```

      - > 注意，新的属性如果没有在 `state()` 中被定义，则不能被添加；它必须包含初始状态
        >
        > 例如：如果 `secondCount` 没有在 `state()` 中定义，无法执行 `store.secondCount = 2`

    - 订阅 state

      - 类似于 Vuex 的 `subscribe` 方法，可以通过 `store` 的 `$subscribe()` 方法侦听 `state` 及其变化

      - 比起普通的 watch()，使用 `$subscribe()` 的好处是 `subscriptions` 在 patch 后只触发一次

        ```js
        cartStore.$subscribe((mutation, state) => {
          // import { MutationType } from 'pinia'
          mutation.type; // 'direct' | 'patch object' | 'patch function'
          // 和 cartStore.$id 一样
          mutation.storeId; // 'cart'
          // 只有 mutation.type === 'patch object'的情况下才可用
          mutation.payload; // 传递给 cartStore.$patch() 的补丁对象
        
          // 每当状态发生变化时，将整个 state 持久化到本地存储
          localStorage.setItem("cart", JSON.stringify(state));
        });
        ```

      - 默认情况下，`state subscription` 会被绑定到添加它们的组件上 (如果 store 在组件的 `setup()` 里面)

        - 这意味着，当该组件被卸载时，它们将被自动删除

        - 如果想在组件卸载后依旧保留它们，将 `{ detached: true }` 作为第二个参数，以将 `state subscription` 从当前组件中*分离*

          ```vue
          <script setup>
          const someStore = useSomeStore();
          // 此订阅器即便在组件卸载之后仍会被保留
          someStore.$subscribe(callback, { detached: true });
          </script>
          ```

  - Getter

    - Getter 完全等同于 `store` 的 `state` 的计算值；可以通过 `defineStore()` 中的 `getters` 属性来定义它们（推荐使用箭头函数，并且它将接收 `state` 作为第一个参数）

      ```js
      export const useCounterStore = defineStore("counter", {
        state: () => ({
          count: 0,
        }),
        getters: {
          doubleCount: (state) => state.count * 2,
        },
      });
      ```

    - 访问其他 `getter`

      - 与计算属性一样，也可以组合多个 getter;通过 `this`

      - 可以访问到其他任何 `getter`

      - 在这种情况下，需要为这个 `getter` 指定一个返回值的类型

        ```ts
        export const useCounterStore = defineStore("counter", {
          state: () => ({
            count: 0,
          }),
          getters: {
            doubleCount(state) {
              return state.count * 2;
            },
            doubleCountPlusOne(): number {
              return this.doubleCount + 1;
            },
          },
        });
        ```

      - 向 getter 传递参数

        - Getter 只是幕后的计算属性，所以不可以向它们传递任何参数

        - 不过，可以从 `getter` 返回一个函数，该函数可以接受任意参数

          ```js
          export const useUserListStore = defineStore("userList", {
            getters: {
              getUserById: (state) => {
                return (userId) =>
                  state.users.find((user) => user.id === userId);
              },
            },
          });
          ```

          ```vue
          <script setup>
          import { useUserListStore } from "./store";
          const userList = useUserListStore();
          const { getUserById } = storeToRefs(userList);
          // 请注意，需要使用 `getUserById.value` 来访问
          // <script setup> 中的函数
          </script>
          
          <template>
            <p>User 2: {{ getUserById(2) }}</p>
          </template>
          ```

        - 注意，当这样做时，`getter` 将不再被缓存

          - 它们只是一个被调用的函数

          - 不过，可以在 getter 本身中缓存一些结果，虽然这种做法并不常见，但有证明表明它的性能会更好

            ```js
            export const useUserListStore = defineStore("userList", {
              getters: {
                getActiveUserById(state) {
                  const activeUsers = state.users.filter((user) => user.active);
                  return (userId) =>
                    activeUsers.find((user) => user.id === userId);
                },
              },
            });
            ```

      - 访问其他 `store` 的 `getter`

        - 想要使用另一个 `store` 的 `getter` 的话，那就直接在 `getter` 内使用就好

          ```js
          import { useOtherStore } from "./other-store";
          
          export const useStore = defineStore("main", {
            state: () => ({
              // ...
            }),
            getters: {
              otherGetter(state) {
                const otherStore = useOtherStore();
                return state.localData + otherStore.data;
              },
            },
          });
          ```

  - Action

    - Action 相当于组件中的 method；它们可以通过 `defineStore()` 中的 `actions` 属性来定义，并且它们也是定义业务逻辑的完美选择

      ```js
      export const useCounterStore = defineStore("main", {
        state: () => ({
          count: 0,
        }),
        actions: {
          increment() {
            this.count++;
          },
          randomizeCounter() {
            this.count = Math.round(100 * Math.random());
          },
        },
      });
      ```

      - 类似 `getter`，`action` 也可通过 `this` 访问整个 store 实例，并支持完整的类型标注

      - 不同的是，`action` 可以是异步的，可以在它们里面 `await` 调用任何 API，以及其他 action

        ```js
        import { mande } from "mande";
        
        const api = mande("/api/users");
        
        export const useUsers = defineStore("users", {
          state: () => ({
            userData: null,
            // ...
          }),
        
          actions: {
            async registerUser(login, password) {
              try {
                this.userData = await api.post({ login, password });
                showTooltip(`Welcome back ${this.userData.name}!`);
              } catch (error) {
                showTooltip(error);
                // 让表单组件显示错误
                return error;
              }
            },
          },
        });
        ```

      - 访问其他 `store` 的 `action`

        - 想要使用另一个 `store` 的话，那直接在 `action` 中调用就好了

          ```js
          import { useAuthStore } from "./auth-store";
          
          export const useSettingsStore = defineStore("settings", {
            state: () => ({
              preferences: null,
              // ...
            }),
            actions: {
              async fetchUserPreferences() {
                const auth = useAuthStore();
                if (auth.isAuthenticated) {
                  this.preferences = await fetchPreferences();
                } else {
                  throw new Error("User must be authenticated");
                }
              },
            },
          });
          ```

      - 订阅 action

        - 可以通过 `store.$onAction()` 来监听 `action` 和它们的结果

        - 传递给它的回调函数会在 `action` 本身之前执行

        - `after` 表示在 `promise` 解决之后，允许在 action 解决后执行一个回调函数

        - 同样地，`onError` 允许在 `action` 抛出错误或 `reject` 时执行一个回调函数

          ```js
          const unsubscribe = someStore.$onAction(
            ({
              name, // action 名称
              store, // store 实例，类似 `someStore`
              args, // 传递给 action 的参数数组
              after, // 在 action 返回或解决后的钩子
              onError, // action 抛出或拒绝的钩子
            }) => {
              // 为这个特定的 action 调用提供一个共享变量
              const startTime = Date.now();
              // 这将在执行 "store "的 action 之前触发
              console.log(`Start "${name}" with params [${args.join(", ")}].`);
          
              // 这将在 action 成功并完全运行后触发
              // 它等待着任何返回的 promise
              after((result) => {
                console.log(
                  `Finished "${name}" after ${
                    Date.now() - startTime
                  }ms.\nResult: ${result}.`
                );
              });
          
              // 如果 action 抛出或返回一个拒绝的 promise，这将触发
              onError((error) => {
                console.warn(
                  `Failed "${name}" after ${
                    Date.now() - startTime
                  }ms.\nError: ${error}.`
                );
              });
            }
          );
          
          // 手动删除监听器
          unsubscribe();
          ```

        - 默认情况下，`action `订阅器会被绑定到添加它们的组件上(如果 store 在组件的 `setup()` 内)

          - 这意味着，当该组件被卸载时，它们将被自动删除

          - 如果想在组件卸载后依旧保留它们，将 `true` 作为第二个参数传递给 `action `订阅器，以便将其从当前组件中分离

            ```vue
            <script setup>
            const someStore = useSomeStore();
            // 此订阅器即便在组件卸载之后仍会被保留
            someStore.$onAction(callback, true);
            </script>
            ```

  - 示例

    ```js
    import { createApp } from "vue";
    import { createPinia } from "pinia";
    import App from "./App.vue";
    
    const pinia = createPinia();
    const app = createApp(App);
    
    app.use(pinia);
    app.mount("#app");
    ```

    ```js
    import { defineStore } from "pinia";
    export const useCounterStore = defineStore("counter", {
      state: () => ({ count: 0, name: "Eduardo" }),
      getters: {
        doubleCount: (state) => state.count * 2,
      },
      actions: {
        increment() {
          this.count++;
        },
      },
    });
    ```

    ```js
    import { defineStore } from "pinia";
    export const useCounterStore = defineStore("counter", () => {
      const count = ref(0);
      const doubleCount = computed(() => count.value * 2);
      function increment() {
        count.value++;
      }
    
      return { count, doubleCount, increment };
    });
    ```

    ```vue
    <script setup>
    import { useCounterStore } from "@/stores/counter";
    // 可以在组件中的任意位置访问 `store` 变量
    const store = useCounterStore();
    setTimeout(() => {
      store.increment();
    }, 1000);
    </script>
    ```