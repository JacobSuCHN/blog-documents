## Promise

```js
const p1 = new Promise((resolve, reject) => {
  resolve("success");
  reject("fail");
});
const p2 = new Promise((resolve, reject) => {
  reject("fail");
  resolve("success");
});
const p3 = new Promise((resolve, reject) => {
  throw "error";
});
const p4 = new Promise((resolve, reject) => {});
console.log(p1); // Promise {<fulfilled>: 'success'}
console.log(p2); // Promise {<rejected>: 'fail'}
console.log(p3); // Promise {<rejected>: 'error'}
console.log(p4); // Promise {<pending>}
```

- Promise 的特点
  - 执行了 resolve，Promise 状态会变成 fulfilled
  - 执行了 reject，Promise 状态会变成 rejected
  - Promise 中有 throw 的话，就相当于执行了 reject
  - Promise 状态不可逆，第一次成功就永久为 fulfilled，第一次失败就永远状态为 rejected

```js
// 马上输出 "success"
const p1 = new Promise((resolve, reject) => {
  resolve("success");
}).then(
  (res) => console.log(res),
  (err) => console.log(err)
);

// 1秒后输出 "fail"
const p2 = new Promise((resolve, reject) => {
  setTimeout(() => {
    reject("fail");
  }, 1000);
}).then(
  (res) => console.log(res),
  (err) => console.log(err)
);

// 链式调用 输出 200
const p3 = new Promise((resolve, reject) => {
  resolve(100);
})
  .then(
    (res) => 2 * res,
    (err) => console.log(err)
  )
  .then(
    (res) => console.log(res),
    (err) => console.log(err)
  );
```

- then 的特点

  - then 接收两个回调函数 resolve -> cb, reject -> cb
  - 支持定时器
  - then 支持链式调用

  - 注：可以在外部调用 resolve/reject 改变 Promise 的状态

## Promise 的方法

- all

  - 接收一个 Promise 数组，数组中如有非 Promise 项，则此项当做成功；

  - 如果所有 Promise 都成功，则返回成功结果数组；

  - 如果有一个 Promise 失败，则返回这个失败结果；

- allsettled

  - 接收一个 Promise 数组，数组中如有非 Promise 项，则此项当做成功；

  - 把每一个 Promise 的结果，集合成数组后返回；

- race

  - 接收一个 Promise 数组，数组中如有非 Promise 项，则此项当做成功；

  - 哪个 Promise 最快得到结果，就返回那个结果，无论成功失败；

- any

  - 接收一个 Promise 数组，数组中如有非 Promise 项，则此项当做成功；

  - 如果有一个 Promise 成功，则返回这个成功结果；

  - 如果所有 Promise 都失败，则报错；

## 手写 Promise

```js
class MyPromise {
  constructor(executor) {
    this.initValue();
    this.initBind();
    try {
      executor(this.resolve, this.reject);
    } catch (error) {
      this.reject(error);
    }
  }

  // 初始化赋值
  initValue() {
    this.PromiseStatus = "pending";
    this.PromiseResult = null;
    // 把当前执行的事件(包含异步事件)存储下来
    this.onFulfilledCallbacks = []; // 存储成功的cb
    this.onRejectedCallbacks = []; // 存储失败的cb
  }

  // 绑定实例
  initBind() {
    // 将原型上的方法绑定实例后传递给实例
    this.resolve = this.resolve.bind(this);
    this.reject = this.reject.bind(this);
  }

  resolve(value) {
    if (this.PromiseStatus !== "pending") {
      return;
    }
    this.PromiseStatus = "fulfilled";
    this.PromiseResult = value;

    // 执行 onFulfilledCallbacks
    while (this.onFulfilledCallbacks.length) {
      this.onFulfilledCallbacks.shift()(this.PromiseResult);
    }
  }

  reject(reason) {
    if (this.PromiseStatus !== "pending") {
      return;
    }
    this.PromiseStatus = "rejected";
    this.PromiseResult = reason;

    // 执行 onRejectedCallbacks
    while (this.onRejectedCallbacks.length) {
      this.onRejectedCallbacks.shift()(this.PromiseResult);
    }
  }

  then(onFulfilled, onRejected) {
    // then的两个参数.如果是函数,执行函数;不是函数,转成函数执行
    onFulfilled =
      typeof onFulfilled === "function" ? onFulfilled : (val) => val;
    onRejected =
      typeof onRejected === "function"
        ? onRejected
        : (reason) => {
            throw reason;
          };

    // 为了确保then返回的结果是一个Promise对象
    var thenPromise = new MyPromise((resolve, reject) => {
      const handlePromise = (cb) => {
        setTimeout(() => {
          try {
            const result = cb(this.PromiseResult);
            if (result === thenPromise) {
              throw new Error("not self");
            }
            if (result instanceof MyPromise) {
              result.then(resolve, reject);
            } else {
              resolve(result);
            }
          } catch (error) {
            reject(error);
            throw new Error(error);
          }
        });
      };
      // 处理状态变化
      if (this.PromiseStatus === "fulfilled") {
        // onFulfilled(this.PromiseResult);
        handlePromise(onFulfilled);
      } else if (this.PromiseStatus === "rejected") {
        // onRejected(this.PromiseResult);
        handlePromise(onRejected);
      } else {
        // 针对pending状态,此处添加回调
        // this.onFulfilledCallbacks.push(onFulfilled)
        // this.onRejectedCallbacks.push(onRejected)
        this.onFulfilledCallbacks.push(handlePromise.bind(this, onFulfilled));
        this.onRejectedCallbacks.push(handlePromise.bind(this, onRejected));
      }
    });
    return thenPromise;
  }

  static all(promises) {
    const result = [];
    let count = 0;
    return new MyPromise((resolve, reject) => {
      const addData = (index, value) => {
        result[index] = value;
        count++;
        if (count === promises.length) resolve(result);
      };
      promises.forEach((promise, index) => {
        if (promise instanceof MyPromise) {
          promise.then(
            (res) => {
              addData(index, res);
            },
            (err) => reject(err)
          );
        } else {
          addData(index, promise);
        }
      });
    });
  }
  static race(promises) {
    return new MyPromise((resolve, reject) => {
      promises.forEach((promise) => {
        if (promise instanceof MyPromise) {
          promise.then(
            (res) => {
              resolve(res);
            },
            (err) => {
              reject(err);
            }
          );
        } else {
          resolve(promise);
        }
      });
    });
  }
  static allSettled(promises) {
    return new Promise((resolve, reject) => {
      const res = [];
      let count = 0;
      const addData = (status, value, i) => {
        res[i] = {
          status,
          value,
        };
        count++;
        if (count === promises.length) {
          resolve(res);
        }
      };
      promises.forEach((promise, i) => {
        if (promise instanceof MyPromise) {
          promise.then(
            (res) => {
              addData("fulfilled", res, i);
            },
            (err) => {
              addData("rejected", err, i);
            }
          );
        } else {
          addData("fulfilled", promise, i);
        }
      });
    });
  }
  static any(promises) {
    return new Promise((resolve, reject) => {
      let count = 0;
      promises.forEach((promise) => {
        promise.then(
          (val) => {
            resolve(val);
          },
          (err) => {
            count++;
            if (count === promises.length) {
              reject(new AggregateError("All promises were rejected"));
            }
          }
        );
      });
    });
  }
}
const test = new MyPromise((resolve, reject) => {
  setTimeout(() => {
    resolve(100);
  }, 1000);
})
  .then(
    (res) => 2 * res,
    (err) => console.log(err, 1)
  )
  .then(
    (res) => console.log(res, 2),
    (err) => console.log(err, 3)
  );
```

## Promise 使用

> 实现一个带并发限制的异步调度器 Scheduler，保证同时运行的任务最多有 N 个

```js
class Scheduler {
  constructor(max) {
    this.max = max;
    this.count = 0; // 当前正在执行的任务
    this.taskQueue = []; // 等待队列
  }
  async add(promiseCreator) {
    // count = max,promiseCreator放入队列
    // count < max,直接执行
    if (this.count >= this.max) {
      // this.taskQueue.push
      await new Promise((resolve, reject) => {
        this.taskQueue.push(resolve);
      });
      // resolve调用时,await释放,继续运行
    }
    this.count++;
    // 阻塞,代码运行完释放
    const res = await promiseCreator();
    this.count--;

    // 如果此时queue中有值
    if (this.taskQueue.length) {
      this.taskQueue.shift()(); // 释放队列,
    }

    return res;
  }
}

const timeout = (time) =>
  new Promise((resolve) => {
    setTimeout(resolve, time);
  });

const scheduler = new Scheduler(2);
const addTask = (time, order) => {
  scheduler.add(() => timeout(time)).then(() => console.log(order));
};

addTask(1000, "1");
addTask(500, "2");
addTask(300, "3");
addTask(400, "4");
// "2"
// "3"
// "1"
// "4"
```
