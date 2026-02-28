## 基础篇

### 环境搭建

- vite-env.d.ts：文件类型声明

```ts
/// <reference types="vite/client" />
```

- `!`：非空断言

```tsx
document.getElementById("root")!;
```

### TSX

- 插值语句 {}，字符串 数字 数组（基本类型） html 元素 三元表达式 API 调用

```tsx
function App() {
  return (
    <>
      <div>{"123"}</div>
      <div>{123}</div>
      <div>{[1, 2, 3]}</div>
      <div>{<span>123</span>}</div>
      <div>{true ? "yse" : "no"}</div>
      <div>{(0.123).toFixed(2)}</div>
    </>
  );
}
```

- 插值语句展示对象，需要序列化

```tsx
function App() {
  return (
    <>
      <div>{JSON.stringfy({ name: "js" })}</div>
    </>
  );
}
```

- 事件如何添加，驼峰 onClick,如果需要传参使用高阶函数

```tsx
function App() {
  const fn = () => {
    console.log(123)
  }
  const fn_params = (params,e) => {
    console.log(params,e)
  }
  return (
    <div onClick={fn}>Click me</div>
    <div onClick={(e)=>fn_params(123,e)}>Click me</div>
  )
}
```

- 支持泛型函数，纠正泛型<T,>

```tsx
function App() {
  const fn = <T,>(params: T) => {
    console.log(params);
  };
  return (
    <>
      <div onClick={() => fn(123)}>Click me</div>
    </>
  );
}
```

- 绑定属性，id，class style 等

```tsx
function App() {
  return (
    const id = 'test'
    <>
      <div id={id} className='test' style={{fontSize:'24px'}}></div>
    </>
  )
}
```

- 添加 html 代码片段类似于 v-html，使用 dangerouslySetInnerHTML

```tsx
function App() {
  const html = `<div style="color: red;">html section</div>`;
  return (
    <>
      <div dangerouslySetInnerHTML={{ __html: html }}></div>
    </>
  );
}
```

- 如何遍历数组，使用 map

```tsx
function App() {
  const arr = [1, 2, 3, 4, 5];
  return (
    <>
      <div>
        {arr.map((v) => {
          return <span key={v}>{v}</span>;
        })}
      </div>
    </>
  );
}
```

## 原理篇

### vdom

- Virtual DOM 就是用 JavaScript 对象去描述一个 DOM 结构，虚拟 DOM 不是直接操作浏览器的真实 DOM，而是首先对 UI 的更新在虚拟 DOM 中进行，再将变更高效地同步到真实 DOM 中
- 优点
  - 性能优化：直接操作真实 DOM 是比较昂贵的，尤其是当涉及到大量节点更新时。虚拟 DOM 通过减少不必要的 DOM 操作，主要体现在 diff 算法的复用操作，其实也提升不了多少性能。
  - ==跨平台性：虚拟 DOM 是一个与平台无关的概念，它可以映射到不同的渲染目标，比如浏览器的 DOM 或者移动端(React Native)的原生 UI。==

```js
const React = {
  createElement(type, props = {}, ...children) {
    return {
      type,
      props: {
        ...props,
        children: children.map((child) => {
          if (typeof child === "object") {
            return child;
          } else {
            return React.createTextElement(child);
          }
        }),
      },
    };
  },
  createTextElement(text) {
    return {
      type: "TEXT_ELEMENT",
      props: {
        nodeValue: text,
        children: [],
      },
    };
  },
};

const vdom = React.createElement(
  "div",
  { id: 1 },
  React.createElement("span", null, "js")
);
```

### fiber

- Fiber 是 React 16 引入的一种新的协调引擎，用于解决和优化 React 应对复杂 UI 渲染时的性能问题
- 作用：将 同步递归无法中断的更新 重构为 异步的可中断更新
  - 可中断的渲染：Fiber 允许将大的渲染任务拆分成多个小的工作单元（Unit of Work），使得 React 可以在空闲时间执行这些小任务。当浏览器需要处理更高优先级的任务时（如用户输入、动画），可以暂停渲染，先处理这些任务，然后再恢复未完成的渲染工作
  - 优先级调度：在 Fiber 架构下，React 可以根据不同任务的优先级决定何时更新哪些部分。React 会优先更新用户可感知的部分（如动画、用户输入），而低优先级的任务（如数据加载后的界面更新）可以延后执行
  - 双缓存树（Fiber Tree）：Fiber 架构中有两棵 Fiber 树——current fiber tree（当前正在渲染的 Fiber 树）和 work in progress fiber tree（正在处理的 Fiber 树）。React 使用这两棵树来保存更新前后的状态，从而更高效地进行比较和更新
  - 任务切片：在浏览器的空闲时间内（利用 requestIdleCallback 思想），React 可以将渲染任务拆分成多个小片段，逐步完成 Fiber 树的构建，避免一次性完成所有渲染任务导致的阻塞
- 浏览器一帧（16ms≈1000/60=60FPS）
  - 处理时间的回调 click...事件
  - 处理计时器的回调
  - 开始帧
  - 执行 requestAnimationFrame 动画的回调
  - 计算机页面布局计算 合并到主线程
  - 绘制
  - 如果此时还有空闲时间，执行 requestIdleCallback

```js
const React = {
  createElement(type, props = {}, ...children) {
    return {
      type,
      props: {
        ...props,
        children: children.map((child) => {
          if (typeof child === "object") {
            return child;
          } else {
            return React.createTextElement(child);
          }
        }),
      },
    };
  },
  createTextElement(text) {
    return {
      type: "TEXT_ELEMENT",
      props: {
        nodeValue: text,
        children: [],
      },
    };
  },
};
let nextUnitOfWork = null; // 下一个工作单元
let wipRoot = null; // 工作中的 Fiber 树
let currentRoot = null; // 当前 Fiber 树
let deletions = []; // 删除的 Fiber 列表
function render(element, container) {
  wipRoot = {
    dom: container, // 容器 DOM
    props: { children: [element] }, // 根元素的属性
    alternate: currentRoot, // 当前 Fiber 树
    type: "ROOT", // 根节点类型
  };
  nextUnitOfWork = wipRoot; // 设置下一个工作单元为根节点
  deletions = []; // 清空删除列表
}

function createFiber(element, parent) {
  return {
    type: element.type, // 元素类型
    props: element.props, // 元素属性
    dom: null, // DOM 元素尚未创建
    parent: parent, // 父节点
    child: null, // 子节点
    sibling: null, // 兄弟节点
    alternate: null, // 旧的 Fiber 节点
    effectTag: null, // 副作用标记
  };
}
function createDom(fiber) {
  const dom =
    fiber.type === "TEXT_ELEMENT"
      ? document.createTextNode("")
      : document.createElement(fiber.type); // 创建 DOM 元素
  updateDom(dom, {}, fiber.props); // 更新 DOM 属性
  return dom;
}
function updateDom(dom, prevProps, nextProps) {
  // 删除旧的属性
  Object.keys(prevProps)
    .filter((name) => name !== "children")
    .filter((name) => prevProps[name] !== nextProps[name])
    .forEach((name) => {
      dom[name] = "";
    });
  // 添加新的属性
  Object.keys(nextProps)
    .filter((name) => name !== "children")
    .forEach((name) => {
      dom[name] = nextProps[name];
    });
}
function workLoop(deadline) {
  let shouldYield = false; // 是否需要让出控制权
  // 如果没有下一个工作单元，且有工作中的 Fiber 树，设置下一个工作单元为工作中的 Fiber 树
  while (nextUnitOfWork && !shouldYield) {
    nextUnitOfWork = performUnitOfWork(nextUnitOfWork); // 执行当前工作单元
    shouldYield = deadline.timeRemaining() < 1; // 检查是否有足够的时间继续执行
  }
  // 如果没有下一个工作单元且有工作中的 Fiber 树，提交 Fiber 树
  if (!nextUnitOfWork && wipRoot) {
    commitRoot(); // 提交工作中的 Fiber 树
  }
  requestIdleCallback(workLoop); // 如果还有工作单元，继续在空闲时间执行
}
requestIdleCallback(workLoop); // 利用浏览器空闲时间执行工作循环
function performUnitOfWork(fiber) {
  if (!fiber.dom) {
    fiber.dom = createDom(fiber); // 创建 DOM 元素
  }
  // 遍历子节点
  reconcileChildren(fiber, fiber.props.children);
  // 如果有子节点，返回第一个子节点作为下一个工作单元
  if (fiber.child) {
    return fiber.child; // 返回第一个子节点作为下一个工作单元
  }
  let nextFiber = fiber; // 当前工作单元
  // 向上查找兄弟节点
  while (nextFiber) {
    if (nextFiber.sibling) {
      return nextFiber.sibling; // 返回兄弟节点作为下一个工作单元
    }
    nextFiber = nextFiber.parent; // 向上查找父节点
  }
  return null; // 没有更多工作单元
}
function reconcileChildren(wipFiber, elements) {
  // 形成fiber树，并实现diff算法
  let index = 0; // 当前元素索引
  let prevSibling = null; // 上一个兄弟节点
  let oldFiber = wipFiber.alternate && wipFiber.alternate.child; // 获取旧的子节点
  // 删除列表，用于存储需要删除的 Fiber 节点
  while (index < elements.length || oldFiber != null) {
    const element = elements[index]; // 获取当前元素
    // 1.如果旧的子节点存在且类型匹配，复用旧的节点
    const sameType = oldFiber && element && oldFiber.type === element.type;
    let newFiber = null; // 新的 Fiber 节点
    // 如果旧的子节点存在且类型匹配，复用旧的节点
    if (sameType) {
      newFiber = {
        type: oldFiber.type, // 复用旧的类型
        props: element.props, // 更新属性
        dom: oldFiber.dom, // 复用旧的 DOM 元素
        parent: wipFiber, // 设置父节点
        alternate: oldFiber, // 保留旧的 Fiber
        effectTag: "UPDATE", // 标记为更新
      };
    }
    // 2.如果旧的子节点不存在，创建新的节点
    if (element && !sameType) {
      newFiber = createFiber(element, wipFiber); // 创建新的 Fiber 节点
      newFiber.effectTag = "PLACEMENT"; // 标记为放置
    }
    // 3.如果旧的子节点存在但类型不匹配，删除旧的节点
    if (oldFiber && !sameType) {
      oldFiber.effectTag = "DELETION"; // 标记为删除
      deletions.push(oldFiber); // 添加到删除列表
    }
    if (oldFiber) {
      oldFiber = oldFiber.sibling; // 移动到下一个旧的兄弟节点
    }

    // 将新的 Fiber 节点添加到当前 Fiber 的子节点列表中
    // 如果是第一个子节点，直接设置为当前 Fiber 的子节点
    if (index == 0) {
      wipFiber.child = newFiber; // 第一个子节点
    } else if (element) {
      prevSibling.sibling = newFiber; // 设置兄弟节点
    }
    prevSibling = newFiber; // 更新上一个兄弟节点
    index++;
  }
}

function commitRoot() {
  deletions.forEach(commitWork); // 提交删除的 Fiber
  commitWork(wipRoot.child); // 提交工作中的 Fiber 树
  currentRoot = wipRoot; // 更新当前 Fiber 树
  wipRoot = null; // 清空工作中的 Fiber 树
}
function commitWork(fiber) {
  if (!fiber) {
    return; // 如果 Fiber 不存在，直接返回
  }
  const domParent = fiber.parent ? fiber.parent.dom : null; // 获取父节点的 DOM
  if (fiber.effectTag === "PLACEMENT" && fiber.dom) {
    domParent.appendChild(fiber.dom); // 将新创建的 DOM 元素添加到父节点
  } else if (fiber.effectTag === "UPDATE" && fiber.dom) {
    updateDom(fiber.dom, fiber.alternate.props, fiber.props); // 更新 DOM 元素的属性
  } else if (fiber.effectTag === "DELETION") {
    domParent.removeChild(fiber.dom); // 删除 DOM 元素
  }
  // 提交子节点
  commitWork(fiber.child);
  // 提交兄弟节点
  commitWork(fiber.sibling);
}
const vdom = React.createElement(
  "div",
  { id: 1 },
  React.createElement("span", null, "js")
);
render(vdom, document.getElementById("root"));
```

### requestIdleCallback

- requestIdleCallback 接受一个回调函数 callback 并且在回调函数中会注入参数 deadline；deadline 有两个值
  - deadline.timeRemaining() 返回是否还有空闲时间(毫秒)
  - deadline.didTimeout 返回是否因为超时被强制执行(布尔值)
    - `{ timeout: 1000 }` 指定回调的最大等待时间（以毫秒为单位）。如果在指定的 timeout 时间内没有空闲时间，回调会强制执行，避免任务无限期推迟

```js
const total = 1000; // 定义需要生成的函数数量，即1000个任务
const arr = []; // 存储任务函数的数组

// 生成1000个函数并将其添加到数组中
function generateArr() {
  for (let i = 0; i < total; i++) {
    // 每个函数的作用是将一个 <div> 元素插入到页面的 body 中
    arr.push(function () {
      document.body.innerHTML += `<div>${i + 1}</div>`; // 将当前索引 + 1 作为内容
    });
  }
}
generateArr(); // 调用函数生成任务数组

// 用于调度和执行任务的函数
function workLoop(deadline) {
  // 检查当前空闲时间是否大于1毫秒，并且任务数组中还有任务未执行
  if (deadline.timeRemaining() > 1 && arr.length > 0) {
    const fn = arr.shift(); // 从任务数组中取出第一个函数
    fn(); // 执行该函数，即插入对应的 <div> 元素到页面中
  }
  // 再次使用 requestIdleCallback 调度下一个空闲时间执行任务
  requestIdleCallback(workLoop);
}

// 开始调度任务，在浏览器空闲时执行 workLoop
requestIdleCallback(workLoop, { timeout: 1000 });
```

> 为什么 React 不用原生 requestIdleCallback 实现呢？
>
> 1. 兼容性差 Safari 并不支持
> 2. 控制精细度 React 要根据组件优先级、更新的紧急程度等信息，更精确地安排渲染的工作
> 3. 执行时机 requestIdleCallback(callback) 回调函数的执行间隔是 50ms（W3C 规定），也就是 20FPS，1 秒内执行 20 次，间隔较长。
> 4. 差异性 每个浏览器实现该 API 的方式不同，导致执行时机有差异有的快有的慢

- MessageChannel（0~1ms 触发的红任务）：设计初衷是为了方便 我们在不同的上下文之间进行通讯，例如 web Worker,iframe 它提供了两个端口（port1 和 port2），通过这些端口，消息可以在两个独立的线程之间双向传递

```js
// 创建 MessageChannel
const channel = new MessageChannel();
const port1 = channel.port1;
const port2 = channel.port2;

// 设置 port1 的消息处理函数
port1.onmessage = (event) => {
  console.log("Received by port1:", event.data);
  port1.postMessage("Reply from port1"); // 向 port2 发送回复消息
};

// 设置 port2 的消息处理函数
port2.onmessage = (event) => {
  console.log("Received by port2:", event.data);
};

// 通过 port2 发送消息给 port1
port2.postMessage("Message from port2");
```

- React 简易版调度器

```js
const ImmediatePriority = 1; // 立即执行的优先级, 级别最高 [点击事件 输入框]
const UserBlockingPriority = 2; // 用户阻塞级别的优先级, [滚动 拖拽这些]
const NormalPriority = 3; // 正常的优先级 [redner 列表 动画 网络请求]
const LowPriority = 4; // 低优先级  [分析统计]
const IdlePriority = 5; // 最低阶的优先级, 可以被闲置的那种 [console.log]

// 获取当前时间
function getCurrentTime() {
  // 使用 performance.now() 获取高精度的时间戳
  return performance.now();
}

class SimpleScheduler {
  constructor() {
    /**
     * @type {Array<{callback: function, priorityLevel: number, expirationTime: number}>}
     * 任务队列，存储待执行的任务
     * 每个任务包含回调函数、优先级和过期时间
     * 优先级越高，过期时间越短
     * 过期时间是当前时间加上超时时间
     * 超时时间根据优先级不同而不同
     */
    this.taskQueue = [];
    /**
     * @type {boolean}
     * 是否正在执行任务
     * 用于避免重复调度
     */
    this.isPerformingWork = false;

    // 使用 MessageChannel 处理任务调度
    const channel = new MessageChannel();
    // channel.port1 用于接收消息，port2 用于发送消息
    this.port = channel.port2;
    // 监听 port1 的消息事件，当有消息时执行 performWorkUntilDeadline
    channel.port1.onmessage = this.performWorkUntilDeadline.bind(this);
  }

  // 调度任务
  /**
   * @param {number} priorityLevel - 任务的优先级
   * @param {function} callback - 任务回调函数
   */
  scheduleCallback(priorityLevel, callback) {
    const curTime = getCurrentTime();
    let timeout;
    // 根据优先级设置超时时间
    switch (priorityLevel) {
      case ImmediatePriority:
        timeout = -1;
        break;
      case UserBlockingPriority:
        timeout = 250;
        break;
      case LowPriority:
        timeout = 10000;
        break;
      case IdlePriority:
        timeout = 1073741823;
        break;
      case NormalPriority:
      default:
        timeout = 5000;
        break;
    }

    const task = {
      callback,
      priorityLevel,
      expirationTime: curTime + timeout, // 直接根据当前时间加上超时时间
    };

    this.push(this.taskQueue, task); // 将任务加入队列
    // 如果当前没有正在执行的任务，则调度执行
    this.schedulePerformWorkUntilDeadline();
  }

  /**
   * 调度执行任务直到截止时间
   */
  schedulePerformWorkUntilDeadline() {
    if (!this.isPerformingWork) {
      this.isPerformingWork = true;
      this.port.postMessage(null); // 触发 MessageChannel 调度
    }
  }

  /**
   * 执行任务直到截止时间
   */
  performWorkUntilDeadline() {
    this.isPerformingWork = true;
    this.workLoop();
    this.isPerformingWork = false;
  }

  /**
   * 工作循环
   * 遍历任务队列，执行每个任务的回调函数
   * 如果任务队列为空，则结束循环
   * 如果有任务被执行，则继续循环，直到没有更多任务
   * 任务执行完毕后，清空已完成的任务
   * 该方法会在 performWorkUntilDeadline 中被调用
   */
  workLoop() {
    let curTask = this.peek(this.taskQueue);
    while (curTask) {
      const callback = curTask.callback;
      if (typeof callback === "function") {
        callback(); // 执行任务
      }
      this.pop(this.taskQueue); // 移除已完成任务
      curTask = this.peek(this.taskQueue); // 获取下一个任务
    }
  }

  // 以下未模拟，React源码并不是直接使用这些方法，而是通过调度器来管理任务的执行
  // 获取队列中的任务
  peek(queue) {
    return queue[0] || null;
  }

  // 向队列中添加任务
  push(queue, task) {
    queue.push(task);
    queue.sort((a, b) => a.expirationTime - b.expirationTime); // 根据优先级排序，优先级高的在前 从小到大
  }

  // 从队列中移除任务
  pop(queue) {
    return queue.shift();
  }
}

// 测试
const scheduler = new SimpleScheduler();

scheduler.scheduleCallback(LowPriority, () => {
  console.log("Task 1: Low Priority");
});

scheduler.scheduleCallback(ImmediatePriority, () => {
  console.log("Task 2: Immediate Priority");
});

scheduler.scheduleCallback(IdlePriority, () => {
  console.log("Task 3: Idle Priority");
});

scheduler.scheduleCallback(UserBlockingPriority, () => {
  console.log("Task 4: User Blocking Priority");
});

scheduler.scheduleCallback(NormalPriority, () => {
  console.log("Task 5: Normal Priority");
});
```

## 组件篇

### 初识组件

- React 没有全局组件和局部组件的概念，所有组件都是局部组件
- 自定义类全局组件（Pop）

```tsx
import "./components/Message";

function App() {
  return (
    <>
      <button onClick={() => window.onShow()}>Confirm</button>
    </>
  );
}

export default App;
```

```tsx
import ReactDom from "react-dom/client";
const Message = () => {
  return <div>Tip</div>;
};
interface Item {
  messageContainer: HTMLDivElement;
  root: ReactDom.Root;
}
const queue: Item[] = [];
window.onShow = () => {
  const messageContainer = document.createElement("div");
  messageContainer.className = "message";
  messageContainer.style.top = `${queue.length * 50}px`;
  document.body.appendChild(messageContainer);
  // 容器关联Message组件
  // 把容器注册成根组件
  const root = ReactDom.createRoot(messageContainer);
  root.render(<Message />);
  queue.push({
    messageContainer,
    root,
  });
  setTimeout(() => {
    const item = queue.find(
      (item) => item.messageContainer === messageContainer
    )!;
    item.root.unmount();
    document.body.removeChild(item.messageContainer);
    queue.splice(queue.indexOf(item), 1);
  }, 2000);
};

// ts的声明扩充
declare global {
  interface Window {
    onShow: () => void;
  }
}

export default Message;
```

### 组件通信

- props
  - React 组件使用 props 来互相通信
  - 每个父组件都可以提供 props 给它的子组件，从而将一些信息传递给它
- props 的泛型

  - interface 赋给 props

  ```tsx
  interface Props {
    title?: string;
  }
  export default function Card(props: Props) {
    return (
      <div className="card">
        <header>
          <div>{props.title}</div>
          <div>Subtitle</div>
        </header>
      </div>
    );
  }
  ```

  - React.FC\<Props\> 赋给组件

  ```tsx
  import React from "react";
  interface Props {
    title?: string;
  }
  const Card: React.FC<Props> = (props) => {
    return (
      <div className="card">
        <header>
          <div>{props.title}</div>
          <div>Subtitle</div>
        </header>
      </div>
    );
  };

  export default Card;
  ```

- props 的默认值

  - 解构 `{title='Default Title'}`
  - 声明一个默认对象

  ```tsx
  const defaultProps: Partial<Props> = {
    title: "Default Title",
  };
  const Card: React.FC<Props> = (props) => {
    const { title } = { ...defaultProps, ...props };
    // ...
  };
  ```

- `props.children`：类似于 Vue 的插槽，直接在子组件内部插入标签会自动一个参数`props.children`

```tsx
import Card from "./components/Card";
function App() {
  return (
    <>
      <Card title={"title1"}>
        <div>
          <section>
            <i>content1</i>
          </section>
        </div>
      </Card>
    </>
  );
}

export default App;
```

```tsx
import React from "react";
interface Props {
  title?: string;
  children?: React.ReactNode;
}
const Card: React.FC<Props> = (props) => {
  return (
    <div className="card">
      <main>{props.children}</main>
    </div>
  );
};
export default Card;
```

- props 支持类型

  - string `title={'测试'}`
  - number `id={1}`
  - boolean `isGirl={false}`
  - null `empty={null}`
  - undefined `empty={undefined}`
  - object `obj={ { a: 1, b: 2 } }`
  - array `arr={[1, 2, 3]}`
  - function `cb={(a: number, b: number) => a + b}`
  - JSX.Element `element={<div>测试</div>}`

- 父子组件通信

  - 父传子

  ```tsx
  import Card from "./components/Card";
  function App() {
    return (
      <>
        <Card title={"title1"}></Card>
      </>
    );
  }
  export default App;
  ```

  ```tsx
  import React from "react";
  interface Props {
    title?: string;
  }
  const Card: React.FC<Props> = (props) => {
    return (
      <div className="card">
        <header>
          <div>{props.title}</div>
        </header>
      </div>
    );
  };
  export default Card;
  ```

  - 子传父

  ```tsx
  import Card from "./components/Card";
  const fn = (params: string) => {
    console.log("🚀 ~ fn ~ params:", params);
  };
  function App() {
    return (
      <>
        <Card callback={fn}> </Card>
      </>
    );
  }

  export default App;
  ```

  ```tsx
  interface Props {
    callback?: (params: string) => void;
  }
  const Card: React.FC<Props> = (props) => {
    return (
      <div className="card">
        <footer>
          <button
            onClick={() => props.callback && props.callback("child params")}
          >
            Confirm
          </button>
          <button>Cancel</button>
        </footer>
      </div>
    );
  };
  export default Card;
  ```

- 兄弟组件通信：定义两个组件放到一起作为兄弟组件，其原理就是发布订阅设计模式

```tsx
import "./App.css";
import Card1 from "./components/Card1";
import Card2 from "./components/Card2";

function App() {
  return (
    <>
      <Card1 title={"card1"}></Card1>
      <Card2 title={"card2"}></Card2>
    </>
  );
}

export default App;
```

```tsx
import React from "react";
interface Props {
  title?: string;
}
declare global {
  interface Event {
    params: {
      name: string;
    };
  }
}
const Card1: React.FC<Props> = (props) => {
  // 创建自定义事件
  const e = new Event("on-card");
  const clickTap = () => {
    e.params = { name: "card1" };
    // 派发事件
    window.dispatchEvent(e);
  };
  return (
    <div className="card">
      <footer>
        <button onClick={clickTap}>Confirm</button>
        <button>Cancel</button>
      </footer>
    </div>
  );
};

export default Card1;
```

```tsx
import "./index.css";
import React from "react";
interface Props {
  title?: string;
}
const Card2: React.FC<Props> = (props) => {
  // 接收派发
  window.addEventListener("on-card", (e) => {
    console.log("🚀 ~ e:", e);
  });
  return <div className="card"></div>;
};

export default Card2;
```

### 受控组件

- React 受控组件

  - 受控组件一般是指表单元素，表单的数据由 React 的 State 管理，更新数据时，需要手动调用 setState()方法，更新数据。因为 React 没有类似于 Vue 的 v-model，所以需要自己实现绑定事件。
  - 使用受控组件可以确保表单数据与组件状态同步、便于集中管理和验证数据，同时提供灵活的事件处理机制以实现数据格式化和 UI 联动效果

  ```tsx
  import React, { useState } from "react";

  const App: React.FC = () => {
    const [value, setValue] = useState("");
    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
      setValue(e.target.value);
    };
    return (
      <>
        <input type="text" value={value} onChange={handleChange} />
        <div>{value}</div>
      </>
    );
  };

  export default App;
  ```

- React 非受控组件

  - 非受控组件指的是该表单元素不受 React 的 State 管理，表单的数据由 DOM 管理。通过 useRef()来获取表单元素的值

  ```tsx
  import React, { useState, useRef } from "react";
  const App: React.FC = () => {
    const value = "js";
    const inputRef = useRef<HTMLInputElement>(null);
    const handleChange = () => {
      console.log(inputRef.current?.value);
    };
    return (
      <>
        <input
          type="text"
          onChange={handleChange}
          defaultValue={value}
          ref={inputRef}
        />
      </>
    );
  };

  export default App;
  ```

  ```tsx
  import React, { useRef } from "react";
  const App: React.FC = () => {
    const inputRef = useRef<HTMLInputElement>(null);
    const handleChange = () => {
      console.log(inputRef.current?.files);
    };
    return (
      <>
        <input type="file" ref={inputRef} onChange={handleChange} />
      </>
    );
  };

  export default App;
  ```

### 异步组件

- Suspense：Suspense 是一种异步渲染机制，其核心理念是在组件加载或数据获取过程中，先展示一个占位符（loading state），从而实现更自然流畅的用户界面更新体验。

- 应用场景
  - 异步组件加载：通过代码分包实现组件的按需加载，有效减少首屏加载时的资源体积，提升应用性能。
  - 异步数据加载：在数据请求过程中展示优雅的过渡状态（如 loading 动画、骨架屏等），为用户提供更流畅的交互体验。
  - 异步图片资源加载：智能管理图片资源的加载状态，在图片完全加载前显示占位内容，确保页面布局稳定，提升用户体验

```tsx
<Suspense fallback={<div>Loading...</div>}>
  <AsyncComponent />
</Suspense>
```

- 入参
  - fallback: 指定在组件加载或数据获取过程中展示的组件或元素
  - children: 指定要异步加载的组件或数据
- 案例

  - 骨架组件

  ```tsx
  import "./index.css";
  export const Skeleton = () => {
    return (
      <div className="skeleton">
        <header className="skeleton-header">
          <div className="skeleton-name"></div>
          <div className="skeleton-age"></div>
        </header>
        <section className="skeleton-content">
          <div className="skeleton-address"></div>
          <div className="skeleton-avatar"></div>
        </section>
      </div>
    );
  };
  ```

  ```css
  .skeleton {
    width: 300px;
    height: 150px;
    border: 1px solid #d6d3d3;
    margin: 30px;
    border-radius: 2px;
  }

  .skeleton-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid #d6d3d3;
    padding: 10px;
  }

  .skeleton-name {
    width: 100px;
    height: 20px;
    background-color: #d6d3d3;
    animation: skeleton-loading 1.5s ease-in-out infinite;
  }

  .skeleton-age {
    width: 50px;
    height: 20px;
    background-color: #d6d3d3;
    animation: skeleton-loading 1.5s ease-in-out infinite;
  }

  .skeleton-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px;
  }

  .skeleton-address {
    width: 100px;
    height: 20px;
    background-color: #d6d3d3;
    animation: skeleton-loading 1.5s ease-in-out infinite;
  }

  .skeleton-avatar {
    width: 50px;
    height: 50px;
    background-color: #d6d3d3;
    animation: skeleton-loading 1.5s ease-in-out infinite;
  }

  @keyframes skeleton-loading {
    0% {
      opacity: 0.6;
    }

    50% {
      opacity: 1;
    }

    100% {
      opacity: 0.6;
    }
  }
  ```

  - 卡片组件
    > use API 用于获取组件内部的 Promise,或者 Context 的内容

  ```tsx
  import { use } from "react";
  import "./index.css";
  interface Data {
    name: string;
    age: number;
    address: string;
    avatar: string;
  }

  const getData = async () => {
    await new Promise((resolve) => setTimeout(resolve, 2000));
    return (await fetch("http://localhost:5173/data.json").then((res) =>
      res.json()
    )) as { data: Data };
  };

  const dataPromise = getData();

  const Card: React.FC = () => {
    const { data } = use(dataPromise);
    return (
      <div className="card">
        <header className="card-header">
          <div className="card-name">{data.name}</div>
          <div className="card-age">{data.age}</div>
        </header>
        <section className="card-content">
          <div className="card-address">{data.address}</div>
          <div className="card-avatar">
            <img width={50} height={50} src={data.avatar} alt="" />
          </div>
        </section>
      </div>
    );
  };

  export default Card;
  ```

  ```css
  .card {
    width: 300px;
    height: 150px;
    border: 1px solid #d6d3d3;
    margin: 30px;
    border-radius: 2px;
  }

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid #d6d3d3;
    padding: 10px;
  }

  .card-age {
    font-size: 12px;
    color: #999;
  }

  .card-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px;
  }
  ```

  - 异步组件

  ```tsx
  import { Suspense } from "react";
  import Card from "./components/Card";
  import Skeleton from "./components/Skeleton";
  export const App = () => {
    return (
      <>
        <Suspense fallback={<Skeleton />}>
          <Card />
        </Suspense>
      </>
    );
  };
  export default App;
  ```

### 高阶组件

- 高阶组件就是一个组件，它接受另一个组件作为参数，并返回一个新的组件，（如果你学过 Vue 的话，跟 Vue 中的二次封装组件有点类似）新的组件可以复用旧组件的逻辑，并可以添加新的功能。常用于类组件中，虽然目前都是 hooks 写法会缩小 HOC 的使用场景，但还是有部分场景会用到
- 注意点

  - HOC 不会修改传入的组件，而是使用组合的方式，通过将原组件包裹在一个容器组件中来实现功能扩展
  - 注意避免多层嵌套，一般 HOC 的嵌套层级不要超过 3 层
  - HOC 的命名规范：with 开头，如 withLoading、withAuth 等

- 基本用法

```tsx
import React from "react";

enum Role {
  ADMIN = "admin",
  USER = "user",
}
const withAuthorization = (role: Role) => (Component: React.FC) => {
  const isAuth = (role: Role) => {
    return role === Role.ADMIN;
  };
  return (props: any) => {
    return isAuth(role) ? <Component {...props} /> : <h1>Not Authorized</h1>;
  };
};
const AdminComponent = withAuthorization(Role.ADMIN)((props: any) => {
  return <h1>Admin Component</h1>;
});
const UserComponent = withAuthorization(Role.USER)((props: any) => {
  return <h1>User Component</h1>;
});
const APP = () => {
  return (
    <>
      <AdminComponent a={1} />
      <UserComponent a={1} />
    </>
  );
};

export default APP;
```

- 进阶用法
  - 封装一个通用的 HOC，实现埋点统计，比如点击事件，页面挂载，页面卸载等。封装一个埋点服务可以根据自己的业务自行扩展
    - trackType 表示发送埋点的组件类型
    - data 表示发送的数据
    - eventData 表示需要统计的用户行为数据
    - navigator.sendBeacon 是浏览器提供的一种安全可靠的异步数据传输方式，适合发送少量数据，比如埋点数据,并且浏览器关闭时，数据也会发送，不会阻塞页面加载

```tsx
import React, { useEffect } from "react";
const trackService = {
  sendEvent: <T,>(trackType: string, data: T = null as T) => {
    const eventData = {
      timestamp: Date.now(), // 时间戳
      trackType, // 事件类型
      data, // 事件数据
      userAgent: navigator.userAgent, // 用户代理
      url: window.location.href, // 当前URL
    };
    //发送数据
    navigator.sendBeacon("http://localhost:5173", JSON.stringify(eventData));
  },
};
const withTrack = (Component: React.ComponentType<any>, trackType: string) => {
  return (props: any) => {
    useEffect(() => {
      //发送数据 组件挂载
      trackService.sendEvent(`${trackType}-MOUNT`);
      return () => {
        //发送数据 组件卸载
        trackService.sendEvent(`${trackType}-UNMOUNT`);
      };
    }, []);

    //处理事件
    const trackEvent = (eventType: string, data: any) => {
      trackService.sendEvent(`${trackType}-${eventType}`, data);
    };

    return <Component {...props} trackEvent={trackEvent} />;
  };
};
const Button = ({
  trackEvent,
}: {
  trackEvent: (eventType: string, data: any) => void;
}) => {
  // 点击事件
  const handleClick = (e: React.MouseEvent<HTMLButtonElement>) => {
    trackEvent(e.type, {
      name: e.type,
      type: e.type,
      clientX: e.clientX,
      clientY: e.clientY,
    });
  };

  return <button onClick={handleClick}>Click</button>;
};
// 使用HOC高阶组件
const TrackButton = withTrack(Button, "button");
// 使用组件
const App = () => {
  return (
    <div>
      <TrackButton />
    </div>
  );
};

export default App;
```

### 传送 API

- createPortal：注意这是一个 API，不是组件，他的作用是：将一个组件渲染到 DOM 的任意位置，跟 Vue 的 Teleport 组件类似

```tsx
import { createPortal } from "react-dom";

const App = () => {
  return createPortal(<div>js</div>, document.body);
};

export default App;
```

- 入参
  - children：要渲染的组件
  - domNode：要渲染到的 DOM 位置
  - key?：可选，用于唯一标识要渲染的组件
- 返回值：返回一个 React 元素(即 jsx)，这个元素可以被 React 渲染到 DOM 的任意位置
- 应用场景

  - 弹窗
  - 下拉框
  - 全局提示
  - 全局遮罩
  - 全局 Loading

- 案例

  - Modal

  ```tsx
  import "./index.css";
  const Modal = () => {
    return (
      <div className="modal">
        <div className="modal-header">
          <div className="modal-title">Title</div>
        </div>
        <div className="modal-content">
          <h1>Modal</h1>
        </div>
        <div className="modal-footer">
          <button className="modal-close-button">Close</button>
          <button className="modal-confirm-button">Confirm</button>
        </div>
      </div>
    );
  };
  export default Modal;
  ```

  ```css
  .modal {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    border: 1px solid #4d4d4d;
    width: 500px;
    height: 400px;
    left: 50%;
    top: 50%;
    transform: translate(-50%, -50%);
    padding: 20px;
    border-radius: 5px;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
  }

  .modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .modal-title {
    font-size: 1.5rem;
    font-weight: bold;
  }

  .modal-content {
    padding: 20px 0;
    flex: 1;
  }

  .modal-footer {
    display: flex;
    justify-content: flex-end;
  }

  .modal-close-button {
    margin-right: 10px;
    background-color: #000;
    color: #fff;
    border: none;
    padding: 10px 20px;
    border-radius: 5px;
    cursor: pointer;
  }

  .modal-confirm-button {
    margin-left: 10px;
    background-color: rgb(46, 46, 164);
    color: #fff;
    border: none;
    padding: 10px 20px;
    border-radius: 5px;
    cursor: pointer;
  }
  ```

  - 传送 API

  ```tsx
  import { createPortal } from "react-dom";
  import Modal from "./components/Modal";
  const APP = () => {
    return <>{createPortal(<Modal />, document.body)}</>;
  };

  export default APP;
  ```

- 更推荐使用 createPortal 因为他更灵活，可以挂载到任意位置，而 position: fixed,会有很多问题，在默认的情况下他是根据浏览器视口进行定位的，但是如果父级设置了 transform、perspective、filter 或 backdrop-filter 属性非 none 时，他就会相对于父级进行定位，这样就会导致 Modal 组件定位不准确(他不是一定按照浏览器视口进行定位)，所以不推荐使用

## CSS 方案

### CSS Modules

- css modules：因为 React 没有 Vue 的 Scoped，但是 React 又是 SPA(单页面应用)，所以需要一种方式来解决 css 的样式冲突问题，也就是把每个组件的样式做成单独的作用域，实现样式隔离，而 css modules 就是一种解决方案，但是我们需要借助一些工具来实现，比如 webpack，postcss，css-loader，vite

```css
.button {
  color: red;
}
```

```tsx
import styles from "./index.module.css";

export default function Button() {
  return <button className={styles.button}>button</button>;
}
```

```html
<button class="_button_1svig_1">button</button>
```

- 修改 css modules 规则：在 vite.config.ts 中配置 css modules 的规则
  ts

```ts
export default defineConfig({
  css: {
    modules: {
      localsConvention: "dashes", // 修改css modules的类名规则 可以改成驼峰命名 或者 xxx-xxx命名等
      generateScopedName: "[name]__[local]___[hash:base64:5]", // 修改css modules的类名规则 name:组件名 local:css属性名 hash:base64:5
    },
  },
  plugins: [react(), viteMockServer()],
});
```

```html
<button class="index-module__button___Ad2nq">button</button>
```

- localsConvention
  - camelCase：将 css 属性名转换为驼峰命名，保留原始属性名
  - camelCaseOnly：只将 css 属性名转换为驼峰命名，删除原始属性名
  - dashed：将 css 属性名转换为连字符命名，保留原始属性名
  - dashedOnly：只将 css 属性名转换为连字符命名，删除原始属性名
- 维持类名：意思就是说在样式文件中的某些样式，不希望被编译成 css modules，可以设置为 global

```tsx
.app{
    background: red;
    width: 200px;
    height: 200px;
    :global(.button){
        background: blue;
        width: 100px;
        height: 100px;
    }
}
```

### css-in-js

- 优点
  - 可以让 CSS 拥有独立的作用域，阻止 CSS 泄露到组件外部，防止冲突
  - 可以动态的生成 CSS 样式，根据组件的状态来动态的生成 CSS 样式
  - CSS-in-JS 可以方便地实现主题切换功能，只需更改主题变量即可改变整个应用的样式
- 缺点
  - css-in-js 是基于运行时，所以会损耗一些性能(电脑性能高可以忽略)
  - 调试困难，CSS-in-JS 的样式难以调试，因为它们是动态生成的，而不是在 CSS 文件中定义的

```tsx
import React from "react";
import styled from "styled-components";
const Button = styled.button<{ primary?: boolean }>`
  ${(props) => (props.primary ? "background: #6160F2;" : "background: red;")}
  padding: 10px 20px;
  border-radius: 5px;
  color: white;
  cursor: pointer;
  margin: 10px;
  &:hover {
    color: black;
  }
`;
const App: React.FC = () => {
  return (
    <>
      <Button>Click</Button>
      <Button primary={false}>Click</Button>
      <Button primary>Click</Button>
      <Button primary={true}>Click</Button>
    </>
  );
};

export default App;
```

- 继承：我们可以实现一个基础的 Button 组件，然后通过继承来实现更多的按钮样式

```tsx
import React from "react";
import styled from "styled-components";
const Button = styled.button<{ primary?: boolean }>`
  ${(props) => (props.primary ? "background: #6160F2;" : "background: blue;")}
  padding: 10px 20px;
  border-radius: 5px;
  color: white;
  cursor: pointer;
  margin: 10px;
  &:hover {
    color: black;
  }
`;
const ErrorButton = styled(Button)`
  background: red;
`;

const App: React.FC = () => {
  return (
    <>
      <Button primary>Click</Button>
      <ErrorButton>Error</ErrorButton>
    </>
  );
};

export default App;
```

- 属性：我们可以通过 attrs 来给组件添加属性，比如 defaultValue，然后通过 props 来获取属性值

```tsx
import React from "react";
import styled from "styled-components";
interface DivComponentProps {
  defaultValue: string;
}
const InputComponent = styled.input.attrs<DivComponentProps>((props) => ({
  type: "text",
  defaultValue: props.defaultValue,
}))`
  border: 1px solid blue;
  margin: 20px;
`;

const App: React.FC = () => {
  const defaultValue = "JS";
  return (
    <>
      <InputComponent defaultValue={defaultValue}></InputComponent>
    </>
  );
};

export default App;
```

- 全局样式：我们可以通过 createGlobalStyle 来创建全局样式, 然后放到 App 组件中

```tsx
import React from "react";
import { createGlobalStyle } from "styled-components";
const GlobalStyle = createGlobalStyle`
  body {
    background-color: #6160F2;
  },
  * {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
  }
  ul,ol{
      list-style: none;
  }
`;
const App: React.FC = () => {
  return (
    <>
      <GlobalStyle />
    </>
  );
};

export default App;
```

- 动画：我们可以通过 keyframes 来创建动画

```tsx
import React from "react";
import styled, { keyframes } from "styled-components";

const move = keyframes`
  0%{
    transform: translateX(0);
  }
  100%{
    transform: translateX(100px);
  }
`;
const Box = styled.div`
  width: 100px;
  height: 100px;
  background-color: #6160f2;
  animation: ${move} 1s linear infinite;
`;
const App: React.FC = () => {
  return (
    <>
      <Box></Box>
    </>
  );
};

export default App;
```

- 原理剖析
  - 这个技术叫标签模板， 是 ES6 新增的特性，它可以紧跟在函数后面，该函数将被用来调用这个字符串模板
  - 调用完成之后,这个函数的第一个参数是模板字符串的静态字符串,从第二个参数开始,是模板字符串中变量值,也就是${}里面的值
    - strArr：['\n color:red;\n width:', 'px;\n height:', 'px;\n', raw: Array(3)]
    - args：[30, 50]

```ts
const div = function (strArr: TemplateStringsArray, ...args: any[]) {
  return strArr.reduce((result, str, i) => {
    return result + str + (args[i] || "");
  }, "");
};

const a = div`
  color:red;
  width:${30}px;
  height:${50}px;
`;
console.log(a);
//  输出结果
//  color:red;
//  width:30px;
//  height:50px;
```

### css 原子化

- 什么是原子化 css：原子化 CSS 是一种现代 CSS 开发方法，它将 CSS 样式拆分成最小的、单一功能的类。比如一个类只负责设置颜色，另一个类只负责设置边距。这种方式让样式更容易维护和复用，能提高开发效率，减少代码冗余。通过组合这些小型样式类，我们可以构建出复杂的界面组件
- 原子化 css 基本概念：原子化 css 是一种 css 的编程范式，它将 css 的样式拆分成最小的单元，每个单元都是一个独立的 css 类
- 推荐：tailwindcss

## Hooks

> 所有 hook 都必须在组件最顶层调用

### 数据驱动

#### useState

- 基本数据类型使用
  - useState 接收一个参数，即状态的初始值，然后返回一个数组，其中包含两个元素：当前的状态值和一个更新该状态的函数
  - `const [state, setState] = useState(initialState)`

```tsx
import { useState } from "react";
function App() {
  const [value, setValue] = useState("test");
  const handleClick = () => {
    setValue("test-update");
  };
  return (
    <>
      <h1>{value}</h1>
      <button onClick={handleClick}>Update</button>
    </>
  );
}

export default App;
```

- 引用数据类型使用

  - 数组：在 React 中你需要将数组视为只读的，不可以直接修改原数组

  ```tsx
  import { useState } from "react";
  function App() {
    const [value, setValue] = useState([1, 2, 3]);
    const handleClick = () => {
      setValue([...value, 4]);
    };
    return (
      <>
        <h1>{value}</h1>
        <button onClick={handleClick}>Update</button>
      </>
    );
  }

  export default App;
  ```

  - 对象：在使用 setObject 的时候，可以使用 Object.assign 合并对象 或者 ... 合并对象，不能单独赋值，不然会覆盖原始对象

  ```tsx
  import { useState } from "react";
  function App() {
    const [value, setValue] = useState(() => {
      const timestamp = Date.now();
      return {
        timestamp,
        name: "js",
      };
    });
    const handleClick = () => {
      // setValue({ ...value, name: "sx" });
      setValue(Object.assign({}, value, { name: "sx" }));
    };
    return (
      <>
        <div>Timestamp: {value.timestamp}</div>
        <div>Name: {value.name}</div>
        <button onClick={handleClick}>Update</button>
      </>
    );
  }

  export default App;
  ```

  > useState 可以接受一个函数，可以在函数里面编写逻辑，初始化值，注意这个只会执行一次，更新的时候就不会执行了

- 更新机制

  - 异步机制

  ```tsx
  import { useState } from "react";
  function App() {
    const [value, setValue] = useState(0);
    const handleClick = () => {
      setValue(value + 1); // 异步任务
      console.log(value); // 0 同步任务
    };
    return (
      <>
        <h1>{value}</h1>
        <button onClick={handleClick}>Update</button>
      </>
    );
  }

  export default App;
  ```

  - 内部机制：当我们多次以相同的操作更新状态时，React 会进行比较，如果值相同，则会屏蔽后续的更新行为。自带防抖的功能，防止频繁的更新

  ```tsx
  import { useState } from "react";
  function App() {
    const [value, setValue] = useState(0);
    const handleClick = () => {
      // setValue(value + 1) // 1
      // setValue(value + 1) // 1
      // setValue(value + 1) // 1
      setValue((value) => value + 1); // 1
      setValue((value) => value + 1); // 2
      setValue((value) => value + 1); // 3
      // value => value + 1 将接收 value 作为待定状态，并返回 value + 1 作为下一个状态
    };
    return (
      <>
        <h1>{value}</h1>
        <button onClick={handleClick}>Update</button>
      </>
    );
  }

  export default App;
  ```

#### useReducer

- useReducer 是 React 提供的一个高级 Hook，没有它我们也可以正常开发，但是 useReducer 可以使我们的代码具有更好的可读性，可维护性
- useReducer 跟 useState 一样的都是帮我们管理组件的状态的，但是呢与 useState 不同的是 useReducer 是集中式的管理状态的
- `const [state, dispatch] = useReducer(reducer, initialArg, init?)`
  - reducer 是一个处理函数，用于更新状态, reducer 里面包含了两个参数，第一个参数是 state，第二个参数是 action。reducer 会返回一个新的 state。
  - initialArg 是 state 的初始值。
  - init 是一个可选的函数，用于初始化 state，如果编写了 init 函数，则默认值使用 init 函数的返回值，否则使用 initialArg
- 计数器案例

```tsx
import { useState, useReducer } from "react";
const initState = {
  count: -1,
};
type State = typeof initState;
const initFn = (state: State) => {
  return { count: state.count + 1 };
};
const reducer = (state: State, action: { type: string }) => {
  switch (action.type) {
    case "add":
      return { count: state.count + 1 };
    case "sub":
      return { count: state.count - 1 };
    default:
      return state;
  }
};
function App() {
  const [count, seCount] = useState(0);
  const [state, dispatch] = useReducer(reducer, initState, initFn);
  return (
    <>
      <h1>{count}</h1>
      <button onClick={() => seCount(count + 1)}>+1</button>
      <button onClick={() => seCount(count - 1)}>-1</button>
      ==================
      <h1>{state.count}</h1>
      <button onClick={() => dispatch({ type: "add" })}>+1</button>
      <button onClick={() => dispatch({ type: "sub" })}>-1</button>
    </>
  );
}

export default App;
```

- 购物车案例

```tsx
import { useReducer } from "react";
const initData = [
  { name: "product1", price: 100, count: 1, id: 1, isEdit: false },
  { name: "product2", price: 200, count: 1, id: 2, isEdit: false },
  { name: "product3", price: 300, count: 1, id: 3, isEdit: false },
];
type List = typeof initData;
interface Action {
  type: "ADD" | "SUB" | "DELETE" | "EDIT" | "UPDATE_NAME";
  id: number;
  newName?: string;
}
function reducer(state: List, action: Action) {
  const item = state.find((item) => item.id === action.id)!;
  switch (action.type) {
    case "ADD":
      item.count++;
      return [...state];
    case "SUB":
      item.count--;
      return [...state];
    case "DELETE":
      return state.filter((item) => item.id !== action.id);
    case "EDIT":
      item.isEdit = !item.isEdit;
      return [...state];
    case "UPDATE_NAME":
      item.name = action.newName!;
      return [...state];
    default:
      return state;
  }
}
function App() {
  const [data, dispatch] = useReducer(reducer, initData);
  return (
    <>
      <table cellPadding={0} cellSpacing={0} width={600} border={1}>
        <thead>
          <tr>
            <th>Name</th>
            <th>Price</th>
            <th>Count</th>
            <th>Operation</th>
          </tr>
        </thead>
        <tbody>
          {data.map((item) => {
            return (
              <tr key={item.id}>
                <td align="center">
                  {item.isEdit ? (
                    <input
                      onBlur={() => dispatch({ type: "EDIT", id: item.id })}
                      onChange={(e) =>
                        dispatch({
                          type: "UPDATE_NAME",
                          id: item.id,
                          newName: e.target.value,
                        })
                      }
                      value={item.name}
                    />
                  ) : (
                    <span>{item.name}</span>
                  )}
                </td>
                <td align="center">{item.price * item.count}</td>
                <td align="center">
                  <button
                    onClick={() => dispatch({ type: "SUB", id: item.id })}
                  >
                    -
                  </button>
                  <span>{item.count}</span>
                  <button
                    onClick={() => dispatch({ type: "ADD", id: item.id })}
                  >
                    +
                  </button>
                </td>
                <td align="center">
                  <button
                    onClick={() => dispatch({ type: "EDIT", id: item.id })}
                  >
                    Edit
                  </button>
                  <button
                    onClick={() => dispatch({ type: "DELETE", id: item.id })}
                  >
                    Delete
                  </button>
                </td>
              </tr>
            );
          })}
        </tbody>
        <tfoot>
          <tr>
            <td colSpan={3}></td>
            <td align="center">
              Total:
              {data.reduce((prev, next) => prev + next.price * next.count, 0)}
            </td>
          </tr>
        </tfoot>
      </table>
    </>
  );
}

export default App;
```

#### useSyncExternalStore

- useSyncExternalStore 是 React 18 引入的一个 Hook，用于从外部存储获取状态并在组件中同步显示。这对于需要跟踪外部状态的应用非常有用
- 场景
  - 订阅外部 store 例如(redux,Zustand 德语)
  - 订阅浏览器 API 例如(online,storage,location)等
  - 抽离逻辑，编写自定义 hooks
  - 服务端渲染支持
- `const res = useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot?)`
  - subscribe：用来订阅数据源的变化，接收一个回调函数，在数据源更新时调用该回调函数
  - getSnapshot：获取当前数据源的快照（当前状态）
  - getServerSnapshot?：在服务器端渲染时用来获取数据源的快照
  - 返回值：该 res 的当前快照，可以在你的渲染逻辑中使用

```tsx
const subscribe = (callback: () => void) => {
  // 订阅
  callback();
  return () => {
    // 取消订阅
  };
};

const getSnapshot = () => {
  return data;
};

const res = useSyncExternalStore(subscribe, getSnapshot);
```

- 订阅浏览器 Api 实现自定义 hook

```tsx
import { useStorage } from "./hooks/useStorage";
function App() {
  const [count, setCount] = useStorage("count", 1);
  return (
    <>
      <h1>{count}</h1>
      <button onClick={() => setCount(count + 1)}>+1</button>
      <button onClick={() => setCount(count - 1)}>-1</button>
    </>
  );
}

export default App;
```

```ts
import { useSyncExternalStore } from "react";
// 导出一个名为useStorage的函数，接收两个参数：key和initialValue
export const useStorage = (key: string, initialValue: any) => {
  // 订阅者
  const subscribe = (callback: () => void) => {
    // 订阅浏览器API
    window.addEventListener("storage", callback);
    return () => {
      // 返回取消订阅
      window.removeEventListener("storage", callback);
    };
  };

  const getSnapshot = () => {
    // 从sessionStorage中获取key对应的值，如果存在则解析为JSON对象，否则返回initialValue
    return JSON.parse(sessionStorage.getItem(key)!) ?? initialValue;
  };

  const res = useSyncExternalStore(subscribe, getSnapshot);
  const updateStorage = (value: any) => {
    sessionStorage.setItem(key, JSON.stringify(value));
    // 通知订阅者
    window.dispatchEvent(new StorageEvent("storage"));
  };
  return [res, updateStorage];
};
```

- 订阅 history 实现路由跳转

```tsx
import { useHistory } from "./hooks/useHistory";
function App() {
  const [url, push, replace] = useHistory();
  return (
    <>
      <h1>{url}</h1>
      <button onClick={() => push("/A")}>Push</button>
      <button onClick={() => replace("/B")}>Replace</button>
    </>
  );
}

export default App;
```

```ts
import { useSyncExternalStore } from "react";
// history api去实现 跳转页面 监听history变化
export const useHistory = () => {
  const subscribe = (callback: () => void) => {
    window.addEventListener("popstate", callback);
    window.addEventListener("hashchange", callback);
    return () => {
      window.removeEventListener("popstate", callback);
      window.removeEventListener("hashchange", callback);
    };
    // popstate: 只能监听浏览器的前进后退
  };
  const getSnapshot = () => {
    return window.location.href;
  };
  const url = useSyncExternalStore(subscribe, getSnapshot);
  const push = (path: string) => {
    window.history.pushState(null, "", path);
    window.dispatchEvent(new PopStateEvent("popstate"));
  };
  const replace = (path: string) => {
    window.history.replaceState(null, "", path);
    window.dispatchEvent(new PopStateEvent("popstate"));
  };
  return [url, push, replace] as const; // 返回一个元组
};
```

- 注意事项
  - 如果 getSnapshot 返回值不同于上一次，React 会重新渲染组件。这就是为什么，如果总是返回一个不同的值，会进入到一个无限循环，并产生这个报错（`Uncaught (in promise) Error: Maximum update depth exceeded. This can happen when a component repeatedly calls setState inside componentWillUpdate or componentDidUpdate. React limits the number of nested updates to prevent infinite loops.`）
  ```ts
  function getSnapshot() {
    return myStore.todos; //object
  }
  ```
  - 如果你的 store 数据是可变的，getSnapshot 函数应当返回一个它的不可变快照。这意味着 确实 需要创建新对象，但不是每次调用都如此。而是应当保存最后一次计算得到的快照，并且在 store 中的数据不变的情况下，返回与上一次相同的快照。如何决定可变数据发生了改变则取决于你的可变 store
  ```ts
  function getSnapshot() {
    if (myStore.todos !== lastTodos) {
      // 只有在 todos 真的发生变化时，才更新快照
      lastSnapshot = { todos: myStore.todos.slice() };
      lastTodos = myStore.todos;
    }
    return lastSnapshot;
  }
  ```

#### useTransition

- useTransition 是 React 18 中引入的一个 Hook，用于管理 UI 中的过渡状态，特别是在处理长时间运行的状态更新时。它允许你将某些更新标记为“过渡”状态，这样 React 可以优先处理更重要的更新，比如用户输入，同时延迟处理过渡更新
- `const [isPending, startTransition] = useTransition();`

  - isPending(boolean)，告诉你是否存在待处理的 transition
  - startTransition(function) 函数，你可以使用此方法将状态更新标记为 transition，不允许在该函数使用异步函数

- 模拟数据

```ts
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react-swc";
// vite 插件
import type { Plugin } from "vite";
import mockjs from "mockjs";
import url from "node:url";
const viteMockServer = (): Plugin => {
  return {
    name: "vite:mock-server",
    configureServer(server) {
      server.middlewares.use("/api/list", (req, res) => {
        const parseUrl = url.parse(req.originalUrl!, true).query;
        res.setHeader("Content-Type", "application/json;charset=utf-8");
        const data = mockjs.mock({
          "list|1000": [
            {
              "id|+1": 1,
              name: `@name(true)`,
              keyword: parseUrl.name,
              "age|18-60": 1,
              "gender|1": ["Male", "Female"],
            },
          ],
        });
        res.end(JSON.stringify(data));
      });
    },
  };
};
// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), viteMockServer()],
});
```

```tsx
import React, { useState, useTransition } from "react";
import { Input, List } from "antd";

interface Item {
  id: number;
  name: string;
  keyword: string;
  age: number;
  gender: string;
}
function App() {
  const [value, setValue] = useState("");
  const [list, setList] = useState<Item[]>([]);
  const [isPending, startTransition] = useTransition();
  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    setValue(value);
    fetch("/api/list?keyword=" + value)
      .then((res) => res.json())
      .then((data) => {
        startTransition(() => {
          setList(data.list);
        });
      });
  };
  return (
    <>
      <div>
        <Input value={value} onChange={handleChange} />
        {isPending ? (
          <div>Loading...</div>
        ) : (
          <List
            renderItem={(item) => (
              <List.Item>
                <List.Item.Meta
                  title={item.name}
                  description={item.age + " | " + item.gender}
                />
              </List.Item>
            )}
            dataSource={list}
          />
        )}
      </div>
    </>
  );
}

export default App;
```

#### useDeferredValue

- useDeferredValue 用于延迟某些状态的更新，直到主渲染任务完成。这对于高频更新的内容（如输入框、滚动等）非常有用，可以让 UI 更加流畅，避免由于频繁更新而导致的性能问题。

- 关联问题：useTransition 和 useDeferredValue 的区别

  - useTransition 和 useDeferredValue 都涉及延迟更新，但它们关注的重点和用途略有不同：

  - useTransition 主要关注点是状态的过渡。它允许开发者控制某个更新的延迟更新，还提供了过渡标识，让开发者能够添加过渡反馈。
  - useDeferredValue 主要关注点是单个值的延迟更新。它允许你把特定状态的更新标记为低优先级。

- `const deferredValue = useDeferredValue(value);`
  - value: 延迟更新的值(支持任意类型)
  - deferredValue: 延迟更新的值,在初始渲染期间，返回的延迟值将与您提供的值相同
- 注意事项：当 useDeferredValue 接收到与之前不同的值（使用 Object.is 进行比较）时，除了当前渲染（此时它仍然使用旧值），它还会安排一个后台重新渲染。这个后台重新渲染是可以被中断的，如果 value 有新的更新，React 会从头开始重新启动后台渲染。举个例子，如果用户在输入框中的输入速度比接收延迟值的图表重新渲染的速度快，那么图表只会在用户停止输入后重新渲染

```tsx
import { useState, useDeferredValue } from "react";
import { Input, List } from "antd";
import mockjs from "mockjs";

interface Item {
  id: number;
  name: string;
  address: string;
}
function App() {
  const [value, setValue] = useState("");
  const [list] = useState<Item[]>(() => {
    return mockjs.mock({
      "list|1000": [
        {
          "id|+1": 1,
          name: "@natural",
          address: "@county(true)",
        },
      ],
    }).list;
  });
  const deferredQuery = useDeferredValue(value);
  const findItem = () => {
    return list.filter((item) => item.name.toString().includes(deferredQuery));
  };
  return (
    <>
      <div>
        <Input value={value} onChange={(e) => setValue(e.target.value)} />
        <List
          renderItem={(item) => (
            <List.Item>
              <List.Item.Meta title={item.name} description={item.address} />
            </List.Item>
          )}
          dataSource={findItem()}
        />
      </div>
    </>
  );
}

export default App;
```

### 副作用

#### useEffect

- useEffect 是 React 中用于处理副作用的钩子。并且 useEffect 还在这里充当生命周期函数，在之前你可能会在类组件中使用 componentDidMount、componentDidUpdate 和 componentWillUnmount 来处理这些生命周期事件
- 纯函数

  - 输入决定输出：相同的输入永远会得到相同的输出。这意味着函数的行为是可预测的
  - 无副作用：纯函数不会修改外部状态，也不会依赖外部可变状态。因此，纯函数内部的操作不会影响外部的变量、文件、数据库等

  ```ts
  const add = (x: number, y: number) => x + y;
  add(1, 2); // 3
  ```

- 副作用函数

  - 副作用函数 指的是那些在执行时会改变外部状态或依赖外部可变状态的函数
  - 可预测性降低但是副作用不一定是坏事有时候副作用带来的效果才是我们所期待的
  - 高耦合度函数非常依赖外部的变量状态紧密
  - 例如
    - 操作引用类型
    - 操作本地存储例如 localStorage
    - 调用外部 API，例如 fetch ajax
    - 操作 DOM
    - 计时器

  ```ts
  let globalVariable = 0;

  function calculateDouble(number) {
    globalVariable += 1; // 修改函数外部环境变量

    localStorage.setItem("globalVariable", globalVariable); // 修改 localStorage

    fetch(/* ... */).then((res) => {
      // 网络请求
      // ...
    });

    document.querySelector(".app").style.color = "red"; // 修改 DOM element

    return number * 2;
  }
  ```

- `useEffect(setup, dependencies?)`
  - setup：Effect 处理函数,可以返回一个清理函数。组件挂载时执行 setup,依赖项更新时先执行 cleanup 再执行 setup,组件卸载时执行 cleanup
  - dependencies(可选)：setup 中使用到的响应式值列表(props、state 等)。必须以数组形式编写如[dep1, dep2]。不传则每次重渲染都执行 Effect
  - 返回值：useEffect 返回 undefined
- 副作用函数能做的事情 useEffect 都能做，例如操作 DOM、网络请求、计时器等等

```tsx
import { useEffect } from "react";

function App() {
  const dom = document.getElementById("data");
  console.log(dom); // null
  useEffect(() => {
    const data = document.getElementById("data");
    console.log(data); // <div id='data'>js</div>
    fetch("http://localhost:5174/getList");
  }, []);
  return <div id="data">js</div>;
}

export default App;
```

- 执行时机

  - 组件挂载时执行：根据我们下面的例子可以观察到，组件在挂载的时候就执行了 useEffect 的副作用函数。类似于 componentDidMount

  ```tsx
  import { useEffect } from "react";

  function App() {
    useEffect(() => {
      console.log("init");
    }, []);
    return <div id="data">js</div>;
  }

  export default App;
  ```

  - 组件更新时执行

    - 无依赖项更新：根据我们下面的例子可以观察到，当有响应式值发生改变时，useEffect 的副作用函数就会执行。类似于 componentDidUpdate + componentDidMount

    ```tsx
    import { useEffect, useState } from "react";

    function App() {
      const [count, setCount] = useState(0);
      useEffect(() => {
        console.log("update");
      });
      return (
        <div>
          <button onClick={() => setCount(count + 1)}>{count}</button>
        </div>
      );
    }

    export default App;
    ```

    - 有依赖项更新：根据我们下面的例子可以观察到，当依赖项数组中的 count 值发生改变时，useEffect 的副作用函数就会执行。而当 name 值改变时,由于它不在依赖项数组中,所以不会触发副作用函数的执行

    ```tsx
    import { useEffect, useState } from "react";

    function App() {
      const [count, setCount] = useState(0);
      const [name, setName] = useState("");
      useEffect(() => {
        console.log("update");
      }, [count]);
      return (
        <div>
          <button onClick={() => setCount(count + 1)}>{count}</button>
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
          />
        </div>
      );
    }

    export default App;
    ```

    - 依赖项空值：根据我们下面的例子可以观察到，当依赖项为空数组时，useEffect 的副作用函数只会执行一次，也就是组件挂载时执行。适合做一些初始化的操作例如获取详情什么的

  - 组件卸载时执行：useEffect 的副作用函数可以返回一个清理函数，当组件卸载时，useEffect 的副作用函数就会执行清理函数。确切说清理函数就是副作用函数运行之前，会清楚上一次的副作用函数。类似于 componentWillUnmount

  ```tsx
  import { useEffect, useState } from "react";
  const Child = (props: { name: string }) => {
    useEffect(() => {
      const timer = setTimeout(() => {
        fetch("http://localhost:5173/getList?name=" + props.name);
      }, 500);
      return () => {
        clearTimeout(timer);
        console.log("unmount");
      };
    }, [props.name]);
    return <div>child</div>;
  };
  function App() {
    const [name, setName] = useState("");
    const [show, setShow] = useState(true);
    return (
      <div>
        <button onClick={() => setShow(!show)}>{show ? "Hide" : "Show"}</button>
        <input
          type="text"
          value={name}
          onChange={(e) => setName(e.target.value)}
        />
        {show && <Child name={name} />}
      </div>
    );
  }

  export default App;
  ```

- 用户信息获取案例

```tsx
import React, { useState, useEffect } from "react";
interface UserData {
  name: string;
  email: string;
  username: string;
  phone: string;
  website: string;
}
function App() {
  const [userId, setUserId] = useState(1);
  const [userData, setUserData] = useState<UserData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<null | string>(null);

  useEffect(() => {
    const fetchUserData = async () => {
      if (userId) {
        setLoading(true);
        setError(null);
        setUserData(null);
        try {
          const response = await fetch(
            `https://jsonplaceholder.typicode.com/users/${userId}`
          );
          if (!response.ok) {
            throw new Error(response.status.toString());
          }
          const data = await response.json();
          setUserData(data);
          setError(null);
        } catch (err: unknown) {
          if (err instanceof Error) {
            setError(err.message);
          } else {
            setError("An unknown error occurred");
          }
        } finally {
          setLoading(false);
        }
      }
    };
    fetchUserData();
  }, [userId]);

  const handleUserChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setUserId(parseInt(event.target.value));
  };

  return (
    <div>
      <label>
        输入用户ID:
        <input
          type="number"
          value={userId}
          onChange={handleUserChange}
          min="1"
          max="10"
        />
      </label>
      <div>
        <h2>User Info</h2>
        {loading && <p>Loading...</p>}
        {error && <p>Error: {error}</p>}
        {userData && (
          <>
            <p>Name: {userData.name}</p>
            <p>Email: {userData.email}</p>
            <p>UserName: {userData.username}</p>
            <p>Phone: {userData.phone}</p>
            <p>Website: {userData.website}</p>
          </>
        )}
      </div>
    </div>
  );
}

export default App;
```

#### useLayoutEffect

- useLayoutEffect 是 React 中的一个 Hook，用于在浏览器重新绘制屏幕之前触发。与 useEffect 类似

```tsx
useLayoutEffect(() => {
  // 副作用代码
  return () => {
    // 清理代码
  };
}, [dependencies]); // 依赖项数组
```

- 区别(useLayoutEffect/useEffect)

| 区别     | useLayoutEffect                      | useEffect                            |
| -------- | ------------------------------------ | ------------------------------------ |
| 执行时机 | 浏览器完成布局和绘制`之前`执行副作用 | 浏览器完成布局和绘制`之后`执行副作用 |
| 执行方式 | 同步执行                             | 异步执行                             |
| DOM 渲染 | 阻塞 DOM 渲染                        | 不阻塞 DOM 渲染                      |

- 测试 DOM 阻塞

```tsx
import { useLayoutEffect, useEffect, useState } from "react";

function App() {
  const [count, setCount] = useState(0);
  // 不阻塞DOM
  // useEffect(() => {
  //   for (let i = 0; i < 50000; i++) {
  //     console.log(i);
  //     setCount((count) => count + 1);
  //   }
  // }, []);
  // 阻塞DOM
  useLayoutEffect(() => {
    for (let i = 0; i < 50000; i++) {
      // console.log(i);
      setCount((count) => count + 1);
    }
  }, []);
  return (
    <div>
      <div>app</div>
      {Array.from({ length: count }).map((_, index) => (
        <div key={index}>{index}</div>
      ))}
    </div>
  );
}

export default App;
```

- 测试同步异步渲染

```css
#app1 {
  width: 200px;
  height: 200px;
  background: red;
}

#app2 {
  width: 200px;
  height: 200px;
  background: blue;
  margin-top: 20px;
  position: absolute;
  top: 230px;
}
```

```tsx
import { useLayoutEffect, useEffect } from "react";
import "./App.css";

function App() {
  // 使用 useEffect 实现动画效果
  useEffect(() => {
    const app1 = document.getElementById("app1") as HTMLDivElement;
    app1.style.transition = "opacity 3s";
    app1.style.opacity = "1";
  }, []);

  // 使用 useLayoutEffect 实现动画效果
  useLayoutEffect(() => {
    const app2 = document.getElementById("app2") as HTMLDivElement;
    app2.style.transition = "opacity 3s";
    app2.style.opacity = "1";
  }, []);

  return (
    <div>
      <div id="app1" style={{ opacity: 0 }}>
        app1
      </div>
      <div id="app2" style={{ opacity: 0 }}>
        app2
      </div>
    </div>
  );
}

export default App;
```

- 应用场景
  - 需要同步读取或更改 DOM：例如，你需要读取元素的大小或位置并在渲染前进行调整。
  - 防止闪烁：在某些情况下，异步的 useEffect 可能会导致可见的布局跳动或闪烁。例如，动画的启动或某些可见的快速 DOM 更改。
  - 模拟生命周期方法：如果你正在将旧的类组件迁移到功能组件，并需要模拟 componentDidMount、componentDidUpdate 和 componentWillUnmount 的同步行为
- 案例：可以记录滚动条位置，等用户返回这个页面时，滚动到之前记录的位置，增强用户体验

```tsx
import React, { useLayoutEffect } from "react";

function App() {
  const scrollHandler = (e: React.UIEvent<HTMLUListElement>) => {
    const scrollTop = e.currentTarget.scrollTop;
    window.history.replaceState({}, "", `?top=${scrollTop}`);
  };
  useLayoutEffect(() => {
    const urlParams = new URLSearchParams(window.location.search);
    const top = urlParams.get("top");
    if (top) {
      const list = document.getElementById("list");
      if (list) {
        list.scrollTop = parseInt(top);
      }
    }
  });
  return (
    <ul
      onScroll={scrollHandler}
      id="list"
      style={{ height: "500px", overflowY: "scroll" }}
    >
      {Array.from({ length: 500 }, (_, i) => (
        <li key={i}>Item {i + 1}</li>
      ))}
    </ul>
  );
}

export default App;
```

### 状态传递

#### useRef

- 当你在 React 中需要处理 DOM 元素或需要在组件渲染之间保持持久性数据时，便可以使用 useRef

```tsx
import { useRef } from "react";
const refValue = useRef(initialValue);
refValue.current;
// 访问ref的值 类似于vue的ref,Vue的ref是.value
// 其次就是vue的ref是响应式的，而react的ref不是响应式的
```

- initialValue：ref 对象的 current 属性的初始值。可以是任意类型的值。这个参数在首次渲染后被忽略
- 返回值：useRef 返回一个对象，对象的 current 属性指向传入的初始值。 {current:xxxx}

> 注意
> 改变 ref.current 属性时，React 不会重新渲染组件。React 不知道它何时会发生改变，因为 ref 是一个普通的 JavaScript 对象
> 除了 初始化 外不要在渲染期间写入或者读取 ref.current，否则会使组件行为变得不可预测

- 通过 Ref 操作 DOM 元素

```tsx
import { useRef } from "react";

function App() {
  const divRef = useRef<HTMLDivElement>(null);
  const handleClick = () => {
    console.dir(divRef.current);
    divRef.current!.style.color = "red";
  };
  return (
    <div>
      <h1>Blog</h1>
      <div ref={divRef}>Balabalabala...</div>
      <button onClick={handleClick}>Get dom</button>
    </div>
  );
}

export default App;
```

- 数据存储

```tsx
import { useRef, useState } from "react";

function App() {
  // let num = 0; // setCount导致组件重新渲染，num值一直为0
  const num = useRef(0); // useRef在组件重新渲染时不会丢失状态
  const [count, setCount] = useState(0);
  const handleClick = () => {
    setCount(count + 1);
    // num = count; // 这里num的值已更新
    num.current = count; // 这里num的值已更新
  };
  return (
    <div>
      <div>count: {count}</div>
      <div>num: {num.current}</div>
      <button onClick={handleClick}>add</button>
    </div>
  );
}

export default App;
```

- 计数器案例

```tsx
import { useRef, useState } from "react";

function App() {
  const timer = useRef<null | NodeJS.Timeout>(null);
  const [count, setCount] = useState(0);
  const handleStart = () => {
    timer.current = setInterval(() => {
      setCount((count) => count + 1);
    }, 300);
  };
  const handleFinish = () => {
    if (timer.current) {
      clearInterval(timer.current);
      timer.current = null;
    }
  };
  return (
    <div>
      <div>{count}</div>
      <button onClick={handleStart}>Start</button>
      <button onClick={handleFinish}>Finish</button>
    </div>
  );
}

export default App;
```

- 注意事项
  - 组件在重新渲染的时候，useRef 的值不会被重新初始化
  - 改变 ref.current 属性时，React 不会重新渲染组件。React 不知道它何时会发生改变，因为 ref 是一个普通的 JavaScript 对象
  - useRef 的值不能作为 useEffect 等其他 hooks 的依赖项，因为它并不是一个响应式状态
  - useRef 不能直接获取子组件的实例，需要使用 forwardRef

#### useImperativeHandle

- 可以在子组件内部暴露给父组件句柄，那么说人话就是，父组件可以调用子组件的方法，或者访问子组件的属性，就类似于 Vue 的 defineExpose

```tsx
useImperativeHandle(
  ref,
  () => {
    return {
      // 暴露给父组件的方法或属性
    };
  },
  [deps]
);
```

- ref: 父组件传递的 ref 对象
- createHandle: 返回值，返回一个对象，对象的属性就是子组件暴露给父组件的方法或属性
- deps?:\[可选\] 依赖项，当依赖项发生变化时，会重新调用 createHandle 函数，类似于 useEffect 的依赖项

```tsx
import React, { useImperativeHandle, useRef, useState } from "react";
interface ChildRef {
  name: string;
  count: number;
  addCount: () => void;
  subCount: () => void;
}

// React18
// const Child = React.forwardRef<ChildRef>((_, ref) => {
//   const [count, setCount] = useState(0);
//   //重点
//   useImperativeHandle(ref, () => {
//     return {
//       name: "child",
//       count,
//       addCount: () => setCount(count + 1),
//       subCount: () => setCount(count - 1),
//     };
//   });
//   return (
//     <div>
//       <h3>Child</h3>
//       <div>count:{count}</div>
//       <button onClick={() => setCount(count + 1)}>+</button>
//       <button onClick={() => setCount(count - 1)}>-</button>
//     </div>
//   );
// });
// React19
const Child = ({ ref }: { ref: React.Ref<ChildRef> }) => {
  const [count, setCount] = useState(0);
  //重点
  useImperativeHandle(ref, () => {
    return {
      name: "child",
      count,
      addCount: () => setCount(count + 1),
      subCount: () => setCount(count - 1),
    };
  });
  return (
    <div>
      <h3>Child</h3>
      <div>count:{count}</div>
      <button onClick={() => setCount(count + 1)}>+</button>
      <button onClick={() => setCount(count - 1)}>-</button>
    </div>
  );
};

function App() {
  const childRef = useRef<ChildRef>(null);
  const showRefInfo = () => {
    console.log(childRef.current);
  };
  return (
    <div>
      <h2>Parent</h2>
      <button onClick={showRefInfo}>Get child</button>
      <button onClick={() => childRef.current?.addCount()}>child+1</button>
      <button onClick={() => childRef.current?.subCount()}>child-1</button>
      <hr />
      <Child ref={childRef}></Child>
    </div>
  );
}

export default App;
```

- 版本区别
  - 18 版本
    - 需要配合 forwardRef 一起使用
    - forwardRef 包装之后，会有两个参数，第一个参数是 props，第二个参数是 ref
  - 19 版本
    - 不需要配合 forwardRef 一起使用，直接使用即可，会把 Ref 跟 props 放到一起
    - useRef 的参数改为必须传入一个参数例，如`useRef<ChildRef>(null)`
- 执行时机

  - `useImperativeHandle(ref, () => {})`：如果不传入第三个参数，那么 useImperativeHandle 会在组件挂载时执行一次，然后状态更新时，都会执行一次
  - `useImperativeHandle(ref, () => {}, [])`：如果传入第三个参数，并且是一个空数组，那么 useImperativeHandle 会在组件挂载时执行一次，然后状态更新时，不会执行
  - `useImperativeHandle(ref, () => {}, [count])`：如果传入第三个参数，并且有值，那么 useImperativeHandle 会在组件挂载时执行一次，然后会根据依赖项的变化，决定是否重新执行

- 表单案例

```tsx
import React, { useImperativeHandle, useRef, useState } from "react";
interface ChildRef {
  name: string;
  validate: () => string | true;
  reset: () => void;
}

const Child = ({ ref }: { ref: React.Ref<ChildRef> }) => {
  const [form, setForm] = useState({
    username: "",
    password: "",
    email: "",
  });
  const validate = () => {
    if (!form.username) {
      return "Username can not be empty";
    }
    if (!form.password) {
      return "Password can not be empty";
    }
    if (!form.email) {
      return "Email can not be empty";
    }
    return true;
  };
  const reset = () => {
    setForm({
      username: "",
      password: "",
      email: "",
    });
  };
  useImperativeHandle(ref, () => {
    return {
      name: "child",
      validate: validate,
      reset: reset,
    };
  });
  return (
    <div style={{ marginTop: "20px" }}>
      <h3>Form</h3>
      <input
        value={form.username}
        onChange={(e) => setForm({ ...form, username: e.target.value })}
        placeholder="Please input username"
        type="text"
      />
      <input
        value={form.password}
        onChange={(e) => setForm({ ...form, password: e.target.value })}
        placeholder="Please input password"
        type="text"
      />
      <input
        value={form.email}
        onChange={(e) => setForm({ ...form, email: e.target.value })}
        placeholder="Please input email"
        type="text"
      />
    </div>
  );
};

function App() {
  const childRef = useRef<ChildRef>(null);
  const showRefInfo = () => {
    console.log(childRef.current);
  };
  const submit = () => {
    const res = childRef.current?.validate();
    console.log(res);
  };
  return (
    <div>
      <h2>Parent</h2>
      <button onClick={showRefInfo}>Get child</button>
      <button onClick={() => submit()}>Validate child</button>
      <button onClick={() => childRef.current?.reset()}>Reset</button>
      <hr />
      <Child ref={childRef}></Child>
    </div>
  );
}

export default App;
```

#### useContext

- useContext 提供了一个无需为每层组件手动添加 props，就能在组件树间进行数据传递的方法。设计的目的就是解决组件树间数据传递的问题

```tsx
const MyThemeContext = React.createContext({ theme: "light" }); // 创建一个上下文
function App() {
  return (
    <MyThemeContext.Provider value={{ theme: "light" }}>
      <MyComponent />
    </MyThemeContext.Provider>
  );
}
function MyComponent() {
  const themeContext = useContext(MyThemeContext); // 使用上下文
  return <div>{themeContext.theme}</div>;
}
```

- 入参 context：是 createContext 创建出来的对象，他不保持信息，他是信息的载体。声明了可以从组件获取或者给组件提供信息。
- 返回值返回传递的 Context 的值，并且是只读的。如果 context 发生变化，React 会自动重新渲染读取 context 的组件

- 切换主题案例

```tsx
import React, { useContext, useState } from "react";
const ThemeContext = React.createContext<ThemeContextType>(
  {} as ThemeContextType
);
interface ThemeContextType {
  theme: string;
  setTheme: (theme: string) => void;
}

// 定义一个名为Child的函数组件
const Child = () => {
  // 使用useContext钩子获取ThemeContext的值
  const themeContext = useContext(ThemeContext);
  // 定义一个名为styles的对象，用于存储组件的样式
  const styles = {
    // 根据ThemeContext的值设置背景颜色
    backgroundColor: themeContext.theme === "light" ? "white" : "black",
    // 设置边框样式
    border: "1px solid red",
    // 设置宽度
    width: 100 + "px",
    // 设置高度
    height: 100 + "px",
    // 根据ThemeContext的值设置文字颜色
    color: themeContext.theme === "light" ? "black" : "white",
  };
  // 返回一个包含一个div的div，div的样式为styles
  return (
    <div>
      <div style={styles}>child</div>
    </div>
  );
};

const Parent = () => {
  const themeContext = useContext(ThemeContext);
  const styles = {
    backgroundColor: themeContext.theme === "light" ? "white" : "black",
    border: "1px solid red",
    width: 100 + "px",
    height: 100 + "px",
    color: themeContext.theme === "light" ? "black" : "white",
  };
  return (
    <div>
      <div style={styles}>Parent</div>
      <Child />
    </div>
  );
};
function App() {
  const [theme, setTheme] = useState("light");
  return (
    <div>
      <button onClick={() => setTheme(theme === "light" ? "dark" : "light")}>
        Change Theme
      </button>

      <ThemeContext value={{ theme, setTheme }}>
        <Parent />
      </ThemeContext>
    </div>
  );
}

export default App;
```

- 注意事项

  - 19 版本和 18 版本是差不多的，只是 19 版本更加简单了，不需要再使用 Provider 包裹，直接使用即可
  - 使用 ThemeContext 时，传递的 key 必须为 value

  ```tsx
  // 🚩 不起作用：prop 应该是“value”
  <ThemeContext theme={theme}>
     <Button />
  </ThemeContext>
  // ✅ 传递 value 作为 prop
  <ThemeContext value={theme}>
     <Button />
  </ThemeContext>
  ```

  - 可以使用多个 Context；如果使用多个 Context，那么需要注意，如果使用的值是相同的，那么会覆盖

  ```tsx
  const ThemeContext = React.createContext({ theme: "light" });

  function App() {
    return (
      <ThemeContext value={{ theme: "light" }}>
        <ThemeContext value={{ theme: "dark" }}>
          {" "}
          {/* 覆盖了上面的值 */}
          <Parent />
        </ThemeContext>
      </ThemeContext>
    );
  }
  ```

### 性能优化

#### useMemo

- React.memo：React.memo 是一个 React API，用于优化性能。它通过记忆上一次的渲染结果，仅当 props 发生变化时才会重新渲染, 避免重新渲染

- 使用 React.memo 包裹组件\[一般用于子组件\]，可以避免组件重新渲染

```tsx
import React, { memo } from "react";
const MyComponent = React.memo(({ prop1, prop2 }) => {
  // 组件逻辑
});
const App = () => {
  return <MyComponent prop1="value1" prop2="value2" />;
};
```

- React 组件的渲染条件

  - 组件的 props 发生变化
  - 组件的 state 发生变化
  - useContext 发生变化

- React.memo 案例

```tsx
import React, { useState } from "react";
interface User {
  name: string;
  age: number;
  phone: string;
}
const UserCard = React.memo((props: { user: User }) => {
  console.log("render child");
  const { user } = props;
  return (
    <div>
      <p>{user.name}</p>
      <p>{user.age}</p>
      <p>{user.phone}</p>
    </div>
  );
});
function App() {
  const [input, setInput] = useState("");
  const [user, setUser] = useState({
    name: "js",
    age: 25,
    phone: "18888888888",
  });
  const changeUser = () => {
    setUser({
      ...user,
      name: input,
    });
  };
  return (
    <>
      <input value={input} onChange={(e) => setInput(e.target.value)} />
      <button onClick={changeUser}>Change User</button>
      <UserCard user={user} />
    </>
  );
}

export default App;
```

- React.memo 总结

  - 使用场景
    - 当子组件接收的 props 不经常变化时
    - 当组件重新渲染的开销较大时
    - 当需要避免不必要的渲染时
  - 优点
    - 通过记忆化避免不必要的重新渲染
    - 提高应用性能
    - 减少资源消耗
  - 注意事项
    - 不要过度使用，只在确实需要优化的组件上使用
    - 对于简单的组件，使用 memo 的开销可能比重新渲染还大
    - 如果 props 经常变化，memo 的效果会大打折扣

- useMemo 是 React 提供的一个性能优化 Hook。它的主要功能是避免在每次渲染时执行复杂的计算和对象重建。通过记忆上一次的计算结果，仅当依赖项变化时才会重新计算，提高了性能，有点类似于 Vue 的 computed

```tsx
import React, { useMemo, useState } from "react";
const App = () => {
  const [count, setCount] = useState(0);
  const memoizedValue = useMemo(() => count, [count]);
  return <div>{memoizedValue}</div>;
};
```

- 入参
  - 回调函数 Function：返回需要缓存的值
  - 依赖项 Array：依赖项发生变化时，回调函数会重新执行(执行时机跟 useEffect 类似)
- 返回值：返回需要缓存的值(返回之后就不是函数了)

```tsx
import { useMemo, useState } from "react";

function App() {
  const [search, setSearch] = useState("");
  const [goods, setGoods] = useState([
    { id: 1, name: "apple", price: 10, count: 1 },
    { id: 2, name: "banana", price: 20, count: 1 },
    { id: 3, name: "orange", price: 30, count: 1 },
  ]);
  const handleAdd = (id: number) => {
    setGoods(
      goods.map((item) =>
        item.id === id ? { ...item, count: item.count + 1 } : item
      )
    );
  };
  const handleSub = (id: number) => {
    setGoods(
      goods.map((item) =>
        item.id === id && item.count > 0
          ? { ...item, count: item.count - 1 }
          : item
      )
    );
  };
  // const total = () => {
  //   console.log("total");
  //   return goods.reduce((total, item) => total + item.price * item.count, 0);
  // };
  const total = useMemo(() => {
    console.log("total");
    return goods.reduce((total, item) => total + item.price * item.count, 0);
  }, [goods]);
  return (
    <div>
      <input
        type="text"
        value={search}
        onChange={(e) => setSearch(e.target.value)}
      />
      <table border={1} cellPadding={5} cellSpacing={0}>
        <thead>
          <tr>
            <th>Name</th>
            <th>Price</th>
            <th>Count</th>
          </tr>
        </thead>
        <tbody>
          {goods.map((item) => (
            <tr key={item.id}>
              <td>{item.name}</td>
              <td>{item.price * item.count}</td>
              <td>
                <button onClick={() => handleAdd(item.id)}>+</button>
                <span>{item.count}</span>
                <button onClick={() => handleSub(item.id)}>-</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      {/* <h2>Total: {total()}</h2> */}
      <h2>Total: {total}</h2>
    </div>
  );
}

export default App;
```

- useMemo 总结
  - 使用场景
    - 当需要缓存复杂计算结果时
    - 当需要避免不必要的重新计算时
    - 当计算逻辑复杂且耗时时
  - 优点
    - 通过记忆化避免不必要的重新计算
    - 提高应用性能
    - 减少资源消耗
  - 注意事项
    - 不要过度使用，只在确实需要优化的组件上使用
    - 如果依赖项经常变化，useMemo 的效果会大打折扣
    - 如果计算逻辑简单，使用 useMemo 的开销可能比重新计算还大

#### useCallback

- useCallback 用于优化性能，返回一个记忆化的回调函数，可以减少不必要的重新渲染，也就是说它是用于缓存组件内的函数，避免函数的重复创建
- 在 React 中，函数组件的重新渲染会导致组件内的函数被重新创建，这可能会导致性能问题。useCallback 通过缓存函数，可以减少不必要的重新渲染，提高性能

```tsx
const memoizedCallback = useCallback(() => {
  doSomething(a, b);
}, [a, b]);
```

- 入参
  - callback：回调函数
  - deps：依赖项数组，当依赖项发生变化时，回调函数会被重新创建，跟 useEffect 一样
- 返回值：返回一个记忆化的回调函数，可以减少函数的创建次数，提高性能

- 案例 1

```tsx
import React, { useCallback, useState } from "react";
const functionMap = new WeakMap();
let counter = 1;
function App() {
  console.log("render");

  const [input, setInput] = useState("");
  const changeValue = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    setInput(e.target.value);
  }, []);
  if (!functionMap.has(changeValue)) {
    functionMap.set(changeValue, counter++);
  }
  console.log("changeValue", functionMap.get(changeValue));
  return (
    <>
      <input value={input} onChange={changeValue} />
    </>
  );
}

export default App;
```

- 案例 2

```tsx
import React, { useCallback, useState } from "react";
interface Props {
  user: {
    name: string;
    age: number;
  };
  callback: () => void;
}
const Child = React.memo((props: Props) => {
  console.log("child render");
  return (
    <>
      <p>{props.user.name}</p>
      <p>{props.user.age}</p>
      <button onClick={props.callback}>click</button>
    </>
  );
});
function App() {
  const [input, setInput] = useState("");
  const [user] = useState({
    name: "js",
    age: 25,
  });
  const callback = useCallback(() => {
    console.log("callback");
  }, []);
  return (
    <>
      <input value={input} onChange={(e) => setInput(e.target.value)} />
      <Child callback={callback} user={user} />
    </>
  );
}

export default App;
```

### 工具

#### useDebugValue

- useDebugValue 是一个专为开发者调试自定义 Hook 而设计的 React Hook。它允许你在 React 开发者工具中为自定义 Hook 添加自定义的调试值

- `const debugValue = useDebugValue(value)`
- 入参
  - value: 要在 React DevTools 中显示的值
  - formatter?: (可选) 格式化函数
    - 作用：自定义值的显示格式
    - 调用时机：仅在 React DevTools 打开时才会调用，可以进行复杂的格式化操作
    - 参数：接收 value 作为参数
    - 返回：返回格式化后的显示值
  - 返回值：无(void)
- useCookie 案例

```tsx
import { useDebugValue, useState } from "react";

const useCookie = (name: string, initValue: string = "") => {
  // 1.获取Cookie
  const getCookie = () => {
    const match = document.cookie.match(
      new RegExp(`(^| )${name}=([^;]*)(;|$)`)
    );
    return match ? match[2] : initValue;
  };
  const [cookie, setCookie] = useState(getCookie());
  // 2.更新Cookie
  const updateCookie = (newValue: string) => {
    document.cookie = `${name}=${newValue}`;
    setCookie(newValue);
  };
  // 3.删除Cookie
  const deleteCookie = () => {
    document.cookie = `${name}=;expires=Thu, 01 Jan 1970 00:00:00 GMT`; // 设置过期时间为1970年1月1日
    setCookie("");
  };
  useDebugValue(cookie, (value) => {
    return `cookie: ${value}`;
  });
  return [cookie, updateCookie, deleteCookie] as const;
};

function App() {
  const [cookie, updateCookie, deleteCookie] = useCookie("myCookie", "default");
  return (
    <>
      <div>{cookie}</div>
      <button onClick={() => updateCookie("new value")}>Update</button>
      <button onClick={deleteCookie}>Delete</button>
    </>
  );
}

export default App;
```

#### useId

- useId 是 React 18 新增的一个 Hook，用于生成稳定的唯一标识符，主要用于解决 SSR 场景下的 ID 不一致问题，或者需要为组件生成唯一 ID 的场景。

- 使用场景
  - 为组件生成唯一 ID
  - 解决 SSR 场景下的 ID 不一致问题
  - 无障碍交互唯一 ID
- `const id = useId()`
  - 无入参
  - 返回值：唯一标识符 例如`«r0»`
- 案例

```tsx
import { useId } from "react";
export const App = () => {
  const id = useId();
  return (
    <>
      <label htmlFor={id}>Name</label>
      <input id={id} type="text" />
    </>
  );
};
export default App;
```

```tsx
import { useId } from "react";
export const App = () => {
  const id = useId();
  return (
    <div>
      <input type="text" aria-describedby={id} />
      <p id={id}>请输入有效的电子邮件地址，例如：xiaoman@example.com</p>
    </div>
  );
};
export default App;
```

## React Router

### 基本使用

#### 安装

- 安装：`pnpm i react-router`
- 使用模式

  - 数据模式（推荐-功能齐全）

  ```tsx
  export const router = createBrowserRouter([
    {
      path: "/",
      Component: Home,
    },
    {
      path: "/about",
      Component: About,
    },
  ]);
  ```

  - 声明模式

  ```tsx
  import React from "react";
  import ReactDOM from "react-dom/client";
  import { BrowserRouter, Routes, Route } from "react-router";
  import App from "./app";
  import About from "../about";
  const root = document.getElementById("root");

  ReactDOM.createRoot(root).render(
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<App />} />
        <Route path="about" element={<About />} />
      </Routes>
    </BrowserRouter>
  );
  ```

- 基本使用

```ts
import { createBrowserRouter } from "react-router";

import Home from "../pages/Home";
import About from "../pages/About";

const router = createBrowserRouter([
  {
    path: "/",
    Component: Home,
  },
  {
    path: "/about",
    Component: About,
  },
]);

export default router;
```

```tsx
import { NavLink } from "react-router";
export default function About() {
  return (
    <div>
      <h1>About</h1>
      <NavLink to="/">Home</NavLink>
    </div>
  );
}
```

```tsx
import { NavLink } from "react-router";
export default function Home() {
  return (
    <div>
      <h1>Home</h1>
      <NavLink to="/about">About</NavLink>
    </div>
  );
}
```

```tsx
import React from "react";
import { RouterProvider } from "react-router";
import router from "./router";
const App: React.FC = () => {
  return (
    <>
      <RouterProvider router={router} />
    </>
  );
};

export default App;
```

> RouterProvider 只是注册，并非类似于 App 的根组件，所以需要包裹在 App 组件中
> RouterProvider 只能有一个，所以需要将所有的路由都放在一个数组中

#### 路由模式

- createBrowserRouter
  - 核心特点
    - 使用 HTML5 的 history API (pushState, replaceState, popState)
    - 浏览器 URL 比较纯净 (/search, /about, /user/123)
    - 需要服务器端支持(nginx, apache,等)否则会刷新 404
  - 使用场景
    - 大多数现代浏览器环境
    - 需要服务器端支持
    - 需要 URL 美观
- createHashRouter
- 核心特点
  - 使用 URL 的 hash 部分(#/search, #/about, #/user/123)
  - 不需要服务器端支持
  - 刷新页面不会丢失
  - 使用场景
    - 静态站点托管例如(github pages, netlify, vercel)
    - 不需要服务器端支持
- createMemoryRouter
  - 核心特点
    - 使用内存中的路由表
    - 刷新页面会丢失状态
    - 切换页面路由不显示 URL
  - 使用场景
    - 非浏览器环境例如(React Native, Electron)
    - 单元测试或者组件测试(Jest, Vitest)
- createStaticRouter
  - 核心特点
    - 专为服务端渲染（SSR）设计
    - 在服务器端匹配请求路径，生成静态 HTML
    - 需与客户端路由器（如 createBrowserRouter）配合使用
  - 使用场景
    - 服务端渲染应用（如 Next.js 的兼容方案）
    - 需要 SEO 优化的页面
- 解决刷新 404

```conf
location / {
  try_files $uri $uri/ /index.html;
};
```

#### 路由

- 嵌套路由

  - 嵌套路由就是父路由中嵌套子路由 children，子路由可以继承父路由的布局，也可以有自己的布局
  - 注意事项
    - 父路由的 path 是 index 开始，所以访问子路由的时候需要加上父路由的 path 例如 /index/home /index/about
    - 子路由不需要增加/了直接写子路由的 path 即可
    - 子路由默认是不显示的，需要父路由通过 Outlet 组件来显示子路由 outlet 就是类似于 Vue 的\<router-view\>展示子路由的一个容器
    - 子路由的层级可以无限嵌套，但是要注意的是，一般实际工作中就是 2-3 层

```ts
const router = createBrowserRouter([
  {
    path: "/index",
    Component: Layout, // 父路由
    children: [
      {
        path: "home",
        Component: Home, // 子路由
      },
      {
        path: "about",
        Component: About, // 子路由
      },
    ],
  },
]);
```

- 布局路由：布局路由是一种特殊的嵌套路由，父路由可以省略 path，这样不会向 URL 添加额外的路径段

```ts
const router = createBrowserRouter([
  {
    // path: '/index', //省略
    Component: Layout,
    children: [
      {
        path: "home",
        Component: Home,
      },
      {
        path: "about",
        Component: About,
      },
    ],
  },
]);
```

- 索引路由：索引路由使用 index: true 来定义，作为父路由的默认子路由

```ts
const router = createBrowserRouter([
  {
    path: "/",
    Component: Layout,
    children: [
      {
        index: true,
        // path: 'home',
        Component: Home,
      },
      {
        path: "about",
        Component: About,
      },
    ],
  },
]);
```

- 前缀路由：前缀路由只设置 path 而不设置 Component，用于给一组路由添加统一的路径前缀

```ts
const router = createBrowserRouter([
  {
    path: "/project",
    //Component: Layout, //省略
    children: [
      {
        path: "home",
        Component: Home,
      },
      {
        path: "about",
        Component: About,
      },
    ],
  },
]);
```

- 动态路由：动态路由通过 :参数名 语法来定义动态段

```ts
const router = createBrowserRouter([
  {
    path: "/",
    Component: Layout,
    children: [
      {
        path: "home/:id",
        Component: Home,
      },
      {
        path: "about",
        Component: About,
      },
    ],
  },
]);
```

- 使用

```tsx
import { Menu as AntdMenu } from "antd";
import { AppstoreOutlined } from "@ant-design/icons";
import type { MenuProps } from "antd";
import { useNavigate } from "react-router";
export default function Menu() {
  const navigate = useNavigate(); // 编程式导航
  const handleClick: MenuProps["onClick"] = (info) => {
    navigate(info.key);
  };
  const menuItems = [
    {
      key: "/home",
      label: "Home",
      icon: <AppstoreOutlined />,
    },
    {
      key: "/about",
      label: "About",
      icon: <AppstoreOutlined />,
    },
  ];
  return (
    <AntdMenu
      onClick={handleClick}
      style={{ height: "100vh" }}
      items={menuItems}
    />
  );
}
```

```tsx
import { Breadcrumb } from "antd";

export default function Header() {
  return (
    <Breadcrumb
      items={[
        {
          title: "Home",
        },
        {
          title: "List",
        },
        {
          title: "App",
        },
      ]}
    />
  );
}
```

```tsx
import { Outlet } from "react-router";
export default function Content() {
  return <Outlet />;
}
```

```tsx
import Header from "./Header";
import Menu from "./Menu";
import Content from "./Content";
import { Layout as AntdLayout } from "antd";
export default function Layout() {
  return (
    <AntdLayout>
      <AntdLayout.Sider>
        <Menu />
      </AntdLayout.Sider>
      <AntdLayout>
        <Header />
        <AntdLayout.Content>
          <Content />
        </AntdLayout.Content>
      </AntdLayout>
    </AntdLayout>
  );
}
```

```ts
import { createBrowserRouter } from "react-router";

import Home from "../pages/Home";
import About from "../pages/About";
import Layout from "../layout";
const router = createBrowserRouter([
  {
    path: "/",
    Component: Layout, // 父路由
    children: [
      {
        path: "home",
        Component: Home, // 子路由
      },
      {
        path: "about",
        Component: About, // 子路由
      },
    ],
  },
]);

export default router;
```

```tsx
import React from "react";
import { RouterProvider } from "react-router";
import router from "./router";
const App: React.FC = () => {
  return (
    <>
      <RouterProvider router={router} />
    </>
  );
};

export default App;
```

#### 路由传参

- Query

  - 跳转方式

  ```tsx
  <NavLink  to="/about?id=123">About</NavLink> //1. NavLink 跳转
  <Link to="/about?id=123">About</Link> //2. Link 跳转
  import { useNavigate } from 'react-router'
  const navigate = useNavigate()
  navigate('/about?id=123') //3. useNavigate 跳转
  ```

  - 获取参数

  ```tsx
  //1. 获取参数
  import { useSearchParams } from "react-router";
  const [searchParams, setSearchParams] = useSearchParams();
  console.log(searchParams.get("id")); //获取id参数

  //2. 获取参数（不方便）
  import { useLocation } from "react-router";
  const { search } = useLocation();
  console.log(search); //获取search参数 ?id=123
  ```

- Params
  - `/user/:id`
  - 跳转方式
  ```tsx
  <NavLink to="/user/123">User</NavLink> //1. NavLink 跳转
  <Link to="/user/123">User</Link> //2. Link 跳转
  import { useNavigate } from 'react-router'
  const navigate = useNavigate()
  navigate('/user/123') //3. useNavigate 跳转
  ```
  - 获取参数
  ```tsx
  import { useParams } from "react-router";
  const { id } = useParams();
  console.log(id); //获取id参数
  ```
- State

  - 跳转方式

  ```tsx
  <Link to="/user" state={{ name: 'js', age: 18 }}>User</Link> //1. Link 跳转
  <NavLink to="/user" state={{ name: 'js', age: 18 }}>User</NavLink> //2. NavLink 跳转
  import { useNavigate } from 'react-router'
  const navigate = useNavigate()
  navigate('/user', { state: { name: 'js', age: 18 } }) //3. useNavigate 跳转
  ```

  - 获取参数

  ```tsx
  import { useLocation } from "react-router";
  const { state } = useLocation();
  console.log(state); //获取state参数
  console.log(state.name); //获取name参数
  console.log(state.age); //获取age参数
  ```

- 总结
- Params 方式 (/user/:id)
  - 适用于：传递必要的路径参数（如 ID）
  - 特点：符合 RESTful 规范，刷新不丢失
  - 限制：只能传字符串，参数显示在 URL 中
- Query 方式 (/user?name=xiaoman)
  - 适用于：传递可选的查询参数
  - 特点：灵活多变，支持多参数
  - 限制：URL 可能较长，参数公开可见
- State 方式
  - 适用于：传递复杂数据结构
  - 特点：支持任意类型数据，参数不显示在 URL
  - 限制：刷新可能丢失，不利于分享

#### 路由懒加载

- 体验优化
- 性能优化：使用懒加载打包后，会把懒加载的组件打包成一个独立的文件，从而减小主包的大小

```ts
import { createBrowserRouter } from "react-router";
import Home from "../pages/Home";
import Layout from "../layout";
const sleep = (time: number) =>
  new Promise((resolve) => setTimeout(resolve, time));
const router = createBrowserRouter([
  {
    path: "/",
    Component: Layout,
    children: [
      {
        path: "home",
        Component: Home,
      },
      {
        path: "about",
        lazy: async () => {
          await sleep(5000); // 模拟加载
          const about = await import("../pages/About");
          return { Component: about.default };
        }, // 懒加载
      },
    ],
  },
]);

export default router;
```

```tsx
import { Outlet, useNavigation } from "react-router";
import { Alert, Spin } from "antd";
export default function Content() {
  const navigation = useNavigation();
  console.log(navigation.state);
  const isLoading = navigation.state === "loading";
  return (
    <div>
      {isLoading ? (
        <Spin size="large" tip="loading...">
          <Alert
            description="正在加载中，请稍等"
            message="加载中"
            type="info"
          />
        </Spin>
      ) : (
        <Outlet />
      )}
    </div>
  );
}
```

#### 路由操作

- 路由操作
  - 由两个部分组成的：loader、action
  - 在平时工作中大部分都是在做增刪查改(CRUD)的操作，所以一个界面的接口过多之后就会使逻辑臃肿复杂，难以维护，所以需要使用路由的高级操作来优化代码
- loader
  - 只有 GET 请求才会触发 loader，所以适合用来获取数据
  - 在之前的话我们是 RenderComponent(渲染组件)-> Fetch(获取数据)-> RenderView(渲染视图)
  - 有了 loader 之后是 loader(通过 fetch 获取数据) -> useLoaderData(获取数据) -> RenderComponent(渲染组件)

```ts
import { createBrowserRouter } from "react-router";
import Home from "../pages/Home";
import Layout from "../layout";
const data = [
  {
    name: "home",
    path: "/home",
  },
  {
    name: "about",
    path: "/about",
  },
];
const sleep = (time: number) =>
  new Promise((resolve) => setTimeout(resolve, time));
const router = createBrowserRouter([
  {
    path: "/",
    Component: Layout,
    children: [
      {
        path: "home",
        Component: Home,
        loader: async () => {
          await sleep(2000); // 模拟加载
          // fetch ajax axios 获取数据
          return { data, success: true };
        },
      },
      {
        path: "about",
        lazy: async () => {
          await sleep(5000); // 模拟加载
          const about = await import("../pages/About");
          return { Component: about.default };
        }, // 懒加载
      },
    ],
  },
]);

export default router;
```

```tsx
import { NavLink } from "react-router";
import { useLoaderData } from "react-router";
export default function Home() {
  const { data, success } = useLoaderData();
  return (
    <>
      {data.map((item) => (
        <div>
          <NavLink to={item.path} key={item.path}>
            {item.name}
          </NavLink>
        </div>
      ))}
    </>
  );
}
```

- action
  - 一般用于表单提交，删除，修改等操作
  - 只有 POST DELETE PATCH PUT 等请求才会触发 action，所以适合用来提交表单

```tsx
import { useLoaderData, useSubmit, NavLink } from "react-router";
import { Form, Input, Button } from "antd";
export default function Home() {
  const { data } = useLoaderData();
  const submit = useSubmit();
  // onFinish -> action -> api
  const onFinish = (values: any) => {
    submit(values, {
      method: "post",
      encType: "application/json", // 默认formData
    });
  };
  return (
    <>
      <Form onFinish={onFinish}>
        <Form.Item label="页面" name="name">
          <Input />
        </Form.Item>
        <Form.Item label="路径" name="path">
          <Input />
        </Form.Item>
        <Form.Item>
          <Button type="primary" htmlType="submit">
            提交
          </Button>
        </Form.Item>
      </Form>

      {data.map((item) => (
        <div>
          <NavLink to={item.path} key={item.path}>
            {item.name}
          </NavLink>
        </div>
      ))}
    </>
  );
}
```

```ts
import { createBrowserRouter } from "react-router";
import Home from "../pages/Home";
import Layout from "../layout";
const data = [
  {
    name: "home",
    path: "/home",
  },
  {
    name: "about",
    path: "/about",
  },
];
const sleep = (time: number) =>
  new Promise((resolve) => setTimeout(resolve, time));
const router = createBrowserRouter([
  {
    path: "/",
    Component: Layout,
    children: [
      {
        path: "home",
        Component: Home,
        loader: async () => {
          await sleep(2000); // 模拟加载
          // fetch ajax axios 获取数据
          return { data, success: true };
        },
        action: async ({ request }) => {
          const json = await request.json();
          console.log(json);
          data.push(json);
          await sleep(2000); // 模拟加载
          // fetch ajax axios 提交数据
          return { success: true, message: "提交成功" };
        },
      },
      {
        path: "about",
        lazy: async () => {
          await sleep(5000); // 模拟加载
          const about = await import("../pages/About");
          return { Component: about.default };
        }, // 懒加载
      },
    ],
  },
]);

export default router;
```

- 状态变更
  - GET 提交：`idle -> loading -> idle`
  - POST 提交：`idle -> submitting ->loading -> idle`

#### 导航

- 在 React-router V7 中，大致有四种导航方式：

  - 使用 Link 组件：Link 组件是一个用于导航到其他页面的组件，他会被渲染成一个特殊的\<a\>标签，跟传统 a 标签不同的是，他不会刷新页面，而是会通过 router 管理路由
  - 使用 NavLink 组件：NavLink 的使用方式和 Link 组件类似，但是 NavLink 组件可以实现路由的激活状态
    - Navlink 会经过以下三个状态的转换，而 Link 不会，所以 Navlink 就是一个 link 的增强版
    - active：激活状态(当前路由和 to 属性匹配)
    - pending：等待状态(loader 有数据需要加载)
    - transitioning：过渡状态(通过 viewTransition 属性触发)
    ```tsx
    <NavLink
      viewTransition
      style={({ isActive, isPending, isTransitioning }) => {
        return {
          marginRight: "10px",
          color: isActive ? "red" : "blue",
          backgroundColor: isPending ? "yellow" : "transparent",
        };
      }}
      to="/index/about"
    >
      About
    </NavLink>
    ```
  - 使用编程式导航 useNavigate：useNavigate 是一个 React-router 的钩子，用于编程式导航，的路由跳转
  - 使用 redirect 重定向：redirect 是用于重定向，通常用于 loader 中，当 loader 返回 redirect 的时候，会自动重定向到 redirect 指定的路由

  ```tsx
  import { redirect } from "react-router";
  {
    path: "/home",
    loader: async ({request}) => {
      const isLogin = await checkLogin();
      if(!isLogin) return redirect('/login');
      return {
          data: 'home'
      }
    }
  }
  ```

#### 边界处理

- 404：使用\*作为通配符，当路由匹配不到时，显示 404 页面

```ts
const router = createBrowserRouter([
  {
    path: "/index",
    Component: Layout,
    children: [
      {
        path: "home",
        Component: Home,
      },
      {
        path: "about",
        Component: About,
      },
    ],
  },
  {
    path: "*", // 通配符，当路由匹配不到时，显示404页面
    Component: NotFound, // 404页面组件
  },
]);
```

- ErrorBoundary
  - ErrorBoundary 是用于捕获路由 loader 或 action 的错误，并进行处理
  - 如果 loader 或 action 抛出错误，会调用 ErrorBoundary 组件

```tsx
import NotFound from "../layout/404"; // 404页面组件
import Error from "../layout/error"; // 错误处理组件
const router = createBrowserRouter([
  {
    path: "/index",
    Component: Layout,
    children: [
      {
        path: "home",
        Component: Home,
        ErrorBoundary: Error, //如果组件抛出错误，会调用ErrorBoundary组件
      },
      {
        path: "about",
        loader: async () => {
          //throw new Response('Not Found', { status: 404, statusText: 'Not Found' }); 可以返回Response对象
          //也可以返回json等等
          throw {
            message: "Not Found",
            status: 404,
            statusText: "Not Found",
            data: "132131",
          };
        },
        Component: About,
        ErrorBoundary: Error, //如果loader或action抛出错误，会调用ErrorBoundary组件
      },
    ],
  },
  {
    path: "*",
    Component: NotFound,
  },
]);
```

```tsx
import { useRouteError } from "react-router";

export default function Error() {
  const error = useRouteError();
  return <div>{error.message}</div>;
}
```

## Redux

### 基本使用

- 核心概念

  - action: 动作的对象包含两个属性
    - type：标识属性，值为字符串，唯一，必要属性
    - data：数据属性，值为任意类型，可选属性
    - 例：`{type: 'add_student', data:{name: 'js', age: 18}}`
  - reducer：用于初始化状态、加工状态。加工时，根据旧的 state 和 action， 产生新的 state 的纯函数
  - store：将 state、action、reducer 联系在一起的对象，内部维护着 state 和 reducer
    - state 就是把 action 和 reducer 联系起来的对象，store 本质上是一个状态树，保存了所有对象的状态。任何 UI 组件都可以直接从 store 访问特定对象的状态，其具有 dispatch，subscribe，getState 方法

- Redux+React-Redux

```ts
import { createStore } from "redux";

const initialState = {
  value: 0,
};
type Action =
  | { type: "INCREMENT" }
  | { type: "DECREMENT" }
  | { type: "INCREMENT_BY_AMOUNT"; payload: number };
const reducer = function reducer(state = initialState, action: Action) {
  state = { ...state };
  switch (action.type) {
    case "INCREMENT":
      state.value += 1;
      break;
    case "DECREMENT":
      state.value -= 1;
      break;
    case "INCREMENT_BY_AMOUNT":
      state.value += action.payload;
      break;
    default:
      break;
  }
  return state;
};
const store = createStore(reducer);

export default store;
```

```tsx
import { createRoot } from "react-dom/client";
import App from "./App.tsx";
import store from "./store/index.ts";
import { Provider } from "react-redux";

createRoot(document.getElementById("root")!).render(
  <Provider store={store}>
    <App />
  </Provider>
);
```

```tsx
import { connect } from "react-redux";
import store from "./store";
function APP() {
  return (
    <div>
      <div>
        <button
          aria-label="Increment value"
          onClick={() => store.dispatch({ type: "INCREMENT" })}
        >
          Increment
        </button>
        <span>{store.getState().value}</span>
        <button
          aria-label="Decrement value"
          onClick={() => store.dispatch({ type: "DECREMENT" })}
        >
          Decrement
        </button>
      </div>
    </div>
  );
}
const mapStateToProps = (state) => ({
  count: state,
});

const mapDispatchToProps = (dispatch) => ({
  onIncrement: () => dispatch({ type: "INCREMENT" }),
  onDecrement: () => dispatch({ type: "DECREMENT" }),
});
export default connect(mapStateToProps, mapDispatchToProps)(APP);
```

- Redux Toolkit+React-Redux

```ts
import { createSlice } from "@reduxjs/toolkit";

export const counterSlice = createSlice({
  name: "counter",
  initialState: {
    value: 0,
  },
  reducers: {
    increment: (state) => {
      // Redux Toolkit 允许我们在 reducers 中编写 mutating 逻辑。
      // 它实际上并没有 mutate state 因为它使用了 Immer 库，
      // 它检测到草稿 state 的变化并产生一个全新的基于这些更改的不可变 state
      state.value += 1;
    },
    decrement: (state) => {
      state.value -= 1;
    },
    incrementByAmount: (state, action) => {
      state.value += action.payload;
    },
  },
});

// 为每个 case reducer 函数生成 Action creators
export const { increment, decrement, incrementByAmount } = counterSlice.actions;

export default counterSlice.reducer;
```

```ts
import { configureStore } from "@reduxjs/toolkit";
import counterReducer from "./counterSlice";

export default configureStore({
  reducer: {
    counter: counterReducer,
  },
});
```

```tsx
import { createRoot } from "react-dom/client";
import App from "./App.tsx";
import store from "./store/index.ts";
import { Provider } from "react-redux";

createRoot(document.getElementById("root")!).render(
  <Provider store={store}>
    <App />
  </Provider>
);
```

```tsx
import { useSelector, useDispatch } from "react-redux";
import { decrement, increment } from "./store/counterSlice";

export default function APP() {
  const count = useSelector(
    (state: { counter: { value: number } }) => state.counter.value
  );
  const dispatch = useDispatch();

  return (
    <div>
      <div>
        <button
          aria-label="Increment value"
          onClick={() => dispatch(increment())}
        >
          Increment
        </button>
        <span>{count}</span>
        <button
          aria-label="Decrement value"
          onClick={() => dispatch(decrement())}
        >
          Decrement
        </button>
      </div>
    </div>
  );
}
```

## Zustand

### 基本使用

- 优点
  - 轻量级 Zustand 的体积非常小，只有 1kb 左右。
  - 简单易用 Zustand 不需要像 Redux，去通过 Provider 包裹组件，Zustand 提供了简洁的 API，能够快速上手。
  - 易于集成 Zustand 可以轻松的与 React 和 Vue 等框架集成。(Zustand 也有 Vue 版本)
  - 扩拓展性 Zustand 提供了中间件的概念，可以通过插件的方式扩展功能，例如(持久化,异步操作，日志记录)等。
  - 无副作用 Zustand 推荐使用 immer 库处理不可变性， 避免不必要的副作用
- store/price.ts
  - 初始化仓库
  - create 函数，传入一个函数；该函数包含 set 和 get 两个参数，并返回一个对象
  - set 函数，用于更新状态；该函数包含一个参数 state，state 为当前状态
  - get 函数，用于获取状态；该函数包含一个参数 state，state 为当前状态

```ts
import { create } from "zustand";

interface PriceStore {
  price: number;
  incrementPrice: () => void;
  decrementPrice: () => void;
  resetPrice: () => void;
  getPrice: () => number;
}

const usePriceStore = create<PriceStore>((set, get) => ({
  price: 0,
  incrementPrice: () => set((state) => ({ price: state.price + 1 })),
  decrementPrice: () => set((state) => ({ price: state.price - 1 })),
  resetPrice: () => set({ price: 0 }),
  getPrice: () => get().price,
}));

export default usePriceStore;
```

- App.tsx

```tsx
import React from "react";
import Left from "./pages/Left";
import Right from "./pages/Right";
import "./App.css";
import usePriceStore from "./store/price";
const App: React.FC = () => {
  const { price } = usePriceStore();
  return (
    <>
      <div className="container">
        <h1>Zustand Demo</h1>
        <div className="wraps">
          <Left />
          <Right />
        </div>
        <div className="price">
          价格:<span>{price}</span>
        </div>
      </div>
    </>
  );
};

export default App;
```

- left/index.tsx

```tsx
import "../index.css";
import usePriceStore from "../../store/price";
export default function Left() {
  const { incrementPrice, decrementPrice, resetPrice } = usePriceStore();
  return (
    <div className="left">
      <h1>A组件</h1>
      <button onClick={incrementPrice}>增加+1</button>
      <button onClick={decrementPrice}>减少-1</button>
      <button onClick={resetPrice}>重置</button>
    </div>
  );
}
```

- right/index.tsx

```tsx
import "../index.css";
import usePriceStore from "../../store/price";
export default function Right() {
  const { incrementPrice, decrementPrice, resetPrice } = usePriceStore();
  return (
    <div className="right">
      <h1>B组件</h1>
      <button onClick={incrementPrice}>增加+1</button>
      <button onClick={decrementPrice}>减少-1</button>
      <button onClick={resetPrice}>重置</button>
    </div>
  );
}
```

### 状态处理

- 深层次状态处理：Zustand 会合并第一层的 state，但是对于深层次的状态更新，我们需要特别注意

```tsx
import { create } from "zustand";

interface User {
  gourd: {
    gourd1: string;
    gourd2: string;
    gourd3: string;
    gourd4: string;
    gourd5: string;
    gourd6: string;
    gourd7: string;
  };
  updateGourd: () => void;
}
const useUserStore = create<User>((set) => ({
  gourd: {
    gourd1: "gourd1",
    gourd2: "gourd2",
    gourd3: "gourd3",
    gourd4: "gourd4",
    gourd5: "gourd5",
    gourd6: "gourd6",
    gourd7: "gourd7",
  },
  updateGourd: () =>
    set((state) => ({
      gourd: {
        ...state.gourd, // 合并第一层
        gourd1: `${state.gourd.gourd1}-plus`,
      },
    })),
}));
export default useUserStore;
```

- 使用 immer 中间件

```tsx
import { produce } from "immer";

const data = {
  user: {
    name: "js",
    age: 18,
  },
};

// 使用 produce 创建新状态
const newData = produce(data, (draft) => {
  draft.user.age = 20; // 直接修改 draft
});

console.log(newData, data);
// 输出:
// { user: { name: 'js', age: 20 } }
// { user: { name: 'js', age: 18 } }
```

```tsx
import { create } from "zustand";
import { immer } from "zustand/middleware/immer";
interface User {
  gourd: {
    gourd1: string;
    gourd2: string;
    gourd3: string;
    gourd4: string;
    gourd5: string;
    gourd6: string;
    gourd7: string;
  };
  updateGourd: () => void;
}
const useUserStore = create<User>()(
  immer((set) => ({
    gourd: {
      gourd1: "gourd1",
      gourd2: "gourd2",
      gourd3: "gourd3",
      gourd4: "gourd4",
      gourd5: "gourd5",
      gourd6: "gourd6",
      gourd7: "gourd7",
    },
    updateGourd: () =>
      set((state) => {
        state.gourd.gourd1 = state.gourd.gourd1 + "plus";
      }),
  }))
);
export default useUserStore;
```

### 状态简化

- 状态选择器：只选择我们需要的部分状态，这样就不会引发不必要的重渲染

```tsx
const name = useUserStore((state) => state.name);
const age = useUserStore((state) => state.age);
```

- useShallow：useShallow 只检查顶层对象的引用是否变化，如果顶层对象的引用没有变化（即使其内部属性或子对象发生了变化，但这些变化不影响顶层对象的引用），使用 useShallow 的组件将不会重新渲染

```tsx
import { useShallow } from "zustand/react/shallow";
const { name, age, address } = useUserStore(
  useShallow((state) => ({
    name: state.name,
    age: state.age,
    address: state.info.address,
  }))
);
```

### 中间件

- 自定义中间件
  - config (外层函数参数)
    - 类型：函数 (set, get, api) => StoreApi
    - 作用：原始创建 store 的配置函数，由用户传入。中间件需要包装这个函数。
  - set (内层函数参数)
    - 类型：函数 (partialState) => void
    - 作用：原始的状态更新函数，用于修改 store 的状态。
  - get (内层函数参数)
    - 类型：函数 () => State
    - 作用：获取当前 store 的状态值。
  - api (内层函数参数)
    - 类型：对象 StoreApi
    - 作用：包含 store 的完整 API（如 setState, getState, subscribe, destroy 等方法）

```ts
import { create } from "zustand";
import { immer } from "zustand/middleware/immer";
interface User {
  gourd: {
    gourd1: string;
    gourd2: string;
    gourd3: string;
    gourd4: string;
    gourd5: string;
    gourd6: string;
    gourd7: string;
  };
  updateGourd: () => void;
}
const logger = (config) => (set, get, api) =>
  config(
    (...args) => {
      console.log(api);
      console.log("before", get());
      set(...args);
      console.log("after", get());
    },
    get,
    api
  );
const useUserStore = create<User>()(
  immer(
    logger((set) => ({
      gourd: {
        gourd1: "gourd1",
        gourd2: "gourd2",
        gourd3: "gourd3",
        gourd4: "gourd4",
        gourd5: "gourd5",
        gourd6: "gourd6",
        gourd7: "gourd7",
      },
      updateGourd: () =>
        set((state) => {
          state.gourd.gourd1 = state.gourd.gourd1 + "plus";
        }),
    }))
  )
);
export default useUserStore;
```

- devtools：devtools 是 zustand 提供的一个用于调试的工具，它可以帮助我们更好地管理状态

```ts
import { devtools } from "zustand/middleware";
const useUserStore = create<User>()(
  immer(
    devtools((set) => ({
      //...
    }))
  )
);
```

- persist：persist 是 zustand 提供的一个用于持久化状态的工具，它可以帮助我们更好地管理状态，默认是存储在 localStorage 中，可以指定存储方式

```ts
import { persist, createJSONStorage } from "zustand/middleware";
const useUserStore = create<User>()(
  immer(
    persist(
      (set) => ({
        //...
      }),
      {
        name: "user", // 仓库名称(唯一)
        storage: createJSONStorage(() => localStorage), // 存储方式 可选 localStorage sessionStorage IndexedDB 默认localStorage
        partialize: (state) => ({
          name: state.name,
          age: state.age,
        }), // 部分状态持久化
      }
    )
  )
);
```

```tsx
import useUserStore from "../../store/user";
const App = () => {
  const clear = () => {
    useUserStore.persist.clearStorage();
  };
  return <div onClick={clear}>清空缓存</div>;
};
```

### 订阅

- 订阅一个状态：只要 store 的 state 发生变化，就会触发回调函数，另外就是这个订阅可以在组件内部订阅，也可以在组件外部订阅,如果在组件内部订阅需要放到 useEffect 中,防止重复订阅

```tsx
const store = create((set) => ({
  count: 0,
}));
//外部订阅
store.subscribe((state) => {
  console.log(state.count);
});
//组件内部订阅
useEffect(() => {
  store.subscribe((state) => {
    console.log(state.count);
  });
}, []);
```

- 案例

```ts
import { create } from "zustand";
import { immer } from "zustand/middleware/immer";
import { subscribeWithSelector } from "zustand/middleware";
interface PointStore {
  point: number;
  incrementPoint: () => void;
}
const usePointStore = create<PointStore>(
  immer(
    subscribeWithSelector((set) => ({
      point: 55,
      incrementPoint: () =>
        set((state) => {
          state.point = state.point + 1;
        }),
    }))
  )
);

export default usePointStore;
```

```tsx
import React, { useEffect, useState } from "react";
import usePointStore from "./store/point";
import { useShallow } from "zustand/shallow";
const App: React.FC = () => {
  const { point, incrementPoint } = usePointStore(
    useShallow((state) => ({
      point: state.point,
      incrementPoint: state.incrementPoint,
    }))
  );
  const [pointStatus, setPointStatus] = useState("");
  useEffect(() => {
    usePointStore.subscribe(
      (state) => state.point,
      (point) => {
        console.log("🚀 ~ useEffect ~ point:", point);
        if (point >= 26) {
          setPointStatus("合格");
        } else {
          setPointStatus("不合格");
        }
      },
      {
        fireImmediately: true,
      }
    );
  }, []);
  return (
    <>
      <div>{point}</div>
      <div>{pointStatus}</div>
      <button onClick={incrementPoint}>+1</button>
    </>
  );
};

export default App;
```
