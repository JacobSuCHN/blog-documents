## 路由

- 路由：根据不同的 url 地址展示不同的内容或页面
- 前端路由：SPA 前端管理页面跳转

- 后端路由：url 不同 都会向服务器发送请求

  - 优点：减轻前端压力 html 由服务器拼接
  - 缺点：用户体验差

- 前端路由模式

  - hash 模式：`hash值`改变会触发 `onhashchange` 事件

    - localhost:8080/#home

  - history 模式：`history API`允许开发者直接更改 url 而不重新发送请求

    - localhost:8080/home
    - nginx 配置伪静态：解决页面刷新 404

    ```nginx
    location{
      root  /usr/local/nginx/html/dist;
      index index.html index.htm
      try_files $uri $uri/ /index.html
    }
    ```

## VueRouter 使用

- 配置路由

  ```js
  import Vue from "vue";
  import { createRouter, createWebHistory } from "vue-router";

  // 创建和挂载
  const routes = [
    { path: "/", component: { template: "<div>Home</div>" } },
    { path: "/about", component: { template: "<div>About</div>" } },
  ];

  const router = createRouter({
    history: createWebHistory(),
    routes,
  });

  const app = Vue.createAPP({});

  app.use(router);

  app.mount("#app");

  // 组件内使用
  import { useRouter } from "vue-router";

  const router = useRouter();
  console.log(router.createRoute);
  router.back();
  // ...
  ```

  - 默认情况下所有路由是不区分大小写的
  - 能匹配带有或不带有尾部斜线的路由

- 动态参数路由

  ```js
  const User = {
    template: "<div>User</div>",
  };

  // 这些都会传递给 `createRouter`
  const routes = [
    // 动态字段以冒号开始
    { path: "/users/:id", component: User },
  ];
  ```

  - `/users/jacob` 和 `/users/su` 这样的 URL 都会映射到同一个路由

  - `/users/jacob` => `/users/su` created 不会再次执行

    ```js
    // 方式一:// created监听路由变化
    const User = {
      template: "<div>User {{ $route.params.id }}</div>",
      created() {
        this.$watch(
          () => this.$route.params,
          () => {
            console.log();
          }
        );
      },
      // 方式二：导航守卫监听路由变化
      async beforeRouteUpdate(to, from) {
        console.log(to, from);
      },
    };
    ```

- 编程导航

  ```js
  const username = "eduardo";
  // 我们可以手动建立 url，但我们必须自己处理编码
  router.push(`/user/${username}`); // -> /user/eduardo
  // 同样
  router.push({ path: `/user/${username}` }); // -> /user/eduardo
  // 如果可能的话，使用 `name` 和 `params` 从自动 URL 编码中获益
  router.push({ name: "user", params: { username } }); // -> /user/eduardo
  // `params` 不能与 `path` 一起使用
  router.push({ path: "/user", params: { username } }); // -> /user
  ```

  ```js
  router.push({ path: "/home", replace: true });
  // 相当于
  router.replace({ path: "/home" });
  ```

- 命名路由

  ```js
  import Vue from "vue";
  import VueRouter from "vue-router";

  Vue.use(VueRouter);

  const Home = { template: "<div>This is Home</div>" };
  const Foo = { template: "<div>This is Foo</div>" };
  const Bar = { template: "<div>This is Bar {{ $route.params.id }}</div>" };

  const router = new VueRouter({
    mode: "history",
    base: __dirname,
    routes: [
      { path: "/", name: "home", component: Home },
      { path: "/foo", name: "foo", component: Foo },
      { path: "/bar/:id", name: "bar", component: Bar },
    ],
  });
  ```

  ```html
  <router-link :to="{ name: 'user', params: { username: 'erina' }}">
    User
  </router-link>
  ```

  ```js
  router.push({ name: "user", params: { username: "erina" } });
  ```

- 重定向

  - 重定向也是通过 `routes` 配置来完成

    ```js
    // /home 重定向到 /
    const routes = [{ path: "/home", redirect: "/" }];
    ```

    ```js
    const routes = [{ path: "/home", redirect: { name: "homepage" } }];
    ```

  - 动态返回重定向目标

    ```js
    const routes = [
      {
        // /search/screens 重定向到 /search?q=screens
        path: "/search/:searchText",
        redirect: (to) => {
          // 方法接收目标路由作为参数
          // return 重定向的字符串路径/路径对象
          return { path: "/search", query: { q: to.params.searchText } };
        },
      },
      {
        path: "/search",
        // ...
      },
    ];
    ```

  - 定位到相对重定向

    ```js
    const routes = [
      {
        // /users/123/posts 重定向到 /users/123/profile。
        path: "/users/:id/posts",
        redirect: (to) => {
          // 该函数接收目标路由作为参数
          // 相对位置不以`/`开头
          // 或 { path: 'profile'}
          return "profile";
        },
      },
    ];
    ```

- 不同路由模式

  ```js
  import {
    createRouter,
    createWebHashHistory,
    createWebHistory,
  } from "vue-router";

  const router = createRouter({
    // history: createWebHashHistory(),
    history: createWebHistory(),
    routes: [
      //...
    ],
  });
  ```

## 手写简版 VueRouter

- 目标

  - 监测 url 变化
  - 改变 url 不引起页面刷新
  - 支持 hash 和 history 模式
  - 创建 router-link 和 router-view 组件

- 文件结构

  ```sh
  ├── public
  │   ├── favicon.ico
  │   ├── index.html
  │   └── test.html
  ├── src
  │   ├── router
  │   │   ├── index.js
  │   │   └── myVueRouter.js
  │   ├── views
  │   │   ├── About.vue
  │   │   └── Home.vue
  │   ├── App.vue
  │   └── main.js
  ├── .gitignore
  ├── package.json
  └── pnpm-lock.yaml
  ```

- 代码

  - `src/router/myVueRouter.js`

    ```js
    class HistoryRoute {
      constructor() {
        this.current = null;
      }
    }
    class VueRouter {
      constructor(options) {
        this.mode = options.mode || "hash";
        this.routes = options.routes || []; //你传递的这个路由是一个数组表
        this.routesMap = this.createMap(this.routes);
        this.history = new HistoryRoute();
        this.init();
      }
      init() {
        if (this.mode === "hash") {
          // 先判断用户打开时有没有hash值，没有的话跳转到#/
          location.hash ? "" : (location.hash = "/");
          window.addEventListener("load", () => {
            this.history.current = location.hash.slice(1);
          });
          window.addEventListener("hashchange", () => {
            this.history.current = location.hash.slice(1);
          });
        } else {
          location.pathname ? "" : (location.pathname = "/");
          window.addEventListener("load", () => {
            this.history.current = location.pathname;
          });
          window.addEventListener("popstate", () => {
            this.history.current = location.pathname;
          });
        }
      }

      createMap(routes) {
        return routes.reduce((pre, current) => {
          pre[current.path] = current.component;
          return pre;
        }, {});
      }
    }
    VueRouter.install = function (Vue) {
      Vue.mixin({
        beforeCreate() {
          if (this.$options && this.$options.router) {
            // 根组件
            this._root = this; //把当前实例挂载到_root上
            this._router = this.$options.router;
            // 定义响应式数据
            Vue.util.defineReactive(this._router, "history");
          } else {
            // 子组件
            this._root = this.$parent && this.$parent._root;
          }
          Object.defineProperty(this, "$router", {
            get() {
              return this._root._router;
            },
          });
        },
      });
      Vue.component("router-link", {
        props: {
          to: String,
        },
        render(h) {
          // _self: 实例本身属性，指向实例自身
          let mode = this._self._root._router.mode;
          let to = mode === "hash" ? "#" + this.to : this.to;
          return h(
            "a",
            {
              attrs: { href: to },
              on: {
                click: (e) => {
                  // 阻止浏览器刷新
                  history.pushState({}, "", to);
                  this._self._root._router.history.current = to;
                  e.preventDefault();
                },
              },
            },
            this.$slots.default
          );
        },
      });
      Vue.component("router-view", {
        render(h) {
          let current = this._self._root._router.history.current;
          let routeMap = this._self._root._router.routesMap;
          return h(routeMap[current]);
        },
      });
    };

    export default VueRouter;
    ```

    - `&&短路`行为
      - 第一个表达式的结果为 `false`，那么整个表达式的结果就确定为 `false`，并且不会评估第二个表达式
      - 第一个表达式的结果为 `true`，那么就会评估第二个表达式，并且整个表达式的结果就是第二个表达式的结果
      - `this._root = this.$parent && this.$parent._root;`
      - 如果第一个对象在逻辑上被视为 `false`（在 JavaScript 中，只有 `null`、`undefined`、`NaN`、空字符串 `""`、数字 `0` 和布尔值 `false` 被视为假值），那么整个表达式的结果就是第一个对象（在这种情况下，这个假值对象）
      - 如果第一个对象在逻辑上被视为 `true`（即它不是上述任何假值），那么 JavaScript 会评估第二个对象，并且整个表达式的结果就是第二个对象

  - `src/router/index.js`

    ```js
    import Vue from "vue";
    import VueRouter from "./myVueRouter";
    import Home from "../views/Home.vue";
    import About from "../views/About.vue";
    Vue.use(VueRouter);
    const routes = [
      {
        path: "/home",
        name: "Home",
        component: Home,
      },
      {
        path: "/about",
        name: "About",
        component: About,
      },
    ];
    const router = new VueRouter({
      mode: "hash",
      routes,
    });
    export default router;
    ```

  - `App.vue`

    ```vue
    <template>
      <div id="app">
        <div id="nav">
          <router-link to="/home">Home</router-link>|
          <router-link to="/about">About</router-link>
        </div>
        <router-view />
      </div>
    </template>
    ```

  - `Home.vue`

    ```vue
    <template>
      <div class="home">
        <h1>这是Home组件</h1>
      </div>
    </template>
    <script>
    export default {
      name: "Home",
    };
    </script>
    ```

  - `About.vue`

    ```vue
    <template>
      <div class="about">
        <h1>这是about组件</h1>
      </div>
    </template>
    <script>
    export default {
      name: "About",
    };
    </script>
    ```

  - `main.js`

    ```js
    import Vue from "vue";
    import App from "./App.vue";
    import router from "./router";

    Vue.config.productionTip = false;

    new Vue({
      router,
      render: function (h) {
        return h(App);
      },
    }).$mount("#app");
    ```
