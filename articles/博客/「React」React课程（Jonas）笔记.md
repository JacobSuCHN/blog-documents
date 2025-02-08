> This article is a [React](https://www.udemy.com/course/the-ultimate-react-course/) course note.
> If there is any infringement, please contact me.

## 从一个 demo 开始

[react-doc/00-demo](https://github.com/JacobSuCHN/react-doc/tree/main/code/00-demo)

```jsx
import { useState, useEffect } from "react";
export default function App() {
  const [advice, setAdvice] = useState("");
  const [count, setCount] = useState(0);

  async function getAdvice() {
    const res = await fetch("https://api.adviceslip.com/advice");
    const data = await res.json();
    console.log(data.slip.advice);
    setAdvice(data.slip.advice);
    setCount((c) => c + 1);
  }

  useEffect(function () {
    getAdvice();
  }, []);

  return (
    <div>
      <h1>{advice}</h1>
      <button onClick={getAdvice}>Get advie</button>
      <Message count={count} />
    </div>
  );
}

function Message(props) {
  return <p>{props.count}</p>;
}
```

## React 基础

### 初识 React

[react-doc/01-pure-react](https://github.com/JacobSuCHN/react-doc/tree/main/code/01-pure-react)

#### 什么是 React

- 以组件为基础
- 使用 JSX
- 状态驱动
- React 是 JavaScript 库
- 非常受欢迎

#### 纯 React

- 纯 React（Pure React）

  ```html
  <!DOCTYPE html>
  <html lang="en">
    <head>
      <meta charset="UTF-8" />
      <meta http-equiv="X-UA-Compatible" content="IE=edge" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Hello React!</title>
    </head>
    <body>
      <div id="root"></div>

      <script
        src="https://unpkg.com/react@18/umd/react.development.js"
        crossorigin
      ></script>
      <script
        src="https://unpkg.com/react-dom@18/umd/react-dom.development.js"
        crossorigin
      ></script>

      <script>
        function App() {
          // const time = new Date().toLocaleTimeString();
          const [time, setTime] = React.useState(
            new Date().toLocaleTimeString()
          );

          React.useEffect(function () {
            setInterval(function () {
              setTime(new Date().toLocaleTimeString());
            }, 1000);
          }, []);

          return React.createElement(
            "header",
            null,
            `Hello React! It's ${time}`
          );
        }

        const root = ReactDOM.createRoot(document.getElementById("root"));
        root.render(React.createElement(App));
      </script>
    </body>
  </html>
  ```

  - 缺陷：没有模块系统、无法转换 JSX 等

#### 创建 React 项目

- 创建 React 项目的方式

  - create-react-app
  - create-next-app
  - vite

- `create-react-app`创建项目

  - ```sh
    npx create-react-app@5 pizza-menu
    ```

### 组件 属性 JSX

[react-doc/02-pizza-menu](https://github.com/JacobSuCHN/react-doc/tree/main/code/02-pizza-menu)

#### 组件

- React 应用程序完全由组件组成
- React 中用户界面的构建模块
- 拥有自己的数据、逻辑和外观的用户界面组件
- 我们通过构建多个组件并将它们组合在一起来构建复杂的用户界面
- 组件可以重复使用、相互嵌套并在它们之间传递数据
- 组件可以用命名函数定义，也可以使用箭头函数赋值给对象定义

#### 属性

- props 用于将父组件数据传递给子组件
- props 用于配置和自定义组件
- props 用于父组件控制子组件的外观和工作方式
- props 可以是任意类型
- props 不能修改
  - 修改 props 会影响父类，产生副作用（不纯粹）
  - 组件的 props 和状态必须是纯函数
- 每个组件都有 props，没有传值则是空对象

```jsx
function Menu() {
  return (
    <main>
      <h2>Our menu</h2>
      <Pizza
        name="Pizza Funghi"
        ingredients="Tomato, mushrooms"
        price={12}
        photoName="pizzas/funghi.jpg"
      />
    </main>
  );
}
function Pizza(props) {
  return (
    <li>
      <img src={props.photoName} alt={props.name} />
      <div>
        <h3>{props.name}</h3>
        <p>{props.ingredients}</p>
      </div>
    </li>
  );
}
```

#### JSX

- 声明式语法可描述组件的外观和工作方式
- 组件必须返回一个 JSX 块
- JavaScript 的扩展，允许我们在 HTML 中嵌入 JavaScript、CSS 和 React 组件
- 每个 JSX 元素都会转换为 React.createElement 函数调用
- 我们可以在没有 JSX 的情况下使用 React
- 声明式
  - 根据当前数据，使用 JSX 描述用户界面的样子
  - React 是对 DOM 的抽象：我们从不接触 DOM
  - 相反，我们认为用户界面是对当前数据的反映
- JSX 使用规则
  - JSX 的工作原理与 HTML 基本相同，但我们可以通过使用 {}（文本或属性）
  - 进入 "JavaScript 模式"，我们可以将 JavaScript 表达式（有返回值的式子）放在 {} 中
  - 不允许使用语句（if/else、for、switch）
  - 一个 JSX 片段只能有一个根元素；如果需要更多，请使用 （或短 <>）

#### 组件样式

- 组件添加样式

  ```jsx
  const style = { color: "red", fontSize: "48px", textTransform: "uppercase" };
  return (
    <div>
      <h1 style={{ color: "red" }}>h1</h1>
      <h2 style={style}>h2</h2>
    </div>
  );
  ```

  ```jsx
  return <header className="header"></header>;
  ```

#### 列表渲染

```jsx
<ul className="pizzas">
  {pizzas.map((pizza) => (
    <Pizza pizzaObj={pizza} key={pizza.name} />
  ))}
</ul>
```

- 列表的每一项都必须包含 key 值，唯一

#### 条件渲染

```jsx
<footer className="footer">
  {isOpen && <Order closeHour={closeHour} openHour={openHour} />}
</footer>
```

```jsx
<footer className="footer">
  {isOpen ? (
    <Order closeHour={closeHour} openHour={openHour} />
  ) : (
    <p>
      We're happy to welcome you between {openHour}:00 and {closeHour}:00.
    </p>
  )}
</footer>
```

```jsx
if (!isOpen) return <p>CLOSED</p>;

return (
  <p>
    We're happy to welcome you between {openHour}:00 and {closeHour}:00.
  </p>
);
```

#### 解构 props

```jsx
function Pizza({ pizzaObj }) {
  return (
    <li className={`pizza ${pizzaObj.soldOut ? "sold-out" : ""}`}>
      <img src={pizzaObj.photoName} alt={pizzaObj.name} />
      <div>
        <h3>{pizzaObj.name}</h3>
        <p>{pizzaObj.ingredients}</p>

        <span>{pizzaObj.soldOut ? "SOLD OUT" : pizzaObj.price}</span>
      </div>
    </li>
  );
}
```

#### React 片段

- 解决 JSX 返回单根元素的问题
- React 片段不会插入 DOM 树中

```jsx
<>
  <p></p>
  <p></p>
</>
```

```jsx
<React.Fragment>
  <p></p>
  <p></p>
</React.Fragment>
```

```jsx
function Menu() {
  const pizzas = pizzaData;
  const numPizzas = pizzas.length;

  return (
    <main className="menu">
      <h2>Our menu</h2>

      {numPizzas > 0 ? (
        <>
          <p>
            Authentic Italian cuisine. 6 creative dishes to choose from. All
            from our stone oven, all organic, all delicious.
          </p>

          <ul className="pizzas">
            {pizzas.map((pizza) => (
              <Pizza pizzaObj={pizza} key={pizza.name} />
            ))}
          </ul>
        </>
      ) : (
        <p>We're still working on our menu. Please come back later :)</p>
      )}

      {/* <Pizza
        name="Pizza Spinaci"
        ingredients="Tomato, mozarella, spinach, and ricotta cheese"
        photoName="pizzas/spinaci.jpg"
        price={10}
      /> */}
    </main>
  );
}
```

- 注意：每个`{}`都是一个 JSX 片段，每个 JSX 都需要返回单根元素
- 注意：注释也需要包裹进`{}`才可以使用

### 状态、事件和表单

[react-doc/03-steps](https://github.com/JacobSuCHN/react-doc/tree/main/code/03-steps)
[react-doc/04-travel-list](https://github.com/JacobSuCHN/react-doc/tree/main/code/04-travel-list)

#### 事件

- `onClick={}`：`{}`传入函数，传入的是本身，而不是函数调用
- 函数传参时可以使用箭头函数
- 函数可以定义在组件内

#### 状态

- 组件可长期保存的数据，是在整个应用程序生命周期中需要记住的必要信息
- 组件内存
- 状态变量"/"状态片段"：单个
- 更新组件状态时触发 React 重新渲染组件
- 状态的作用

  - 更新组件视图（重新渲染）
  - 在两次渲染之间持续保持本地变量

  ```jsx
  import { useState } from "react";
  function Steps() {
    const [step, setStep] = useState(1);
    function handleNext() {
      setStep(step + 1);
    }
  }
  ```

  - 只能在函数组件或自定义钩子内部调用：useState 不能在类组件中使用，它也不能在普通的 JavaScript 函数中使用，除非这些函数是作为自定义钩子被定义的
  - 仅在顶层调用：useState 必须在函数组件或自定义钩子的最顶层调用，不能在条件语句、循环或嵌套函数中调用
  - 更新状态使用状态更新函数，而不是修改状态（虽然对象的属性变换能监听到）
  - 若基于当前状态更新，建议使用回调函数

  ```jsx
  function Steps() {
    const [step, setStep] = useState(1);
    function handleNext() {
      setStep((s) => s + 1);
    }
  }
  ```

  - `UI = f(state)`
  - 状态使用
    - 使用状态变量来表示组件应长期跟踪（"记住"）的任何数据
    - 每当希望组件中的某样东西是动态的，就创建一段与该 "东西" 相关的状态，并在该 "东西" 发生变化时更新状态（又称 "动态"）
    - 如果要更改组件的外观或显示的数据，请更新其状态
    - 构建组件时，将其视图想象为随时间变化的状态的反映
    - 对于不应触发组件重新渲染的数据，不要使用状态。而应使用常规变量
  - 同一组件的状态是独立的

#### 表单

```jsx
function Form() {
  function handleSubmit(e) {
    e.preventDefault();
  }

  return (
    <form className="add-form" onSubmit={handleSubmit}>
      <h3>What do you need for your 😍 trip?</h3>
      <select
        value={quantity}
        onChange={(e) => setQuantity(Number(e.target.value))}
      >
        {Array.from({ length: 20 }, (_, i) => i + 1).map((num) => (
          <option value={num} key={num}>
            {num}
          </option>
        ))}
      </select>
      <input type="text" placeholder="Item..." />
      <button>Add</button>
    </form>
  );
}
```

#### 受控元素

- 它指的是其视图状态完全由 React 组件的 state 数据控制的元素

```jsx
function Form() {
  const [description, setDescription] = useState("");
  const [quantity, setQuantity] = useState(1);

  function handleSubmit(e) {
    e.preventDefault();

    if (!description) return;

    const newItem = { description, quantity, packed: false, id: Date.now() };

    setDescription("");
    setQuantity(1);
  }

  return (
    <form className="add-form" onSubmit={handleSubmit}>
      <h3>What do you need for your 😍 trip?</h3>
      <select
        value={quantity}
        onChange={(e) => setQuantity(Number(e.target.value))}
      >
        {Array.from({ length: 20 }, (_, i) => i + 1).map((num) => (
          <option value={num} key={num}>
            {num}
          </option>
        ))}
      </select>
      <input
        type="text"
        placeholder="Item..."
        value={description}
        onChange={(e) => setDescription(e.target.value)}
      />
      <button>Add</button>
    </form>
  );
}
```

#### 状态与属性

- 状态
  - 由组件拥有的内部数据
  - 组件 "存储器"
  - 可由组件本身更新
  - 更新状态会导致组件重新渲染
  - 用于组件交互
- 属性
  - 外部数据，由父组件所有
  - 与函数参数类似
  - 只读
  - 接收新属性（接受状态作为属性）会导致组件重新渲染，通常是在父节点的状态更新后
  - 用于父组件配置子组件（设置）

### 状态管理

#### React 思维

- 将所需的用户界面分解为多个组件，并建立组件树
- 构建静态版本（无状态）
- 考虑状态
  - 何时使用状态
  - 状态的类型：局部与全局
  - 在何处放置每个状态片段
- 建立数据流
  - 单向数据流
  - 父子组件通信
  - 访问全局状态

#### 局部状态与全局状态

- 局部状态
  - 只有一个或少数几个组件需要的状态
  - 在一个组件中定义的状态，且只有该组件和子组件能访问它（通过属性传递）
  - 应始终从局部状态出发
- 全局状态
  - 状态许多组件可能需要
  - 每个组件都能访问的共享状态

#### 状态提升

- 状态提升（State Lifting）是一种设计模式，主要用于解决多个组件需要共享相同状态的情况
  - 在父组件中定义状态：使用 React 的 useState 或类组件的 constructor 来定义状态
  - 通过 props 传递状态及其更新函数：父组件通过 props 将状态及其更新函数传递给子组件
  - 子组件使用 props 中的状态和更新函数：子组件通过 props 接收状态和更新函数，并在需要时调用更新函数来修改状态

```jsx
function App() {
  const [items, setItems] = useState([]);

  function handleAddItems(item) {
    setItems((items) => [...items, item]);
  }
  return (
    <div className="app">
      <Logo />
      <Form onAddItems={handleAddItems} />
      <PackingList items={items} />
      <Stats />
    </div>
  );
}
```

```jsx
function PackingList ( {items} ) {
  return (
    <div className="list">
      <ul>
        {items.map((item) => (
          <Item
            item={item}
            key={item.id}
          />
        ))}
      </ul>
  );
}
```

```jsx
function Form({ onAddItems }) {
  const [description, setDescription] = useState("");
  const [quantity, setQuantity] = useState(1);

  function handleSubmit(e) {
    e.preventDefault();

    if (!description) return;

    const newItem = { description, quantity, packed: false, id: Date.now() };
    onAddItems(newItem);
    setDescription("");
    setQuantity(1);
  }

  return (
    <form className="add-form" onSubmit={handleSubmit}>
      <h3>What do you need for your 😍 trip?</h3>
      <select
        value={quantity}
        onChange={(e) => setQuantity(Number(e.target.value))}
      >
        {Array.from({ length: 20 }, (_, i) => i + 1).map((num) => (
          <option value={num} key={num}>
            {num}
          </option>
        ))}
      </select>
      <input
        type="text"
        placeholder="Item..."
        value={description}
        onChange={(e) => setDescription(e.target.value)}
      />
      <button>Add</button>
    </form>
  );
}
```

- 注意：`setItems((items) => [...items, item])`，不能使用`items.push(item)`，React 不允许，因为这改变了原数据

#### 传递参数

```jsx
function Item({ item, onDeleteItem, onToggleItem }) {
  return (
    <li>
      <input
        type="checkbox"
        value={item.packed}
        onChange={() => onToggleItem(item.id)}
      />
      <span style={item.packed ? { textDecoration: "line-through" } : {}}>
        {item.quantity} {item.description}
      </span>
      <button onClick={() => onDeleteItem(item.id)}>❌</button>
    </li>
  );
}
```

- 若直接使用`onClick={onDeleteItem}`，React 会将事件对象作为参数传入
- `{}`应传入函数本身而不是函数调用，此处应改为`onClick={() => onDeleteItem(item.id)}`

#### 派生状态

- 指从现有状态或属性（props）中计算得出的状态
- 组件重新渲染时会自动重新计算派生状态

```jsx
const [cart, setCart] = useState([
  { name: "cart1", price: 10 },
  { name: "cart2", price: 20 },
]);
const [numItems, setNumItems] = useState(2);
const [totalPrice, setTotalPrice] = useState(30);
```

```jsx
const [cart, setCart] = useState([
  { name: "cart1", price: 10 },
  { name: "cart2", price: 20 },
]);
const numItems = cart.length;
const totalPrice = cart.reduce((acc, cur) => acc + cur.price, 0);
```

#### 拆分组件

```jsx
import { useState } from "react";
import Logo from "./Logo";
import Form from "./Form";
import PackingList from "./PackingList";
import Stats from "./Stats";

export default function App() {
  const [items, setItems] = useState([]);

  function handleAddItems(item) {
    setItems((items) => [...items, item]);
  }

  function handleDeleteItem(id) {
    setItems((items) => items.filter((item) => item.id !== id));
  }

  function handleToggleItem(id) {
    setItems((items) =>
      items.map((item) =>
        item.id === id ? { ...item, packed: !item.packed } : item
      )
    );
  }

  function handleClearList() {
    const confirmed = window.confirm(
      "Are you sure you want to delete all items?"
    );

    if (confirmed) setItems([]);
  }

  return (
    <div className="app">
      <Logo />
      <Form onAddItems={handleAddItems} />
      <PackingList
        items={items}
        onDeleteItem={handleDeleteItem}
        onToggleItem={handleToggleItem}
        onClearList={handleClearList}
      />
      <Stats items={items} />
    </div>
  );
}
```

```jsx
export default function Logo() {
  ...
}

```

```jsx
export default function Form({ onAddItems }) {
  ...
}

```

```jsx
import Item from "./Item";

export default function PackingList({
  items,
  onDeleteItem,
  onToggleItem,
  onClearList,
}) {
  ...
}

```

```jsx
export default function Stats({ items }) {
  ...
}

```

```jsx
export default function Item({ item, onDeleteItem, onToggleItem }) {
  ...
}

```

#### children 属性

- children 属性允许我们将 JSX 传递到元素中（除常规常规外）
- 制作可重用和可配置组件（尤其是组件内容）的基本工具
- 对于在使用前不知道其内容的通用组件（如模态）非常有用
- 通过 props.children 访问

```jsx
function Steps() {
  function handlePrevious() {}

  function handleNext() {}

  return (
    <div className="buttons">
      <Button bgColor="#7950f2" textColor="#fff" onClick={handlePrevious}>
        <span>👈</span> Previous
      </Button>

      <Button bgColor="#7950f2" textColor="#fff" onClick={handleNext}>
        Next <span>👉</span>
      </Button>
    </div>
  );
}
```

```jsx
function Button({ textColor, bgColor, onClick, children }) {
  return (
    <button
      style={{ backgroundColor: bgColor, color: textColor }}
      onClick={onClick}
    >
      {children}
    </button>
  );
}
```

## React 强化

### 组件 组合 复用

[react-doc/05-usepopcorn](https://github.com/JacobSuCHN/react-doc/tree/main/code/05-usepopcorn)

#### 组件拆分

- 逻辑分隔内容/布局
- 可重用性
- 职责/复杂性
- 个人编码方式

- 注意
  - 创建一个新组件就会创建一个新的抽象；抽象是有代价的，尽量不要过早创建新组件
  - 根据组件的功能或显示内容为其命名，不要害怕使用长组件名
  - 切勿在另一个组件内声明新组件！
  - 将相关组件放在同一文件中。不要将组件分隔成过早出现不同文件
  - 一个应用程序有许多不同大小的组件，这是完全正常的

#### 组件类别

- 无状态/介绍性组件
  - 无状态
  - 可以接收道具和仅此一次数据或其他内容
  - 通常体积小，可重复使用
- 有状态组件
  - 有状态
  - 可复用
- 结构型组件
  - 应用的页面、布局或界面
  - 组件组合
  - 组件复杂的、不可再用

#### 属性钻取

```jsx
function App() {
  const [movies, setMovies] = useState(tempMovieData);

  return (
    <>
      <MovieList movies={movies} />
    </>
  );
}
```

```jsx
function MovieList({ movies }) {
  return (
    <ul className="list">
      {movies?.map((movie) => (
        <Movie movie={movie} key={movie.imdbID} />
      ))}
    </ul>
  );
}
```

```jsx
function Movie({ movie }) {
  return (
    <li>
      <img src={movie.Poster} alt={`${movie.Title} poster`} />
      <h3>{movie.Title}</h3>
      <div>
        <p>
          <span>🗓</span>
          <span>{movie.Year}</span>
        </p>
      </div>
    </li>
  );
}
```

#### 组件组合

- 使用 children 属性（或明确定义的属性）组合复杂的组件
- 作用
  - 创建高度可重用和灵活的
  - 修复属性钻取（非常适合布局）

```jsx
function Modal({ children }) {
  return <div className="modal">{children}</div>;
}
```

```jsx
function Success() {
  return <p>Success</p>;
}
```

```jsx
function Error() {
  return <p>Error</p>;
}
```

```jsx
return (
  <Modal>
    <Success />
  </Modal>
);
return (
  <Modal>
    <Error />
  </Modal>
);
```

- 组件组合解决属性钻取

  ```jsx
  function App() {
    const [movies, setMovies] = useState(tempMovieData);

    return (
      <>
        <NavBar>
          <Search />
          <NumResults movies={movies} />
        </NavBar>
      </>
    );
  }
  ```

  ```jsx
  function NavBar({ children }) {
    return (
      <nav className="nav-bar">
        <Logo />
        {children}
      </nav>
    );
  }
  ```

#### element 属性

```jsx
function Box({ children }) {
  return <div className="box">{children}</div>;
}
```

```jsx
<Box>
  <MovieList movies={movies} />
</Box>
```

```jsx
function Box({ element }) {
  return <div className="box">{element}</div>;
}
```

```jsx
<Box element={<MovieList movies={movies} />} />
```

- element 属性名可自定义
- React 并不推荐

#### 属性默认值

```jsx
function StarRating({
  maxRating = 5,
  color = "#fcc419",
  size = 48,
  className = "",
  messages = [],
  defaultRating = 0,
  onSetRating,
}) {}
```

- 对于函数组件，在参数解构时直接为属性提供默认值

#### propTypes

```jsx
StarRating.propTypes = {
  maxRating: PropTypes.number,
  defaultRating: PropTypes.number,
  color: PropTypes.string,
  size: PropTypes.number,
  messages: PropTypes.array,
  className: PropTypes.string,
  onSetRating: PropTypes.func,
};
function StarRating({
  maxRating = 5,
  color = "#fcc419",
  size = 48,
  className = "",
  messages = [],
  defaultRating = 0,
  onSetRating,
}) {}
```

- propTypes：类型检查，现已不常用，可用 ts 代替

### React 运作原理概述

#### 组件 组件实例 React 元素 DOM 元素

组件>组件实例>React 元素>DOM 元素

- 组件
  - 用户界面说明
  - 组件是一个返回 React 元素（元素树）的函数，元素通常写成 JSX
  - 蓝图或模板
- 组件实例
  - 当我们使用组件时会创建实例
  - 组件的实际表现形式
  - 拥有自己的状态和属性
  - 有生命周期
- 组件实例与元素
  - JSX 最终转换成 `React.createElement()` 函数的调用
  - React 元素是函数调用的结果
  - 组件实例返回 React 元素
  - 创建 DOM 元素所需的信息
  - 注意：直接调用组件函数会直接返回 React 元素

#### React 相关运作原理

- 组件相关

  - 组件是用户界面片段的蓝图，使用组件时会创建组件实例，实例包含属性、状态等信息，渲染组件实例会返回 React 元素
  - 绝不要在一个组件内部声明新组件，否则父组件重新渲染时会重置子组件状态，因 React 会视嵌套子组件为 “新的”

- 渲染相关

  - “渲染” 指调用组件函数并计算 DOM 元素变化的过程，与直接写 DOM 内容无关，组件实例渲染或重新渲染时渲染函数会再被调用
  - 应用首次渲染及后续状态更新会触发整个应用渲染流程，影响相关组件
  - 组件实例重新渲染时子组件也会重新渲染，但 React 的协调机制可检查元素变化情况，不过重新渲染仍可能影响性能

- Diffing 机制与 key 属性

  - Diffing 机制用于决定 DOM 元素的添加或修改，元素在树中位置等情况影响对应 DOM 元素和状态是否改变
  - 给元素添加 key 属性可让 React 区分组件实例，key 不变元素保留在 DOM 中，改变 key 则元素会被销毁重建，可利用此重置状态

- 渲染逻辑限制与 DOM 更新

  - 组件实例生成 JSX 输出的渲染逻辑不能产生副作用，像调用 API、设置定时器等操作不允许在此进行，副作用允许在事件处理器和 useEffect 钩子中
  - DOM 更新发生在提交阶段，由 ReactDOM 渲染器执行，React Web 应用需同时包含 React 和 ReactDOM 库，也可用其他渲染器用于不同平台应用开发

- 状态更新与事件相关

  - 事件处理器函数内多次状态更新会批处理，只触发一次重新渲染，状态更新是异步的，更新后不应立即访问状态变量，React 18 起超时操作也会批处理
  - 使用事件时，React 提供合成事件对象确保在各浏览器工作一致，多数合成事件会冒泡，但 scroll 事件不会冒泡

- React 性质相关

  - React 是库而非框架，可使用第三方库组装应用

### 数据获取 副作用

[react-doc/05-usepopcorn](https://github.com/JacobSuCHN/react-doc/tree/main/code/05-usepopcorn)

#### 组件（实例）声明周期

- MOUNT / INITIAL RENDER
  - 组件实例首次被渲染
  - 创建新的状态（state）和属性（props）
- RE-RENDER
  - 触发时机：State、Props、Context 变化，Parent 重新渲染
- UNMOUNT
  - 组件实例已被销毁并移除
  - 状态（state）和属性（props）已被销毁

#### 副作用

- 副作用：指 React 组件与组件外部世界之间的任何交互
  - 可以将副作用视为切实执行某些操作的代码
  - 例如：数据获取、设置订阅、设置定时器、手动访问 DOM 等等
- React 严格模式
  - `<React.StrictMode><App /></React.StrictMode>`
  - 在开发环境中，React 开启严格模式后，副作用函数会执行两次

#### useEffect

```jsx
import { useEffect, useState } from "react";

function App() {
  const [movies, setMovies] = useState([]);
  useEffect(function () {
    fetch(`http://www.omdbapi.com/?apikey=${KEY}&s=${query}`)
      .then((res) => res.json())
      .then((data) => setMovies(data.Search));
  }, []);
  return <></>;
}
```

- useEffect 函数不能返回 Promise
  ```jsx
  useEffect(function () {
    async function fetchMovies() {
      const res = await fetch(
        `http://www.omdbapi.com/?apikey=${KEY}&s=${query}`
      );
      const data = await res.json();
      setMovies(data.Search);
    }
  }, []);
  ```

#### useEffect 依赖数组

- 默认情况下，副作用在每次渲染后都会运行，我们可以通过传递一个依赖数组来避免这种情况
- 若没有依赖数组，React 就不知道何时运行副作用
- 每当某个依赖项发生变化，副作用就会再次执行
- 在副作用内部使用的每个状态变量和属性都必须包含在依赖数组中
- 依赖数组的三种情况
  - `useEffect(fn, [x, y, z]);`
    - 同步：副作用与 x、y 和 z 同步
    - 生命周期：在挂载以及因 x、y 或 z 更新而触发的重新渲染时运行
  - `useEffect(fn, []);`
    - 同步：副作用不与任何状态 / 属性同步
    - 生命周期：仅在挂载（初始渲染）时运行
  - `useEffect(fn);`
    - 同步：副作用与所有状态和属性同步（即每次渲染时都会执行该副作用，因为所有可能的变化都能触发它）
    - 生命周期：在每次渲染时运行（通常这样做不太好）

#### useEffect 清理函数

- 我们可以从副作用函数（可选）中返回的函数
- 该函数会在两种不同情况下运行
  - 在副作用再次执行之前
  - 组件卸载之后
- 每当组件重新渲染或卸载后，若副作用仍持续存在，这个返回函数就必不可少
- 每个副作用应该只做一件事！为每个副作用使用一个 `useEffect` 钩子，这会让副作用的清理工作更简便

```jsx
useEffect(
  function () {
    if (!title) return;
    document.title = `Movie | ${title}`;

    // 清理函数
    return function () {
      document.title = "usePopcorn";
    };
  },
  [title]
);
```

### Hooks

[react-doc/05-usepopcorn](https://github.com/JacobSuCHN/react-doc/tree/main/code/05-usepopcorn)

#### Hooks

- 特殊的内置函数，使我们能够 “挂钩” 到 React 内部机制
  - 从 Fiber 树中创建和访问状态
  - 在 Fiber 树中注册副作用
  - 手动选择 DOM
  - …
- 钩子函数名始终以 “use” 开头（如 useState、useEffect 等）
- 它便于复用非可视化逻辑：我们可以将多个钩子组合成自定义钩子
- 它赋予函数式组件拥有状态以及在不同生命周期节点运行副作用的能力（在 16.8 版本之前，这些能力仅类组件具备）
- 内置 Hooks
  - 常用
    - useState
    - useEffect
    - useReducer
    - useContext
  - 不常用
    - useRef
    - useCallback
    - useMemo
    - useTransition
    - useDeferredValue
    - useLayoutEffect
    - useDebugValue
    - useImperativeHandle
    - useId
  - 仅适用于库
    - useSyncExternalStore
    - useInsertionEffect
- 使用规则
  - 只在顶层调用钩子函数
    - 不要在条件语句、循环、嵌套函数中调用钩子函数，也不要在提前返回语句之后调用
    - 这对于确保钩子函数始终以相同顺序调用是必要的（钩子函数依赖于此）
  - 只从 React 函数中调用钩子函数
    - 只在函数组件或自定义钩子内部调用钩子函数

#### useState

- `useState({})`的初始值只会在首次渲染的时候加载
- 状态更新是异步的，当执行 set 时，无法立即获取更新的状态，只用当 React 处理完数据处理器才会更新所有状态并重新渲染页面
  - 可以通过设置回调函数解决该问题
  ```jsx
  setAvgRating(Number(imdbRating));
  setAvgRating((avgRating) => (avgRating + userRating) / 2);
  ```
- 创建 state
  - 参数：值和回调函数（延迟计算）
  - 函数必须是纯函数，且不接受任何参数
  - 仅在初次渲染时调用
- 更新 state
  - 参数：值和回调函数
  - 函数必须为纯函数，且返回下一个状态（函数的第一个参数代表该状态的前一个值）
  - 务必不要对对象或数组进行直接修改，而是要替换它们

#### useRef

- “容器”（对象），具有可变的.current 属性，该属性在多次渲染中保持不变（“普通” 变量在每次渲染时都会重置）

- 主要用例

  - 创建一个在多次渲染间保持不变的变量（例如，上一个状态、setTimeout 的 ID 等）

    - 普通变量在组件重新渲染时会重置

    ```jsx
    function MovieDetails({ selectedId, onCloseMovie, onAddWatched, watched }) {
      // ...
      const countRef = useRef(0);

      useEffect(
        function () {
          if (userRating) countRef.current++;
        },
        [userRating]
      );
      // ...
      function handleAdd() {
        const newWatchedMovie = {
          // ...
          countRatingDecisions: countRef.current,
        };
        // ...
      }
      // ...
      return (
        <div className="details">
          {
            //...
          }
        </div>
      );
    }
    ```

  - 选择并存储 DOM 元素

    ```jsx
    import { useEffect, useRef, useState } from "react";
    function Search({ query, setQuery }) {
      const inputEl = useRef(null);

      useEffect(function () {
        inputEl.current.focus();
      }, []);

      return (
        <input
          className="search"
          type="text"
          placeholder="Search movies..."
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          ref={inputEl}
        />
      );
    }
    ```

- Refs 用于存储不参与渲染的数据：通常仅出现在事件处理函数或副作用中，而非 JSX 中（否则应使用状态）

- 不要在渲染逻辑中读写.current（这一点与状态类似）

- state 与 refs

  |           | 跨渲染保持 | 更新引发重渲染 | 不可变 | 异步更新 |
  | --------- | ---------- | -------------- | ------ | -------- |
  | **STATE** | √          | √              | √      | √        |
  | **REFS**  | √          | ×              | ×      | ×        |

#### 自定义 Hooks

- 复用性

  - UI：组件
  - 逻辑
    - 不包含钩子：常规函数
    - 自定义钩子
      - 自定义钩子让我们能够在多个组件中复用非可视化逻辑
      - 一个自定义钩子应当只有一个用途，这样才能使其可复用且便于移植（甚至在多个项目间都能复用）
      - 钩子的规则同样适用于自定义钩子

- 自定义 Hooks

  ```js
  function useFetch(url) {
    const [data, setData] = useState([]);
    const [isLoading, setIsLoading] = useState(false);

    useEffect(function () {
      fetch(url)
        .then((res) => res.json())
        .then((res) => setData(res));
    }, []);
    return [data, isLoading];
  }
  ```

  - `useFetch`：函数名必须以 use 开头
  - `useEffect`：至少使用一个钩子
  - `return [data, isLoading]`：与组件不同，可以接收和返回数据（通常是数组[]或对象{}形式）

## React 进阶

### useReducer

[react-doc/06-react-quiz](https://github.com/JacobSuCHN/react-doc/tree/main/code/06-react-quiz)

#### useReducer 使用

```jsx
import { useReducer } from "react";

const initialState = { count: 0, step: 1 };

function reducer(state, action) {
  console.log(state, action);

  switch (action.type) {
    case "dec":
      return { ...state, count: state.count - state.step };
    case "inc":
      return { ...state, count: state.count + state.step };
    case "setCount":
      return { ...state, count: action.payload };
    case "setStep":
      return { ...state, step: action.payload };
    case "reset":
      return initialState;
    default:
      throw new Error("Unknown action");
  }
}

function DateCounter() {
  const [state, dispatch] = useReducer(reducer, initialState);
  const { count, step } = state;

  const date = new Date("june 21 2027");
  date.setDate(date.getDate() + count);

  const dec = function () {
    dispatch({ type: "dec" });
  };

  const inc = function () {
    dispatch({ type: "inc" });
  };

  const defineCount = function (e) {
    dispatch({ type: "setCount", payload: Number(e.target.value) });
  };

  const defineStep = function (e) {
    dispatch({ type: "setStep", payload: Number(e.target.value) });
  };

  const reset = function () {
    dispatch({ type: "reset" });
  };

  return (
    <div className="counter">
      <div>
        <input
          type="range"
          min="0"
          max="10"
          value={step}
          onChange={defineStep}
        />
        <span>{step}</span>
      </div>

      <div>
        <button onClick={dec}>-</button>
        <input value={count} onChange={defineCount} />
        <button onClick={inc}>+</button>
      </div>

      <p>{date.toDateString()}</p>

      <div>
        <button onClick={reset}>Reset</button>
      </div>
    </div>
  );
}
```

- 为什么使用 useReducer

  - 在某些情况下，仅使用 useState 进行状态管理是不够的
  - 当组件拥有大量的状态变量，并且状态更新分散在组件各处的众多事件处理程序中时
  - 当需要同时进行多个状态更新时（作为对同一事件的响应，比如 “开始一场游戏”）
  - 当更新某一个状态依赖于一个或多个其他状态时

- 使用 useReducer 管理状态

  - 一种设置状态的替代方式，非常适合管理复杂状态以及相关联的状态片段
  - 将相关联的状态片段存储在一个状态对象中
  - useReducer 需要 reducer：这是一个包含所有更新状态逻辑的函数，它将状态逻辑与组件解耦
  - reducer：是一个纯函数（无副作用！），接收当前状态和动作，并返回下一个状态
  - action：一个描述如何更新状态的对象
  - dispatch：一个用于触发状态更新的函数，通过将事件处理程序中的动作“发送”给 reducer 来实现

#### useState VS useReducer

- useState
  - 适用于单个、独立的状态片段（数字、字符串、单个数组等）
  - 更新状态的逻辑直接置于事件处理函数或副作用中，分散在一个或多个组件里
  - 通过调用 setState（useState 返回的设置函数）来更新状态
  - 这是命令式的状态更新方式
  - 易于理解和使用
- useReducer
  - 适用于多个相关的状态片段以及复杂状态（例如包含多个值的对象，还有嵌套对象或数组）
  - 更新状态的逻辑集中存于一处，与组件解耦，这个地方就是 reducer
  - 通过向 reducer 派发一个 action 来更新状态
  - 这是声明式的状态更新方式：复杂的状态转换被映射到各个 action 上
  - 理解和实现起来难度稍高

### React Router

[react-doc/07-worldwise](https://github.com/JacobSuCHN/react-doc/tree/main/code/07-worldwise)

#### SPA

- 路由
  - 通过路由，我们将不同的 URL 与不同的用户界面视图（React 组件）进行匹配：这些匹配关系就是路由
  - 这使用户能够借助浏览器的 URL，在应用程序的不同屏幕之间进行导航
  - 它能让用户界面与当前浏览器的 URL 保持同步
  - 还让我们能够构建单页应用程序
- SPA：单页面应用
  - 完全在客户端（浏览器）运行的应用程序
  - 路由：不同的 URL 对应不同的视图（组件）
  - 借助 JavaScript（React）来更新页面（DOM）
  - 页面永不刷新
  - 使用起来宛如原生应用
  - 还能从 Web API 加载额外数据

#### React Router 使用

- 安装：`npm install react-router-dom`
- 配置路由

  ```jsx
  import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";

  import Homepage from "./pages/Homepage";
  import Product from "./pages/Product";
  import Pricing from "./pages/Pricing";
  import PageNotFound from "./pages/PageNotFound";

  function App() {
    return (
      <BrowserRouter>
        <Routes>
          <Route index element={<Homepage />} />
          <Route path="product" element={<Product />} />
          <Route path="pricing" element={<Pricing />} />
          <Route path="*" element={<PageNotFound />} />
        </Routes>
      </BrowserRouter>
    );
  }

  export default App;
  ```

- 路由导航

  ```jsx
  import { Link } from "react-router-dom";

  export default function Homepage() {
    return (
      <main>
        <Link to="/pricing">Pricing</Link>
      </main>
    );
  }
  ```

  - NavLink：功能与 Link 类似；NavLink 处于活动状态，它就会自动拥有一个 .active 类名，便于使用 CSS 进行样式设计

#### 嵌套路由

```jsx
<Route path="app" element={<AppLayout />}>
  <Route index element={<Navigate replace to="cities" />} />
  <Route path="cities" element={<CityList />} />
  <Route path="countries" element={<CountryList />} />
  <Route path="form" element={<Form />} />
</Route>
```

```jsx
import { Outlet } from "react-router-dom";
function Sidebar() {
  return (
    <div>
      {/* ... */}
      <Outlet />
      {/* ... */}
    </div>
  );
}

export default Sidebar;
```

- React 路由器支持嵌套路由
- 为了让子路由在父布局内部呈现，我们需要在父布局中呈现 Outlet
- 索引路由在父路由的 URL 上呈现为父路由的 `<Outlet/>` （就像默认的子路由）
- 索引路由使用 index 配置

#### 路由参数

```jsx
<Route path="cities/:id" element={<City />} />
```

```jsx
<Link to={`${id}?lat=${position.lat}&lng=${position.lng}`}>{/*  */}</Link>
```

#### useParams

```jsx
import { useParams } from "react-router-dom";
const { id } = useParams();
```

- 在这种情况下， :id 是动态数据段。该城市的解析值将从 useParams 中获得

#### useSearchParams

```jsx
import { useSearchParams } from "react-router-dom";
const [searchParams, setSearchParams] = useSearchParams();
const lat = searchParams.get("lat");
const lng = searchParams.get("lng");
return (
  <div>
    <button
      onClick={() => {
        setSearchParams({ lat: 23, lng: 50 });
      }}
    >
      change pos
    </button>
  </div>
);
```

- 搜索参数是 URL 中 ? 后面的值。它们可通过 useSearchParams 访问，useSearchParams 返回 URLSearchParams 的实例

#### useNavigate

```jsx
import { useNavigate } from "react-router-dom";
const navigate = useNavigate();
navigate("/app/cities");
navigate(-1);
```

#### Navigate 组件

```jsx
import { Route, Navigate } from "react-router-dom";
<Route index element={<Navigate replace to="cities" />} />;
```

- 类似于重定向

#### CSS 模块

- 使用

  - 文件名：`xxx.module.css`

    ```css
    .nav {
      background-color: orange;
    }

    .nav ul {
      list-style: none;
      display: flex;
      justify-content: space-between;
    }
    :global(.test) {
      background-color: red;
    }
    ```

  - 语法：与 css 相似，全局使用时用`:global(xxx)`包裹选择器，类名建议使用驼峰

  - 引入

    ```jsx
    import styles from "./AppLayout.module.css";

    function AppLayout() {
      return <div className={styles.app}></div>;
    }

    export default AppLayout;
    ```

### Context API

[react-doc/08-atomic-blog](https://github.com/JacobSuCHN/react-doc/tree/main/code/08-atomic-blog)

#### Context API 概述

- 无需手动在组件树中逐层传递属性，即可在应用程序中传递数据的系统
- 该系统允许我们将全局状态 “广播” 到整个应用程序
  - Provider（提供者）：使所有子组件都能访问某个值
  - value（值）：我们希望提供的数据（通常是状态和函数）
  - Consumers（消费者）：所有读取所提供上下文值的组件

#### Context API 使用

- 创建上下文

```jsx
const PostContext = createContext();
```

- 向子组件提供值

```jsx
return (
  <PostContext.Provider
    value={{
      posts: searchedPosts,
      onAddPost: handleAddPost,
      onClearPosts: handleClearPosts,
      searchQuery,
      setSearchQuery,
    }}
  >
    <section>
      <Header />
      <Main />
      <Archive />
      <Footer />
    </section>
  </PostContext.Provider>
);
```

- 使用上下文值

```jsx
const { onClearPosts } = useContext(PostContext);
```

#### 自定义 Provider 组件

```jsx
import { useEffect, useState } from "react";
import { PostProvider, usePosts } from "./PostContext";
function App() {
  return (
    <section>
      <PostProvider>
        <Header />
      </PostProvider>
    </section>
  );
}
function Header() {
  const { onClearPosts } = usePosts();
  return (
    <header>
      <button onClick={onClearPosts}>Clear posts</button>
    </header>
  );
}
export default App;
```

```jsx
import { createContext, useContext, useState } from "react";
import { faker } from "@faker-js/faker";
function createRandomPost() {
  return {
    title: `${faker.hacker.adjective()} ${faker.hacker.noun()}`,
    body: faker.hacker.phrase(),
  };
}
const PostContext = createContext();
function PostProvider({ children }) {
  const [posts, setPosts] = useState(() =>
    Array.from({ length: 30 }, () => createRandomPost())
  );
  const [searchQuery, setSearchQuery] = useState("");
  const searchedPosts =
    searchQuery.length > 0
      ? posts.filter((post) =>
          `${post.title} ${post.body}`
            .toLowerCase()
            .includes(searchQuery.toLowerCase())
        )
      : posts;
  function handleAddPost(post) {
    setPosts((posts) => [post, ...posts]);
  }
  function handleClearPosts() {
    setPosts([]);
  }
  return (
    <PostContext.Provider
      value={{
        posts: searchedPosts,
        onAddPost: handleAddPost,
        onClearPosts: handleClearPosts,
        searchQuery,
        setSearchQuery,
      }}
    >
      {children}
    </PostContext.Provider>
  );
}

function usePosts() {
  const context = useContext(PostContext);
  if (context === undefined)
    throw new Error("PostContext was used outside of the PostProvider");
  return context;
}
export { PostProvider, usePosts };
```

### 性能优化

[react-doc/07-worldwise](https://github.com/JacobSuCHN/react-doc/tree/main/code/07-worldwise)
[react-doc/08-atomic-blog](https://github.com/JacobSuCHN/react-doc/tree/main/code/08-atomic-blog)

#### 性能优化工具

- 性能优化
  - 避免无效渲染
    - memo
    - useMemo
    - useCallback
    - 将元素作为子组件（children）或普通属性（prop）传递传递
  - 提高应用程序速度 / 响应性
    - useMemo
    - useCallback
    - useTransition
  - 减小打包体积
    - 减少第三方包的使用
    - 代码分割与懒加载
- 组件实例何时重新渲染
  - 状态变更
  - 上下文变更
  - 父组件重新渲染
- 无效渲染：指未在 DOM 中产生任何变化的渲染；只有当无效渲染发生得过于频繁，或者组件运行极为缓慢时，才会成为问题

#### children

```jsx
function Test() {
  const [count, setCount] = useState(0);
  return (
    <div>
      <h1>Slow counter?!?</h1>
      <button onClick={() => setCount((c) => c + 1)}>Increase: {count}</button>

      <SlowComponent />
    </div>
  );
}
```

- 情况：慢组件嵌套在另一个组件中
- 解决方案：外层组件更新时，内存组件不需要更新

```jsx
function Counter({ children }) {
  const [count, setCount] = useState(0);
  return (
    <div>
      <h1>Slow counter?!?</h1>
      <button onClick={() => setCount((c) => c + 1)}>Increase: {count}</button>

      {children}
    </div>
  );
}
```

```jsx
function Test() {
  return (
    <div>
      <h1>Slow counter?!?</h1>
      <Counter>
        <SlowComponent />
      </Counter>
    </div>
  );
}
```

- 慢组件在计数器组件更新前就已经渲染
- 上下文组件就涉及该特性

#### 记忆化

- 记忆化
  - 一种优化技术，它会执行一次纯函数，并将结果存储在内存中
  - 如果我们尝试使用与之前相同的参数再次执行该函数，将会直接返回之前存储的结果，而无需再次执行该函数
- React 记忆化
  - 使用 memo 对组件进行记忆化处理
  - 使用 useMemo 对对象进行记忆化处理
  - 使用 useCallback 对函数进行记忆化处理
  - 作用
    - 防止无效渲染
    - 提升应用速度 / 响应性

#### memo 函数

- 用于创建一个组件，当它的父组件重新渲染时，只要两次渲染间传入的 props 保持不变，该组件就不会重新渲染。
- 仅影响 props！一个经过记忆化处理的组件，在其自身状态发生变化，或者它所订阅的上下文发生变化时，仍然会重新渲染。
- 仅当该组件渲染开销大（渲染缓慢）、频繁重新渲染，且重新渲染时 props 不变的情况下，才有意义

```jsx
import { memo } from "react";
const Archive = memo(function Archive({ show }) {
  return {
    // ...
  };
});
```

#### useMemo && useCallback

- 用于在多次渲染之间对值（使用 useMemo）和函数（使用 useCallback）进行记忆化处理
- 传入 useMemo 和 useCallback 的值会存储在内存中（“缓存”），并且只要依赖项（“输入”）保持不变，在后续的重新渲染中就会返回这些值
- useMemo 和 useCallback 都有一个依赖项数组（类似于 useEffect）：每当其中一个依赖项发生变化，值就会被重新创建
- 仅在三种使用场景之一中使用它们！
  - 与 memo 配合对属性进行记忆化处理，以防止无效渲染
  - 对值进行记忆化处理，避免在每次渲染时进行开销较大的重新计算
  - 对用于另一个钩子函数依赖数组中的值进行记忆化处理
- useMemo

```jsx
function App() {
  const [posts, setPosts] = useState(() =>
    Array.from({ length: 30 }, () => createRandomPost())
  );
  const archiveOptions = useMemo(() => {
    return {
      show: false,
      title: `Post archive in addition to ${posts.length} main posts`,
    };
  }, [posts.length]);
  return <Archive archiveOptions={archiveOptions} />;
}
```

```jsx
const Archive = memo(function Archive({ archiveOptions }) {
  return <h2>{archiveOptions.title}</h2>;
});
```

- useCallback

```jsx
function App() {
  const [posts, setPosts] = useState(() =>
    Array.from({ length: 30 }, () => createRandomPost())
  );
  const handleAddPost = useCallback(function handleAddPost(post) {
    setPosts((posts) => [post, ...posts]);
  }, []);
  const archiveOptions = useMemo(() => {
    return {
      show: false,
      title: `Post archive in addition to ${posts.length} main posts`,
    };
  }, [posts.length]);
  return <Archive archiveOptions={archiveOptions} onAddPost={handleAddPost} />;
}
```

```jsx
const Archive = memo(function Archive({ archiveOptions, onAddPost }) {
  const [posts] = useState(() =>
    Array.from({ length: 30000 }, () => createRandomPost())
  );

  const [showArchive, setShowArchive] = useState(archiveOptions.show);

  return (
    <>
      <h2>{archiveOptions.title}</h2>
      <button onClick={() => onAddPost(post)}>Add as new post</button>
    </>
  );
});
```

#### 代码包

- 代码包：包含整个应用程序代码的 JavaScript 文件；下载该代码包将一次性加载整个应用程序，使其成为单页应用程序（SPA）
- 代码包大小：用户为开始使用应用程序而必须下载的 JavaScript 代码量；这是需要优化的最重要因素之一，目的是缩短代码包的下载时间
- 代码分割：将代码包分割成多个部分，这些部分可以逐步下载（即 “懒加载”）

```jsx
import { lazy, Suspense } from "react";
const Homepage = lazy(() => import("./pages/Homepage"));
```

```jsx
import { Suspense } from "react";
function App() {
  return (
    <AuthProvider>
      <CitiesProvider>
        <BrowserRouter>
          <Suspense fallback={<SpinnerFullPage />}>
            <Routes>
              <Route index element={<Homepage />} />
              {/* ... */}
            </Routes>
          </Suspense>
        </BrowserRouter>
      </CitiesProvider>
    </AuthProvider>
  );
}
```

#### 性能优化注意事项

- 优化事项

  - 使用性能分析器和可视化检查（界面卡顿情况）来找出性能瓶颈
  - 解决这些实际的性能问题
  - 对开销大的重渲染进行记忆化处理
  - 对开销大的计算进行记忆化处理
  - 如果上下文有众多使用者且频繁变化，对其进行优化
  - 对上下文值和子组件进行记忆化处理
  - 针对单页应用（SPA）的路由，实现代码分割和懒加载

- 避免事项
  - 切勿过早优化！
  - 如果没有需要优化的地方，就不要进行任何优化...
  - 不要将所有组件都用 memo() 包裹
  - 不要将所有值都用 useMemo() 包裹
  - 不要将所有函数都用 useCallback() 包裹
  - 如果上下文运行不慢且没有众多使用者，就不要对其进行优化

#### useEffect 注意事项

- 依赖项数组规则
  - 在 useEffect 内部使用的每一个状态变量、属性以及上下文值，都必须包含在依赖数组中。
  - 所有 “响应式值” 都得包含进来！这指的是，任何引用了其他响应式值的函数或变量都在此列。
  - 依赖项是自动确定的：绝不要忽视 ESLint 的 “exhaustive - deps” 规则！
  - 不要把对象或数组用作依赖项（每次渲染时对象都会重新创建，React 会把新创建的对象视为不同的对象，比如 {}!== {}
  - 响应式值：指状态、属性、上下文值，或任何引用了其他响应式值的其他值
  - 同样的规则也适用于其他钩子函数的依赖数组：useMemo 和 useCallback
- 移除不必要的依赖项
  - 移除函数依赖项
    - 将函数移入副作用
    - 如果你在多个地方需要该函数，对其进行记忆化处理（使用 useCallback）
    - 如果该函数不引用任何响应式值，将其移出组件。
  - 移除对象依赖项
    - 不要包含整个对象，而是只包含你需要的属性（基本类型值）
    - 如果上述方法不可行，采用与处理函数相同的策略（移动对象或对对象进行记忆化处理）
  - 其他策略
    - 如果你有多个相关的响应式值作为依赖项，可以尝试使用 reducer（useReducer）
    - 你无需将 setState（来自 useState）和 dispatch（来自 useReducer）包含在依赖项中，因为 React 保证它们在每次渲染时都保持稳定
- 何时不使用副作用
  - 只有在其他方法都行不通时，才应将副作用作为最后的手段。React 将其称为跳出 React 常规流程的 “逃生舱口”
  - 以下是三种副作用被过度使用的情况（初学者应避免这些情况）
    - 响应用户事件。此时应使用事件处理函数代替
    - 在组件挂载时获取数据。在小型应用中这样做尚可，但在实际项目中，应使用类似 React Query 这样的库
    - 同步状态变化（根据另一个状态变量设置状态）。尽量使用派生状态和事件处理函数

### Redux

[react-doc/09-redux-intro](https://github.com/JacobSuCHN/react-doc/tree/main/code/09-redux-intro)

#### Redux 概述

- 用于管理全局状态的第三方库
- 独立库，但借助 react-redux 库可轻松与 React 应用集成
- 所有全局状态都存储在一个全局可访问的存储（store）中，通过 “action”（类似 useReducer）可轻松更新
- 从概念上讲，它类似于使用 Context API + useReducer
- 有两个 “版本”：（1）经典 Redux，（2）现代 Redux Toolkit

#### Redux 使用

[react-doc/09-redux-intro](https://github.com/JacobSuCHN/react-doc/tree/main/code/09-redux-intro)
