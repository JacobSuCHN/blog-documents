## 函数式编程

- 海鸥程序

  - 面向对象编程

    ```js
    const Flock = function (n) {
      this.seagulls = n;
    };

    Flock.prototype.conjoin = function (other) {
      this.seagulls += other.seagulls;
      return this;
    };

    Flock.prototype.breed = function (other) {
      this.seagulls = this.seagulls * other.seagulls;
      return this;
    };

    const flock_a = new Flock(4);
    const flock_b = new Flock(2);
    const flock_c = new Flock(0);

    let result = flock_a
      .conjoin(flock_c)
      .breed(flock_b)
      .conjoin(flock_a.breed(flock_b)).seagulls;
    console.log(result); // 32
    ```

    - 期望是 16，但输出结果是 32

    - 错误原因：seagulls 私有属性在运算过程中永久地改变了

    - 这样的代码形式会使得代码的内部状态变得非常难以追踪

  - 函数式编程

    ```js
    // 没有使用共享的数据，共享的属性
    // 纯函数：没有副作用，不会改变外部的数据
    // 纯函数保证相同的输入，永远会得到相同的输出
    const conjoin = function (flock_x, flock_y) {
      return flock_x + flock_y;
    };
    const breed = function (flock_x, flock_y) {
      return flock_x * flock_y;
    };

    const flock_a = 4;
    const flock_b = 2;
    const flock_c = 0;

    let result = conjoin(
      breed(flock_b, conjoin(flock_a, flock_c)),
      breed(flock_a, flock_b)
    );
    console.log(result); // 16
    ```

- 函数式编程的优势

  - 可读性提升

  - 可维护性提升

  - 结果可预测

  - 可测试性提升

- 函数式编程带来的好处

  - react hooks 的实现，代数效应
  - composition api 实现

- 函数是`一等公民（first-class citizen）`

  - 编程语言中，一等公民可以作为函数参数，可以作为函数返回值，也可以赋值给变量

  - 函数为一等公民是函数式编程的基础

## 纯函数

- 纯函数：即相同的输入，永远会得到相同的输出，而且没有任何可观察的副作用

  ```js
  // 没有使用共享的数据，共享的属性
  // 纯函数：没有副作用，不会改变外部的数据
  // 纯函数保证相同的输入，永远会得到相同的输出
  const add = function (a, b) {
    return a + b;
  };
  const multiply = function (a, b) {
    return a * b;
  };

  const flock_a = 4;
  const flock_b = 2;
  const flock_c = 0;

  let result = add(
    multiply(flock_b, add(flock_a, flock_c)),
    multiply(flock_a, flock_b)
  );
  console.log(result); // 16
  ```

  ```js
  // 保证函数的输入一致，不一定时纯函数
  async function getData(url) {
    // 内部有无法预知的操作
    const result = await fetch(url).then((res) => res.json());
    return result;
  }
  ```

- 常见的副作用

  - 更改文件系统

  - 往数据库插入记录

  - 发送一个 http 请求

  - 可变数据

  - 打印/log

  - 获取用户输入

  - DOM 查询

  - 访问系统状态...

- 纯函数的好处

  - 可缓存性

    ```js
    // 用于缓存函数
    function add(a, b) {
      // 占用计算资源
      for (let i = 0; i < 1000000000; i++) {
        // do something
      }
      return a + b;
    }

    // console.log(add(1, 2)); // 3
    // console.log(add(1, 2)); // 3
    // console.log(add(1, 2)); // 3
    // console.log(add(1, 2)); // 3

    // 缓存函数
    function memorize(fn) {
      // 缓存区
      const cache = {};
      // const cache = new Map();

      // 实现缓存命中
      return function () {
        // 把确定的入参处理之后作为key，函数结果作为value，存入缓存区
        const argsStr = JSON.stringify(arguments);
        // 命中缓存
        const cacheValue = cache[argsStr];
        if (cacheValue) {
          return cacheValue;
        }

        // 未命中缓存
        const value = fn.apply(this, arguments);
        cache[argsStr] = value;
        return value;
      };
    }

    const memorizedAdd = memorize(add);

    console.log(memorizedAdd(1, 2));
    console.log(memorizedAdd(1, 2));
    console.log(memorizedAdd(1, 2));
    console.log(memorizedAdd(1, 2));
    ```

  - 可移植性

  - 可测试性

  - 合理性

  - 并行代码

## 柯里化

- 柯里化（Currying）：又称部分求值（Partial Evaluation），是把接受多个参数的函数变换成接受一个单一参数（最初函数的第一个参数）的函数，并且返回接受余下的参数而且返回结果的新函数的技术

- 核心思想：把多参数传入的函数拆成单参数（或部分）函数，内部再返回调用下一个单参数（或部分）函数，依次处理剩余的参数

  ```js
  function add(a, b, c) {
    return a + b + c;
  }

  // add(1, 2, 3);
  // add(1)(2)(3);
  // add(1, 2)(3);
  // add(1)(2, 3);

  // 函数闭包层数由参数个数决定
  function curry(fn) {
    // 参数个数
    const len = fn.length;
    return function curried(...args1) {
      // apply 可以接受数组作为参数，并在调用时结构
      if (args1.length >= len) {
        // 收集的参数个数大于函数本身参数的个数，执行函数
        return fn.apply(null, args1);
      } else {
        // 继续收集参数（继续闭包）
        return function (...args2) {
          // 参数拼接
          return curried.apply(null, [...args1, ...args2]);
        };
      }
    };
  }

  const curryAdd = curry(add);

  console.log(curryAdd(1, 2, 3)); // 6
  console.log(curryAdd(1)(2)(3)); // 6
  console.log(curryAdd(1, 2)(3)); // 6
  console.log(curryAdd(1)(2, 3)); // 6
  ```

## 函数组合

- 函数组合：将多个简单的函数，组合成一个更复杂的函数的行为或机制；每个函数的执行结果，作为参数传递给下一个函数，最后一个函数的执行结果就是整个函数的结果

  ```js
  function upperCase(str) {
    return str.toUpperCase();
  }
  function splitStr(str) {
    return str.split("");
  }
  const str = "hello world";
  // 未使用函数组合
  const upperCaseRes = upperCase(str);
  const splitStrRes = splitStr(upperCaseRes);
  console.log(splitStrRes); // ['H', 'E', 'L', 'L', 'O', ' ', 'W', 'O', 'R', 'L', 'D']
  ```

- compose：组合（从右往左）

  ```js
  function upperCase(str) {
    return str.toUpperCase();
  }
  function splitStr(str) {
    return str.split("");
  }
  const str = "hello world";

  function compose(...fns) {
    if (fns.length === 0) {
      return (arg) => arg;
    }
    if (fns.length === 1) {
      return fns[0];
    }

    return fns.reduce(
      (a, b) =>
        (...args) =>
          a(b(...args))
    );
  }

  const composedFn = compose(console.log, splitStr, upperCase);
  composedFn(str); // ['H', 'E', 'L', 'L', 'O', ' ', 'W', 'O', 'R', 'L', 'D']
  ```

- pipe：管道（从左往右）

  ```js
  function upperCase(str) {
    return str.toUpperCase();
  }
  function splitStr(str) {
    return str.split("");
  }
  const str = "hello world";

  function pipe(...fns) {
    if (fns.length === 0) {
      return (arg) => arg;
    }
    if (fns.length === 1) {
      return fns[0];
    }

    return fns.reduce(
      (a, b) =>
        (...args) =>
          b(a(...args))
    );
  }

  const pipedFn = pipe(upperCase, splitStr, console.log);
  pipedFn(str); // ['H', 'E', 'L', 'L', 'O', ' ', 'W', 'O', 'R', 'L', 'D']
  ```
