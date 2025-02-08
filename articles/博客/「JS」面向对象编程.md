## 参数按值传递

- 按值传递：把函数外部的值复制给函数内部的参数，就和把值从一个变量复制到另一个变量一样

  ```js
  var value = 1;
  function foo(v) {
    v = 2;
    console.log(v); // 2
  }
  foo(value);
  console.log(value); // 1
  
  var obj = {
    value: 1,
  };
  function foo(o) {
    o.value = 2;
    console.log(o.value); // 2
  }
  foo(obj);
  console.log(obj.value); // 2
  ```

  - ECMAScript 中所有函数的参数都是按值传递的
  - 按值传递：基础数据类型

  - 共享传递：引用数据类型

## 原型与原型链


> 简单说说 JavaScript 原型继承的概念
>
> 怎么理解 prototype 和 \_\_proto\_\_

```js
// 构造器/类：用来构造实例对象
function Person() {}

// 原型
Person.prototype.say = function () {
  console.log("hello");
};

// 对象
const person = new Person();
person.say(); // "hello"

console.log(Person.__proto__ === Function.prototype); // true
const regx = /hello/gi;
console.log(regx.__proto__ === RegExp.prototype);
```

- 顶级父类 `Object.prototype.__proto__`

- 对象的\_\_proto\_\_指向对象构造器的原型

## 继承的多种方式与优缺点

- 原型链继承

  ```js
  function Parent() {
    this.names = ["xianzao", "zaoxian"];
  }
  function Child() {}
  Child.prototype = new Parent();
  let child1 = new Child();
  child1.names.push("test");
  console.log(child1.names); // ["xianzao", "zaoxian", "test"]
  let child2 = new Child();
  console.log(child2.names); // ["xianzao", "zaoxian", "test"]
  ```

  - 缺点：引用类型的属性被所有实例共享

- 构造函数借用

  ```js
  function Parent() {
    this.names = ["xianzao", "zaoxian"];
  }
  function Child() {
    Parent.call(this);
  }
  let child1 = new Child();
  child1.names.push("test");
  console.log(child1.names); // ["xianzao", "zaoxian", "test"]
  let child2 = new Child();
  console.log(child2.names); // ["xianzao", "zaoxian"]
  ```

  - 优点
    - 避免了引用类型的属性被所有实例共享
    - 可以在 Child 中向 Parent 传参

  ```js
  function Parent(name) {
    this.name = name;
  }
  function Child(name) {
    Parent.call(this, name);
  }
  let child1 = new Child("child1");
  console.log(child1.name); // "child1"
  let child2 = new Child("child2");
  console.log(child2.name); // "child2"
  ```

  - 缺点：方法都在构造函数中定义，每次创建实例都会创建一遍方法

- 组合继承

  ```js
  function Parent(name) {
    this.name = name;
    this.colors = ["red", "blue", "green"];
  }
  Parent.prototype.getName = function () {
    console.log(this.name);
  };
  function Child(name, age) {
    Parent.call(this, name); // 构造器借用了
    this.age = age;
  }
  Child.prototype = new Parent(); // 原型链继承
  Child.prototype.constructor = Child; // 将构造器引用指回来
  let child1 = new Child("kevin", "18");
  child1.colors.push("black");
  console.log(child1.name); // "kevin"
  console.log(child1.age); // 18
  console.log(child1.colors); // ["red", "blue", "green", "black"]
  let child2 = new Child("daisy", "20");
  console.log(child2.name); // "daisy"
  console.log(child2.age); // 20
  console.log(child2.colors); // ["red", "blue", "green"]
  ```

  - ==优点：融合原型链继承和构造函数的优点，是 JavaScript 中最常用的继承模式==
  
- 原型继承

  ```js
  function createObj(o) {
    function F() {}
    F.prototype = o;
    return new F();
  }
  ```

  - 缺点：包含引用类型的属性值始终都会共享相应的值，这点跟原型链继承一样

  ```js
  var person = {
    name: "kevin",
    friends: ["daisy", "kelly"],
  };
  var person1 = createObj(person);
  var person2 = createObj(person);
  person1.name = "person1";
  console.log(person2.name); // "kevin"
  person1.friends.push("taylor");
  console.log(person2.friends); // ["daisy", "kelly", "taylor"]
  ```

- 寄生式继承

  - 创建一个仅用于封装继承过程的函数，该函数在内部以某种形式来做增强对象，最后返回对象

    ```js
    function createObj(o) {
      var clone = Object.create(o);
      clone.sayName = function () {
        console.log("hi");
      };
      return clone;
    }
    ```

## 手写硬绑定（call/apply/bind）

- this 指向首先需要跟执行上下文挂钩，其次与绑定方式挂钩

- 绑定方式

  - 软绑定（始终指向调用它的地方）

    ```js
    this.name = "window";
    function test() {
      console.log(this.name);
      console.log(arguments); // 箭头函数没有arguments
    }
    const js = {
      name: "js",
      test: test,
    };
    test(); // "window"
    js.test(); // "js"
    ```

  - 硬绑定（call、apply、bind）

    ```js
    function test() {
      console.log(this.name);
      console.log(arguments); // 箭头函数没有arguments
    }
    const sx = { name: "sx" };
    test.call(sx, 1, 2);
    // "sx"
    // [1, 2, ...]
    test.apply(sx, [1, 2]);
    // "sx"
    // [1, 2, ...]
    const t = test.bind(sx);
    t(1, 2);
    // "sx"
    // [1, 2, ...]
    ```

- 手写 call

  - call() ：在使用一个指定的 this 值和若干个指定的参数值的前提下调用某个函数或方法

    ```js
    function test() {
      console.log(this.name);
      console.log(arguments); // 箭头函数没有arguments
    }
    const sx = { name: "sx" };
    Function.prototype.myCall = function (context, ...args) {
      // 用户嗅探
      const globalCtx = typeof window === "undefined" ? globalThis : window;
      // 参数兜底
      const ctx = context || globalCtx;
      // 避免覆盖
      let fnSymbol = Symbol();
      ctx[fnSymbol] = this;
      let fn = ctx[fnSymbol](...args);
      delete ctx[fnSymbol];
      return fn;
    };
  
    test.myCall(sx, 1, 2); // this指向test
    test.myCall(null);
    ```

- 手写 apply

  - apply()：apply、call 作用完全一样，只是接受参数的方式不太一样，call 接参为一个或多个参数，apply 接参为一个数组

    ```js
    Function.prototype.myApply = function (context, args) {
      const globalCtx = typeof window === "undefined" ? globalThis : window;
      const ctx = context || globalCtx;
      let fnSymbol = Symbol();
      ctx[fnSymbol] = this;
      let fn = ctx[fnSymbol](...(args || []));
      delete ctx[fnSymbol];
      return fn;
    };
    test.myApply(sx, 1, 2); // this指向test
    test.myApply(null);
    ```

- 手写 bind

  - bind()：指定的 this 值，但不会像 call 和 apply 立即执行

    ```js
    Function.prototype.myBind = function (context) {
      const globalCtx = typeof window === "undefined" ? globalThis : window;
      const ctx = context || globalCtx;
      self = this;
      return function (...args) {
        return self.apply(ctx, args);
      };
    };
    const t = test.myBind(sx); // this指向test
    t(1, 2);
    ```
