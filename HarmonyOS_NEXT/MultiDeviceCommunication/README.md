# 一次开发，多端部署-即时通讯（ArkTS）

### 简介

基于自适应和响应式布局，实现一次开发、多端部署音乐专辑页面。

手机效果图如下：

![image](screenshots/device/HomeSM.png)

折叠屏效果图如下：

![image](screenshots/device/HomeMD.png)

平板效果图如下：

![image](screenshots/device/HomeLG.png)

### 相关概念

- [一次开发，多端部署](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V2/application-dev-guide-0000001630265101-V2?catalogVersion=V2)：一套代码工程，一次开发上架，多端按需部署。支撑开发者快速高效的开发支持多种终端设备形态的应用，实现对不同设备兼容的同时，提供跨设备的流转、迁移和协同的分布式体验。
- 自适应布局：当外部容器大小发生变化时，元素可以根据相对关系自动变化以适应外部容器变化的布局能力。相对关系如占比、固定宽高比、显示优先级等。当前自适应布局有4种：[线性布局](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V2/arkts-layout-development-linear-0000001580185246-V2)、[层叠布局](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V2/arkts-layout-development-stack-layout-0000001630145829-V2)、[弹性布局](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V2/arkts-layout-development-flex-layout-0000001580345174-V2)、[相对布局](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V2/arkts-layout-development-relative-layout-0000001630425157-V2)。自适应布局能力可以实现界面显示随外部容器大小连续变化。
- 响应式布局：当外部容器大小发生变化时，元素可以根据断点、栅格或特定的特征（如屏幕方向、窗口宽高等）自动变化以适应外部容器变化的布局能力。当前响应式布局能力有2种：[媒体查询](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V2/arkts-layout-development-media-query-0000001580025846-V2)、[栅格布局](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V2/arkts-layout-development-grid-layout-0000001630305773-V2)。
- [Navigation](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V2/ts-basic-components-navigation-0000001580026346-V2?catalogVersion=V2)：页面根容器，一般用于分栏布局场景使用。

### 相关权限

不涉及

### 使用说明

1. 分别在手机、折叠屏、平板安装并打开应用，不同设备的应用页面通过响应式布局和自适应布局呈现不同的效果。
2. 点击界面上的消息标签，显示聊天列表页面。
3. 点击聊天列表中数据，跳转至聊天详情页面。
4. 点击界面上的通讯录标签，显示通讯录列表页面。
5. 点击通讯录列表中数据，跳转至通讯录详情页面。
6. 点击界面上的社交圈标签，显示社交圈页面。
7. 其他按钮无实际点击事件或功能。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机或运行在DevEco Studio上的华为手机设备模拟器。
2. 本示例为Stage模型，支持API version 10。
3. 本示例需要使用DevEco Studio 4.0.1.601进行编译运行。
4. 本示例运行时需要在DevEco Studio的entry模块中的Run/Debug Configurations设置项中勾选Deploy Multi Hap Packages。