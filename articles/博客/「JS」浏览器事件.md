## 浏览器事件模型

- DOM：document object modal 文档对象模型

  - VDOM -> 虚拟 DOM(Virtual DOM) API -> js 对象 跨平台 -> 作用到宿主环境

- DOM0

  ```js
  btn.onclick = function (e) {
    fn1.call(this);
    fn2();
  };
  ```

- DOM1

  - 98 W3C

- DOM2

  - addEventListener
  - removeEventListener

  ```js
  // 显式声明，便于remove
  function fn1() {}
  function fn2() {}
  
  // btn.addEventListener('click', ()=>{}, boolean) // boolean 是否在冒泡中执行 默认false
  btn.addEventListener("click", fn1);
  btn.addEventListener("click", fn2);
  btn.removeEventListener("click", fn2);
  ```

  - IE DOM2

  ```js
  btn.attachEvent("click", fn1);
  btn.detachEvent();
  ```

  - .browserslist：兼容

## 事件冒泡与事件捕获

- 事件流程

  ```pseudocode
  document
    html
      body
        div
          ul
            li
  ```

  - 事件捕获（从上到下）

  - 处于当前阶段

  - 事件冒泡（从下到上）

  ```js
  li.addEventListener(
    "click",
    function (e) {
      console.log("capture");
      e.stopPropagation();
    },
    true
  );
  
  preventDefault();
  ```

  - stopPropagation()：阻塞当前事件传播的过程

  - preventDefault()：阻止当前事件的默认行为

## 事件委托

- 事件委托：子元素的事件委托给父元素

```html
<ul id="myLinks">
  <li id="goSomewhere">Go somewhere</li>
  <li id="doSomething">Do something</li>
  <li id="sayHi">Say hi</li>
</ul>
```

```js
var item1 = document.getElementById("goSomewhere");
var item2 = document.getElementById("doSomething");
var item3 = document.getElementById("sayHi");
EventUtil.addHandler(item1, "click", function (event) {
  location.href = "http://www.xianzao.com";
});
EventUtil.addHandler(item2, "click", function (event) {
  document.title = "I changed the document's title";
});
EventUtil.addHandler(item3, "click", function (event) {
  alert("hi");
});
```

```js
// 事件委托
var list = document.getElementById("myLinks");
EventUtil.addHandler(list, "click", function(event) {
  event = EventUtil.getEvent(event);
  var target = EventUtil.getTarget(event);
  switch(target.id) {
    case "doSomething":
      document.title = "I changed the document's title";
      break;
    case "goSomewhere":
      location.href = "http://www.wrox.com";
      break;
    case "sayHi": alert("hi");
      break;
  }
}
```

## 浏览器请求

- ajax

  - 标准定义：Asynchronous JavaScript And XML 异步的 JavaScript 和 XML

  ```js
  const ajax = (option) => {
    // type, url, data, timeout, success, error将所有参数换成一个对象{}
  
    // 0.将对象转换成字符串
  
    // 处理obj
    const objToString = (data) => {
      data.t = new Date().getTime();
      let res = [];
      for (let key in data) {
        // 需要将key和value转成非中文的形式，因为url不能有中文。使用encodeURIComponent();
        res.push(encodeURIComponent(key) + " = " + encodeURIComponent(data[key]));
      }
      return res.join("&");
    };
  
    let str = objToString(option.data || {});
  
    // 1.创建一个异步对象xmlHttp；
    var xmlHttp, timer;
    if (window.XMLHttpRequest) {
      xmlHttp = new XMLHttpRequest();
    } else if (xmlHttp) {
      // code for IE6, IE5
      xmlHttp = new ActiveXObject("Microsoft.xmlHttp");
    }
  
    // 2.设置请求方式和请求地址；
    // 判断请求的类型是POST还是GET
    if (option.type.toLowerCase() === "get") {
      xmlHttp.open(option.type, option.url + "?t=" + str, true);
      //  3.发送请求；
      xmlHttp.send();
    } else {
      xmlHttp.open(option.type, option.url, true);
      // 注意：在post请求中，必须在open和send之间添加HTTP请求头：setRequestHeader(header,value);
      xmlHttp.setRequestHeader(
        "Content-type",
        "application/x-www-form-urlencoded"
      );
      // 3.发送请求；
      xmlHttp.send(str);
    }
  
    // 4.监听状态的变化；
    xmlHttp.onreadystatechange = function () {
      clearInterval(timer);
      if (xmlHttp.readyState === 4) {
        if (
          (xmlHttp.status >= 200 && xmlHttp.status < 300) ||
          xmlHttp.status == 304
        ) {
          // 5.处理返回的结果；
          option.success(xmlHttp.responseText); // 成功后回调；
        } else {
          option.error(xmlHttp.responseText); // 失败后回调；
        }
      }
    };
  
    //判断外界是否传入了超时时间
    if (option.timeout) {
      timer = setInterval(function () {
        xmlHttp.abort(); //中断请求
        clearInterval(timer);
      }, option.timeout);
    }
  };
  ```
  
  - onreadystatechange（readyState）
    - 0：还没有调用 open
    - 1：open 但没 send
    - 2：header 
    - 3：部分数据可用
    - 4：ready
