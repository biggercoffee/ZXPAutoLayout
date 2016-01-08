# ZXPAutoLayout
## 方便简洁的ios自动布局
## 此处简单入门但也足以, 如需深入一点了解, 可以查看这篇博文, 详细讲解了ZXPAutoLayout的使用 : [http://blog.csdn.net/biggercoffee/article/details/50136839](http://blog.csdn.net/biggercoffee/article/details/50136839)
## v1.1.0版本已加入一行搞定`cell的自适应高度`,只需要调用`zxp_cellHeightWithindexPath:`方法即可.详情看demo.
> cell自适应注意:在tableView: cellForRowAtIndexPath: 方法里请用
>    [tableView dequeueReusableCellWithIdentifier:cellid];
>    方式获取cell
> 
>    请不要使用
>    [tableView dequeueReusableCellWithIdentifier:cellid forIndexPath:indexPath]; 
>    会造成野指针错误


###这几天在添加可变参数, 版本可能不稳定, 请大家尽量使用1.2.3版本,如要使用V1.3, 可变参数务必传float类型.方能正确

#什么是ZXPAutoLayout ?

<font size=4>
**iOS原生的自动布局(`NSLayoutConstraint`)非常繁琐, 影响开发进度和可读性也不利于维护, 正所谓工欲善其事必先利其器 , 有一个良好的自动布局框架, 则会让我们事半功倍. 而`ZXPAutoLayout`则是解决这一问题和诞生 . 采用新颖的链式语法, 扩展性,可读性,维护成本也较低.并致力打造最好用,最简洁,最方便,最轻巧的自动布局.** 
**`ps : autolayout简单来说就是 适配iPhone机型并且是0数学布局和兼容横竖屏,如不懂童鞋, 请自寻网上查阅`**
</font>
> <font size=4>**举个例子:**
> **在使用ZXPAutoLayout之前,也就是原生的iOS布局,要添加一个约束是这样的:**</font>
> <pre ><code>
> NSLayoutConstraint *constraint = [NSLayoutConstraint 
> constraintWithItem:view //第一个view
> attribute:NSLayoutAttribute //约束属性, 比如上下左右宽高等间距
> relatedBy:NSLayoutRelationEqual //相等,或者大于等于,小于等于
> toItem:secondView //第二个view,也就是第一个view是要参照第二个view的
> attribute:NSLayoutAttribute //参照第二个view的属性
> multiplier:multiplier  //比例0--1
> constant:0]; //约束值
> </code></pre>
>**<font size=4> 就这样随便加一个约束就如此的繁琐,更何况一个view最起码有上边距,左边距和宽高,也就是所谓的`x,y,width,height`四个基本属性.就相当于以上那复杂的代 码就要最少写四次.** </font>

<font size=4>  **而现在用<font color=red size=5>`ZXPAutoLayout`</font>来给一个view添加上边距,左边距,宽高.** </font>
```objctive-c
//设置一个背景为半透明红色的view,上下左右四边都距离superview的距离为10
    UIView *bgView = [UIView new];
    [self.view addSubview:bgView];
    bgView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.5];
    [bgView zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        //上下左右四边都距离superview的距离为10
        layout.edgeInsets(UIEdgeInsetsMake(10, 10, 10, 10));
        
        //也可以如下这行代码来设置,但要同时设置top,left,bottom,right.推荐以上写法,比较简洁.
        //layout.topSpace(10).leftSpace(10).bottomSpace(10).rightSpace(10);
    }];
```
</p>
</p>
# 加入ZXPAutoLayout !
###  第一种方式:直接去github上下载:[https://github.com/biggercoffee/ZXPAutoLayout](https://github.com/biggercoffee/ZXPAutoLayout)
<p></p>
### 第二种方式: 直接在Cocoapods里搜索ZXPAutoLayout <font color=brown>(不知道什么是cocoapods或者使用方法者请自行百度, Google, 网上一大堆资料). </font>搜索命令:  `pod search zxpautolayout` 然后在安装到你的cocoapods里.  <p></p><font color=red>注意:有些用Cocoapods搜索出来的版本不是最新或者无法搜索到的, 请升级一下cocoapods即可</font>

#如何使用它?
<font size=4>**在需要的地方导入`ZXPAutoLayout.h`头文件即可**</font>
##**`设置一个红色的view,与self.view保持一致, 并适配各个iPhone机型和横竖屏`**
```objective-c
	//设置一个背景为半透明红色的view
    UIView *bgView = [UIView new];
    [self.view addSubview:bgView];
    bgView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.5];
    [bgView zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
	    layout.edgeEqualTo(self.view); //位置和宽度等于self.view
		//也可以如下两种写法
        //上下左右四边都距离superview的距离为0
        //layout.edgeInsets(UIEdgeInsetsMake(0, 0, 0, 0));
        
        //也可以如下这行代码来设置,但要同时设置top,left,bottom,right.推荐以上写法,比较简洁.
        //layout.topSpace(10).leftSpace(10).bottomSpace(10).rightSpace(10);
    }];
```

##**`设置一个蓝色view , 设置在superview里的距离和设置自身的宽高.`**
```objective-c
	UIView *blueView = [UIView new];
    [bgView addSubview:blueView];
    blueView.backgroundColor = [UIColor blueColor];
    [blueView zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        layout.topSpace(20); //设置在superview里的上边距
        layout.leftSpace(20); //设置在superview里的左边距
        layout.rightSpace(20); //设置在superview里的右边距
        layout.heightValue(100); //设置高度
        // 注意:
        // 1.设置了左边距和右边距, 会自动拉升宽度,所以如上代码并没有设置宽度.
        // 2.如上代码可以写成一行,比如layout.topSpace(20).leftSpace(20)
        // 3.但是不推荐全部写在一行, 阅读性太差 , 而且在一行代码里写了诸多属性也不利于DEBUG
    }];
```

##**`设置一个灰色view , 设置参照于其他view的距离和等宽等距离属性`**
```objective-c
	UIView *grayView = [UIView new];
    [bgView addSubview:grayView];
    grayView.backgroundColor = [UIColor grayColor];
    [grayView zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        /*
            上边距参照blueview, 并加10的距离.
            意思就是说上边距在blueView的下边,并加上10的间距.
            如果只是想在blueview的下边没有距离的话, 第二个参数写为0即可
         */
        layout.topSpaceByView(blueView,10);
        
        /*
            左边距等同于blueView的左边距
            第二个参数是距离的值, 如果为0就代表左边距和blueview相等
            如果不为0,则先相等于blueview的距离,然后在加上第二参数的距离
         */
        layout.leftSpaceEqualTo(blueView,0);
        
        /*
            宽度等同于bluewView
            multiplier是倍数, 可选属性,如果不写此属性宽度就是等同于blueview
            如果写了此属性,如下示例, 则宽度等同于blueview的 0.5 倍
         */
        layout.widthEqualTo(blueView,0).multiplier(0.5);
        layout.heightValue(40); //设置高度
    }];
```

##**`UILabel的文字自适应,只需要设置autoHeight属性即可`**
```objective-c
	UILabel *label = [UILabel new];
    [self.view addSubview:label];
    label.backgroundColor = [UIColor purpleColor];
    label.textColor = [UIColor whiteColor];
    label.text = @"这是文字自适应, 这是文字自适应 ,这是文字自适应 .这是文字自适应";
    [label zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        //设置上边距在grayView的下边,并且加10的距离
        layout.leftSpaceEqualTo(grayView,10);
        
        layout.bottomSpace(20); //设置在superview里的下边距
        
        layout.widthValue(100);//设置宽度
        
        layout.autoHeight(); //自适应高度,只针对UILabel有效
    }];
```

##**`等宽并水平对齐第一种方式`**
```objective-c
		UIView *view1 = [UIView new];
        [self.view addSubview:view1];
        view1.backgroundColor = [UIColor blueColor];
        
        UIView *view2 = [UIView new];
        [self.view addSubview:view2];
        view2.backgroundColor = [UIColor blackColor];
        
        UIView *view3 = [UIView new];
        [self.view addSubview:view3];
        view3.backgroundColor = [UIColor blueColor];
        
        [view1 zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
            layout.topSpaceByView(grayView,10);
            layout.leftSpace(20);
            layout.heightValue(40);
            layout.widthEqualTo(view2);
        }];
        
        [view2 zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
            layout.topSpaceEqualTo(view1,0);
            layout.leftSpaceByView(view1,20);
            layout.heightValue(40);
            layout.widthEqualTo(view3);
        }];
        
        [view3 zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
            layout.topSpaceEqualTo(view1,0);
            layout.leftSpaceByView(view2,20);
            layout.rightSpace(20);
            layout.heightValue(40);
        }];
```

##**`等宽并水平对齐第二种方式 -- ZXPStackView的使用`**
```objective-c
		ZXPStackView *stackView = [ZXPStackView new];
        [self.view addSubview:stackView];
        stackView.backgroundColor = [UIColor blackColor];
        
        //只需要设置stackView的宽高和位置即可
        [stackView zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
            layout.topSpaceByView(grayView,20);
            layout.leftSpace(0);
            layout.rightSpace(0);
            layout.heightValue(100);
        }];
        
        UIView *view1 = [UIView new];
        [stackView addSubview:view1];
        view1.backgroundColor = [UIColor blueColor];
        
        UIView *view2 = [UIView new];
        [stackView addSubview:view2];
        view2.backgroundColor = [UIColor yellowColor];
        
        UIView *view3 = [UIView new];
        [stackView addSubview:view3];
        view3.backgroundColor = [UIColor redColor];
        
        //stack的内边距
        stackView.padding = UIEdgeInsetsMake(10, 10, 10,10);
        //view直接的距离
        stackView.space = 10;
        //调用此方法会给subviews自动添加约束条件,进行等宽或者等高排列
        [stackView layoutWithType:ZXPStackViewTypeHorizontal];
```

##**`ZXPStackView之等高垂直对齐`**
<font size=4>**只需要调用ZXPStackView的layoutWithType: 方法,并传入ZXPStackViewTypeVertical即可实现,如以上代码一样.只是布局所传入的类型参数不同而已, 内部会根据所传入的布局类型,自动进行约束的添加.**</font>
```objective-c
		ZXPStackView *stackView = [ZXPStackView new];
        [self.view addSubview:stackView];
        stackView.backgroundColor = [UIColor blackColor];
        
        //只需要设置stackView的宽高和位置即可
        [stackView zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
            layout.topSpaceByView(grayView,20);
            layout.leftSpace(0);
            layout.rightSpace(0);
            layout.heightValue(100);
        }];
        
        UIView *view1 = [UIView new];
        [stackView addSubview:view1];
        view1.backgroundColor = [UIColor blueColor];
        
        UIView *view2 = [UIView new];
        [stackView addSubview:view2];
        view2.backgroundColor = [UIColor yellowColor];
        
        UIView *view3 = [UIView new];
        [stackView addSubview:view3];
        view3.backgroundColor = [UIColor redColor];
        
        //stack的内边距
        stackView.padding = UIEdgeInsetsMake(10, 10, 10,10);
        //view直接的距离
        stackView.space = 10;
        //调用此方法会给subviews自动添加约束条件,进行等宽或者等高排列
        [stackView layoutWithType:ZXPStackViewTypeVertical];
```

## <font color=red>**注意: ZXPStackView的subview不需要添加约束, 在调用`layoutWithType: `方法的时候,内部会自动进行约束的添加 **</font>

#**总结**
###**本篇文章讲解了`ZXPAutoLayout`的基本使用和常用api的方法. 比如如何设置一个view的约束, 或者等宽, 等高, 位置相对于某个view的某一边,  宽高又相对于某一个view或者等比例的常用apis. `如有问题或者写的不好地方留言即可~!`**

#### 有任何问题欢迎issue我,你们的issue才是我的动力~! thanks
