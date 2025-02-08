## Webpack

- webpack

  - 能够将源码资源进行转换处理，生成构建产物
  - webpack 本身不负责具体的转换和构建工作，loader 和 plugin 来负责整体转换构建工作
  - loader 和 plugin 组合增强了 webpack 的构建能力

- 学习路线
  - 基础配置
    - entry
    - output
    - module
    - plugins
    - mode
    - devServer
    - optimization
    - devtool
    - externals
  - 充分了解 loader 和 plugins
    - style-loader
    - css-loader
    - less-loader、sass-loader
    - babel-loader
    - ts-loader、swc-loader、esbuild-loader
    - HtmlWebpackPlugin
    - ProvidePlugin
    - DllPlugin
  - 实战
    - 搭建一个 react 环境
    - 搭建一个 vue 环境
  - 打包构建优化分析
    - 构建报的具体情况：webpackBundleAnalyzer
    - 构建过程：构建缓存（cache-loader）、多心阿成打包（hoppypack）
  - 了解自定义 loader 和 plugin
    - 用来增强打包能力
    - plugin，在构建完成后，将静态资源上传至 oss（静态资源服务）
  - 深入了解 webpack 打包构建流程

## 搭建环境

- [webpack-starter](https://github.com/JacobSuCHN/frond-end/tree/main/4.FEE/code/react-webpack-starter/)
- [react-webpack-starter](https://github.com/JacobSuCHN/frond-end/tree/main/4.FEE/code/react-webpack-starter/)
