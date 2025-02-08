## V8 执行流程

![V8执行流程](https://image.jslog.net/online/a-35/2024/12/20/V8执行流程.svg)

- V8 引擎执行流程
  - V8 解析源代码并将其转化为抽象语法树（AST）
  - 基于该 AST，Ignition 解释器可以开始做它的事情，并产生字节码
  - 在这一点上，引擎开始运行代码并收集反馈
  - 为了使它运行得更快，字节码可以和反馈数据一起被发送到优化编译器；Turbofun 优化编译器在此基础上做出某些假设，然后产生高度优化的机器代码
  - 如果在某些时候，其中一个假设被证明是不正确的，Turbofun 优化编译器就会取消优化，并回到 Ignition 解释器

## 垃圾回收

- 垃圾回收又称为 GC

- 对象的可达性

  - 从初始的根对象（window，global）的指针开始，这个根指针对象被称为根集（root set）
  - 从这个根集向下搜索其子节点，被搜索到的子节点说明该节点的引用对象可达，并为其留下标记
  - 递归这个搜索的过程，直到所有子节点都被遍历结束
  - 没有被标记的对象节点不可达，进行垃圾回收

- 引用计数算法

  - 算法描述

    - 当声明了一个变量并且将一个引用类型赋值给该变量的时候这个值的引用次数就为 1
    - 如果同一个值又被赋给另一个变量，那么引用数加 1
    - 如果该变量的值被其他的值覆盖了，则引用次数减 1
    - 当这个值的引用次数变为 0 的时候，说明没有变量在使用，这个值没法被访问了，回收空间，垃圾回收器会在运行的时候清理掉引用次数为 0 的值占用的内存

  - 缺点：计数器需要占位，无法解决循环引用无法回收的问题

- 标记清除算法（Mark-Sweep）

  ![标记清除算法](https://image.jslog.net/online/a-35/2024/12/20/标记清除算法.svg)

  - 算法描述
    - 垃圾收集器在运行时会给内存中的所有变量都加上一个标记，假设内存中所有对象都是垃圾，全标记为 0
    - 然后从各个根对象开始遍历，把不是垃圾的节点改成 1
    - 清理所有标记为 0 的垃圾，销毁并回收它们所占用的内存空间
    - 最后，把所有内存中对象标记修改为 0，等待下一轮垃圾回收
  - 缺点：内存碎片化，空闲内存块是不连续的，且因此导致分配速度慢

- 标记整理算法（Mark-Compact）

  - 标记清除算法并解决内存碎片化问题
  - 标记阶段和标记清除算法相同
  - 标记结束后，将存活对象向内存的一端移动，最后清理掉边界的内存

## V8 垃圾回收

- V8 垃圾回收策略主要基于分代式垃圾回收机制

  ![V8分代](https://image.jslog.net/online/a-35/2024/12/20/V8分代.svg)

  - V8 中将堆内存分为新生代和老生代两区域，采用不同的垃圾回收器也就是不同的策略管理垃圾回收
  - 新生代：采用 Scavenge 算法
  - 老生代：采用标记整理算法

- Scavenge 算法

  ![Scavenge算法](https://image.jslog.net/online/a-35/2024/12/20/Scavenge算法.svg)

  - 将堆一分为二，每一部分空间称为 semispace，采用复制的方式进行垃圾回收
  - 在这两个 semispace 中，只有一个处于使用中（From 空间），另一个处于闲置状态（To 空间）
  - 分配对象的时，首先在 From 空间中进行分配
  - 当进行垃圾回收的时候，检查 From 空间中的存活对象，将存活对象复制到 To 空间，而非存活对象的空间将会被释放
  - 完成复制之后，From 空间变为 To 空间， To 空间变为 From 空间，即进行角色互换

- 对象晋升

  - 将 From 空间的对象移动到 To 空间之前需要进行检查，在一定条件下需要将新生代的对象移动到老生代中
  - 对象晋升条件
    - 对象是否经历过一次 Scavenge 回收
    - To 空间的内存占比超过 25%

## 浏览器进程

- 浏览器主进程
  - 协调控制其他子进程（创建、销毁）
  - 浏览器界面显示，用户交互，前进、后退、收藏
  - 将渲染进程得到的内存中的 Bitmap，绘制到用户界面上
  - 存储功能等
- 第三方插件进程
  - 每种类型的插件对应一个进程，仅当使用该插件时才创建
- GPU 进程
  - 用于 3D 绘制等
- 渲染进程（浏览器内核）
  - 排版引擎 Blink 和 JavaScript 引擎 V8 都是运行在该进程中，将 HTML、CSS 和 JavaScript 转换为用户可以与之交互的网页，
  - 负责页面渲染，脚本执行，事件处理等
  - 每个 tab 页一个渲染进程
  - 出于安全考虑，渲染进程都是运行在沙箱模式下
- 网络进程
  - 负责页面的网络资源加载，之前作为一个模块运行在浏览器主进程里面，最近才独立成为一个单独的进程

## 浏览器事件循环

- 浏览器事件循环：Event Loop

  - 当前执行栈同步任务

  - 宏任务队列
  - 微任务队列

- 宏任务

  - script（整体代码）

  - I/O

  - setTimeout

  - setInterval

  - setImmediate

  - requestAnimationFrame

- 微任务

  - process.nextTick

  - MutationObserver

  - Promise.then catch finally

- 浏览器事件循环

  ![事件循环](https://image.jslog.net/online/a-35/2024/12/20/事件循环.svg)

  - 执行同步代码
  - 执行一个宏任务（执行栈中没有就从任务队列中获取）
  - 执行过程中如果遇到微任务，就将它添加到微任务的任务队列中
  - 宏任务执行完毕后，立即执行当前微任务队列中的所有微任务（依次执行）
  - 当前宏任务执行完毕，开始检查渲染，然后渲染线程接管进行渲染
  - 渲染完毕后，JavaScript 线程继续接管，开始下一个循环

- 分析代码运行

  ```js
  console.log("start");
  setTimeout(() => {
    console.log("setTimeout start");
    Promise.resolve()
      .then(() => {
        console.log("promise resolve1");
      })
      .then(() => {
        console.log("promise resolve2");
      });
    new Promise((resolve) => {
      console.log("promise1 start");
      resolve();
    }).then(() => {
      console.log("promise1 end");
    });
    setTimeout(() => {
      console.log("inner setTimeout");
    });
    console.log("setTimeout end");
  });
  function promiseFn() {
    return new Promise((resolve) => {
      console.log("promiseFn");
      resolve();
    });
  }
  async function asyncFn() {
    console.log("asyncFn start");
    await promiseFn();
    console.log("asyncFn end");
  }

  asyncFn();
  console.log("end");

  // "start"
  // "asyncFn start"
  // "promiseFn"
  // "end"
  // "asyncFn end"
  // "setTimeout start"
  // "promise1 start"
  // "setTimeout end"
  // "promise resolve1"
  // "promise1 end"
  // "promise resolve2"
  // "inner setTimeout"
  ```

  ![事件循环1](https://image.jslog.net/online/a-35/2024/12/20/事件循环示例_1.svg)

  ![事件循环2](https://image.jslog.net/online/a-35/2024/12/20/事件循环示例_2.svg)

  ![事件循环3](https://image.jslog.net/online/a-35/2024/12/20/事件循环示例_3.svg)
