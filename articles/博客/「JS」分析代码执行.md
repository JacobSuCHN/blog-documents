## 原型 原型链

![原型链](https://image.jslog.net/online/a-30/2024/12/17/原型链.svg)

> 蓝色为原型链

- 构造函数创建对象

  ```js
  function Person() {}
  var person = new Person();
  person.name = "JacobSu";
  console.log(person.name); // "JacobSu"
  ```

  - Person 就是一个构造函数
  - 使用 new 创建一个实例对象 person

- prototype

  ```js
  function Person() {}
  Person.prototype.name = "JacobSu";
  
  const person1 = new Person();
  const person2 = new Person();
  console.log(person1.name, person2.name); // "JacobSu" "JacobSu"
  ```

  - 每个函数都有一个 `prototype` 属性
  - prototype 是函数才会有的属性

- proto

  ```js
  function Person() {}
  const person = new Person();
  console.log(person.__proto__ === Person.prototype); // true
  ```

  - 每一个 JavaScript 对象（除了 null）都具有`__proto__`属性，这个属性会指向该对象的原型

- constructor

  ```js
  function Person() {}
  const person = new Person();
  console.log(Person === Person.prototype.constructor); // true
  ```

  - 没有原型指向实例的属性（PS：实例有过个）
  - 每个原型指都有一个 `constructor` 属性指向关联的构造函数

  ```js
  function Person() {}
  const person = new Person();
  console.log(Object.getPrototypeOf(person) === Person.prototype); // true
  ```

- 实例与原型

  - 当读取实例的属性时，如果找不到，就会查找与对象关联的原型中的属性，如果还查不到，就去找原型的原型，一直找到最顶层为止

  ```js
  console.log(Person.prototype.__proto__ === Object.prototype); // true
  ```

- 原型链

  - `Object.prototype` 没有原型== `Object.prototype.__proto__` 的值为 null

    ```js
    console.log(Object.prototype.__proto__); // null
    console.log(Object.prototype.__proto__ === null); // true
    ```

## 作用域

- 作用域

  - 作用域是指程序源代码中定义变量的区域
  - 作用域规定了如何查找变量，也就是确定当前执行代码对变量的访问权限

- 静态作用域与动态作用域

  - 静态作用域 / 词法作用域：作用域在函数定义时就确定好了（JS）
  - 动态作用域：函数作用域，在函数调用时才确定

  ```js
  var value = 1;
  function foo() {
    console.log(value);
  }
  function bar() {
    var value = 2;
    foo();
  }
  bar(); // 1
  ```

  ```js
  // case1
  var scope = "global scope";
  function checkscope() {
    var scope = "local scope";
    function f() {
      return scope;
    }
    return f();
  }
  console.log(checkscope()); // "local scope"
  
  // case2
  var scope = "global scope";
  function checkscope() {
    var scope = "local scope";
    function f() {
      return scope;
    }
    return f;
  }
  console.log(checkscope()()); // "local scope"
  ```

## 执行上下文

```js
var foo = function () {
  console.log("foo1");
};
foo(); // "foo1"
var foo = function () {
  console.log("foo2");
};
foo(); // "foo2"
```

```js
function foo() {
  console.log("foo1");
}
foo(); // "foo2"
function foo() {
  console.log("foo2");
}
foo(); // "foo2"
```

```js
console.log(add2(1, 1)); // 2
function add2(a, b) {
  return a + b;
}
console.log(add1(1, 1)); // Error
var add1 = function (a, b) {
  return a + b;
};
```

- 执行上下文（execution context） -> 准备工作，准备去执行

- 执行上下文栈（Execution context stack ECS）-FILO：管理执行上下文

  - 可执行代码类型

    - 全局类型
    - 函数类型
    - eval

    ```js
    ECStack = [functionContext, globalContext];
    ```

  - 当执行一个函数的时候，就会创建一个执行上下文，并且压入执行上下文栈，当函数执行完毕的时候，就会将函数的执行上下文从栈中弹出

![执行上下文1](https://image.jslog.net/online/a-30/2024/12/17/执行上下文1.svg)

![执行上下文2](https://image.jslog.net/online/a-30/2024/12/17/执行上下文2.svg)

- 每一个执行上下文中的属性

  - 变量对象 variable object VO

  - 作用域链 scope chain

  - this

## 变量对象

- 变量对象：是与执行上下文相关的数据作用域，存储了在上下文中定义的变量和函数声明。

- 全局上下文的变量对象

  - 全局对象是预定义的对象，作为 JavaScript 的全局函数和全局属性的占位符
  - 通过使用全局对象，可以访问所有其他所有预定义的对象、函数和属性
  - 在顶层 JavaScript 代码中，可以用关键字 this 引用全局对象
  - 客户端 JavaScript 中，全局对象就是 Window 对象-`console.log(this) // this === window`

- 函数上下文的变量对象

  - AO activation object 活动对象
  - 活动对象和变量对象其实是一个东西，只是变量对象是规范上的或者说是引擎实现上的，不可在 JavaScript 环境中访问，只有到当进入一个执行上下文中，这个执行上下文的变量对象才会被激活，所以才叫 activation object，而只有被激活的变量对象，也就是活动对象上的各种属性才能被访问
  - 活动对象是在进入函数上下文时刻被创建的，它通过函数的 arguments 属性初始化
  - arguments 属性值是 Arguments 对象

- 执行过程

  ```js
  function foo(a) {
    var b = 2;
    function c() {}
    var d = function () {};
  
    b = 3;
  }
  foo(1);
  ```

  - 进入执行上下文

    - 定义形式参数

    - 函数声明

    - 变量声明

      ```js
      AO = {
        arguments: {
          0: 1,
          length: 1
        },
        a: 1,
        b: undefined,
        c: reference to function c,
        d: undefined,
      }
      ```

  - 代码执行

    - 在代码执行阶段，会顺序执行代码，根据代码，修改变量对象的值

      ```js
      AO = {
        arguments: {
          0: 1,
          length: 1
        },
        a: 1,
        b: 3,
        c: reference to function c,
        d: reference to function expression,
      }
      ```

  ```js
  function foo() {
    console.log(a);
    a = 1; // 全局声明，不在当前AO中
  }
  foo(); // Error
  
  AO = {
    arguments: {
      length: 0,
    },
  };
  
  function bar() {
    a = 1; // 全局声明
    console.log(a);
  }
  bar(); // 1
  ```

## 作用域链

- 作用域链：当查找变量的时候，会先从当前上下文的变量对象中查找，如果没有找到，就会从父级（词法层面上的父级）执行上下文的变量对象中查找，一直找到全局上下文的变量对象，也就是全局对象；这样由多个执行上下文的变量对象构成的链表就叫做作用域链

- 函数的作用域在函数定义的时候就决定了，这是因为函数有一个内部属性 [[scope]]，当函数创建的时候，就会保存所有父变量对象到其中，可以理解 [[scope]] 就是所有父变量对象的层级链，注意：[[scope]] 并不代表完整的作用域链

  ```js
  function foo() {
    function bar() {}
  }
  ```

  - 函数创建

    ```js
    foo.[[scope]] = [
      globalContext.VO
    ]
    bar.[[scope]] = [
      fooContext.AO,
      globalContext.VO
    ]
    ```

  - 函数执行

    - 当函数激活时，进入函数上下文，创建 VO/AO 后，就会将活动对象添加到作用链的前端

    - `Scope = [AO].concat([[Scope]]);`

      ```js
      foo.[[scope]] = [
        fooContext.AO,
        globalContext.VO
      ]
      bar.[[scope]] = [
        barContext.AO,
        fooContext.AO,
        globalContext.VO
      ]
      ```

  ```js
  var scope = "global scope"
  function checkscope(){
    var scope2 = "local scope"
    return scope2
  }
  checkscope()
  
  // 创建时
  checkscope.[[scope]] = [
    globalContext.VO
  ]
  // 执行时
  checkScope.[[scope]] = [
    checkScope.AO,
    globalContext.VO
  ]
  
  checkScopeContext = {
    AO:{
      arguments: {
        length: 0
      },
      scope2: "local scope",
    },
    Scope: [
      checkScopeContext.AO,
      globalContext.VO
    ]
  }
  ```

- 闭包：能够访问自由变量的函数 -> 自由变量：能够在函数中使用，但既不是函数的参数，也不是局部变量的那些变量

  - 函数返回函数声明，执行函数后，在执行上下完栈中函数已经出栈
  - 但由于存在作用域链，在静态作用域的基础之下，通过作用域链就能够找到函数定义时它访问的变量

  ```js
  var scope = "global scope"
  function checkscope(){
    var scope = "local scope"
    function f(){
      return scope
    }
    return f
  }
  var foo = checkscope()
  foo()
  
  globalContext = {
    VO:{
      scope: "global scope",
      checkscope: reference to function checkscope,
      foo: function running,
    },
    Scope:[globalContext.VO]
  }
  
  checkScopeContext = {
    AO: {
      arguments:{
        length:0
      },
      scope:undefined,
      f: reference to f,
    },
    Scope:[
      checkScopeContext.AO,
      globalContext.VO
    ]
  }
  fContext = {
    AO: {
      arguments:{
        length:0
      }
    },
    Scope:[
      fContext.AO
      checkScopeContext.AO,
      globalContext.VO
    ]
  }
  ```

## this

- TLDR this 始终指向调用它的地方

## 分析代码执行

```js
var scope = "global scope";
function checkscope() {
  var scope = "local scope";
  function f() {
    return scope;
  }
  return f();
}
checkscope();
```

- 执行全局代码，创建全局执行上下文，全局上下文被压入执行上下文栈

  ```js
  ECStack = [globalContext];
  ```

- 全局上下文初始化

  ```js
  globalContext = {
    VO: {
      scope: "global scope",
      checkscope: function running,
    },
    Scope: [globalContext.VO],
    this: globalContext.VO,
  };
  ```

- 初始化的同时，checkscope 函数被创建，保存作用域链到函数的内部属性[[scope]]

  ```js
  checkscope.[[scope]] = [
    globalContext.VO
  ];
  ```

- 执行 checkscope 函数，创建 checkscope 函数执行上下文，checkscope 函数执行上下文被压入执行上下文栈

  ```js
  ECStack = [checkscopeContext, globalContext];
  ```

- checkscope 函数执行上下文初始化

  - 复制函数 [[scope]] 属性创建作用域链
  - 用 arguments 创建活动对象
  - 初始化活动对象，即加入形参、函数声明、变量声明
  - 将活动对象压入 checkscope 作用域链顶端

  同时 f 函数被创建，保存作用域链到 f 函数的内部属性[[scope]]

  ```js
  checkscopeContext = {
    AO: {
      arguments: {
        length: 0
      },
      scope: undefined,
      f: reference to function f(){}
    },
    Scope: [AO, globalContext.VO],
    this: undefined
  }
  ```

- f 函数执行，沿着作用域链查找 scope 值，返回 scope 值

- f 函数执行完毕，f 函数上下文从执行上下文栈中弹出

  ```js
  ECStack = [checkscopeContext, globalContext];
  ```

- checkscope 函数执行完毕，checkscope 执行上下文从执行上下文栈中弹出

  ```js
  ECStack = [globalContext];
  ```



