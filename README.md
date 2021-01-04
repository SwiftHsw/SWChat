##### SWChatUI
聊天界面布局以及模拟数据实现，用途：当第三方IM内置UI不满足我们的需求时候，我们可以借鉴他们的接口，绘制自己的UI，我这边主要是模拟微信界面。以供参考。

##### 已实现功能以及知识点：
1.底部工具View视图的封装，包括自定义计算表情键盘，功能键盘，自定义输入框(自动换行，计算行高，输入的多种判断，@某人功能，复制粘贴等功能)，切换键盘逻辑

2.tableView显示部分，自定义多种Cell，长按删除，双击浏览，cell计算行高

3.键盘的处理

4.富文本超链接、手机号码、识别

5.图片拉伸

6.透传消息监听对方正在输入

7.语音录制功能UI(未实现录制，源码已提供方法调用）

8.发送位置，集成高德SDK

9.模拟红包发送界面功能

10.FMDB 数据库的增删改查

11.静态存储，实现模拟上传进度

12.接入环信SDK的接口，实现即时通讯

13.草稿+置顶功能

14.好友列表 排序功能

15. 消息撤回

##### 框架说明
 1.使用MVC搭建 
 
 2.Demo 文件夹下，包含视图控制器，模型，工具，子视图等
 
 3.在现实开发当中，可以实现继承 父类SWChatViewController 的“单聊” 以及“群聊” 界面，界面功能通用。
 
 ![效果地址](https://upload-images.jianshu.io/upload_images/1911628-b2c85634957f06f8.gif?imageMogr2/auto-orient/strip|imageView2/2/w/326/format/webp)
 
![效果地址](https://upload-images.jianshu.io/upload_images/1911628-e3c6d2aba03fc22f.gif?imageMogr2/auto-orient/strip|imageView2/2/w/360/format/webp)

![效果地址](https://upload-images.jianshu.io/upload_images/1911628-524d77778cad233c.gif?imageMogr2/auto-orient/strip|imageView2/2/w/360/format/webp)
