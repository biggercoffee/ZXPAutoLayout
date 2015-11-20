# ZXPAutoLayout
## 方便简洁的ios自动布局
#### 传统的自动布局添加一个约束(用代码实现) ####

<pre><code> NSLayoutConstraint *constraintX = [NSLayoutConstraint constraintWithItem:view1 //要添加的约束
                                                                       attribute:NSLayoutAttribute //约束属性
                                                                       relatedBy:NSLayoutRelationEqual //等于,小于等于,大于等于
                                                                          toItem:view2 //相对于某一个view
                                                                       attribute:NSLayoutAttribute //相对于某一个view的属性
                                                                      multiplier:1.0 //比例
                                                                        constant:0]; //约束值
</code></pre>

#### 现在简单使用ZXPAutoLayout来布局(注:使用自动布局之前要先添加到父视图里)

##### 加入ZXPAutoLayout的方法 
##### 第一种方法:直接下载并导入ZXPAutoLayout.h文件
##### 第二种方法:使用Cocoapod搜索: pod search ZXPAutoLayout 
#####   cocoapod安装: pod 'ZXPAutoLayout', :head

##### 添加一个与self.view的上下左右相等的约束
<pre><code>
[view zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        layout.edges.equalTo(self.view); //上下左右边距等于self.view
    }];
</code></pre>

##### 添加一个view ,距离在view的下边并+20距离,距离左边20距离,宽高与view相等
<pre><code>
[view2 zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        layout.top.equalTo(view.zxp_bottom).offset(20);
        layout.left.offset(20);
        layout.width.height.equalTo(view);
    }];
</code></pre>

##### UILabel的文字自适应
<pre><code>
    //uilabel 自适应
    UILabel *label = [UILabel new];
    [self.view addSubview:label];
    label.backgroundColor = [UIColor blackColor];
    label.textColor = [UIColor whiteColor];
    label.text = @"1.this is a test 2.this is a test 3.this is a test 4.this is a test";
    label.numberOfLines = 0;//自适应第一步, numberoflines = 0
    [label zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        layout.top.offset(200); //距离父视图的顶部距离为200
        layout.left.offset(20); //距离父视图的左侧距离为20
        layout.width.equalToWithMultiplier(self.view,0.5); //设置宽度为self.view的宽度的0.5(比例)
        layout.height.greaterThanOrEqual(@1); //自适应第二步,设置高度大于等于1即可
    }];
</code></pre>

##### 等宽并对齐
<pre><code>
    UIView *view1 = [UIView new];
        view1.backgroundColor = [UIColor purpleColor];
        [self.view addSubview:view1];
        
        UIView *view2 = [UIView new];
        view2.backgroundColor = [UIColor blueColor];
        [self.view addSubview:view2];
        
        UIView *view3 = [UIView new];
        view3.backgroundColor = [UIColor yellowColor];
        [self.view addSubview:view3];
        
        [view1 zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
            layout.top.offset(200);
            layout.left.offset(10);
            layout.height.offset(40);
            layout.width.equalTo(view2);
        }];
        
        [view2 zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
            layout.top.height.equalTo(view1);
            layout.left.equalTo(view1.zxp_right).offset(10);
            layout.width.equalTo(view3);
        }];
        
        [view3 zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
            layout.top.height.equalTo(view1);
            layout.left.equalTo(view2.zxp_right).offset(10);
            layout.right.offset(-10);
            layout.width.equalTo(view1);
        }];
</code></pre>

##### 等高并对齐
<pre><code>
    UIView *view1 = [UIView new];
        view1.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [self.view addSubview:view1];
        
        UIView *view2 = [UIView new];
        view2.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.3];
        [self.view addSubview:view2];
        
        UIView *view3 = [UIView new];
        view3.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.3];
        [self.view addSubview:view3];
        
        [view1 zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
            layout.top.offset(10);
            layout.left.offset(10);
            layout.right.offset(-10);
            layout.height.equalTo(view2);
        }];
        
        [view2 zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
            layout.top.equalTo(view1.zxp_bottom).offset(10);
            layout.left.right.equalTo(view1);
            layout.height.equalTo(view3);
        }];
        
        [view3 zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
            layout.top.equalTo(view2.zxp_bottom).offset(10);
            layout.bottom.offset(-10);
            layout.left.right.equalTo(view1);
            layout.height.equalTo(view1);
        }];
</code></pre>

#### 有任何问题欢迎issue我,你们的issue才是我的动力~! thanks
