## let

```js
for (var i = 0; i < 5; i++) {
  setTimeout(function () {
    console.log(i); // 5 5 5 5 5
  }, 1000);
}
for (var i = 0; i < 5; i++) {
  ((i) =>
    setTimeout(function () {
      console.log(i); // 0 1 2 3 4
    }, 1000))(i);
}

for (let i = 0; i < 5; i++) {
  setTimeout(function () {
    console.log(i); // 0 1 2 3 4
  }, 1000);
}
```

- let 是块级作用域下的变量声明

- 存储位置

  - var 变量存储在当前执行上下文中的全局变量存储区
  - let 变量存储在词法环境（词法分析、语义分析、代码生成）

- 特性

  - var 变量提升

  - let 存储在词法环境，不存在提升，形成暂时性死区（词法环境）

  - const 跟 let 特性类似，只是 const 多了一层常量的处理，声明时必须进行初始化

  - 向上查找时，在作用域中有声明，且在查找之后，不会再次向上查找，会报错

    ```js
    let a = 1;
    function fn() {
      console.log(a);
      let a = 2;
    }
    ```

    > typeof 有安全机制，未被定义的变量不会报错，对有定义未声明无效报错

## class

- 面向对象思想核心概念：封装、继承、多态

  - 封装：对象的属性和方法结合成一个整体，并隐藏对象的内部实现细节，仅通过公共接口与外部进行交互

    ```js
    class Person {
      constructor(name) {
        this.name = name;
      }

      greet() {
        console.log(`${this.name} greet!`);
      }
    }
    ```

  - 继承：允许一个类（子类）继承另一个类（父类）的属性和方法，从而实现代码复用和扩展

    ```js
    class Person {
      constructor(name) {
        this.name = name;
      }

      greet() {
        console.log(`${this.name} greet!`);
      }
    }
    class Student extends Person {
      constructor(name, level) {
        super(name);
        this.level = level;
      }

      greet() {
        console.log(`${this.level}-${this.name} greet!`);
      }
    }
    ```

  - 多态：允许将父类对象视为子类对象使用，从而实现接口或方法的多种不同表现形式

    ```js
    class Animal {
      speak() {
        console.log("Animal makes a sound");
      }
    }

    class Dog extends Animal {
      speak() {
        console.log("Dog barks");
      }
    }

    class Cat extends Animal {
      speak() {
        console.log("Cat meows");
      }
    }

    function makeAnimalSpeak(animal) {
      animal.speak(); // 多态性在这
    }
    ```

    ```ts
    interface Duck {
      age: number;
      speak(): void;
    }

    class NiceDuck implements Duck {
      age: number;
      constructor(age: number) {
        this.age = age;
      }
      speak() {
        console.log("Quack");
      }
    }

    class BadDuck implements Duck {
      age: number;

      constructor(age: number) {
        this.age = age;
      }
      speak() {
        console.log("Quack");
      }
    }

    function speak(duck: Duck) {
      duck.speak();
    }
    ```

- 静态方法和属性

  - 类中的静态方法和属性可以使用 static 关键字来定义，它们不是类实例的属性，而是类本身的属性和方法
  - 静态方法和属性可以通过类本身直接调用静态方法和属性

  ```js
  class Person {
    static species = "human";

    static saySpecies() {
      console.log(`We are ${this.species}.`);
    }
  }
  console.log(Person.species); // "human"
  Person.saySpecies(); // "We are human."
  ```

- getter 和 setter

  - 在类中定义 getter 和 setter 方法可以让我们封装实例的内部数据属性，使得这些属性的读写行为更加的安全和合理
  - 在类的实现中，getter 和 setter 其实是被定义在构造函数的 prototype 属性上，从而可以被该类的所有实例对象访问

  ```js
  class Person {
    constructor(name, age) {
      this.name = name;
      this.age = age;
    }

    get name() {
      return this.name.toUpperCase();
    }

    set age(age) {
      if (age > 0 && age < 120) {
        this.age = age;
      } else {
        console.log("Invalid age value.");
      }
    }

    get age() {
      return this.age;
    }
  }
  ```

## 模板字符串

- 模板字符串

  ```js
  const hello = "hello";

  const html = `<div>
    <h1>${hello}</h1>
  </div>`;
  ```

- tagged template

  ```js
  function tag(sitrngs, ...values) {
    console.log(sitrngs, values);
  }

  const a = 1;
  const b = 2;
  tag`hello${1}world${b}`;
  ```

  - 应用：css in js

    ```js
    const StyledDiv = styled.div`
      background: pink;
    `;
    ```

## 解构语法

- 数组结构

  ```js
  const [a, , c] = [1, 2, 3];
  console.log(a, c); // 1 3
  ```

- 对象结构

  ```js
  // 使用rest参数收集剩余属性，rest可以自定义命名
  // { firstname: first, lastname: last, ...remainingProperties }
  const {
    firstname: first,
    lastname: last,
    ...rest
  } = { firstname: "Jacob", lastname: "Su", age: 25, gender: "Male" };
  console.log(first, last); // "Jacob" "Su"
  console.log(rest); // { age: 25, gender: 'Male' }
  ```

- 嵌套结构

  ```js
  const [x, [, [z]]] = [1, [2, [3]]];
  console.log(x, z); // 1 3
  ```

## 箭头函数

- 箭头函数与普通函数的区别

  - this 指向，箭头函数 this 指向父级

  - 不能当作构造函数，不能 new 实例化对象

  - 无法使用 arguments 访问参数

  - 无法使用 bind、apply、call 改变 this 指向

- 箭头函数的使用
  - 箭头函数可以用更简洁的语法定义函数，单行表达式即可替代多行代码
  - 箭头函数不绑定自己的 this，它会捕获其所在上下文的 this 值，因此适用于需要引用父级 this 指针的场景
  - 在函数式编程中，箭头函数有助于简化函数定义和调用过程

## 生成器 generator

- 函数只能返回一次，并且函数的执行无法中断

- 生成器：可中断函数，yield 关键字暂时中断函数执行，在合适的实际从中断位置继续执行

  ```js
  function* getAsyncData() {
    // 先拿到第一个数据返回内容
    yield "hello 1";
    // 再拿到第二个数据返回内容
    yield "hello 2";
    // 再拿到第三个数据返回内容
    yield "hello 3";
  }

  let gen = getAsyncData();

  console.log(gen.next().value); // "hello 1"
  console.log(gen.next().value); // "hello 2"
  console.log(gen.next().value); // "hello 3"
  ```

- 生成器的使用：await/async 就是借助 promise 和 generator

## 异步处理

- Promise：ES6 提供的一种处理异步操作的机制，用于解决 callback 回调函数嵌套过多的问题

  ```js
  function fetchData() {
    return new Promise(function (resolve) {
      setTimeout(() => {
        const data = "Promise";
        resolve(data);
      }, 1000);
    });
  }

  fetchData().then(function (data) {
    console.log(data); // "Promise"
  });
  ```

- async/await：ES8 的新特性，基于 Promise 实现的一种的异步编程方式，使异步代码看起来更像是同步代码

  - `async` 关键字用于定义一个返回 Promise 对象的异步函数
  - `await` 关键字则用于在异步函数内部等待一个 Promise 完成，并返回其结果
  - `await` 只能在 `async` 函数内部使用

  ```js
  async function fetchData() {
    return new Promise((resolve) => {
      setTimeout(() => {
        const data = "async/await";
        resolve(data);
      }, 1000);
    });
  }

  async function printData() {
    const data = await fetchData();
    console.log(data); // "async/await"
  }

  printData();
  ```

## Reflect

- Reflect：反射是一种能够在运行时检查、修改对象、类和函数等程序结构的能力，通过反射，我们可以读取和修改对象属性、调用对象方法、定义新属性、修改原型等

  ```js
  const handler = {
    get(target, key, receiver) {
      console.log("get");
      return Reflect.get(target, key, receiver);
    },
    set(target, key, value, receiver) {
      console.log("set");
      Reflect.set(target, key, value, receiver);
    },
  };
  const target = {
    a: 1,
    b: 2,
  };
  const reactiveTarget = new Proxy(target, handler);
  reactiveTarget.a = 10;
  console.log(reactiveTarget.a);
  // "set"
  // "get"
  // 10
  ```

- Reflect 不关心传入需要变更对象的具体实现，只需要关注想要更改的属性

- Reflect 的优势

  - 更明确的返回值：Reflect 方法通常返回一个布尔值，返回值与操作结果直接相关
  - 更好的异常处理：Reflect 方法通常返回一个布尔值，避免抛出异常影响代码运行
  - 方法的可扩展性：可以使用 Reflect 方法来定义和操作 Proxy 对象的行为
  - 对象操作的统一：Reflect 方法集中统一，且方法都是静态的，无需实例化

## BigInt

- BigInt：是在 ES10 中引入的一种新数据类型，旨在解决 Number 类型无法精确表示大于`2^53 - 1`整数的问题。

- 使用：在数字后加“n”，支持加、减、乘、除等基本数学运算，并可通过 BigInt()构造方法将字符串或 Number 类型数据转换为 BigInt

  ```js
  // 2^53 - 1 = 9007199254740991
  console.log(Number.MAX_SAFE_INTEGER); // 9007199254740991
  // 精度丢失
  console.log(10000000100000001); // 10000000100000000

  // 避免精度丢失
  const bigNum1 = BigInt(Number.MAX_SAFE_INTEGER);
  console.log(bigNum1 + 1n); // 9007199254740992n

  const bigNum2 = BigInt("10000000100000001");
  console.log(bigNum2); // 10000000100000001n
  ```

- 注意：BigInt 与 Number 类型不能进行混合运算，否则将抛出类型错误
