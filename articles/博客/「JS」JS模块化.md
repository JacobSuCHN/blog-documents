## 模块化的概念

- 为什么使用模块化
  - 内部子模块 scope
  - 多个模块间管理
  - 在模块维度上 complier

## 模块化演进过程

- 全局函数模式

  ```js
  function m1() {}
  function m2() {}
  ```

  - 作用：将不同的功能封装成不同的全局函数
  - 编码：全局函数
  - 问题：污染全局命名空间，容易引起命名冲突或数据不安全，而且模块成员之间看不出直接关系

- namespace 模式

  ```js
  let modalA = {
    data: "js",
    foo() {},
    bar() {},
  };
  modalA.data = "sx"; // 可被重写
  ```

  - 作用：减少了全局变量，解决命名冲突
  - 编码：对象封装
  - 问题：数据不安全（外部可以直接修改模块内部的数据）

- IIFE 模式

  ```js
  (function () {
    var a = 1;
    console.log(a);
  })()(function (params, $) {
    let data = "js";
    function getData() {
      return data;
    }
    function setData(val) {
      data = val;
    }

    params.modalA = {
      getData,
      setData,
    };
  })(window, jQuery);
  ```

  - 作用：数据是私有的, 外部只能通过暴露的方法操作
  - 编码：IIFE 匿名函数自调用（立即执行函数，闭包），将数据和行为，装到一个函数内部，通过给 window 添加属性来向外暴露接口
  - 问题：引用依赖模糊，引用顺序不可变

## 模块化规范

- CommonJS

  ```js
  // example.js
  var x = 5
  var addX = function (value) {
    return value + x
  }
  module.exports.x = x
  module.exports.addX = addX
  // demo.js
  var example = require(./example.js)
  console.log(example.x); // 5
  console.log(example.addX(1)); // 6
  ```

  ```js
  // lib.js
  var counter = 3;
  function incCounter() {
    counter++;
  }
  module.exports = {
    counter: counter,
    incCounter: incCounter,
  };
  // main.js
  var counter = require("./lib").counter;
  var incCounter = require("./lib").incCounter;
  console.log(counter); // 3
  incCounter();
  console.log(counter); // 3
  ```

  - CommonJS 规范加载模块是同步的
  - browserify：commonjs 在浏览器中使用，转化成立即执行函数

- AMD

  - async module definition

  - require.js：实现 AMD 规范的 js 库

    ```js
    |-js
      |-libs
        |-require.js
      |-modules
        |-alerter.js
        |-dataService.js
      |-main.js
    |-index.html
    ```

    ```js
    // dataService.js文件
    // 定义没有依赖的模块
    define(function () {
      let msg = "www.chenghuai.com";
      function getMsg() {
        return msg.toUpperCase();
      }
      return { getMsg }; // 暴露模块
    });

    //alerter.js文件
    // 定义有依赖的模块
    define(["dataService"], function (dataService) {
      let name = "chenghuai";
      function showMsg() {
        alert(dataService.getMsg() + ", " + name);
      }
      // 暴露模块
      return { showMsg };
    })(
      // main.js文件
      function () {
        require.config({
          baseUrl: "js/", //基本路径 出发点在根目录下
          paths: {
            //映射: 模块标识名: 路径
            alerter: "./modules/alerter", //此处不能写成alerter.js,会报错
            dataService: "./modules/dataService",
          },
        });
        require(["alerter"], function (alerter) {
          alerter.showMsg();
        });
      }
    )();
    ```

    ```html
    // index.html文件
    <!DOCTYPE html>
    <html>
      <head>
        <title>Modular Demo</title>
      </head>
      <body>
        <!-- 引入require.js并指定js主文件的入口 -->
        <script data-main="js/main" src="js/libs/require.js"></script>
      </body>
    </html>
    ```

- CMD

  - Common module definition：CommonJS + AMD

  - sea.js：实现 CMD 规范的 js 库

    ```js
    |-js
      |-libs
        |-sea.js
      |-modules
        |-module1.js
        |-module2.js
        |-module3.js
        |-module4.js
        |-main.js
    |-index.html
    ```

    ```js
    // module1.js文件
    define(function (require, exports, module) {
      //内部变量数据
      var data = "chenghuai.com";
      //内部函数
      function show() {
        console.log("module1 show() " + data);
      }
      //向外暴露
      exports.show = show;
    });

    // module2.js文件
    define(function (require, exports, module) {
      module.exports = {
        msg: "I am chenghuai",
      };
    });

    // module3.js文件
    define(function (require, exports, module) {
      const API_KEY = "abc123";
      exports.API_KEY = API_KEY;
    });

    // module4.js文件
    define(function (require, exports, module) {
      //引入依赖模块(同步)
      var module2 = require("./module2");
      function show() {
        console.log("module4 show() " + module2.msg);
      }
      exports.show = show;
      //引入依赖模块(异步)
      require.async("./module3", function (m3) {
        console.log("异步引入依赖模块3  " + m3.API_KEY);
      });
    });

    // main.js文件
    define(function (require) {
      var m1 = require("./module1");
      var m4 = require("./module4");
      m1.show();
      m4.show();
    });
    ```

    ```html
    <script type="text/javascript" src="js/libs/sea.js"></script>
    <script type="text/javascript">
      seajs.use("./js/modules/main");
    </script>
    ```

  - AMD 与 CMD 区别

    ```js
    // CMD
    define(function (requie, exports, module) {
      //依赖就近书写
      var module1 = require("Module1");
      var result1 = module1.exec();
      module.exports = {
        result1: result1,
      };
    });

    // AMD
    define(["Module1"], function (module1) {
      var result1 = module1.exec();
      return {
        result1: result1,
      };
    });
    ```

- ESM

  - ecmascript module definition

  - import export

  ```js
  //module1.js文件
  // 分别暴露
  export function foo() {
    console.log("foo() module1");
  }
  export function bar() {
    console.log("bar() module1");
  }

  //module2.js文件
  // 统一暴露
  function fun1() {
    console.log("fun1() module2");
  }
  function fun2() {
    console.log("fun2() module2");
  }
  export { fun1, fun2 };

  //module3.js文件
  // 默认暴露 可以暴露任意数据类项，暴露什么数据，接收到就是什么数据
  export default () => {
    console.log("默认暴露");
  };

  // app.js文件
  import { foo, bar } from "./module1";
  import { fun1, fun2 } from "./module2";
  import module3 from "./module3";
  foo();
  bar();
  fun1();
  fun2();
  module3();
  ```

  - ESM 与 CommonJS 的区别

    - CommonJS：值的拷贝

      ```js
      // lib.js
      var counter = 3;
      function incCounter() {
        counter++;
      }
      module.exports = {
        counter: counter,
        incCounter: incCounter,
      };
      // main.js
      var counter = require("./lib").counter;
      var incCounter = require("./lib").incCounter;
      console.log(counter); // 3
      incCounter();
      console.log(counter); // 3
      ```

    - ESM：值的引用

      ```js
      // lib.js
      let counter = 3;
      function incCounter() {
        counter++;
      }
      export { counter, incCounter };
      // main.js
      import { counter, incCounter } from "./lib";
      console.log(counter); // 3
      incCounter();
      console.log(counter); // 4
      ```

    - ES6 模块的设计思想是尽量的静态化，使得编译时就能确定模块的依赖关系，以及输入和输出的变量

- UMD

  - universal module definition
  - 同时满足 CommonJS，AMD，CMD 的标准

  ```js
  (function (root, factory) {
    if (typeof module === "object" && typeof module.exports === "object") {
      console.log("是commonjs模块规范，nodejs环境");
      module.exports = factory();
    } else if (typeof define === "function" && define.amd) {
      console.log("是AMD模块规范，如require.js");
      define(factory);
    } else if (typeof define === "function" && define.cmd) {
      console.log("是CMD模块规范，如sea.js");
      define(function (require, exports, module) {
        module.exports = factory();
      });
    } else {
      console.log("没有模块环境，直接挂载在全局对象上");
      root.umdModule = factory();
    }
  })(this, function () {
    return {
      name: "我是一个umd模块",
    };
  });
  ```
