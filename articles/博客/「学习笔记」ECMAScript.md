## 1.ES6

### 1.1.let

- 特性

  - 变量不能重复声明

    - ```js
      let star='JacobSu';
      let star='Su'  //error
      ```

  - let有块级作用域：全局、函数、eval

    - ```js
      {
          let girl='linlin'
      }
      console.log(girl) //error
      ```

    - 不仅仅针对花括号，例如if（）控制语句里面

  - 不存在变量提前

    - ```js
      console.log(song)   //error
      let song='SOS'
      ```

  - 不影响作用域链

    - ```js
      let school='abc'
      function fn(){
          console.log(school) //abc
      }
      ```

- 案例

  - ```html
    <div>
        <div class="item" style="width: 50px;height: 50px;background-color: red"></div>
        <div class="item" style="width: 50px;height: 50px;background-color: red"></div>
        <div class="item" style="width: 50px;height: 50px;background-color: red"></div>
    </div>
    <script>
        let items=document.getElementsByClassName("item");
        // for(var i = 0;i<items.length;i++){
        //     items[i].onclick = function(){
        //         //修改当前元素的背景颜色
        //         // this.style.background = 'pink';
        //         items[i].style.background = 'pink';
        //     }
        // }
        // 当var=3的时候，点击事件开始向外层作用域找，找不到，就是windows.i，此时是3，如果是let i，具有块级作用域，所以每一次触碰事件的i都是不同的
        // console.log(windows.i)  //3 
        for(var i = 0;i<items.length;i++){
            items[i].onclick = function(){
                //修改当前元素的背景颜色
                // this.style.background = 'pink';
                items[i].style.background = 'pink';
            }
        }
    </script>
    ```



### 1.2.const

- 特性

  - 一定要赋初始值

  - 一般常量使用大写（潜规则）

  - 常量的值不能修改

  - 也具有块级作用域

    - ```js
      {
          const pyaler = 'uzi'
      }
      console.log(player) //error
      ```

  - 对于数组和对象的元素修改，不算作对常量的修改

    - ```js
      const team = ['uzi','MXLG','Ming','Letme'];
      team.push('Meiko'); //不报错，常量地址没有发生变化
      ```



### 1.3.解构赋值

- 定义

  - ES6 允许按照一定模式从数组和对象中提取值，对变量进行赋值，这被称为解构赋值

- 数组的解构

  - ```js
    const F4 = ['小沈阳'，'刘能','赵四','宋小宝']
    let [xiao,liu,zhao,song] = F4; 
    console.log(xiao)
    console.log(liu)
    console.log(zhao)
    console.log(song)
    ```

- 对象的结构

  - ```js
    const zhao = {
        name : '赵本山'，
        age: '不详',
        xiaopin: function(){
            console.log("我可以演小品")
        }
    }
    let {name,age,xiaopin} = zhao;
    console.log(name);
    console.log(age);
    console.log(xiaopin);
    ```



### 1.4.模板字符串

- 特性

  - 内容中可以直接出现换行符

    - ```js
      let str = `
      <ul>
      	<li>JS</li>
      	<li>JS</li>
      </ul>`;
      ```

  - 变量拼接

    - ```js
      let lovest = '魏翔';
      let out = `${lovest}是我心目中最搞笑的演员!!`;
      ```



### 1.5.对象简化写法

- 对象简化写法

  - ES6允许在大括号里面，直接写入变量和函数，作为对象的属性和方法,这样的书写更加简洁

- 特性

  - ```js
    let name = 'aaa';
    let change = function(){
        console.log('aaa');
    }
    
    const school = {
        name,
        change,
        improve(){
            consolg.log('bbb');
        }
    }
    ```



### 1.6.箭头函数

- 箭头函数

  - ES6允许使用箭头（=>）定义函数

- 特性

  - this是静态的，this始终指向函数声明时所在作用域下的this的值

    - ```js
      function A(){
          console.log(this.name)
      }
      
      let B = () => {
          console.log(this.name);
      }
      
      window.name = '尚硅谷';
      const school = {
          name: 'ATGUIGU'
      }
      
      //直接调用
      A()   //尚硅谷
      B()   //尚硅谷
      
      //call
      A.call(school);  //ATGUIGU
      B.call(school);  //尚硅谷
      ```

  - 不能作为构造实例化对象

    - ```js
      let A(name,age) => {
          this.name=name;
          this.age=age;
      }
      let me = new A('xiao',123);
      console.me //error
      ```

  - 不能使用arguments变量

    - ```js
      let fn = () => {
          console.log(arguments)；
      }
      fn(1,2,3)  //error
      ```

  - 简写

    - 当形参有且只有一个的时候，省略小括号

      - ```js
        let add = n => {
            return n + 1;
        }
        ```

    - 当代码体只有一条语句的时候，省略花括号，此时return也必须省略

      - ```js
        let add = n => n+1;
        ```

- 案例

  - 箭头函数适合与 this 无关的回调. 定时器, 数组的方法回调

  - 箭头函数不适合与 this 有关的回调.  事件回调, 对象的方法

  - ```html
    <div id="ad"></div>
    <script>
        //需求-1  点击 div 2s 后颜色变成『粉色』
        //获取元素
        let ad = document.getElementById('ad');
        //绑定事件
        ad.addEventListener("click", function(){
            //保存 this 的值
            // let _this = this;
            //定时器
            setTimeout(() => {
                //修改背景颜色 this
                // console.log(this);
                // _this.style.background = 'pink';
                this.style.background = 'pink';
            }, 2000);
        });
    
        //需求-2  从数组中返回偶数的元素
        const arr = [1,6,9,10,100,25];
        // const result = arr.filter(function(item){
        //     if(item % 2 === 0){
        //         return true;
        //     }else{
        //         return false;
        //     }
        // });
        const result = arr.filter(item => item % 2 === 0);
        console.log(result);
        // 箭头函数适合与 this 无关的回调. 定时器, 数组的方法回调
        // 箭头函数不适合与 this 有关的回调.  事件回调, 对象的方法
    </script>
    ```

    

### 1.7.函数参数默认值

- 函数参数默认值

  - ES6允许给函数参数赋值初始值

- 特性

  - 可以给形参赋初始值，一般位置要靠后（潜规则）

    - ```js
      function add(a,b,c=12){
          return a+b+c; 
      }
      let result = add (1,2);
      console.log(result) // 15
      ```

  - 与解构赋值结合

    - ```js
      function A({host='127.0.0.1',username,password,port}){
          console.log(host+username+password+port)
      }
      A({
          username:'ran',
          password:'123456',
          port:3306
      })
      ```

      

### 1.8.rest参数

- rest

  - ES6引入rest参数，用于获取函数的实参，用来代替arguments

- 特性

  - rest 参数必须要放到参数最后

    - ```js
      function date(...args){
          console.log(args);
      }
      date('aaa','bbb','ccc');
      ```

      

### 1.9.扩展运算符

- spread

  - 扩展运算符是能将数组转换为逗号分隔的参数序列

- 特性

  - ```js
    const boys=['AA','BB','CC']
    function chunwan(){
        console.log(arguments);
    }
    chunwan(...boys);  //0:'AA' 1:'BB' 2:'CC'
    ```

- 案例

  - 数组的合并

    - ```js
      const A = ['aa','bb'];
      const B = ['cc','dd'];
      const C = [...A,...B];
      console.log(C)   //[aa,bb,cc,dd]
      ```

  - 数组的复制

    - ```js
      const A = ['a','b','c'];
      const B = [...A];
      console.log(B)   //[a,b,c]
      ```

  - 将伪数组转换为真正的数组

    - ```js
      const A = documents.querySelectorAll('div');
      const B = [...A];
      console.log(B) // [div,div,div]
      ```

      

### 1.10.Symbol

- Symbol

  - ES6引入了一种新的原始数据类型 Symbol，表示独一无二的值；它是JavaScript语言的第七种数据类型，是一种类似于字符串的数据类型
  - Symbol特点
    - Symbol的值是唯一的，用来解决命名冲突的问题
    - Symbol值不能与其他数据进行运算
    - Symbol定义的对象属性不能使用for…in循环遍历，但是可以使用Reflect.ownKeys来获取对象的所有键名
    - Symbol给对象添加属性和方法

- 特性

  - 创建

    - ```js
      let s = Symbol('aa');
      let s2= Symbol('aa');
      console.log(s===s2)   //false
      
      let s3 = Symbol.for('bb');
      let s4 = Symbol.for('bb');
      comsole.log(s3===s4) ///true
      ```

  - 不能与其他数据进行运算

    - ```js
      let result = s + 100  //error
      let result = s > 100  //error
      let result = s + s  //error
      ```

  - Symbol内置值

    - ```js
      class Person {
          static [Symbol.hasInstance](param){
              console.log(param);
              console.log("我被用来检测了")；
              return false;
          }
      }
      let o = {};
      console.log(o instanceof Person); //我被用来检测了，false
      ```

- 案例

  - 给对象添加方法（方式1）

    - ```js
      let game = {
          name : 'ran'
      }
      let methods = {
          up:Symbol()
          down:Symbol()
      }
      game[methods.up]=function(){
          console.log('aaa');
      }
      game[methods.down]=function(){
          console.log('bbb');
      }
      console.log(game)    // name: 'ran',Symbol(),Symbol()
      ```

  - 给对象添加方法（方式2）

    - ```js
      let youxi = {
          name: '狼人杀'，
          [Symbol('say')]:function(){
              console.log('阿萨德')
          }
      }
      console.log(youxi)    // name:'狼人杀',Symbol(say)
      ```

  - 内置属性

    - ```js
      class Person{
              static [Symbol.hasInstance](param){
                  console.log(param);
                  console.log("我被用来检测类型了");
                  return false;
              }
          }
      ```

      

### 1.11.迭代器

- 迭代器

  - 迭代器(lterator)是一种接口，为各种不同的数据结构提供统一的访问机制；任何数据结构只要部署lterator接口，就可以完成遍历操作
  - 原生具备 iterator 接口的数据(可用 for of 遍历)
    - Array、Arguments、Set、Map、String、TypedArray、NodeList
  - 原理
    - 创建一个指针对象，指向数据结构的起始位置
    - 第一次调用next()方法，指针自动指向数据结构第一个成员
    - 接下来不断调用next()，指针一直往后移动，直到指向最后一个成员
    - 每调用next()返回一个包含value和done属性的对象

- 特性

  - ```js
    const xiyou=['AA','BB','CC','DD'];
    // for(let v of xiyou){
    //     console.log(v)  // 'AA','BB','CC','DD'  //for in保存的是键名，for of保存的是键值
    // }
    let iterator = xiyou[Symbol.iterator]();
    console.log(iterator.next()); //{{value:'唐僧'，done:false}}
    console.log(iterator.next()); //{{value:'孙悟空'，done:false}}
    ```

- 案例

  - 自定义遍历数据

    - ```js
      const banji = {
          name : "终极一班",
          stus: [
              'aa',
              'bb',
              'cc',
              'dd'
          ],
          [Symbol.iterator](){
              let index = 0;
              let _this = this;
              return {
                  next: () => {
                      if(index < this.stus.length){
                          const result = {value: _this.stus[index],done: false};
                          //下标自增
                          index++;
                          //返回结果
                          return result;
                      }else {
                          return {value: underfined,done:true};
                      }
                  }
              }
          }
      }
      for(let v of banji){
          console.log(v);  // aa bb cc dd
      }
      ```



### 1.12.生成器

- 生成器

  - 生成器函数是ES6提供的一种异步编程解决方案，语法行为与传统函数完全不同，是一种特殊的函数

- 特性

  - ```js
    function * gen (){    //函数名和function中间有一个 * 
        yield '耳朵'；     //yield是函数代码的分隔符
        yield '尾巴'；
        yield '真奇怪'；
    }
    let iterator = gen();
    console.log(iteretor.next()); 
    //{value:'耳朵',done:false} next（）执行第一段，并且返回yield后面的值
    console.log(iteretor.next()); //{value:'尾巴',done:false}
    console.log(iteretor.next()); //{value:'真奇怪',done:false}
    ```

- 案例

  - 生成器函数的参数传递

    - ```js
      function * gen(args){
          console.log(args);
          let one = yield 111;
          console.log(one);
          let two = yield 222;
          console.log(two);
          let three = yield 333;
          console.log(three);
      }
      
      let iterator = gen('AAA');
      console.log(iterator.next());
      console.log(iterator.next('BBB'));  //next中传入的BBB将作为yield 111的返回结果
      console.log(iterator.next('CCC'));  //next中传入的CCC将作为yield 222的返回结果
      console.log(iterator.next('DDD'));  //next中传入的DDD将作为yield 333的返回结果
      ```

  - 用生成器函数的方式解决回调地狱问题

    - ```js
      function one(){
          setTimeout(()=>{
              console.log('111')
              iterator.next()
          },1000)
      }
      function two(){
          setTimeout(()=>{
              console.log('222')
              iterator.next();
          },2000)
      }
      function three(){
          setTimeout(()=>{
              console.log('333')
              iterator.next();
          },3000)
      }
      
      function * gen(){
          yield one();
          yield two();
          yield three();
      }
      
      let iterator = gen();
      iterator.next();
      ```

  - 模拟异步获取数据

    - ```js
      function one(){
          setTimeout(()=>{
              let data='用户数据';
              iterator.next(data)
          },1000)
      }
      function two(){
          setTimeout(()=>{
              let data='订单数据';
              iterator.next(data)
          },2000)
      }
      function three(){
          setTimeout(()=>{
              let data='商品数据';
              iterator.next(data)
          },3000)
      }
      
      function * gen(){
          let users=yield one();
          console.log(users)
          let orders=yield two();
          console.log(orders)
          let goods=yield three();
          console.log(goods)
      }
      
      let iterator = gen();
      iterator.next();
      ```




### 1.13.Promise

- 参考Promise文档



### 1.14.Set

- Set（集合）

  - ES6提供了新的数据结构set(集合）；它类似于数组，但成员的值都是唯一的，集合实现了iterator接口，所以可以使用「扩展运算符』和「 for…of…』进行遍历，集合的属性和方法
    - size返回集合的元素个数
    - add增加一个新元素，返回当前集合
    - delete删除元素，返回boolean值has检测集合中是否包含某个元素，返回boolean值

- 特性

  - ```js
    let s = new Set();
    let s2 = new Set(['A','B','C','D'])
    
    //元素个数
    console.log(s2.size);
    
    //添加新的元素
    s2.add('E');
    
    //删除元素
    s2.delete('A')
    
    //检测
    console.log(s2.has('C'));
    
    //清空
    s2.clear()
    
    console.log(s2);
    ```

    

- 案例

  - ```js
    let arr = [1,2,3,4,5,4,3,2,1]
    
    //1.数组去重
    let result = [...new Set(arr)]
    console.log(result);
    //2.交集
    let arr2=[4,5,6,5,6]
    let result2 = [...new Set(arr)].filter(item => new Set(arr2).has(item))
    console.log(result2);
    //3.并集
    let result3=[new Set([...arr,...arr2])]
    console.log(result3);
    //4.差集
    let result4= [...new Set(arr)].filter(item => !(new Set(arr2).has(item)))
    console.log(result4);
    ```



### 1.15.Map

- Map

  - ES6提供了Map数据结构；它类似于对象，也是键值对的集合。但是“键”的范围不限于字符串，各种类型的值（包括对象）都可以当作键。Map也实现了iterator接口，所以可以使用『扩展运算符』和「for…of…』进行遍历

- 特性

  - ```js
    let m = new Map();
    m.set('name','ran');
    m.set('change',()=>{
        console.log('改变！')
    })
    let key={
        school:'atguigu'
    }
    m.set(key,['成都','西安']);
    
    //size
    console.log(m.size);
    
    //删除
    m.delete('name');
    
    //获取
    console.log(m.get('change'));
    
    // //清空
    // m.clear()
    
    //遍历
    for(let v of m){
        console.log(v);
    }
    ```



### 1.16.Class

- 参考JavaScript文档



### 1.17.模块化

- 模块化

  - 模块化是指将一个大的程序文件,拆分成许多小的文件，然后将小文件组合起来
  - 作用
    - 防止命名冲突
    - 代码复用
    - 高维护性
  - 模块化规范产品（ES6之前的模块化规范）
    - CommonJS ====> NodeJS、Browserify
    - AMD ====> requireJS
    - CMD ====> seaJS

- 语法

  - 模块功能主要有两个命令构成：export和inport

    - export命令用于规定模块的对外接口
    - inport命令用于输入其他模块提供的功能

  - 使用

    - ```js
      //m1.js
      export let school = '尚硅谷'
      export function teach(){
          console.log('教技能')
      }
      ```

    - ```html
      <!-- html文件 -->
      <script type="module">
          import * as m1 from "./src/js/m1.js";
      	console.log(m1);
      </script>
      ```

- 暴露语法

  - 分别暴露

    - ```js
      export let school = '尚硅谷'
      export function teach(){
          console.log('教技能')
      }
      ```

  - 统一暴露

    - ```js
      //统一暴露
      let school = '尚硅谷';
      function findjob(){
          console.log('找工作吧');
      }
      //export {school,findjob}
      ```

  - 默认暴露

    - ```js
      //默认暴露
      export default {
          school:'ATGUIGU',
          change:function(){
              console.log('我们可以改变你')
          }
      }
      ```

- 引入语法

  - 通用导入方式

    - ```js
      import * as m1 from "./src/js/m1.js"
      import * as m2 from "./src/js/m2.js"
      import * as m3 from "./src/js/m3.js"
      ```

  - 解构赋值方式

    - ```js
      import {school,teach} from "./src/js/m1.js"
      import {school as guigu,findJob} from "./src/js/m2.js"
      import {default as m3 } from "./src/js/m3.js"
      ```

  - 简便形式（只针对默认暴露）

    - ```js
      import m3 from "./src/js/m3.js"
      ```

- babel对模块化代码的转换





## 2.ES7

### 2.1.includes

- Array.prototype.includes

  - 用来检测数组中是否包含某个元素，返回布尔类型值

  - ```js
    const mingzhu = ['西游记','红楼梦','水浒传','三国演义']
    console.log(mingzhu.includes('西游记'))  //true
    console.log(mingzhu.includes('金瓶梅'))  //false
    ```

### 2.2.指数操作符

- 指数操作符**

  - 用来实现幂运算，功能与Math.pow结果相同

  - ```js
    console.log(2**10) // 1024
    ```



## 3.ES8

### 3.1.async与await

- async与await
  - async与await结合可以让异步代码像同步代码一样
  - 参考Promise文档

### 3.2.对象方法扩展

- ```js
  const school = {
      name:'尚硅谷',
      cities:['北京','上海','深圳'],
      xueke:['前端','Java','大数据','运维']
  };
  
  //获取对象所有的键
  console.log(Object.keys(school));
  
  //获取对象所有的值
  console.log(Object.values(school));
  
  //entries,用来创建map
  console.log(Object.entries(school));
  console.log(new Map(Object.entries(school)))
  
  //对象属性的描述对象
  console.log(Object.getOwnPropertyDescriptor(school))
  
  const obj = Object.create(null,{
      name:{
          value:'尚硅谷',
          //属性特性
          writable:true,
          configurable:true,
          enumerable:true,
      }
  })
  ```

  

## 4.ES9

### 4.1.rest与spread

- rest参数与spread扩展运算符在 ES6 中已经引入，不过 ES6 中只针对于数组

- 在ES9中为对象提供了像数组一样的rest参数和spread扩展运算符

- ```js
  //rest 参数
  function connect({host, port, ...user}){
      console.log(host);
      console.log(port);
      console.log(user);
  }
  
  connect({
      host: '127.0.0.1',
      port: 3306,
      username: 'root',
      password: 'root',
      type: 'master'
  });
  
  
  //对象合并
  const skillOne = {
      q: '天音波'
  }
  
  const skillTwo = {
      w: '金钟罩'
  }
  
  const skillThree = {
      e: '天雷破'
  }
  const skillFour = {
      r: '猛龙摆尾'
  }
  
  const mangseng = {...skillOne, ...skillTwo, ...skillThree, ...skillFour};
  
  console.log(mangseng)
  
  // ...skillOne   =>  q: '天音波', w: '金钟罩'
  ```

  

### 4.2.正则扩展

- 命名捕获分组

  - ```js
    //声明一个字符串
    // let str = '<a href="http://www.atguigu.com">尚硅谷</a>';
    
    // //提取 url 与 『标签文本』
    // const reg = /<a href="(.*)">(.*)<\/a>/;
    
    // //执行
    // const result = reg.exec(str);
    
    // console.log(result);
    // // console.log(result[1]);
    // // console.log(result[2]);
    
    
    let str = '<a href="http://www.atguigu.com">尚硅谷</a>';
    //分组命名
    const reg = /<a href="(?<url>.*)">(?<text>.*)<\/a>/;
    
    const result = reg.exec(str);
    
    console.log(result.groups.url);
    
    console.log(result.groups.text);
    ```

- 反向断言

  - ```js
    //声明字符串
    let str = 'JS5211314你知道么555啦啦啦';
    //正向断言
    const reg = /\d+(?=啦)/;
    const result = reg.exec(str);
    
    //反向断言
    const reg = /(?<=么)\d+/;
    const result = reg.exec(str);
    console.log(result);
    ```

- dotAll模式

  - ```js
    //dot  .  元字符  除换行符以外的任意单个字符
    let str = `
    <ul>
        <li>
            <a>肖生克的救赎</a>
            <p>上映日期: 1994-09-10</p>
        </li>
        <li>
            <a>阿甘正传</a>
            <p>上映日期: 1994-07-06</p>
        </li>
    </ul>`;
    //声明正则
    // const reg = /<li>\s+<a>(.*?)<\/a>\s+<p>(.*?)<\/p>/;
    const reg = /<li>.*?<a>(.*?)<\/a>.*?<p>(.*?)<\/p>/gs;
    //执行匹配
    // const result = reg.exec(str);
    let result;
    let data = [];
    while(result = reg.exec(str)){
        data.push({title: result[1], time: result[2]});
    }
    //输出结果
    console.log(data);
    ```

    

## 5.ES10

### 5.1.对象扩展方法

- Object.fromEntries()：创建对象

  - ```js
    //二维数组
    // const result = Object.fromEntries([
    //     ['name','尚硅谷'],
    //     ['xueke', 'Java,大数据,前端,云计算']
    // ]);
    
    //Map
    // const m = new Map();
    // m.set('name','ATGUIGU');
    // const result = Object.fromEntries(m);
    
    //Object.entries ES8
    const arr = Object.entries({
        name: "尚硅谷"
    })
    console.log(arr);
    ```



### 5.2.字符串扩展方法

- ```js
  //trim
  let str= ' asd  '
  console.log(str) //asd
  console.log(str.trimStart()) //asd  清空头空格
  console.log(str.trimEnd()) //  asd  清空尾空格
  ```



### 5.3.数组扩展方法

- ```js
  //flat
  //将多维数组转化为低位数组
  // const arr = [1,2,3,4,[5,6]];
  // const arr = [1,2,3,4,[5,6,[7,8,9]]];
  //参数为深度 是一个数字
  // console.log(arr.flat(2));  
  
  //flatMap
  const arr2=[1,2,3,4]
  const result = arr2.flatMap(item => [item * 10]); //如果map的结果是一个多维数组可以进行flat 是两个操作的结合
  ```

  

### 5.4.Symbol扩展属性

- ```js
  //用来获取Symbol的字符串描述
  let s = Symbol('尚硅谷');
  console.log(s.description);//尚硅谷
  ```

  

## 6.ES11

### 6.1.私有属性

- ```js
  class Person{
      //公有属性
      name;
      //私有属性
      #age;
      #weight;
      //构造方法
      constructor(name, age, weight){
          this.name = name;
          this.#age = age;
          this.#weight = weight;
      }
  
      intro(){
          console.log(this.name);
          console.log(this.#age);
          console.log(this.#weight);
      }
  }
  
  //实例化
  const girl = new Person('晓红', 18, '45kg');
  
  // console.log(girl.name);
  // console.log(girl.#age);
  // console.log(girl.#weight);
  
  girl.intro();
  ```



### 6.2.Promise.allSettled

- ```js
  //声明两个promise对象
  const p1 = new Promise((resolve, reject)=>{
      setTimeout(()=>{
          resolve('商品数据 - 1');
      },1000)
  });
  
  const p2 = new Promise((resolve, reject)=>{
      setTimeout(()=>{
          resolve('商品数据 - 2');
          // reject('出错啦!');
      },1000)
  });
  
  //调用allsettled方法：返回的结果始终是一个成功的，并且异步任务的结果和状态都存在
  // const result = Promise.allSettled([p1, p2]);
  //调用all方法：返回的结果是按照p1、p2的状态来的，如果都成功，则成功，如果一个失败，则失败，失败的结果是失败的Promise的结果
  // const res = Promise.all([p1, p2]);
  
  console.log(res);
  ```

  

### 6.3.String.prototype.matchAll

- ```js
  let str = `<ul>
      <li>
          <a>肖生克的救赎</a>
          <p>上映日期: 1994-09-10</p>
      </li>
      <li>
          <a>阿甘正传</a>
          <p>上映日期: 1994-07-06</p>
      </li>
  </ul>`;
  
  //声明正则
  const reg = /<li>.*?<a>(.*?)<\/a>.*?<p>(.*?)<\/p>/sg
  
  //调用方法：批量匹配
  const result = str.matchAll(reg);
  
  // for(let v of result){
  //     console.log(v);
  // }
  
  const arr = [...result];
  
  console.log(arr);
  ```



### 6.4.可选链操作符

- ```js
  //相当于一个判断符，如果前面的有，就进入下一层级
  //?.
  function main(config){
      const dbHost = config?.db?.host
      console.log(dbHost) //192.168.1.100
  }
  
  main({
      db:{
          host:'192.168.1.100',
          username:'root'
      },
      cache：{
      	host:'192.168.1.200',
      	username:'admin'
  	}
  })
  ```

  

### 6.5.动态import

- ```js
  // hello.js
  export function hello(){
      alert('Hello');
  }
  ```

- ```js
  // app.js
  // import * as m1 from "./hello.js";
  //获取元素
  const btn = document.getElementById('btn');
  btn.onclick = function(){
      import('./hello.js').then(module => {
          module.hello();
      });
  }
  ```

- ```html
  <!-- html -->
  <button id="btn">点击</button>
  <script src="./js/app.js" type="module"></script>
  ```

  

### 6.6.BigInt类型

- ```js
  //大整型
  let n = 521n;
  console.log(n,typeof(n))  // 521n  n 
  
  //函数
  let n = 123;
  console.log(BigInt(n)) // 123n  //不要使用浮点型，只能用int
  
  //大数值运算
  let max = Number.MAX_SAFE_INTEGER; // 9007199254740991
  console.log(max +1) // 9007199254740992
  console.log(max +2) // 9007199254740992 出问题了
  console.log(BigInt(max)+BigInt(1)) 9007199254740992n
  console.log(BigInt(max)+BigInt(2)) 9007199254740993n
  ```



### 6.7.globalThis

- ```js
  //始终指向全局对象
  console.log(globalThis) //window，适用于复杂环境下直接操作window
  ```

  