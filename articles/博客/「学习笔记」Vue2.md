## 1.Vue概述

### 1.1.概述

- Vue是什么
  - Vue是一套用于构建用户界面的渐进式JavaScript框架
    - 构建用户界面：数据->界面
    - 渐进式：Vue可以自底向上逐层的应用
- Vue的特点
  - 采用组件化模式，提高代码复用率，且让代码更好维护
  - 声明式编码，让编码人员无需直接操作DOM，提高代码开发效率
  - 使用虚拟DOM+优秀的Diff算法，尽量复用DOM节点

### 1.2.引入Vue

- Vue版本
  - 开发版本：vue.js
  - 生产版本：vue.min.js

- 引入Vue

  - ```html
    <script src="./js/vue.js"></script>
    ```

- 阻止浏览器Vue提示

  - ```javascript
    Vue.config.productionTip=false
    ```
    
  - productionTip设置为false阻止Vue在启动时生成生产提示



## 2.Vue基础

### 2.1.HelloWorld案例

- ```html
  <!-- 准备一个容器 -->
  <div id="root">
  	<h1>Hello World! - {{name}}, {{address.toUpperCase()}}</h1>
  </div>
  
  <script>
      Vue.config.productionTip=false //阻止Vue在启动时生成生产提示
  
      //创建Vue实例
      new Vue({
          el:'#root', //el用于指定当前Vue实例为哪个容器，值通常为css选择器字符串
          data:{ //data用于存储数据，数据供el所指定的容器去使用，值我们暂时先写成一个对象
              name:'JacobSu'
          }
      })
  </script>
  ```

  
  
- 初识Vue
  
    - 想让Vue工作，就必须创建一个Vue实例，且要传入一个配置对象
    - root容器里的代码依然符合html规范，只不过混入了一些特殊的Vue语法
    - root容器里的代码被称为【Vue模板】
    - Vue实例和容器是一一对应的
    - 真实开发中只有一个Vue实例，并且会配合着组件一起使用
    - {{xxx}}中的xxx要写js表达式，且xxx可以自动读取到data中的所有属性
    - 一旦data中的数据发生改变，那么页面中用到该数据的地方也会自动更新
    
- 注意区分：js表达式 和 js代码(语句)
    - 表达式：一个表达式会产生一个值，可以放在任何一个需要值的地方
        - ```javascript
          (1). a
          (2). a+b
          (3). demo(1)
          (4). x === y ? 'a' : 'b'
          ```
        
    - js代码(语句)
    
        - ```javascript
            (1). if(){}
            (2). for(){}
            ```



### 2.2.模板语法

- Vue模板语法有2大类

  - 插值语法
    - 功能：用于解析标签体内容
    - 写法：{{xxx}}，xxx是js表达式，且可以直接读取到data中的所有属性
  - 指令语法
    - 功能：用于解析标签（包括：标签属性、标签体内容、绑定事件.....）
    - 举例：v-bind:href="xxx" 或  简写为 :href="xxx"，xxx同样要写js表达式，且可以直接读取到data中的所有属性
    - 备注：Vue中有很多的指令，且形式都是：v-????，此处我们只是拿v-bind举个例子

- ```html
  <!-- 准备一个容器 -->
  <div id="root">
      <h1>插值语法</h1>
      <h3>你好,{{name}}</h3>
      <hr>
      <h1>指令语法</h1>
      <a v-bind:href="school.url">{{school.name}}</a>
      <a :href="school.url">{{school.name}}</a>  <!-- 简写 -->
  </div>
  
  <script>
      Vue.config.productionTip=false //阻止Vue在启动时生成生产提示
      new Vue({
          el:'#root',
          data:{
              name: 'JacobSu',
              school:{
                  name: 'bilibili',
                  url:'http://www.bilibili.com'
              }
          }
      })
  </script>
  ```

  

### 2.3.数据绑定

- Vue中有2种数据绑定的方式

  - 单向绑定(v-bind)：数据只能从data流向页面
  - 双向绑定(v-model)：数据不仅能从data流向页面，还可以从页面流向data
    - 备注
      - 双向绑定一般都应用在表单类元素上（如：input、select等）
      - v-model:value 可以简写为 v-model，因为v-model默认收集的就是value值

- ```html
  <!-- 准备一个容器 -->
  <div id="root">
      <!-- 普通写法 -->
      <!-- 单向数据绑定：<input type="text" v-bind:value="name"><br> -->
      <!-- 双向数据绑定：<input type="text" v-model:value="name"><br> -->
      <!-- 简写 -->
      单向数据绑定：<input type="text" :value="name"><br>
      双向数据绑定：<input type="text" v-model="name"><br>
  </div>
  
  <script>
      Vue.config.productionTip=false //阻止Vue在启动时生成生产提示
      new Vue({
          el: "#root",
          data:{
              name: 'JacobSu'
          }
      })
  </script>
  ```

    

### 2.4.el与data的两种写法

- data与el的2种写法

  - el有2种写法
    - new Vue时候配置el属性
    - 先创建Vue实例，随后再通过vm.$mount('#root')指定el的值
  - data有2种写法
    - 对象式
    - 函数式
    - 如何选择：目前哪种写法都可以，以后学习到组件时，data必须使用函数式，否则会报错
  - 一个重要的原则
    - 由Vue管理的函数，一定不要写箭头函数，一旦写了箭头函数，this就不再是Vue实例了

- ```html
  <!-- 准备一个容器 -->
  <div id="root">
      <h1>{{name}}</h1>
  </div>
  
  <script>
      Vue.config.productionTip=false //阻止Vue在启动时生成生产提示
      // el的两种写法
      // const v=new Vue({
      //     // el: "#root",//el的第一种写法
      //     data:{
      //         name: 'JacobSu'
      //     }
      // })
      // console.log(v);
      // v.$mount('#root');//el的第二种写法-挂载
      //data的两种写法
      new Vue({
          el: "#root",
          //data的第一种写法-对象式
          // data:{
          //     name: 'JacobSu'
          // }
          //data的第二种写法-函数式
          data() {
              console.log("this:",this)//此处的this是Vue实例对象
              return{
                  name: "JacobSu"
              }
          }
      })
  </script>
  ```

    

### 2.5.Vue的MVVM模型

- MVVM模型

  - M：模型(Model) ：data中的数据
  - V：视图(View) ：模板代码
  - VM：视图模型(ViewModel)：Vue实例

- 观察发现

  - data中所有的属性，最后都出现在了vm身上
  - vm身上所有的属性及Vue原型上所有属性，在Vue模板中都可以直接使用

- ```html
  <!-- 准备一个容器 -->
  <!-- View -->
  <div id="root">
      <h1>姓名：{{name}}</h1>
      <h1>地址：{{address}}</h1>
      <h1>测试：{{$emit}}</h1>
  </div>
  
  <script>
      Vue.config.productionTip=false //阻止Vue在启动时生成生产提示
      // ViewModel
      const vm=new Vue({
          el: "#root",
          data:{
              // Model
              name: 'JacobSu',
              address:'HeFei'
          }
      })
      console.log(vm);
  </script>
  ```

    

### 2.6.数据代理

#### 2.6.1.Object.defineProperty

- Object.defineProperty

  - Object.defineProperty(object, property, {value : value})
  - 直接在一个对象上定义一个新属性，或者修改一个对象的现有属性，并返回此对象

  - ```html
    <script>
        let number = 18
        let person={
            name: "张三",
            sex: "男"
        }
    
        // Object.defineProperty(object, property, {value : value})
        Object.defineProperty(person,'age',{
            // value:18,
            // enumerable:true,//控制属性是否可以被枚举，默认值false
            // writable: true,//控制属性是否可以被修改，默认值false
            // configurable: true,//控制属性是否可以被删除，默认值false
    
            //当有人读取person的age属性时，get函数(getter)就会被调用，且返回值就是age的值
            get(){
                console.log('有人读取age属性了')
                return number
            },
    
            //当有人修改person的age属性时，set函数(setter)就会被调用，且会收到修改的具体值
            set(value){
                console.log('有人修改了age属性，且值是',value)
                number = value
            }
        })
        console.log(Object.keys(person));
        console.log(person);
    </script>
    ```




#### 2.6.2.数据代理

- 数据代理

  - 通过一个对象代理对另一个对象中属性的操作（读/写）

  - ```html
    <script type="text/javascript" >
        let obj1 = {x:100}
        let obj2 = {y:200}
    
        Object.defineProperty(obj2,'x',{
            get(){
                return obj1.x
            },
            set(value){
                obj1.x = value
            }
        })
    </script>
    ```




#### 2.6.3.Vue中的数据代理

- Vue中的数据代理

  - 通过vm对象来代理data对象中属性的操作（读/写）
  - Vue中数据代理的好处：更加方便的操作data中的数据
  - 基本原理
    - 通过Object.defineProperty()把data对象中所有属性添加到vm上
    - 为每一个添加到vm上的属性，都指定一个getter/setter
    - 在getter/setter内部去操作（读/写）data中对应的属性
  - ![](https://image.jslog.net/online/a-11/2024/05/26/19-27-32-1716722852674-1.png)

  - ```html
    <div id="root">
        <h1>姓名：{{name}}</h1>
        <h1>地址：{{address}}</h1>
    </div>
    
    <script>
        Vue.config.productionTip=false //阻止Vue在启动时生成生产提示
        const vm=new Vue({
            el: "#root",
            //vm._data=data
            data:{
                name: 'JacobSu',
                address:'HeFei'
            }
        })
    </script>
    ```

    

### 2.7.事件处理

#### 2.7.1.事件的基本使用

- 事件的基本使用

  - 使用v-on:xxx 或 @xxx 绑定事件，其中xxx是事件名

  - 事件的回调需要配置在methods对象中，最终会在vm上

  - methods中配置的函数，不要用箭头函数！否则this就不是vm了

  - methods中配置的函数，都是被Vue所管理的函数，this的指向是vm 或 组件实例对象

  - @click="demo" 和 @click="demo($event)" 效果一致，但后者可以传参

  - ```html
    <div id="root">
        <h1>{{name}}</h1>
        <button v-on:click="showInfo1">点我提示信息</button>
        <!-- 简写 -->
        <button @click="showInfo2(23,$event)">点我提示信息</button>
    </div>
    
    <script>
        const vm = new Vue({
            el: "#root",
            data:{
                name: 'JacobSu'
            },
            methods: {
                showInfo1(event){
                    console.log(event.target.innerText);
                    console.log(this)//此处的this是vm
                    alert('!')
                },
                showInfo2(number){
                    console.log(event.target.innerText);
                    console.log(number)
                    alert('!!!')
                }
            }
        })
    </script>
    ```

    

#### 2.7.2.Vue中的事件修饰符

- Vue中的事件修饰符

  - prevent：阻止默认事件（常用）

  - stop：阻止事件冒泡（常用）

  - once：事件只触发一次（常用）

  - capture：使用事件的捕获模式

  - self：只有event.target是当前操作的元素时才触发事件

  - passive：事件的默认行为立即执行，无需等待事件回调执行完毕

  - 修饰符可以连续写，分前后

  - ```html
    <div id="root">
        <h1>{{name}}</h1>
        //事件修饰符prevent阻止默认行为
        <a href="http://bilibili.com" @click.prevent="showInfo">bilibili</a>
    </div>
    
    <script>
        const vm = new Vue({
            el: "#root",
            data:{
                name: 'JacobSu'
            },
            methods: {
                showInfo(event){
                    // e.preventDefault()//阻止默认行为
                    console.log(this)//此处的this是vm
                    alert('!')
                },
            }
        })
    </script>
    ```

  

#### 2.7.3.键盘事件

- 键盘事件

  - Vue中常用的按键别名

    - 回车 => enter
    - 删除 => delete (捕获“删除”和“退格”键)
    - 退出 => esc
    - 空格 => space
    - 换行 => tab (特殊，必须配合keydown去使用)
    - 上 => up
    - 下 => down
    - 左 => left
    - 右 => right

  - Vue未提供别名的按键

    - 可以使用按键原始的key值去绑定，但注意要转为kebab-case（短横线命名，两个词之间用'-'隔开）
    - 可以使用keyCode去指定具体的按键（不推荐）
    - Vue.config.keyCodes.自定义键名 = 键码，可以去定制按键别名

  - 系统修饰键（用法特殊）：ctrl、alt、shift、meta

    - 配合keyup使用：按下修饰键的同时，再按下其他键，随后释放其他键，事件才被触发
    - 配合keydown使用：正常触发事件

  - 键盘修饰符可以连续写

  - ```html
    <div id="root">
        <h1>{{name}}</h1>
        <input type="text" placeholder="按下回车提示输入" @keyup.caps-Lock="showInfo">
    </div>
    
    <script>
        Vue.config.keyCodes.uppercase=20;//为按键设置Vue别名，不太推荐
        const vm = new Vue({
            el: "#root",
            data:{
                name: 'JacobSu'
            },
            methods: {
                showInfo(event){
                    // if (event.keyCode!=13) return;
                    console.log(event.key,event.keyCode);
                    console.log(event.target.value);
    
                }
            }
        })
    </script>
    ```

    

### 2.8.计算属性

#### 2.8.1.姓名案例

- 姓名案例

  - ```html
    <div id="root">
        姓：<input type="text" v-model="firstName"> <br><br>
        名：<input type="text" v-model="lastName"> <br><br>
        <!-- 插值语法实现 -->
        全名：<span>{{firstName}}-{{lastName}}</span><br><br>
        <!-- methods方法实现 -->
        全名：<span>{{fullName()}}</span><br><br>
    </div>
    
    <script>
        const vm = new Vue({
            el: "#root",
            data:{
                firstName: "张",
                lastName:"三"
            },
            methods: {
                fullName(){
                    return this.firstName+"-"+this.lastName
                }
            }
        })
    </script>
    ```

  - Vue中data数据发生变化，模板会重新进行解析




#### 2.8.2.计算属性-computed

- 计算属性-computed

  - 定义：要用的属性不存在，要通过已有属性计算得来

  - 原理：底层借助了Objcet.defineproperty方法提供的getter和setter

  - get函数什么时候执行

    - 初次读取时会执行一次
    - 依赖的数据发生改变时会被再次调用

  - 优势：与methods实现相比，内部有缓存机制（复用），效率更高，调试方便

  - 备注

    - 计算属性最终会出现在vm上，直接读取使用即可
    - 如果计算属性要被修改，那必须写set函数去响应修改，且set中要引起计算时依赖的数据发生改变
    - 一般计算属性不修改，可以将属性简写

  - ```html
    <div id="root">
        姓：<input type="text" v-model="firstName"> <br><br>
        名：<input type="text" v-model="lastName"> <br><br>
        全名：<span>{{fullName}}</span><br><br>
        全名：<span>{{fullName_short}}</span><br><br>
    </div>
    
    <script>
        const vm = new Vue({
            el: "#root",
            data:{
                firstName: "张",
                lastName:"三"
            },
            computed: {
                //完整写法
                fullName:{
                    //只要fullName被读取，get就会被调用，且返回值作为fullName的值
                    get() {
                        return this.firstName+"-"+this.lastName
                    },
                    //只要fullName被修改，set就会被调用，value就是传入的修改值
                    set(value){
                        const arr=value.split('-');
                        this.firstName = arr[0];
                        this.lastName = arr[1];
                    }
                },
                //简写
                fullName_short() {
                    return this.firstName+"-"+this.lastName
                }
            }
        })
    </script>
    ```

     

###     2.9.监视属性

#### 2.9.1.监视属性-watch

- 监视属性-watch

  - 当被监视的属性变化时，回调函数自动调用,，进行相关操作

  - 监视的属性必须存在，才能进行监视

  - 监视的两种写法

    - new Vue时传入watch配置
    - 通过vm.$watch监视

  - 监视属性新文档改为侦听属性

  - ```html
    <div id="root">
        <h1>今天天气很{{info}}</h1>
        <button @click="changeWeather">切换天气</button>
        <!-- 绑定事件的时候：@xxx="yyy" yyy可以写一些简单的语句 -->
        <!-- <button @click="isHot = !isHot">切换天气</button> -->
    </div>
    
    <script>
        const vm = new Vue({
            el:'#root',
            data:{
                isHot:true,
                isHot_short:true
            },
            computed:{
                info(){
                    return this.isHot ? '炎热' : '凉爽'
                }
            },
            methods: {
                changeWeather(){
                    this.isHot = !this.isHot
                    this.isHot_short=!this.isHot_short
                }
            },
            watch:{
                //完整写法
                isHot:{
                    immediate:true,//初始化时调用handler
                    //当isHot发生改变时调用handler
                    handler(newValue,oldValue){
                        console.log(newValue,oldValue);
                    }
                },
                //简写
                isHot_short(newValue,oldValue){
                    console.log(newValue,oldValue);
                }
            }
        })
        //完整写法
        vm.$watch('isHot',{
            immediate:true,
            handler(newValue,oldValue){
                console.log(newValue,oldValue);
            }
        })
        //简写
        vm.$watch('isHot_short',function(newValue,oldValue){
            console.log(newValue,oldValue);
        })
    ```



#### 2.9.2.深度监视

- 深度监视

  - Vue中的watch默认不监测对象内部值的改变（一层）

  - 配置deep:true可以监测对象内部值改变（多层）

  - 备注

    - Vue自身可以监测对象内部值的改变，但Vue提供的watch默认不可以
    - 使用watch时根据数据的具体结构，决定是否采用深度监视

  - ```html
    <div id="root">
        <h1>今天天气很{{info}}</h1>
        <button @click="changeWeather">切换天气</button>
        <hr>
        <h2>a={{numbers.a}}</h2>
        <button @click="numbers.a++">a++</button>
        <h2>b={{numbers.b}}</h2>
        <button @click="numbers.b++">b++</button>
        <hr>
        <!-- <button @click="numbers={a:666,b:888}">替换numbers</button> -->
    </div>
    
    <script>
        const vm = new Vue({
            el:'#root',
            data:{
                isHot:true,
                numbers:{
                    a:1,
                    b:1
                }
            },
            computed:{
                info(){
                    return this.isHot ? '炎热' : '凉爽'
                }
            },
            methods: {
                changeWeather(){
                    this.isHot = !this.isHot
                }
            },
            watch:{
                isHot:{
                    immediate:true,//初始化时调用handler
                    //当isHot发生改变时调用handler
                    handler(newValue,oldValue){
                        console.log("isHot",newValue,oldValue);
                    }
                },
                //监视多级结构中某个属性的变化
                "numbers.a":{
                    handler(newValue, oldValue) {
                        console.log("numbers.a",newValue, oldValue);
                    }
                },
                //监视多级结构中多个属性的变化
                numbers:{
                    deep:true,//开启深度监视
                    handler(newValue, oldValue){
                        console.log("numbers");
                    }
                }
            }
        })
    </script>
    ```

    

#### 2.9.3.计算属性与监视属性

- computed和watch之间的区别

  - computed能完成的功能，watch都可以完成

  - watch能完成的功能，computed不一定能完成，例如：watch可以进行异步操作

  - ```html
    <div id="root">
        姓：<input type="text" v-model="firstName"> <br><br>
        名：<input type="text" v-model="lastName"> <br><br>
        全名：<span>{{fullName}}</span><br><br>
    </div>
    
    <script>
        const vm = new Vue({
            el: "#root",
            data:{
                firstName: "张",
                lastName:"三",
                fullName:"张-三"
            },
            computed: {},
            watch: {
                firstName(val){
                    setTimeout(() => {
                        this.fullName=val+"-"+this.lastName
                    },1000)
                },
                lastName(val) {
                    setTimeout(() => {
                        this.fullName=this.firstName+"-"+val;
                    },1000)
                }
            }
        })
    </script>
    ```

    

- 两个重要的小原则

  - 所被Vue管理的函数，最好写成普通函数，这样this的指向才是vm或组件实例对象
  - 所有不被Vue所管理的函数（定时器的回调函数、ajax的回调函数等、Promise的回调函数），最好写成箭头函数，这样this的指向才是vm或组件实例对象

    

### 2.10.绑定样式

- 绑定样式

  - class样式
    - :class="xxx"：xxx可以是字符串、对象、数组
    - 字符串写法适用于：类名不确定，要动态获取
    - 对象写法适用于：要绑定多个样式，个数不确定，名字也不确定
    - 数组写法适用于：要绑定多个样式，个数确定，名字也确定，但不确定用不用
  - style样式
    - :style="{fontSize: xxx}"其中xxx是动态值
    - :style="[a,b]"其中a、b是样式对象

- ```html
  <div id="root">
      <!-- 绑定class样式--字符串写法，适用于：样式的类名不确定，需要动态指定 -->
      <div class="basic" :class="mood" @click="changeMood">{{name}}</div> <br/><br/>
      <!-- 绑定class样式--数组写法，适用于：要绑定的样式个数不确定、名字也不确定 -->
      <div class="basic" :class="classArr">{{name}}</div> <br/><br/>
      <!-- 绑定class样式--对象写法，适用于：要绑定的样式个数确定、名字也确定，但要动态决定用不用 -->
      <div class="basic" :class="classObj">{{name}}</div> <br/><br/>
  
      <!-- 绑定style样式--对象写法 -->
      <div class="basic" :style="styleObj">{{name}}</div> <br/><br/>
      <!-- 绑定style样式--数组写法 -->
      <div class="basic" :style="styleArr">{{name}}</div>
  </div>
  
  <script>
      const vm = new Vue({
          el: "#root",
          data:{
              name: 'JacobSu',
              mood:"normal",
              classArr:['style1','style2','style3'],
              classObj:{
                  style1:false,
                  style2:false,
              },
              styleObj1:{
                  fontSize: '40px',
                  color:'red',
              },
              styleArr:[
                  {
                      fontSize: '40px',
                      color:'blue',
                  },
                  {
                      backgroundColor:'gray'
                  }
              ]
          },
          methods: {
              changeMood(){
                  const arr=['happy','sad','normal']
                  const index=Math.floor(Math.random()*3)
                  console.log(index);
                  this.mood=arr[index]
              }
          }
      })
  </script>
  ```



### 2.11.条件渲染

- 条件渲染

  - v-if
    - 写法
      - v-if="表达式" 
      - v-else-if="表达式"
      - v-else
    - 适用于：切换频率较低的场景
    - 特点：不展示的DOM元素直接被移除
    - 注意：v-if可以和v-else-if、v-else一起使用，但要求结构不能被“打断”
  - v-show
    - 写法：v-show="表达式"
    - 适用于：切换频率较高的场景
    - 特点：不展示的DOM元素未被移除，仅仅是使用样式隐藏掉
  - 备注
    - 使用v-if的时，元素可能无法获取到，而使用v-show一定可以获取到
    - v-if可以和template标签一起使用，而v-show不行

- ```html
  <div id="root">
      <!-- 使用v-show做条件渲染 -->
      <h1 v-show="false">{{name}}</h1>
      <h1 v-show="1 === 1">{{name}}</h1>
  
      <!-- 使用v-if做条件渲染 -->
      <h1 v-if="false">{{name}}</h1>
      <h1 v-if="1 === 1">{{name}}</h1>
  
      <h1>当前的n值是:{{n}}</h1>
      <button @click="n++">点我n+1</button>
      <!-- v-show实现 -->
      <div v-show="n === 1">Angular<hr></div>
      <div v-show="n === 2">React<hr></div>
      <div v-show="n === 3">Vue<hr></div>
  
      <!-- v-if实现 -->
      <div v-if="n === 1">Angular<hr></div>
      <div v-if="n === 2">React<hr></div>
      <div v-if="n === 3">Vue<hr></div>
  
      <!-- v-else和v-else-if -->
      <div v-if="n === 1">Angular<hr></div>
      <div v-else-if="n === 2">React<hr></div>
      <div v-else-if="n === 3">Vue<hr></div>
      <div v-else>Else<hr></div>
  
      <!-- v-if与template的配合使用 -->
      <template v-if="n>3">
          <h1>你好</h1>
          <h1>{{name}}</h1>
      </template>
  </div>
  
  <script>
      const vm = new Vue({
          el: "#root",
          data:{
              name: 'JacobSu',
              n:1,
          },
      })
  </script>
  ```

    

### 2.12.列表渲染

#### 2.12.1.基本列表

- v-for指令

  - 用于展示列表数据

  - 语法：v-for="(item, index) in xxx" :key="yyy"

  - 可遍历：数组、对象、字符串（用的很少）、指定次数（用的很少）

  - ```html
    <div id="root">
        <h2>人员列表</h2>
        <!-- 遍历数组 -->
        <ul>
            <li v-for="(p,index) in persons" :key="index">
                {{p.name}}-{{p.age}}
            </li>
        </ul>
        <!-- 遍历对象 -->
        <h2>汽车信息</h2>
        <ul>
            <li v-for="(val,k) in car" :key="k">
                {{k}}: {{val}}
            </li>
        </ul>
        <!-- 遍历字符串 -->
        <h2>测试遍历字符串</h2>
        <ul>
            <li v-for="(char,index) in str" :key="index">
                {{index}}: {{char}}
            </li>
        </ul>
        <!-- 遍历指定次数 -->
        <h2>测试遍历字符串</h2>
        <ul>
            <li v-for="(number,index) in 5" :key="index">
                {{index}}: {{number}}
            </li>
        </ul>
    </div>
    
    <script>
        const vm = new Vue({
            el: "#root",
            data:{
                persons:[
                    {id:001,name:'张三',age:18},
                    {id:002,name:'李四',age:19},
                    {id:003,name:'王五',age:20}
                ],
                car:{
                    name: 'A8',
                    price: '100000$',
                    color: 'black'
                },
                str:'hello'
            }
        })
    </script>
    ```



#### 2.12.2.key的原理

- key的原理

  - 虚拟DOM中key的作用

    - key是虚拟DOM对象的标识，当数据发生变化时，Vue会根据【新数据】生成【新的虚拟DOM】,随后Vue进行【新虚拟DOM】与【旧虚拟DOM】的差异比较，比较规则如下

  - 对比规则

    - 旧虚拟DOM中找到了与新虚拟DOM相同的key
      - 若虚拟DOM中内容没变, 直接使用之前的真实DOM
      - 若虚拟DOM中内容变了, 则生成新的真实DOM，随后替换掉页面中之前的真实DOM
    - 旧虚拟DOM中未找到与新虚拟DOM相同的key
      - 创建新的真实DOM，随后渲染到到页面

  - 用index作为key可能会引发的问题

    - 若对数据进行：逆序添加、逆序删除等破坏顺序操作
        - 会产生没有必要的真实DOM更新 ==> 界面效果没问题, 但效率低

    - 如果结构中还包含输入类的DOM
        - 会产生错误DOM更新 ==> 界面有问题
    - ![](https://image.jslog.net/online/a-11/2024/05/26/19-27-32-1716722852751-2.png)

  - 开发中如何选择key

      - 最好使用每条数据的唯一标识作为key, 比如id、手机号、身份证号、学号等唯一值
      - 如果不存在对数据的逆序添加、逆序删除等破坏顺序操作，仅用于渲染列表用于展示，使用index作为key是没有问题的
      - ![](https://image.jslog.net/online/a-11/2024/05/26/19-27-32-1716722852949-3.png)

  - ```html
      <div id="root">
          <h2>人员列表</h2>
          <button @click.once="add">添加人员信息</button>
          <ul>
              <li v-for="(p,index) in persons" :key="p.id">
                  {{p.name}}-{{p.age}}
                  <input type="text">
              </li>
          </ul>
      
      </div>
      
      <script>
          const vm = new Vue({
              el: "#root",
              data:{
                  persons:[
                      {id:001,name:'张三',age:18},
                      {id:002,name:'李四',age:19},
                      {id:003,name:'王五',age:20}
                  ],
              },
              methods: {
                  add() {
                      const p={id:'004',name:'赵六',age:40}
                      this.persons.unshift(p)
                  }
              }
          })
      </script>
      ```



#### 2.12.3.列表过滤

- 列表过滤

  - 监视属性实现

    - ```html
      <div id="root">
          <h2>人员列表</h2>
          <input type="text" placeholder="请输入名字" v-model="keyWord">
          <ul>
              <li v-for="(p,index) in filPersons" :key="p.id">
                  {{p.name}}-{{p.age}}-{{p.sex}}
              </li>
          </ul>
      
      </div>
      
      <script>
          //用监视属性实现
          const vm = new Vue({
              el: "#root",
              data:{
                  keyWord:'',
                  persons:[
                      {id:001,name:'马冬梅',age:19,sex:'女'},
                      {id:002,name:'周冬雨',age:20,sex:'女'},
                      {id:003,name:'周杰伦',age:21,sex:'男'},
                      {id:004,name:'温兆伦',age:22,sex:'男'}
                  ],
                  filPersons:[]
              },
              watch:{
                  keyWord:{
                      immediate:true,
                      handler(val){
                          this.filPersons=this.persons.filter((p)=>{
                              return p.name.indexOf(val)!==-1
                          })
                      }
                  }
              }
          })
      </script>
      ```

  - 计算属性实现

    - ```html
      <div id="root">
          <h2>人员列表</h2>
          <input type="text" placeholder="请输入名字" v-model="keyWord">
          <ul>
              <li v-for="(p,index) in filPersons" :key="p.id">
                  {{p.name}}-{{p.age}}-{{p.sex}}
              </li>
          </ul>
      
      </div>
      
      <script>
          //用计算属性实现
          const vm = new Vue({
              el: "#root",
              data:{
                  keyWord:'',
                  persons:[
                      {id:001,name:'马冬梅',age:19,sex:'女'},
                      {id:002,name:'周冬雨',age:20,sex:'女'},
                      {id:003,name:'周杰伦',age:21,sex:'男'},
                      {id:004,name:'温兆伦',age:22,sex:'男'}
                  ]
              },
              computed:{
                  filPersons(){
                      return this.persons.filter((p)=>{
                          return p.name.indexOf(this.keyWord)!==-1
                      })
                  }
              }
          })
      </script>
      ```



#### 2.12.4.列表排序

- 列表排序

  - ```html
    <div id="root">
        <h2>人员列表</h2>
        <input type="text" placeholder="请输入名字" v-model="keyWord">
        <button @click="sortType=0">原顺序</button>
        <button @click="sortType=1">年龄降序</button>
        <button @click="sortType=2">年龄升序</button>
        <ul>
            <li v-for="(p,index) in filPersons" :key="p.id">
                {{p.name}}-{{p.age}}-{{p.sex}}
            </li>
        </ul>
    </div>
    
    <script>
        const vm = new Vue({
            el: "#root",
            data:{
                keyWord:'',
                sortType: 0,//0原顺序，1降序，2升序
                persons:[
                    {id:001,name:'马冬梅',age:30,sex:'女'},
                    {id:002,name:'周冬雨',age:20,sex:'女'},
                    {id:003,name:'周杰伦',age:28,sex:'男'},
                    {id:004,name:'温兆伦',age:40,sex:'男'}
                ]
            },
            computed:{
                filPersons(){
                    const arr = this.persons.filter((p)=>{
                        return p.name.indexOf(this.keyWord)!==-1
                    })
                    //判断是否排序
                    if (this.sortType) {
                        arr.sort((p1,p2)=>{
                            return this.sortType===1?p2.age-p1.age:p1.age-p2.age
                        })
                    }
                    return arr
                }
            },
        })
    </script>
    ```

    

### 2.13.数据监测

#### 2.13.1.更新时的问题

- ```html
  <div id="root">
      <h2>人员列表</h2>
      <button @click="updateMei">更新马冬梅的信息</button>
      <ul>
          <li v-for="(p,index) in persons" :key="p.id">
              {{p.name}}-{{p.age}}-{{p.sex}}
          </li>
      </ul>
  </div>
  
  <script>
      const vm = new Vue({
          el: "#root",
          data:{
              persons:[
                  {id:001,name:'马冬梅',age:30,sex:'女'},
                  {id:002,name:'周冬雨',age:20,sex:'女'},
                  {id:003,name:'周杰伦',age:28,sex:'男'},
                  {id:004,name:'温兆伦',age:40,sex:'男'}
              ]
          },
          methods: {
              updateMei(){
                  // this.persons[0].name = '马老师' //奏效
                  // this.persons[0].age = 50 //奏效
                  // this.persons[0].sex = '男' //奏效
                  // this.persons[0] = {id:'001',name:'马老师',age:50,sex:'男'} //不奏效，但数据已经更改，Vue并没有检测到
                  this.persons.splice(0,1,{id:'001',name:'马老师',age:50,sex:'男'}) //奏效
              }
          }
      })
  </script>
  ```



#### 2.13.2.Vue数据监测原理

- Vue数据监测原理

  - vue会监视data中所有层次的数据
  - 如何监测对象中的数据
    - 通过setter实现监视，且要在new Vue时就传入要监测的数据
      - 对象中后追加的属性，Vue默认不做响应式处理
      - 如需给后添加的属性做响应式，请使用如下API
        - Vue.set(target，propertyName/index，value) 或 
        - vm.$set(target，propertyName/index，value)
  - 如何监测数组中的数据
    -  通过包裹数组更新元素的方法实现，本质就是做了两件事
      - 调用原生对应的方法对数组进行更新
      - 重新解析模板，进而更新页面
  - 在Vue修改数组中的某个元素一定要用如下方法
    - 使用这些API:push()、pop()、shift()、unshift()、splice()、sort()、reverse()
    - Vue.set() 或 vm.$set()
  - 特别注意
    - Vue.set() 和 vm.$set() 不能给vm 或 vm的根数据对象添加属性
    - 数据劫持：指的是在访问或者修改对象的某个属性时，通过一段代码拦截这个行为，进行额外的操作或者修改返回结果

- ```html
  <div id="root">
      <h1>学生信息</h1>
      <button @click="student.age++">年龄+1岁</button> <br/>
      <button @click="addSex">添加性别属性，默认值：男</button> <br/>
      <button @click="student.sex='未知'">修改性别</button> <br/>
      <button @click="addFriend">在列表首位添加一个朋友</button> <br/>
      <button @click="updateFirstFriendName">修改第一个朋友的名字为：张三</button> <br/>
      <button @click="addHobby">添加一个爱好</button> <br/>
      <button @click="updateHobby">修改第一个爱好为：开车</button> <br/>
      <button @click="removeSmoke">过滤掉爱好中的抽烟</button> <br/>
  
      <h3>{{student.name}}-{{student.age}}</h3>
      <h3 v-if="student.sex">性别：{{student.sex}}</h3>
      <h3>爱好：</h3>
      <ul>
          <li v-for="(h,index) in student.hobby" :key="index">
              {{h}}
          </li>
      </ul>
      <h3>朋友们：</h3>
      <ul>
          <li v-for="(f,index) in student.friends" :key="index">
              {{f.name}}--{{f.age}}
          </li>
      </ul>
  </div>
  
  <script>
      const vm = new Vue({
          el: "#root",
          data: {
              student: {
                  name: 'tom',
                  age: 18,
                  hobby: ['抽烟', '喝酒', '烫头'],
                  friends: [
                      { name: 'jerry', age: 35 },
                      { name: 'tony', age: 36 }
                  ]
              }
          },
          methods: {
              addSex(){
                  // Vue.set(this.student,'sex','男')
                  this.$set(this.student,'sex','男')
              },
              addFriend() {
                  this.student.friends.unshift({name: 'jack',age:70})
              },
              updateFirstFriendName(){
                  this.student.friends[0].name='张三'
              },
              addHobby(){
                  this.student.hobby.push('学习')
              },
              updateHobby(){
                  // this.student.hobby.splice(0,1,'开车')
                  // Vue.set(this.student.hobby,0,'开车')
                  this.$set(this.student.hobby,0,'开车')
              },
              removeSmoke(){
                  this.student.hobby = this.student.hobby.filter((h)=>{
                      return h !== '抽烟'
                  })                
              }
          }
      })
  </script>
  ```

    

### 2.14.收集表单数据

- 收集表单数据

  - 若：\<input type="text"/\>，则v-model收集的是value值，用户输入的就是value值
  - 若：\<input type="radio"/\>，则v-model收集的是value值，且要给标签配置value值
  - 若：\<input type="checkbox"/\>
    - 没有配置input的value属性，那么收集的就是checked（勾选 or 未勾选，是布尔值）
    - 已配置input的value属性
      - v-model的初始值是非数组，那么收集的就是checked（勾选 or 未勾选，是布尔值）
      - v-model的初始值是数组，那么收集的的就是value组成的数组
  - 备注
    - v-model的三个修饰符
      - lazy：失去焦点再收集数据
      - number：输入字符串转为有效的数字
      - trim：输入首尾空格过滤

- ```html
  <div id="root">
      <form @submit.prevent="demo">
          账号：<input type="text" v-model.trim="userInfo.account"><br><br>
          密码：<input type="password" v-model="userInfo.password"><br><br>
          年龄：<input type="number" v-model.number="userInfo.age"><br><br>
          性别：
          男<input type="radio" name="sex" value="male" v-model="userInfo.sex">
          女<input type="radio" name="sex" value="female" v-model="userInfo.sex"><br><br>
          爱好：
          学习<input type="checkbox" value="study" v-model="userInfo.hobby">
          游戏<input type="checkbox" value="game" v-model="userInfo.hobby">
          吃饭<input type="checkbox" value="eat" v-model="userInfo.hobby"><br><br>
          所属校区
          <select v-model="userInfo.city">
              <option value="">请选择校区</option>
              <option value="beijing">北京</option>
              <option value="shanghai">上海</option>
              <option value="shenzhen">深圳</option>
              <option value="wuhan">武汉</option>
          </select><br><br>
          其他信息：
          <textarea v-model.lazy="userInfo.other"></textarea><br><br>
          <input type="checkbox" v-model="userInfo.agree">阅读并接受<a href="http://bilibili.com">《用户协议》</a><br><br>
          <button>提交</button>
      </form>
  </div>
  
  <script>
      const vm = new Vue({
          el: "#root",
          data:{
              userInfo:{
                  account:'',
                  password:'',
                  age:18,
                  sex:'female',
                  hobby:[],
                  city:'beijing',
                  other:'',
                  agree:''
              }
          },
          methods: {
              demo() {
                  console.log(JSON.stringify(this.userInfo));
              }
          }
      })
  </script>
  ```



### 2.15.过滤器

- 过滤器

  - 定义：对要显示的数据进行特定格式化后再显示（适用于一些简单逻辑的处理）
  - 语法
    - 注册过滤器：Vue.filter(name,callback) 或 new Vue{filters:{}}
    - 使用过滤器：{{ xxx | 过滤器名}}  或  v-bind:属性 = "xxx | 过滤器名"
  - 备注
    - 过滤器也可以接收额外参数、多个过滤器也可以串联
    - 并没有改变原本的数据, 是产生新的对应的数据

- ```html
  <div id="root1">
      <h2>显示格式化后的时间</h2>
      <!-- 计算属性实现 -->
      <h3>现在是：{{fmtTime}}</h3>
      <!-- methods实现 -->
      <h3>现在是：{{getFmtTime()}}</h3>
      <!-- 过滤器实现 -->
      <h3>现在是：{{time | timeFormater}}</h3>
      <!-- 过滤器实现（传参） -->
      <h3>现在是：{{time | timeFormater('YYYY-MM-DD') | mySlice}}</h3>
      <!-- v-bind使用过滤器(使用很少) -->
      <h3 :x="msg | mySlice">你好，苏</h3>
  </div>
  
  <div id="root2">
      <h2>{{msg | mySlice}}</h2>
  </div>
  
  <script>
      //全局过滤器-应放在对象前
      Vue.filter('mySlice',function(value){
          return value.slice(0,4)
      })
      new Vue({
          el: "#root1",
          data:{
              time: 1673872864934,//事件戳
              msg: 'Hello,Su'
          },
          computed: {
              fmtTime(){
                  //第三方库dayjs.min.js
                  return dayjs(this.time).format('YYYY年MM月DD日 HH:mm:ss')
              }
          },
          methods: {
              getFmtTime(){
                  return dayjs(this.time).format('YYYY年MM月DD日 HH:mm:ss')
              }
          },
          //局部过滤器
          filters:{
              timeFormater(value,str='YYYY年MM月DD日 HH:mm:ss'){
                  return dayjs(value).format(str)
              }
          }
      })
  
      new Vue({
          el: "#root2",
          data:{
              msg:"Hello,JacobSu"
          }
      })
  
  </script>
  ```



### 2.16.内置指令

#### 2.16.1.内置指令回顾

- 内置指令回顾
  - v-bind：单向绑定解析表达式，可简写为 :xxx
  - v-model：双向数据绑定
  - v-for：遍历数组/对象/字符串
  - v-on：绑定事件监听, 可简写为@
  - v-if：条件渲染（动态控制节点是否存存在）
  - v-else：条件渲染（动态控制节点是否存存在）
  - v-show：条件渲染 (动态控制节点是否展示)

#### 2.16.2.v-text指令

- v-text

  - 作用：向其所在的节点中渲染文本内容，不解析html格式
  - 与插值语法的区别：v-text会替换掉节点中的内容，{{xxx}}则不会

- ```html
  <div id="root">
      <div>{{name}}</div>
      <div v-text="name"></div>
  </div>
  
  <script>
      const vm = new Vue({
          el: "#root",
          data:{
              name: 'JacobSu'
          },
      })
  </script>
  ```

    

#### 2.16.3.v-html指令

- v-html

  - 作用：向指定节点中渲染包含html结构的内容
  - 与插值语法的区别
    - v-html会替换掉节点中所有的内容，{{xxx}}则不会
    - v-html可以识别html结构
  - 严重注意：v-html有安全性问题
    - 在网站上动态渲染任意HTML是非常危险的，容易导致XSS攻击
    - 一定要在可信的内容上使用v-html，永不要用在用户提交的内容上

- ```html
  <div id="root">
      <div v-text="str"></div>
      <div v-html="str"></div>
      <div v-html="strA"></div>
  </div>
  
  <script>
      const vm = new Vue({
          el: "#root",
          data:{
              str:'<h2>Hello</h2>',
              strA:'<a href=javascript:location.href="http://www.baidu.com?"+document.cookie>快来！</a>',
          },
      })
  </script>
  ```

    

#### 2.16.4.v-cloak指令

- v-cloak（没有值）

  - 本质是一个特殊属性，Vue实例创建完毕并接管容器后，会删掉v-cloak属性
  - 使用css配合v-cloak可以解决网速慢时页面展示出{{xxx}}的问题

- ```html
  <style>
      [v-cloak]{
          display:none;
      }
  </style>
  
  <div id="root">
      <h2 v-cloak>{{name}}</h2>
      <!-- 引入Vue -->
      <script src="../js/vue.js"></script>
  </div>
  
  <script>
      const vm = new Vue({
          el: "#root",
          data:{
              name: 'JacobSu'
          },
      })
  </script>
  ```

  

#### 2.16.5.v-once指令

- v-once（没有值）

  - v-once所在节点在初次动态渲染后，就视为静态内容了
  - 以后数据的改变不会引起v-once所在结构的更新，可以用于优化性能

- ```html
  <div id="root">
      <h2 v-once>初始化的n值是:{{n}}</h2>
      <h2>当前的n值是：{{n}}</h2>
      <button @click="n++">点我n++</button>
  </div>
  
  <script>
      const vm = new Vue({
          el: "#root",
          data:{
              n: 1
          },
      })
  </script>
  ```

  

#### 2.16.6.v-pre指令

- v-pre（没有值）

  - 跳过其所在节点的编译过程
  - 可利用它跳过：没有使用指令语法、没有使用插值语法的节点，会加快编译

- ```html
  <div id="root">
      <h2 v-pre>Vue很简单~</h2>
      <h2>当前的n值是：{{n}}</h2>
      <button @click="n++">点我n++</button>
  </div>
  
  <script>
      const vm = new Vue({
          el: "#root",
          data:{
              n: 1
          },
      })
  </script>
  ```

  

### 2.17.自定义指令

- 自定义指令

  - 定义语法

    - 局部指令

      - ```javascript
        new Vue({
            directives:{指令名:配置对象} 
        }) 
        ```

      - ```javascript
        new Vue({
        	directives{指令名:回调函数}
        }) 
        ```

    - 全局指令

      - ```javascript
        Vue.directive(指令名,配置对象)
        ```

      - ```javascript
        Vue.directive(指令名,回调函数)
        ```

  - 配置对象中常用的3个回调

    - bind：指令与元素成功绑定时调用
    - inserted：指令所在元素被插入页面时调用
    - update：指令所在模板结构被重新解析时调用

  - 备注

    - 指令定义时不加v-，但使用时要加v-
    - 指令名如果是多个单词，要使用kebab-case命名方式，不要用camelCase命名
- ```html
    <div id="root">
        <h2>当前的n值是：<span v-text="n"></span> </h2>
        <h2>乘10后的n值是：<span v-big="n"></span> </h2>
        <h2>乘10后的n值是：<span v-big-number="n"></span> </h2>
        <button @click="n++">点我n+1</button>
        <hr>
        <input type="text" v-fbind:value="n">
    </div>
    
    <script>
        //定义全局指令
        // Vue.directive('fbind',{
        // 	//指令与元素成功绑定时（一上来）
        // 	bind(element,binding){
        // 		element.value = binding.value
        // 	},
        // 	//指令所在元素被插入页面时
        // 	inserted(element,binding){
        // 		element.focus()
        // 	},
        // 	//指令所在的模板被重新解析时
        // 	update(element,binding){
        // 		element.value = binding.value
        // 	}
        // })
        new Vue({
            el: "#root",
            data: {
                n:1
            },
            //定义局部指令
            directives: {
                // 需求1：定义一个v-big指令，和v-text功能类似，但会把绑定的数值放大10倍
                big(element,binding) {
                    //big函数何时会被调用
                    // 1.指令与元素成功绑定时（一上来）
                    // 2.指令所在的模板被重新解析时
                    // console.log('big',this) //注意此处的this是window
                    element.innerText=binding.value*10
                },
                //'big-number':funcion(element,binding){}
                'big-number'(element,binding){
                    element.innerText=binding.value*10
                },
                // 需求2：定义一个v-fbind指令，和v-bind功能类似，但可以让其所绑定的input元素默认获取焦点
                fbind:{
                    //指令与元素成功绑定时（一上来）
                    bind(element,binding){
                        element.value = binding.value
                    },
                    //指令所在元素被插入页面时
                    inserted(element,binding){
                        element.focus()
                    },
                    //指令所在的模板被重新解析时
                    update(element,binding){
                        element.value = binding.value
                    }
                }
            }
        })
    </script>
    ```

    

### 2.18.生命周期

#### 2.18.1.引入生命周期

- 生命周期

  - 又名：生命周期回调函数、生命周期函数、生命周期钩子
  - 作用：Vue在关键时刻帮我们调用的一些特殊名称的函数
  - 生命周期函数的名字不可更改，但函数的具体内容是程序员根据需求编写的
  - 生命周期函数中的this指向是vm 或 组件实例对象

- ```html
  <div id="root">
      <h1 :style="{opacity}">Vue</h1>
  </div>
  
  <script>
      const vm = new Vue({
          el: "#root",
          data:{
              opacity:1
          },
          //Vue完成模板的解析并把初始的真实DOM元素放入页面后（挂载完毕）调用mounted
          mounted(){
              console.log('mounted',this) //此处的this是vm
              setInterval(() => {
                  this.opacity -= 0.01
                  if(this.opacity <= 0) this.opacity = 1
              },16)
          },
      })
  
      //通过外部定时器实现（不推荐）
      // setInterval(()=>{
      //     if (vm.opacity<=0) vm.opacity=1
      //     vm.opacity-=0.01
      // },16)
  </script>
  ```



#### 2.18.2.分析生命周期

- ![](https://image.jslog.net/online/a-11/2024/05/26/19-27-32-1716722852699-4.png)

- ```html
  <div id="root">
      <h2>当前的n值是：{{n}}</h2>
      <button @click="add">点我n+1</button>
      <button @click="bye">点我销毁vm</button>
  </div>
  
  <script>
      const vm=new Vue({
          el: "#root",
          data:{
              n:1
          },
          methods: {
              add(){
                  console.log('add')
                  this.n++
              },
              bye(){
                  console.log('bye')
                  this.$destroy()
              }
          },
          watch:{
              n(){
                  console.log('n变了')
              }
          },
          beforeCreate() {
              console.log('beforeCreate');
              // console.log(this);debugger;
          },
          created() {
              console.log('created');
              // console.log(this);debugger;
          },
          beforeMount() {
              console.log('beforeMount');
              // document.querySelector('h2').innerText='hh'
              // console.log(this);debugger;
          },
          mounted() {
              console.log('mounted');
              // document.querySelector('h2').innerText='hh' //不建议操作DOM
              // console.log(this);debugger;
          },
          beforeUpdate() {
              console.log('beforeUpdate');
              // console.log(this.n);
              // console.log(this);debugger;
          },
          updated() {
              console.log('updated');
              // console.log(this);debugger;
          },
          beforeDestroy() {
              console.log('beforeDestory');
              console.log(this.n);
          },
          destroyed() {
              console.log('destroyed');
              console.log(this.n);
          },
      })
  </script>
  ```

  

#### 2.18.3.生命周期总结

- 常用的生命周期钩子

  - mounted：发送ajax请求、启动定时器、绑定自定义事件、订阅消息等【初始化操作】
  - beforeDestroy：清除定时器、解绑自定义事件、取消订阅消息等【收尾工作】

- 关于销毁Vue实例

  - 销毁后借助Vue开发者工具看不到任何信息
  - 销毁后自定义事件会失效，但原生DOM事件依然有效
  - 一般不会在beforeDestroy操作数据，因为即便操作数据，也不会再触发更新流程了

- ```html
  <div id="root">
      <h1 :style="{opacity}">Vue</h1>
      <button @click="opacity=1">透明度设置为1</button>
      <button @click="stop">点我停止变换</button>
  </div>
  
  <script>
      const vm = new Vue({
          el: "#root",
          data:{
              opacity:1
          },
          methods: {
              stop(){
                  this.$destroy()
              }
          },
          mounted(){
              console.log('mounted',this)
              this.timer = setInterval(() => {
                  console.log('setInterval')
                  this.opacity -= 0.01
                  if(this.opacity <= 0) this.opacity = 1
              },16)
          },
          beforeDestroy() {
              clearInterval(this.timer)
              console.log('vm即将驾鹤西游了')
          },
      })
  </script>
  ```

    

## 3.Vue组件化编程

### 3.1.组件

- 传统方式编程
  - 存在的问题
    - 依赖关系混乱，不好维护
    - 代码复用率不高
- 组件方式编程
  - 组件的定义：实现应用中局部功能代码和资源的集合
  - 作用: 复用编码，简化项目编码，提高运行效率

- 模块化
  - 当应用中的js都以模块来编写的，那这个应用就是一个模块化的应用
- 组件化
  - 当应用中的功能都是多组件的方式来编写的, 那这个应用就是一个组件化的应用



### 3.2.非单文件组件

#### 3.2.1.基本使用

- 基本使用

  - Vue中使用组件的三大步骤
    - 定义组件(创建组件)
    - 注册组件
    - 使用组件(写组件标签)
  - 定义组件
    - 使用Vue.extend(options)创建，其中options和new Vue(options)时传入的那个options几乎一样，但也有点区别
    - 区别如下
      - el不要写，最终所有的组件都要经过一个vm的管理，由vm中的el决定服务哪个容器
      - data必须写成函数，避免组件被复用时，数据存在引用关系
    - 备注：使用template可以配置组件结构
  - 注册组件
    - 局部注册：靠new Vue的时候传入components选项
    - 全局注册：靠Vue.component('组件名',组件)

  - 编写组件标签：\<school\>\</school\>

- ```html
  <div id="root1">
      <!-- 3.编写组件标签 -->
      <hello></hello>
      <!-- 3.编写组件标签 -->
      <school></school>
      <!-- 3.编写组件标签 -->
      <student></student>
  </div>
  
  <div id="root2">
      <!-- 3.编写组件标签 -->
      <hello></hello>
  </div>
  <script>
  
      //1.创建school组件
      const school=Vue.extend({
          template: `
              <div>
                  <h2>学校名称：{{schoolName}}</h2>
                  <h2>学校地址：{{address}}</h2>
                  <button @click="showName">点我提示学校名</button>
                  <hr>
              </div>
          `,
          data(){
              return {
                  schoolName: "AHAU",
                  address: "HEFEI"
              }
          },
          methods: {
              showName(){
                  alert(this.schoolName)
              }
          }
      })
      //1.创建student组件
      const student=Vue.extend({
          template: `
              <div>
                  <h2>学生姓名：{{studentName}}</h2>
                  <h2>学生年龄：{{age}}</h2>
                  <hr>
              </div>
          `,
          data(){
              return {
                  studentName: 'JacobSu',
                  age:23
              }
          }
      })
      //1.创建hello组件
      const hello = Vue.extend({
          template:`
              <div>	
                  <h2>你好啊！{{name}}</h2>
                  <hr>
              </div>
          `,
          data(){
              return {
                  name:'Tom'
              }
          }
      })
      //2.全局注册组件
      Vue.component('hello',hello)
  
  
      //创建vm
      new Vue({
          el: "#root1",
          //2.注册组件（局部注册）
          components:{
              school,
              student
          }
      })
  
      new Vue({
          el: "#root2"
      })
  </script>
  ```



#### 3.2.2.注意事项

- 几个注意点

  - 关于组件名
    - 一个单词组成
      - 第一种写法(首字母小写)：school
      - 第二种写法(首字母大写)：School
    - 多个单词组成
      - 第一种写法(kebab-case命名)：my-school
      - 第二种写法(CamelCase命名)：MySchool (需要Vue脚手架支持)
    - 备注
      - 组件名尽可能回避HTML中已有的元素名称，例如：h2、H2都不行
      - 可以使用name配置项指定组件在开发者工具中呈现的名字
  - 关于组件标签
    - 第一种写法：\<school\>\</school\>
    - 第二种写法：\<school/\>
    - 备注：不用使用脚手架时，\<school/\>会导致后续组件不能渲染
  - 一个简写方式
    - `const school = Vue.extend(options) `可简写为：`const school = options`

- ```html
  <div id="root">
      <h1>{{msg}}</h1>
      <school></school>
  </div>
  
  <script>
      const school={
          name: 'AHAU',
          template: `
              <div>
                  <h2>学校名称：{{schoolName}}</h2>
                  <h2>学校地址：{{address}}</h2>
              </div>
          `,
          data(){
              return {
                  schoolName: "AHAU",
                  address: "HEFEI"
              }
          },
      }
  
      new Vue({
          el: "#root",
          data:{
              msg:'欢迎学习Vue'
          },
          components:{
              school:school
          }
      })
  
  </script>
  ```

    

#### 3.2.3.组建的嵌套

- ```html
  <div id="root"></div>
  
  <script>
      //student组件
      const student=Vue.extend({
          template: `
              <div>
                  <h2>学生姓名：{{studentName}}</h2>
                  <h2>学生年龄：{{age}}</h2>
              </div>
          `,
          data(){
              return {
                  studentName: 'JacobSu',
                  age:23
              }
          }
      })
      //school组件
      const school=Vue.extend({
          template: `
              <div>
                  <h2>学校名称：{{schoolName}}</h2>
                  <h2>学校地址：{{address}}</h2>
                  <student></student>
              </div>
          `,
          data(){
              return {
                  schoolName: "AHAU",
                  address: "HEFEI"
              }
          },
          //注册组件（局部）
          components: {
              student
          }
      })
      //hello组件
      const hello = Vue.extend({
          template:`
              <div>	
                  <h2>你好啊！{{name}}</h2>
              </div>
          `,
          data(){
              return {
                  name:'Tom'
              }
          }
      })
      //app组件
      const app=Vue.extend({
          template:`
              <div>
                  <hello></hello>
                  <school></school>
              </div>
          `,
          //注册组件（局部）
          components: {
              school,
              hello
          }
      })
  
      new Vue({
          el: "#root",
          template:'<app></app>',
          //注册组件（局部）
          components:{
              app
          }
      })
  
  </script>
  ```



#### 3.2.4.VueComponent构造函数

- VueComponent

  - school组件本质是一个名为VueComponent的构造函数，且不是程序员定义的，是Vue.extend生成的
  - 我们只需要写\<school/\>或\<school\>\</school\>，Vue解析时会帮我们创建school组件的实例对象，即Vue帮我们执行的：new VueComponent(options)
  - 特别注意：每次调用Vue.extend，返回的都是一个全新的VueComponent
  - 关于this指向
    - 组件配置中
      - data函数、methods中的函数、watch中的函数、computed中的函数
      - 它们的this均是【VueComponent实例对象】
    - new Vue(options)配置中
      - data函数、methods中的函数、watch中的函数、computed中的函数
      - 它们的this均是【Vue实例对象】

  - VueComponent的实例对象，以后简称vc（也可称之为：组件实例对象）
  - Vue的实例对象，以后简称vm



#### 3.2.5.内置关系

- 内置关系

  - VueComponent.prototype.\_\_proto\_\_ === Vue.prototype
  - 让组件实例对象（vc）可以访问到 Vue原型上的属性、方法
  - ![](https://image.jslog.net/online/a-11/2024/05/26/19-27-32-1716722852925-5.png)

- ```html
  <div id="root">
      <school></school>
  </div>
  
  <script>
      Vue.prototype.x = 99
      const school=Vue.extend({
          template: `
              <div>
                  <h2>学校名称：{{schoolName}}</h2>
                  <h2>学校地址：{{address}}</h2>
                  <button @click="showX">点我输出x</button>
              </div>
          `,
          data(){
              return {
                  schoolName: "AHAU",
                  address: "HEFEI"
              }
          },
          methods: {
              showX(){
                  console.log(this.x)
              }
          }
      })
  
      new Vue({
          el: "#root",
          components:{
              school
          }
      })
      console.log(school.prototype.__proto__ === Vue.prototype);
  </script>
  ```

    

### 3.3.单文件组件

- index.html

  - ```html
    <!DOCTYPE html>
    <html>
    	<head>
    		<meta charset="UTF-8" />
    		<title>单文件组件的语法</title>
    	</head>
    	<body>
    		<div id="root"></div>
    		<script type="text/javascript" src="../js/vue.js"></script>
    		<script type="text/javascript" src="./main.js"></script>
    	</body>
    </html>
    ```

- main.js

  - ```javascript
    import App from 'App.vue'
    
    new Vue({
    	el:'#root',
    	template:`<App></App>`,
    	components:{App},
    })
    ```

- App.vue

  - ```html
    <template>
    	<div>
    		<School></School>
    		<Student></Student>
    	</div>
    </template>
    
    <script>
    	//引入组件
    	import School from 'School.vue'
    	import Student from 'Student.vue'
    
    	export default {
    		name:'App',
    		components:{
    			School,
    			Student
    		}
    	}
    </script>
    ```

- School.vue

  - ```html
    <template>
        <!-- 组件的结构 -->
        <div class="demo">
            <h2>学校名称：{{name}}</h2>
            <h2>学校地址：{{address}}</h2>
            <button @click="showName">点我提示学校名</button>
        </div>
    </template>
    
    <script>
        //组件交互相关的代码（数据、方法等等）
        export default {
    		name:'School',
    		data(){
    			return {
    				name:'AHAU',
    				address:'HEFEI'
    			}
    		},
    		methods: {
    			showName(){
    				alert(this.name)
    			}
    		},
    	}
    </script>
    
    <style>
        /* 组建的样式 */
        .demo{
            background-color:#bfa;
        }
    </style>
    ```

- Student.vue

  - ```html
    <template>
      <div>
        <h2>学生姓名：{{ name }}</h2>
        <h2>学生年龄：{{ age }}</h2>
      </div>
    </template>
    
    <script>
    	export default {
    		name: "Student",
    		data() {
    			return {
    				name: "JacobSu",
    				age: 23,
    			};
    		},
    	};
    </script>
    ```

    

## 4.Vue脚手架

### 4.1.初始化Vue脚手架

- 全局安装（仅第一次执行）：`npm install -g @vue/cli `
- 创建项目：`vue create xxx`
- 启动项目：`npm run serve`

### 4.2.脚手架文件结构

- 脚手架结构

  - ```powershell
    ├── node_modules: 包的文件夹
    ├── public
    │   ├── favicon.ico: 页签图标
    │   └── index.html: 主页面
    ├── src
    │   ├── assets: 存放静态资源
    │   │   └── logo.png
    │   │── component: 存放组件
    │   │   └── HelloWorld.vue
    │   │── App.vue: 汇总所有组件
    │   │── main.js: 入口文件
    ├── .gitignore: git版本管制忽略的配置
    ├── babel.config.js: babel的配置文件
    ├── jsconfig.json: 指定JS服务提供的功能
    ├── package.json: 应用包配置文件
    ├── package-lock.json: 包版本控制文件 
    ├── README.md: 应用描述文件
    ├── vue.config.js: 可选的配置文件
    ```

- main.js

  - ```javascript
    // 该文件是整个项目的入口文件
    
    //引入Vue
    import Vue from 'vue'
    //引入App组件，它是所有文件的父组件
    import App from './App.vue'
    //关闭Vue生产提示
    Vue.config.productionTip = false
    
    //创建Vue实例对象-vm
    new Vue({
      el: '#app',
      //将App组件放入容器中
      render: h => h(App),
    })
    ```

- App.vue

  - ```html
    <template>
    	<div>
        	<img src="./assets/logo.png">
    		<School></School>
    		<Student></Student>
    	</div>
    </template>
    
    <script>
    	//引入组件
    	import School from './components/School'
    	import Student from './components/Student'
    
    	export default {
    		name:'App',
    		components:{
    			School,
    			Student
    		}
    	}
    </script>
    ```

- component/School.vue

  - ```html
    <template>
        <!-- 组件的结构 -->
        <div class="demo">
            <h2>学校名称：{{name}}</h2>
            <h2>学校地址：{{address}}</h2>
            <button @click="showName">点我提示学校名</button>
        </div>
    </template>
    
    <script>
        //组件交互相关的代码（数据、方法等等）
        export default {
    		name:'School',
    		data(){
    			return {
    				name:'AHAU',
    				address:'HEFEI'
    			}
    		},
    		methods: {
    			showName(){
    				alert(this.name)
    			}
    		},
    	}
    </script>
    
    <style>
        /* 组建的样式 */
        .demo{
            background-color:#bfa;
        }
    </style>
    ```

- component/Student.vue

  - ```html
    <template>
      <div>
        <h2>学生姓名：{{ name }}</h2>
        <h2>学生年龄：{{ age }}</h2>
      </div>
    </template>
    
    <script>
    	export default {
    		name: "Student",
    		data() {
    			return {
    				name: "JacobSu",
    				age: 23,
    			};
    		},
    	};
    </script>
    ```

- public/index.html

  - ```html
    <!DOCTYPE html>
    <html lang="">
      <head>
        <meta charset="utf-8">
        <!-- 针对IE浏览器的一个特殊配置,让IE浏览器以最高的渲染级别渲染页面 -->
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <!-- 开启移动端的理想视口 -->
        <meta name="viewport" content="width=device-width,initial-scale=1.0">
        <!-- 页签图标 -->
        <link rel="icon" href="<%= BASE_URL %>favicon.ico">
        <!-- 页签标题 -->
        <title><%= htmlWebpackPlugin.options.title %></title>
      </head>
      <body>
        <!-- 当浏览器不支持JS时,noscript中的元素就会被渲染 -->
        <noscript>
          <strong>We're sorry but <%= htmlWebpackPlugin.options.title %> doesn't work properly without JavaScript enabled. Please enable it to continue.</strong>
        </noscript>
        <!-- 容器 -->
        <div id="app"></div>
        <!-- built files will be auto injected -->
      </body>
    </html>
    ```

    

### 4.3.render函数

- render

  - ```javascript
    //将App组件放入容器中
    render: h => h(App),
    //render函数：必须有返回值
    //参数：createElement函数，创建具体的元素
    // render(h){
    //   return h(App)
    // }
    ```

- vue的不同版本

  - vue.js与vue.runtime.xxx.js的区别
      - vue.js是完整版的Vue，包含核心功能 + 模板解析器
      - vue.runtime.xxx.js是运行版的Vue，只包含核心功能，没有模板解析器

  - vue.runtime.xxx.js没有模板解析器，不能使用template这个配置项，需要使用render函数接收到的createElement函数去指定具体内容


### 4.4.vue.config.js配置文件

- 使用`vue inspect > output.js`可以查看到Vue脚手架的默认配置
- 使用vue.config.js可以对脚手架进行个性化定制，详情见：[vue.config.js](https://cli.vuejs.org/zh/config/#vue-config-js)
- public、favicon.ico、index.html、src、main.js不能修改文件名

### 4.5.ref属性

- 被用来给元素或子组件注册引用信息（id的替代者）
- 应用在html标签上获取的是真实DOM元素，应用在组件标签上是组件实例对象（vc）
- 使用方式：
    - 打标识：```<h1 ref="xxx">...</h1>``` 或 ```<School ref="xxx"></School>```
    - 获取：```this.$refs.xxx```

### 4.6.props配置项

- 功能：让组件接收外部传过来的数据

- 传递数据：```<Demo name="xxx"/>```

- 接收数据：

    - 第一种方式（只接收）：```props:['name'] ```

    - 第二种方式（限制类型）：```props:{name:String}```

    - 第三种方式（限制类型、限制必要性、指定默认值）

        - ```
          props:{
              name:{
                  type:String, //类型
                  required:true, //必要性
                  default:'老王' //默认值
              }
          }
          ```

- 备注：props是只读的，Vue底层会监测你对props的修改，如果进行了修改，就会发出警告，若业务需求确实需要修改，那么请复制props的内容到data中一份，然后去修改data中的数据

### 4.7.mixin配置项（混入）

- 功能：可以把多个组件共用的配置提取成一个混入对象

- 使用方式

    - 第一步定义混合

      - ```javascript
        {
            data(){....},
            methods:{....}
            ....
        }
        ```

    - 第二步使用混入

      -  全局混入：```Vue.mixin(xxx)```

      -  局部混入：```mixins:['xxx']  ```

- 备注：data数据和method方法有重复，以vue组件为主；mounted等生命周期钩子有重复，都使用

### 4.8.插件

- 功能：用于增强Vue

- 本质：包含install方法的一个对象，install的第一个参数是Vue，第二个以后的参数是插件使用者传递的数据

- 定义插件

    - ```javascript
      对象.install = function (Vue, options) {
          // 1. 添加全局过滤器
          Vue.filter(....)
      
          // 2. 添加全局指令
          Vue.directive(....)
      
          // 3. 配置全局混入(合)
          Vue.mixin(....)
      
          // 4. 添加实例方法
          Vue.prototype.$myMethod = function () {...}
          Vue.prototype.$myProperty = xxxx
      }
      ```

      

- 使用插件：```Vue.use()```

### 4.9.scoped样式

- 作用：让样式在局部生效，防止冲突
- 写法：```<style scoped>```

### 4.10.TodoList案例

- 组件化编码流程

     - 拆分静态组件：组件要按照功能点拆分，命名不要与html元素冲突

     - 实现动态组件：考虑好数据的存放位置，数据是一个组件在用，还是一些组件在用

       - 一个组件在用：放在组件自身即可
       - 一些组件在用：放在他们共同的父组件上（**状态提升**）

     - 实现交互：从绑定事件开始

- props适用于

     - 父组件 ==> 子组件 通信

     - 子组件 ==> 父组件 通信（要求父先给子一个函数）

- 使用v-model时要切记：v-model绑定的值不能是props传过来的值，因为props是不可以修改的

- props传过来的若是对象类型的值，修改对象中的属性时Vue不会报错，但不推荐这样做

### 4.11.webStorage

- 存储内容大小一般支持5MB左右（不同浏览器可能还不一样）

- 浏览器端通过 Window.sessionStorage 和 Window.localStorage 属性来实现本地存储机制

- 相关API

    - ```xxxxxStorage.setItem('key', 'value');```
             该方法接受一个键和值作为参数，会把键值对添加到存储中，如果键名存在，则更新其对应的值

    - ```xxxxxStorage.getItem('person');```

         ​    该方法接受一个键名作为参数，返回键名对应的值

    - ```xxxxxStorage.removeItem('key');```

         ​    该方法接受一个键名作为参数，并把该键名从存储中删除

    - ``` xxxxxStorage.clear()```

         ​    该方法会清空存储中的所有数据

- 备注：

    - SessionStorage存储的内容会随着浏览器窗口关闭而消失
    - LocalStorage存储的内容，需要手动清除才会消失
    - ```xxxxxStorage.getItem(xxx)```如果xxx对应的value获取不到，那么getItem的返回值是null
    - ```JSON.parse(null)```的结果依然是null

### 4.11.组件的自定义事件

- 组件的自定义事件：一种组件间通信的方式，适用于：**子组件 ===> 父组件**

- 使用场景：A是父组件，B是子组件，B想给A传数据，那么就要在A中给B绑定自定义事件（**事件的回调在A中**）

- 绑定自定义事件：

    - 第一种方式，在父组件中：```<Demo @atguigu="test"/>```  或 ```<Demo v-on:atguigu="test"/>```

    - 第二种方式，在父组件中

        - ```javascript
          <Demo ref="demo"/>
          ......
          mounted(){
             this.$refs.xxx.$on('atguigu',this.test)
          }
          ```

    - 若想让自定义事件只能触发一次，可以使用```once```修饰符，或```$once```方法

- 触发自定义事件：```this.$emit('atguigu',数据)```    

- 解绑自定义事件```this.$off('atguigu')```

- 组件上也可以绑定原生DOM事件，需要使用```native```修饰符

- 注意：通过```this.refs.xxx.refs.xxx.on('atguigu',回调)```绑定自定义事件时，回调**要么配置在methods中**，**要么用箭头函数**，否则this指向会出问题！

### 4.12.全局事件总线

- 全局事件总线（GlobalEventBus）：一种组件间通信的方式，适用于**任意组件间通信**

- 安装全局事件总线

   - ```javascript
      new Vue({
         ......
         beforeCreate() {
            Vue.prototype.$bus = this //安装全局事件总线，$bus就是当前应用的vm
         },
         ......
      }) 
      ```

- 使用事件总线

   - 接收数据：A组件想接收数据，则在A组件中给$bus绑定自定义事件，事件的**回调留在A组件自身**

      - ```javascript
         methods(){
           demo(data){......}
         }
         ......
         mounted() {
           this.$bus.$on('xxxx',this.demo)
         }
         ```

   - 提供数据：```this.$bus.$emit('xxxx',数据)```

- 最好在beforeDestroy钩子中，用$off去解绑**当前组件所用到的**事件

### 4.13.消息订阅与发布

- 消息订阅与发布（pubsub）：一种组件间通信的方式，适用于**任意组件间通信**

- 使用步骤

   - 安装pubsub：```npm i pubsub-js```

   - 引入pubsub：```import pubsub from 'pubsub-js'```

   - 接收数据：A组件想接收数据，则在A组件中订阅消息，订阅的**回调留在A组件自身**

      - ```javascript
         methods(){
           demo(data){......}
         }
         ......
         mounted() {
           this.pid = pubsub.subscribe('xxx',this.demo) //订阅消息
         }
         ```

   - 提供数据：```pubsub.publish('xxx',数据)```

   - 最好在beforeDestroy钩子中，用```PubSub.unsubscribe(pid)```去**取消订阅**

### 4.14.nextTick

1. 语法：```this.$nextTick(回调函数)```
2. 作用：在下一次 DOM 更新结束后执行其指定的回调
3. 什么时候用：当改变数据后，要基于更新后的新DOM进行某些操作时，要在nextTick所指定的回调函数中执行

### 4.15.Vue封装的过度与动画

- 作用：在插入、更新或移除 DOM元素时，在合适的时候给元素添加样式类名

- ![](https://image.jslog.net/online/a-11/2024/05/26/19-27-32-1716722852300-6.png)

- 写法：

   - 准备好样式

      - 元素进入的样式
        - v-enter：进入的起点
        - v-enter-active：进入过程中
        - v-enter-to：进入的终点
      - 元素离开的样式
        - v-leave：离开的起点
        - v-leave-active：离开过程中vue
        - v-leave-to：离开的终点

   - 使用```<transition>```包裹要过度的元素，并配置name属性

      - ```html
         <transition name="hello">
            <h1 v-show="isShow">你好啊！</h1>
         </transition>
         ```

   - 备注：若有多个元素需要过度，则需要使用：```<transition-group>```，且每个元素都要指定```key```值

## 5.Vue中的Ajax

### 5.1.vue脚手架配置代理

- 方法一

  - 在vue.config.js中添加如下配置

    - ```javascript
      devServer:{
        proxy:"http://localhost:5000"
      }
      ```

  - 说明

    - 优点：配置简单，请求资源时直接发给前端（8080）即可

    - 缺点：不能配置多个代理，不能灵活的控制请求是否走代理

    - 工作方式：若按照上述配置代理，当请求了前端不存在的资源时，那么该请求会转发给服务器 （优先匹配前端资源）


- 方法二

  - 编写vue.config.js配置具体代理规则

    - ```javascript
      devServer: {
          proxy: {
              '/api1': {// 匹配所有以 '/api1'开头的请求路径
                  target: 'http://localhost:5000',// 代理目标的基础路径
                  changeOrigin: true,
                  pathRewrite: {'^/api1': ''}
              },
              '/api2': {// 匹配所有以 '/api2'开头的请求路径
                  target: 'http://localhost:5001',// 代理目标的基础路径
                  changeOrigin: true,
                  pathRewrite: {'^/api2': ''}
              }
          }
      }
      /*
         changeOrigin设置为true时，服务器收到的请求头中的host为：localhost:5000
         changeOrigin设置为false时，服务器收到的请求头中的host为：localhost:8080
         changeOrigin默认值为true
      */
      ```

  - 说明

    - 优点：可以配置多个代理，且可以灵活的控制请求是否走代理

    - 缺点：配置略微繁琐，请求资源时必须加前缀


### 5.2.插槽

- 作用：让父组件可以向子组件指定位置插入html结构，也是一种组件间通信的方式，适用于 **父组件 ===> 子组件** 

- 分类：默认插槽、具名插槽、作用域插槽

- 使用方式

   - 默认插槽

      - ```html
         父组件中：
                 <Category>
                    <div>html结构1</div>
                 </Category>
         子组件中：
                 <template>
                     <div>
                        <!-- 定义插槽 -->
                        <slot>插槽默认内容...</slot>
                     </div>
                 </template>
         ```

         

   - 具名插槽

      - ```html
         父组件中：
                 <Category>
                     <template slot="center">
                       <div>html结构1</div>
                     </template>
         
                     <template v-slot:footer>
                        <div>html结构2</div>
                     </template>
                 </Category>
         子组件中：
                 <template>
                     <div>
                        <!-- 定义插槽 -->
                        <slot name="center">插槽默认内容...</slot>
                        <slot name="footer">插槽默认内容...</slot>
                     </div>
                 </template>
         ```

         

   - 作用域插槽

      - 理解：**数据在组件的自身，但根据数据生成的结构需要组件的使用者来决定**（games数据在Category组件中，但使用数据所遍历出来的结构由App组件决定）

      - 具体编码

         - ```html
            父组件中：
                  <Category>
                     <template scope="scopeData">
                        <!-- 生成的是ul列表 -->
                        <ul>
                           <li v-for="g in scopeData.games" :key="g">{{g}}</li>
                        </ul>
                     </template>
                  </Category>
            
                  <Category>
                     <template slot-scope="scopeData">
                        <!-- 生成的是h4标题 -->
                        <h4 v-for="g in scopeData.games" :key="g">{{g}}</h4>
                     </template>
                  </Category>
            子组件中：
                    <template>
                        <div>
                            <slot :games="games"></slot>
                        </div>
                    </template>
                  
                    <script>
                        export default {
                            name:'Category',
                            props:['title'],
                            //数据在子组件自身
                            data() {
                                return {
                                    games:['红色警戒','穿越火线','劲舞团','超级玛丽']
                                }
                            },
                        }
                    </script>
            ```

            




## 6.Vuex

### 6.1.概述

- vuex

  - 概念：在Vue中实现集中式状态（数据）管理的一个Vue插件，对vue应用中多个组件的共享状态进行集中式的管理（读/写），也是一种组件间通信的方式，且适用于任意组件间通信

  - 何时使用：多个组件需要共享数据时

- vuex原理图

  - ![](https://image.jslog.net/online/a-11/2024/05/26/19-27-32-1716722852683-7.png)

- 搭建vuex环境

  - 创建文件：```src/store/index.js```

     - ```javascript
       //引入Vue核心库
       import Vue from 'vue'
       //引入Vuex
       import Vuex from 'vuex'
       //应用Vuex插件
       Vue.use(Vuex)
       
       //准备actions对象——响应组件中用户的动作
       const actions = {}
       //准备mutations对象——修改state中的数据
       const mutations = {}
       //准备state对象——保存具体的数据
       const state = {}
       
       //创建并暴露store
       export default new Vuex.Store({
          actions,
          mutations,
          state
       })
       ```


  - 在```main.js```中创建vm时传入```store```配置项

     - ```javascript
       ...
       //引入store
       import store from './store'
       ...
       
       //创建vm
       new Vue({
          el:'#app',
          render: h => h(App),
          store
       })
       ```


###    6.2.基本使用

- 初始化数据、配置```actions```、配置```mutations```，操作文件```store.js```

   - ```javascript
     //引入Vue核心库
     import Vue from 'vue'
     //引入Vuex
     import Vuex from 'vuex'
     //引用Vuex
     Vue.use(Vuex)
     
     const actions = {
         //响应组件中加的动作
        jia(context,value){
           // console.log('actions中的jia被调用了',miniStore,value)
           context.commit('JIA',value)
        },
     }
     
     const mutations = {
         //执行加
        JIA(state,value){
           // console.log('mutations中的JIA被调用了',state,value)
           state.sum += value
        }
     }
     
     //初始化数据
     const state = {
        sum:0
     }
     
     //创建并暴露store
     export default new Vuex.Store({
        actions,
        mutations,
        state,
     })
     ```

- 组件中读取vuex中的数据：```$store.state.sum```

- 组件中修改vuex中的数据：```$store.dispatch('action中的方法名',数据)``` 或 ```$store.commit('mutations中的方法名',数据)```

- 备注：若没有网络请求或其他业务逻辑，组件中也可以越过actions，即不写```dispatch```，直接编写```commit```

### 6.3.getters的使用

- 概念：当state中的数据需要经过加工后再使用时，可以使用getters加工

- 在```store.js```中追加```getters```配置

   - ```javascript
     ......
     
     const getters = {
        bigSum(state){
           return state.sum * 10
        }
     }
     
     //创建并暴露store
     export default new Vuex.Store({
        ......
        getters
     })
     ```

- 组件中读取数据：```$store.getters.bigSum```

### 6.4.四个map方法的使用

- **mapState方法：**用于帮助我们映射```state```中的数据为计算属性

   - ```javascript
      computed: {
          //借助mapState生成计算属性：sum、school、subject（对象写法）
           ...mapState({sum:'sum',school:'school',subject:'subject'}),
               
          //借助mapState生成计算属性：sum、school、subject（数组写法）
          ...mapState(['sum','school','subject']),
      },
      ```

- **mapGetters方法：**用于帮助我们映射```getters```中的数据为计算属性

   - ```javascript
     computed: {
         //借助mapGetters生成计算属性：bigSum（对象写法）
         ...mapGetters({bigSum:'bigSum'}),
     
         //借助mapGetters生成计算属性：bigSum（数组写法）
         ...mapGetters(['bigSum'])
     },
     ```

- **mapActions方法：**用于帮助我们生成与```actions```对话的方法，即：包含```$store.dispatch(xxx)```的函数

   - ```javascript
     methods:{
         //靠mapActions生成：incrementOdd、incrementWait（对象形式）
         ...mapActions({incrementOdd:'jiaOdd',incrementWait:'jiaWait'})
     
         //靠mapActions生成：incrementOdd、incrementWait（数组形式）
         ...mapActions(['jiaOdd','jiaWait'])
     }
     ```

- **mapMutations方法：**用于帮助我们生成与```mutations```对话的方法，即：包含```$store.commit(xxx)```的函数

   - ```javascript
     methods:{
         //靠mapActions生成：increment、decrement（对象形式）
         ...mapMutations({increment:'JIA',decrement:'JIAN'}),
         
         //靠mapMutations生成：JIA、JIAN（对象形式）
         ...mapMutations(['JIA','JIAN']),
     }
     ```

- 备注：mapActions与mapMutations使用时，若需要传递参数需要，在模板中绑定事件时传递好参数，否则参数是事件对象

### 6.5.模块化+命名空间

- 目的：让代码更好维护，让多种数据分类更加明确

- 修改```store.js```

   - ```javascript
     const countAbout = {
       namespaced:true,//开启命名空间
       state:{x:1},
       mutations: { ... },
       actions: { ... },
       getters: {
         bigSum(state){
            return state.sum * 10
         }
       }
     }
     
     const personAbout = {
       namespaced:true,//开启命名空间
       state:{ ... },
       mutations: { ... },
       actions: { ... }
     }
     
     const store = new Vuex.Store({
       modules: {
         countAbout,
         personAbout
       }
     })
     ```

- 开启命名空间后，组件中读取state数据：

   ```javascript
   //方式一：自己直接读取
   this.$store.state.personAbout.list
   //方式二：借助mapState读取：
   ...mapState('countAbout',['sum','school','subject']),
   ```

- 开启命名空间后，组件中读取getters数据：

   ```javascript
   //方式一：自己直接读取
   this.$store.getters['personAbout/firstPersonName']
   //方式二：借助mapGetters读取：
   ...mapGetters('countAbout',['bigSum'])
   ```

- 开启命名空间后，组件中调用dispatch

   ```javascript
   //方式一：自己直接dispatch
   this.$store.dispatch('personAbout/addPersonWang',person)
   //方式二：借助mapActions：
   ...mapActions('countAbout',{incrementOdd:'jiaOdd',incrementWait:'jiaWait'})
   ```

- 开启命名空间后，组件中调用commit

   ```javascript
   //方式一：自己直接commit
   this.$store.commit('personAbout/ADD_PERSON',person)
   //方式二：借助mapMutations：
   ...mapMutations('countAbout',{increment:'JIA',decrement:'JIAN'}),
   ```

 ## 7.路由

### 7.1.概述

- 理解： 一个路由（route）就是一组映射关系（key - value），多个路由需要路由器（router）进行管理
- 前端路由：key是路径，value是组件
- vue-router：vue的一个插件库，专门用来实现SPA应用
- SPA应用
  - 单页 Web 应用（single page web application，SPA）
  - 整个应用只有一个完整的页面
  - 点击页面中的导航链接不会刷新页面，只会做页面的局部更新
  - 数据需要通过 ajax 请求获取


### 7.2.基本使用

- 安装vue-router，命令：```npm i vue-router```

- 应用插件：```Vue.use(VueRouter)```

- 编写router配置项

   - ```javascript
     //引入VueRouter
     import VueRouter from 'vue-router'
     //引入Luyou 组件
     import About from '../components/About'
     import Home from '../components/Home'
     
     //创建router实例对象，去管理一组一组的路由规则
     const router = new VueRouter({
        routes:[
           {
              path:'/about',
              component:About
           },
           {
              path:'/home',
              component:Home
           }
        ]
     })
     
     //暴露router
     export default router
     ```


- 实现切换（active-class可配置高亮样式）

   - ```html
     <router-link active-class="active" to="/about">About</router-link>
     ```

- 指定展示位置

   - ```html
     <router-view></router-view>
     ```

- 几个注意点

  - 路由组件通常存放在```pages```文件夹，一般组件通常存放在```components```文件夹

  - 通过切换，“隐藏”了的路由组件，默认是被销毁掉的，需要的时候再去挂载

  - 每个组件都有自己的```$route```属性，里面存储着自己的路由信息

  - 整个应用只有一个router，可以通过组件的```$router```属性获取到


### 7.3.多级路由（多级路由）

- 配置路由规则，使用children配置项：

   - ```javascript
     routes:[
        {
           path:'/about',
           component:About,
        },
        {
           path:'/home',
           component:Home,
           children:[ //通过children配置子级路由
              {
                 path:'news', //此处一定不要写：/news
                 component:News
              },
              {
                 path:'message',//此处一定不要写：/message
                 component:Message
              }
           ]
        }
     ]
     ```

- 跳转（要写完整路径）

   - ```html
      <router-link to="/home/news">News</router-link>
      ```


### 7.4.路由的query参数

- 传递参数

   - ```html
     <!-- 跳转并携带query参数，to的字符串写法 -->
     <router-link :to="/home/message/detail?id=666&title=你好">跳转</router-link>
                 
     <!-- 跳转并携带query参数，to的对象写法 -->
     <router-link 
        :to="{
           path:'/home/message/detail',
           query:{
              id:666,
                 title:'你好'
           }
        }"
     >跳转</router-link>
     ```

- 接收参数

   - ```javascript
      $route.query.id
      $route.query.title
      ```


### 7.5.命名路由

- 作用：可以简化路由的跳转

- 如何使用

   - 给路由命名：

      - ```javascript
        {
           path:'/demo',
           component:Demo,
           children:[
              {
                 path:'test',
                 component:Test,
                 children:[
                    {
                              name:'hello' //给路由命名
                       path:'welcome',
                       component:Hello,
                    }
                 ]
              }
           ]
        }
        ```

   - 简化跳转

      - ```html
        <!--简化前，需要写完整的路径 -->
        <router-link to="/demo/test/welcome">跳转</router-link>
        
        <!--简化后，直接通过名字跳转 -->
        <router-link :to="{name:'hello'}">跳转</router-link>
        
        <!--简化写法配合传递参数 -->
        <router-link 
           :to="{
              name:'hello',
              query:{
                 id:666,
                    title:'你好'
              }
           }"
        >跳转</router-link>
        ```

### 7.6.路由的params参数

- 配置路由，声明接收params参数

   - ```javascript
     {
        path:'/home',
        component:Home,
        children:[
           {
              path:'news',
              component:News
           },
           {
              component:Message,
              children:[
                 {
                    name:'xiangqing',
                    path:'detail/:id/:title', //使用占位符声明接收params参数
                    component:Detail
                 }
              ]
           }
        ]
     }
     ```

- 传递参数

   - ```html
     <!-- 跳转并携带params参数，to的字符串写法 -->
     <router-link :to="/home/message/detail/666/你好">跳转</router-link>
                 
     <!-- 跳转并携带params参数，to的对象写法 -->
     <router-link 
        :to="{
           name:'xiangqing',
           params:{
              id:666,
                 title:'你好'
           }
        }"
     >跳转</router-link>
     ```

   - 特别注意：路由携带params参数时，若使用to的对象写法，则不能使用path配置项，必须使用name配置！

- 接收参数

   - ```javascript
      $route.params.id
      $route.params.title
      ```


### 7.7.路由的props配置

-   作用：让路由组件更方便的收到参数

  - ```javascript
    {
       name:'xiangqing',
       path:'detail',
       component:Detail,
    
       //第一种写法：props值为对象，该对象中所有的key-value的组合最终都会通过props传给Detail组件
       // props:{a:900}
    
       //第二种写法：props值为布尔值，布尔值为true，则把路由收到的所有params参数通过props传给Detail组件
       // props:true
       
       //第三种写法：props值为函数，该函数返回的对象中每一组key-value都会通过props传给Detail组件
       props(route){
          return {
             id:route.query.id,
             title:route.query.title
          }
       }
    }
    ```

### 7.8.```<router-link>```的replace属性

- 作用：控制路由跳转时操作浏览器历史记录的模式
- 浏览器的历史记录有两种写入方式
  - ```push```是追加历史记录，路由跳转时候默认为```push```
  - ```replace```是替换当前记录

- 如何开启```replace```模式：```<router-link replace .......>News</router-link>```

### 7.9.编程式路由导航

- 作用：不借助```<router-link> ```实现路由跳转，让路由跳转更加灵活

- 具体编码

   - ```javascript
      //$router的两个API
      this.$router.push({
         name:'xiangqing',
            params:{
               id:xxx,
               title:xxx
            }
      })
      
      this.$router.replace({
         name:'xiangqing',
            params:{
               id:xxx,
               title:xxx
            }
      })
      this.$router.forward() //前进
      this.$router.back() //后退
      this.$router.go() //可前进也可后退
      ```


### 7.10.缓存路由组件

- 作用：让不展示的路由组件保持挂载，不被销毁

- 具体编码

   - ```html
      <keep-alive include="News"> 
          <router-view></router-view>
      </keep-alive>
      ```


### 7.11.两个新的生命周期钩子

- 作用：路由组件所独有的两个钩子，用于捕获路由组件的激活状态
- 具体名字
   - ```activated```路由组件被激活时触发
   - ```deactivated```路由组件失活时触发

### 7.12.路由守卫

- 作用：对路由进行权限控制

- 分类：全局守卫、独享守卫、组件内守卫

- 全局守卫

   - ```javascript
      //全局前置守卫：初始化时执行、每次路由切换前执行
      router.beforeEach((to,from,next)=>{
         console.log('beforeEach',to,from)
         if(to.meta.isAuth){ //判断当前路由是否需要进行权限控制
            if(localStorage.getItem('school') === 'atguigu'){ //权限控制的具体规则
               next() //放行
            }else{
               alert('暂无权限查看')
               // next({name:'guanyu'})
            }
         }else{
            next() //放行
         }
      })
      
      //全局后置守卫：初始化时执行、每次路由切换后执行
      router.afterEach((to,from)=>{
         console.log('afterEach',to,from)
         if(to.meta.title){ 
            document.title = to.meta.title //修改网页的title
         }else{
            document.title = 'vue_test'
         }
      })
      ```

- 独享守卫

   - ```javascript
     beforeEnter(to,from,next){
        console.log('beforeEnter',to,from)
        if(to.meta.isAuth){ //判断当前路由是否需要进行权限控制
           if(localStorage.getItem('school') === 'atguigu'){
              next()
           }else{
              alert('暂无权限查看')
              // next({name:'guanyu'})
           }
        }else{
           next()
        }
     }
     ```

- 组件内守卫

   - ```javascript
     //进入守卫：通过路由规则，进入该组件时被调用
     beforeRouteEnter (to, from, next) {
     },
     //离开守卫：通过路由规则，离开该组件时被调用
     beforeRouteLeave (to, from, next) {
     }
     ```

### 7.13.路由器的两种工作模式

- 对于一个url来说，什么是hash值？—— #及其后面的内容就是hash值

- hash值不会包含在 HTTP 请求中，即：hash值不会带给服务器

- hash模式
   - 地址中永远带着#号，不美观
   - 兼容性较好
   - 若以后将地址通过第三方手机app分享，若app校验严格，则地址会被标记为不合法

- history模式
   - 地址干净，美观 
   - 兼容性和hash模式相比略差
   - 应用部署上线时需要后端人员支持，解决刷新页面服务端404的问题

   

## 8.Vue的UI组件库

### 8.1.移动端常用UI组件库

 

- Vant https://youzan.github.io/vant 
- Cube UI https://didi.github.io/cube-ui 
- Mint UI http://mint-ui.github.io 

### 8.2.PC端常用UI组件库

- Element UI https://element.eleme.cn
- IView UI https://www.iviewui.co

 

 

