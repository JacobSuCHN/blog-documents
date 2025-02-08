## AST

- AST 抽象语法树

  - 应用：代码语法检查 代码风格检查 代码格式化 代码错误提示 代码自动补全等
  - 前端工程化基石
  - 构建工具

    - webpack plugin loader
    - postcss
    - eslint

  - 开发工具

    - react
    - ts

  - 编译器

    - es6 jsx => js
    - 编译：从高级语言转换成低级语言

    - 高级语言：分支 循环 函数 判断等

    - 低级语言：汇编语言 机器语言

    - 前端

      - less/sass -> css
      - ts -> js
      - 编译时 rax -> 小程序 跨段

- 编译器思路

  - 词法分析
    分词器 tokenizer
    input -> token
  - 语法分析
    babel：es6 -> @babel/parser -> AST-> @babel/traverse -> 新 AST -> @babel/generator -> es5
  - 代码转换
    AST -> 新 AST

  - 流程：input => tokenizer => tokens => parser => AST => transformer => new AST => generator => output

## babel

- 用途
  - 转译 esnext、typescript 等到目标环境支持的 js
  - 代码的静态检查：linter 工具也是基于 AST 对代码检查
- @babel
  - @babel/parser: 接受源码，进行词法分析、语法分析，生成 AST
  - @babel/traverse：接受一个 AST，并对其遍历，根据 preset、plugin 进行逻辑处理，进行替换、删除、添加节点
  - @babel/generator：接受最终生成的 AST，并将其转换为代码字符串，同时此过程也可以创建 source map
  - @babel/types：用于检验、构建和改变 AST 树的节点
  - @babel/core: babel 的编译器，核心 API 都在这里面，比如常见的 transform、parse，并实现了插件功能

> [AST Explorer](https://astexplorer.net/)

- babel 插件

  - babel 插件是一个简单的函数，它必须返回一个匹配以下接口的对象

    ```js
    export default function (api, options, dirname) {
      return {
        name：'',
        pre(){},
        visitor: {},
        post(){},
      };
    }
    ```

  - babel 插件接受 3 个参数
    - api：一个对象，包含了 types (@babel/types)、traverse (@babel/traverse)、template(@babel/template) 等实用方法，我们能从这个对象中访问到 @babel/core dependecies 中包含的方法
    - options：插件参数
    - dirname：目录名
  - 返回的对象有 name、manipulateOptions、pre、visitor、post、inherits 等属性
    - name：插件名字
    - inherits：指定继承某个插件，通过 Object.assign 的方式，和当前插件的 options 合并
    - visitor：指定 traverse 时调用的函数
    - pre 和 post 分别在遍历前后调用，可以做一些插件调用前后的逻辑，比如可以往 file（表示文件的对象，在插件里面通过 state.file 拿到）中放一些东西，在遍历的过程中取出来
    - manipulateOptions：用于修改 options，是在插件里面修改配置的方式

- babel 插件 demo

  ```js
  // 源代码
  const hello = () => {};
  // 需要修改为
  const world = () => {};
  ```

  ```js
  const parser = require("@babel/parser");
  const traverse = require("@babel/traverse");
  const generator = require("@babel/generator");

  const transToLet = (code) => {
    const ast = parser.parse(code);
    // 访问者对象
    const visitor = {
      // 遍历声明表达式
      // 可以直接通过节点的类型操作AST节点。
      Identifier(path) {
        if (path.node.name === "hello") {
          path.node.name = "world";
        }
      },
    };
    traverse.default(ast, visitor);
    // 生成代码
    const newCode = generator.default(ast, {}, code).code;
    return newCode;
  };

  const code = `const hello = () => {};`;
  console.log(transToLet(code));
  ```

  ```js
  const parser = require("@babel/parser");
  const traverse = require("@babel/traverse");
  const generator = require("@babel/generator");

  const transToLet = (code) => {
    const ast = parser.parse(code);

    traverse.default(ast, {
      enter(path) {
        if (path.isIdentifier({ name: "hello" })) {
          path.node.name = "world";
        }
      },
    });

    return generator.default(ast, {}, code).code;
  };

  const code = `const hello = () => {};`;

  console.log(transToLet(code));
  ```

  ```js
  const core = require("@babel/core");

  const sourceCode = `const hello = () => {};`;

  const myPlugin = {
    visitor: {
      Identifier: (path) => {
        if (path.node.name === "hello") {
          path.node.name = "world";
        }
      },
    },
  };

  const targetSource = core.transform(sourceCode, {
    plugins: [myPlugin],
  }).code;

  console.log(targetSource);
  ```

- path

  - `inList()`：判断节点是否在数组中，如果 container 为数组，也就是有 listkey 的时候，返回 true
  - `get(key)`：获取某个属性的 path
  - `set(key, node)`：设置某个属性的值
  - `getSibling(key)`：获取某个下标的兄弟节点
  - `getNextSibling()`：获取下一个兄弟节点
  - `getPrevSibling()`：获取上一个兄弟节点
  - `getAllPrevSiblings()`：获取之前的所有兄弟节点
  - `getAllNextSiblings()`：获取之后的所有兄弟节点
  - `find(callback)`：从当前节点到根节点来查找节点（包括当前节点），调用 callback（传入 path）来决定是否终止查找
  - `findParent(callback)`：从当前节点到根节点来查找节点（不包括当前节点），调用 callback（传入 path）来决定是否终止查找
  - `isXxx(opts)`：判断当前节点是否是某个类型，可以传入属性和属性值进一步判断，比如 path.isIdentifier({name: 'a'})
  - `assertXxx(opts)`：同 isXxx，但是不返回布尔值，而是抛出异常
  - `insertBefore(nodes)`：在之前插入节点，可以是单个节点或者节点数组
  - `insertAfter(nodes)`：在之后插入节点，可以是单个节点或者节点数组
  - `replaceWith(replacement)`：用某个节点替换当前节点
  - `replaceWithMultiple(nodes)`：用多个节点替换当前节点
  - `replaceWithSourceString(replacement)`：解析源码成 AST，然后替换当前节点
  - `remove()`：删除当前节点
  - `traverse(visitor, state)`：遍历当前节点的子节点，传入 visitor 和 state（state 是不同节点间传递数据的方式）
  - `skip()`：跳过当前节点的子节点的遍历
  - `stop()`：结束所有遍历

- 转换箭头函数

  - 插件：`babel-plugin-transform-es2015-arrow-functions`
  - 转换结果

    ```js
    const core = require("@babel/core"); //babel核心模块
    let arrowFunctionPlugin = require("babel-plugin-transform-es2015-arrow-functions"); //转换箭头函数插件

    let sourceCode = `const sum = (a, b) => {
      return a + b;
    }`;
    let targetSource = core.transform(sourceCode, {
      plugins: [arrowFunctionPlugin], //使用插件
    });

    console.log(targetSource.code);

    // const sum = function (a, b) {
    //  return a + b;
    // };
    ```

  - 简易实现

    ```js
    const core = require("@babel/core"); //babel核心模块

    let sourceCode = `
    const sum = (a, b) => {
        return a + b;
    }
    `;

    const arrowFunctionPlugin = {
      visitor: {
        //如果是箭头函数，那么就会进来此函数，参数是箭头函数的节点路径对象
        ArrowFunctionExpression(path) {
          let { node } = path;
          node.type = "FunctionExpression";
        },
      },
    };

    let targetSource = core.transform(sourceCode, {
      plugins: [arrowFunctionPlugin], //使用插件
    });

    console.log(targetSource.code);
    ```

  - 复杂实现

    - 处理箭头函数使用简写的语法
    - 处理箭头函数中的 this

    ```js
    const core = require("@babel/core"); //babel核心模块
    let types = require("@babel/types"); //用来生成或者判断节点的AST语法树的节点

    let sourceCode = `
      const sum = (a, b) => {
        console.log(this);
        return a + b;
      };
    `;

    /**
     * 思路：
     * 第一步：找到当前箭头函数要使用哪个作用域内的this，暂时称为父作用域
     * 第二步：往父作用域中加入_this变量，也就是var _this=this
     * 第三步：找出当前箭头函数内所有用到this的地方
     * 第四步：将当前箭头函数中的this，统一替换成_this
     */
    function hoistFunctionEnvironment(path) {
      //确定当前箭头函数要使用哪个地方的this
      const thisEnv = path.findParent((parent) => {
        return (
          (parent.isFunction() && !parent.isArrowFunctionExpression()) ||
          parent.isProgram()
        ); //要求父节点是函数且不是箭头函数，找不到就返回根节点
      });

      //向父作用域内放入一个_this变量
      thisEnv.scope.push({
        id: types.identifier("_this"), //生成标识符节点,也就是变量名
        init: types.thisExpression(), //生成this节点 也就是变量值
      });

      let thisPaths = []; //获取当前节点this的路径
      //遍历当前节点的子节点
      path.traverse({
        ThisExpression(thisPath) {
          thisPaths.push(thisPath);
        },
      });

      //替换
      thisPaths.forEach((thisPath) => {
        thisPath.replaceWith(types.identifier("_this")); //this => _this
      });
    }

    const arrowFunctionPlugin = {
      visitor: {
        //如果是箭头函数，那么就会进来此函数，参数是箭头函数的节点路径对象
        ArrowFunctionExpression(path) {
          let { node } = path;
          hoistFunctionEnvironment(path); //提升函数环境，解决this作用域问题

          node.type = "FunctionExpression"; //箭头函数转换为普通函数
          //如果函数体不是块语句
          if (!types.isBlockStatement(node.body)) {
            node.body = types.blockStatement([
              types.returnStatement(node.body),
            ]);
          }
        },
      },
    };

    let targetSource = core.transform(sourceCode, {
      plugins: [arrowFunctionPlugin], //使用插件
    });

    console.log(targetSource.code);
    ```
