//
//  ViewController.m
//  ZXPAutoLayoutDemo
//
/*
     support : Xcode7.0以上 , iOS 7 以上
     简洁方便的autolayout,有任何问题欢迎issue 我
     github : https://github.com/biggercoffee/ZXPAutolayout
     csdn blog : http://blog.csdn.net/biggercoffee
     QQ : 974792506
 
 */
//  Created by coffee on 15/11/14.
//  Copyright © 2015年 coffee. All rights reserved.
//

#import "ViewController.h"
#import "ZXPAutoLayout.h"
#import "SimpleViewController.h"
#import "ZXPStackViewController.h"
#import "TableViewController.h"
static NSString * const kCellIdentifier = @"identifier";
@interface ViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong,nonatomic) NSMutableArray<NSString *> *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
      ***************** ***************** ***************** *****************
     
     support : Xcode7.0以上 , iOS 7 以上
     简洁方便的autolayout, 打造天朝最优, 最简洁方便, 最容易上手的autolayout
     有任何问题或者需要改善交流的 可在 csdn博客或者github里给我提问题也可以联系我本人QQ
     github : https://github.com/biggercoffee/ZXPAutolayout
     csdn blog : http://blog.csdn.net/biggercoffee
     QQ : 974792506
     Email: z_xiaoping@163.com
     
      ***************** ***************** ***************** *****************
    */
    
    [self.dataSource addObject:@"简单使用示例"];
    [self.dataSource addObject:@"ZXPStackView使用示例"];
    [self.dataSource addObject:@"cell 自适应"];
    
    [self registerCells];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = self.dataSource[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    UIViewController *vc = nil;
    if (row == 0) {
        vc = [SimpleViewController new];
    }
    else if (row == 1) {
        vc = [ZXPStackViewController new];
    }
    else {
        vc = [[TableViewController alloc] initWithNibName:@"TableViewController" bundle:nil];
    }
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - getter 

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

#pragma mark - private

- (void)registerCells {
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
}

@end
