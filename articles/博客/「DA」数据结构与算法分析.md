# 算法复杂度

- 时间复杂度

  - 实际上并不具体表示代码真正的执行时间，而是表示代码执行时间随数据规模增长的变化趋势，所以也叫渐进时间复杂度，简称时间复杂度
  - 最好情况时间复杂度：在最理想的情况下，执行这段代码的时间复杂度。
  - 最坏情况时间复杂度：在最糟糕的情况下，执行这段代码的时间复杂度。
  - 平均情况时间复杂度：用代码在所有情况下执行的次数的加权平均值表示。也叫 加权平均时间复杂度 或者 期望时间复杂度。
  - 均摊时间复杂度：在代码执行的所有复杂度情况中绝大部分是低级别的复杂度，个别情况是高级别复杂度且发生具有时序关系时，可以将个别高级别复杂度均摊到低级别复杂度上。基本上均摊结果就等于低级别复杂度。

- 空间复杂度
  - 渐进空间复杂度，表示算法的存储空间与数据规模之间的增长关系
  - 定义：算法的空间复杂度通过计算算法所需的存储空间实现，算法的空间复杂度的计算公式记作：S(n) = O(f(n))，其中，n 为问题的规模，f(n) 为语句关于 n 所占存储空间的函数。

# 链表

## 单链表

- [单链表](https://github.com/JacobSuCHN/public-code-repository/blob/main/da-js/LinkedList/SinglyLinkedList.js)

## 双链表

- [双链表](https://github.com/JacobSuCHN/public-code-repository/blob/main/da-js/LinkedList/DoubleLinkedList.js)

## 循环链表判断

- 表记法：给每个已遍历过的节点加标志位，遍历链表，当出现下一个节点已被标志时，则证明单链表有环

```js
let hasCycle = function(head) {​
    while(head) {​
        if(head.flag) return true​
        head.flag = true​
        head = head.next​
    }​
    return false​
};
```

- 利用 JSON.stringify() 不能序列化含有循环引用的结构

```js
let hasCycle = function(head) {​
    try{​
        JSON.stringify(head);​
        return false;​
    }​
    catch(err){​
        return true;​
    }​
};
```

- 快慢指针（双指针法）：设置快慢两个指针，遍历单链表，快指针一次走两步，慢指针一次走一步，如果单链表中存在环，则快慢指针终会指向同一个节点，否则直到快指针指向 null 时，快慢指针都不可能相遇

```js
let hasCycle = function(head) {​
    if(!head || !head.next) {​
        return false​
    }​
    let fast = head.next.next, slow = head.next​
    while(fast !== slow) {​
        if(!fast || !fast.next) return false​
        fast = fast.next.next​
        slow = slow.next​
    }​
    return true​
};
```

# 队列

- 事件顺序的一致性
- 实现：数组/链表

- [队列](https://github.com/JacobSuCHN/public-code-repository/blob/main/da-js/Queue/Queue.js)

# 栈

- 实现：数组/链表

- [栈](https://github.com/JacobSuCHN/public-code-repository/blob/main/da-js/Stack/Stack.js)

# 排序算法

- 分析排序算法
  - 执行效率
  - 内存消耗
  - 稳定性
- [code](https://github.com/JacobSuCHN/public-code-repository/blob/main/da-js/Sort/Sort.js)

## 冒泡排序

- 思想：相邻元素进行比较，以从小到大原则，不满足互换
- 分析
  - 时间复杂度：O(n<sup>2</sup>)
  - 空间复杂度：O(1)
  - 稳定性：稳定

![BubbleSort.gif](https://cdn.jsdelivr.net/gh/JacobSuCHN/picgo-img/2025%2F02%2F26%2F09-00-36-33a947c71ad62b254cab62e5364d2813-BubbleSort-993858.gif)

## 插入排序

- 思想：针对剩余元素依次找到合适位置插入
- 分析
  - 时间复杂度：O(n<sup>2</sup>)
  - 空间复杂度：O(1)
  - 稳定性：稳定

![InsertionSort.gif](https://cdn.jsdelivr.net/gh/JacobSuCHN/picgo-img/2025%2F02%2F26%2F09-00-28-91b76e8e4dab9b0cad9a017d7dd431e2-InsertionSort-d825f6.gif)

## 选择排序

- 思想 ​：选择排序每次会从未排序区间中找到最小的元素，将其放到已排序区间的末尾
- 分析
  - 时间复杂度：O(n<sup>2</sup>)
  - 空间复杂度：O(1)
  - 稳定性：不稳定

![SelectionSort.gif](https://cdn.jsdelivr.net/gh/JacobSuCHN/picgo-img/2025%2F02%2F26%2F09-00-51-1c7e20f306ddc02eb4e3a50fa7817ff4-SelectionSort-a5f1f9.gif)

## 归并排序

- 思路：分而治之
- 分析
  - 时间复杂度：O(nlogn)
  - 空间复杂度：O(n)
  - 稳定性：稳定

![MergeSort.gif](https://cdn.jsdelivr.net/gh/JacobSuCHN/picgo-img/2025%2F02%2F26%2F09-43-38-cdda3f11c6efbc01577f5c29a9066772-MergeSort-ba41fe.gif)

## 快速排序

- 思路：基准点,一般取中间,比基准点小->left,比基准点大->right,递归执行,直至数组长度小于等于 1
- 分析
  - 时间复杂度：O(nlogn)
  - 空间复杂度：O(n)
  - 稳定性：不稳定

![QuickSort.gif](https://cdn.jsdelivr.net/gh/JacobSuCHN/picgo-img/2025%2F02%2F26%2F10-14-58-c411339b79f92499dcb7b5f304c826f4-QuickSort-8801ff.gif)

- 对比
  - 归并排序自底向上排序,快速排序自顶向下排序
  - 归并排序稳定,快速排序不稳定

# DP 和贪心算法

[fibo](https://github.com/JacobSuCHN/public-code-repository/blob/main/da-js/Algorithm/fibo.js)
[knapsack](https://github.com/JacobSuCHN/public-code-repository/blob/main/da-js/Algorithm/knapsack.js)

## 动态规划(DP)

> 递归：自顶向下拆分问题=>解决问题
> 动态规划：一开始就从底部解决问题

- 动态规划 ​（DP）：动态规划解决方案从底部开始解决问题，将所有小问题解决掉，然后合并成一个整体解决方案，从而解决掉整个大问题

## 贪心算法

- 贪心算法：总是会选择当下的最优解，而不去考虑这一次的选择会不会对未来的选择造成影响

# 二叉树的遍历

- 前序遍历

![pre-order.png](https://cdn.jsdelivr.net/gh/JacobSuCHN/picgo-img/2025%2F02%2F26%2F17-28-36-74ce5b697168909fa2d8a1d73dce8cf1-pre-order-73a4ef.png)

```js
const preOrderTraverse = (root) => {
  let result = [];
  const preOrderTraverseNode = (node) => {
    if (node) {
      result.push(node.val);
      preOrderTraverseNode(node.left);
      preOrderTraverseNode(node.right);
    }
  };
  preOrderTraverseNode(root);
  return result;
};
```

- 中序遍历

![in_order.png](https://cdn.jsdelivr.net/gh/JacobSuCHN/picgo-img/2025%2F02%2F26%2F17-29-04-cae62ae635e3fbdedcfd85cb9198d20b-in_order-ce8660.png)

```js
const preOrderTraverse = (root) => {
  let result = [];
  const preOrderTraverseNode = (node) => {
    if (node) {
      preOrderTraverseNode(node.left);
      result.push(node.val);
      preOrderTraverseNode(node.right);
    }
  };
  preOrderTraverseNode(root);
  return result;
};
```

- 后序遍历

![post_order.png](https://cdn.jsdelivr.net/gh/JacobSuCHN/picgo-img/2025%2F02%2F26%2F17-28-57-160677025355af7ba9fa7b8efecb3ffb-post_order-fa7421.png)

```js
const preOrderTraverse = (root) => {
  let result = [];
  const preOrderTraverseNode = (node) => {
    if (node) {
      preOrderTraverseNode(node.left);
      preOrderTraverseNode(node.right);
      result.push(node.val);
    }
  };
  preOrderTraverseNode(root);
  return result;
};
```

# DFS 和 BFS

## DFS

- DFS：深度优先遍历，纵向优先

```js
function deepthFirstSearch(node, nodeList) {
  if (node) {
    nodeList.push(node);
    let children = node.children;

    for (let i = 0; i < children?.length || 0; i++)
      deepFirstSearch(children[i], nodeList);
  }
  return nodeList;
}
```

## BFS

- BFS：广度优先遍历，横向优先

```js
function breadthFirstSearch(node) {
  const nodes = [];
  let i = 0;
  if (node) {
    nodes.push(node);
    breadthFirstSearch(nodes.nextElementSibling);
    node = nodes[i++];
    breadthFirstSearch(nodes.firstElementChild);
  }
  return nodes;
}
```

# 双指针

- 双指针：数组/链表
- 要找到指定的 target -> <- 对向的双指针
- 要找到两个数组/字符串/链表的关系 -> -> 同向的双指针
- 遍历 while，指定终止态

[two-sum](https://github.com/JacobSuCHN/public-code-repository/blob/main/da-js/Algorithm/two-sum.js)
[3sum-closest](https://github.com/JacobSuCHN/public-code-repository/blob/main/da-js/Algorithm/3sum-closest.js)
[is-subsequence](https://github.com/JacobSuCHN/public-code-repository/blob/main/da-js/Algorithm/is-subsequence.js)
[move-zeroes](https://github.com/JacobSuCHN/public-code-repository/blob/main/da-js/Algorithm/move-zeroes.js)

# 滑动窗口

- 定长的滑动窗口
- 不定长的滑动窗口

- 单调队列
  - 加入所需元素：向单调队列重复加入元素直到当前元素达到所求区间的右边界，这样就能保证所需元素都在单调队列中。
  - 弹出越界队首：单调队列本质上是维护的是所有已插入元素的最值，但我们想要的往往是一个区间最值。于是我们弹出在左边界外的元素，以保证单调队列中的元素都在所求区间中。
  - 获取最值：直接取队首作为答案即可

[sliding-window-maximum](https://github.com/JacobSuCHN/public-code-repository/blob/main/da-js/Algorithm/sliding-window-maximum.js)

# 二叉树

- 确定终态 return
- 回溯 root 递归

[lowest-common-ancestor-of-a-binary-tree](https://github.com/JacobSuCHN/public-code-repository/blob/main/da-js/Algorithm/lowest-common-ancestor-of-a-binary-tree.js)

# 堆

[smallest-k-lcci](https://github.com/JacobSuCHN/public-code-repository/blob/main/da-js/Algorithm/smallest-k-lcci.js)
[top-k-frequent-elements](https://github.com/JacobSuCHN/public-code-repository/blob/main/da-js/Algorithm/top-k-frequent-elements.js)
[kth-largest-element-in-an-array](https://github.com/JacobSuCHN/public-code-repository/blob/main/da-js/Algorithm/kth-largest-element-in-an-array.js)

# 图

[find-the-town-judge](https://github.com/JacobSuCHN/public-code-repository/blob/main/da-js/Algorithm/find-the-town-judge.js)
[course-schedule](https://github.com/JacobSuCHN/public-code-repository/blob/main/da-js/Algorithm/course-schedule.js)

# 动态规划

[climbing-stairs](https://github.com/JacobSuCHN/public-code-repository/blob/main/da-js/Algorithm/climbing-stairs.js)
[min-cost-climbing-stairs](https://github.com/JacobSuCHN/public-code-repository/blob/main/da-js/Algorithm/min-cost-climbing-stairs.js)

# 回溯

[generate-parentheses](https://github.com/JacobSuCHN/public-code-repository/blob/main/da-js/Algorithm/generate-parentheses.js)

