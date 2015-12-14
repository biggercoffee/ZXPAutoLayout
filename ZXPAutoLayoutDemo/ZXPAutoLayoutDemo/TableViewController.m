//
//  TableViewController.m
//  ZXPAutoLayoutDemo
//
//  Created by coffee on 15/12/13.
//  Copyright © 2015年 coffee. All rights reserved.
//

#import "TableViewController.h"
#import "TestTableViewCell.h"
#import "ZXPAutoLayout.h"

static NSString * const kTestCellID = @"kTestCellID";
@interface TableViewController () <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSMutableArray<NSString *> *dataSource;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    for (int i = 0; i < 20; i ++) {
        
        NSMutableString *string = [NSMutableString stringWithFormat:@"%zi ",i];
        NSInteger length = arc4random() % 30 + 1;
        
        for (int j=0; j<length; j++) {
            [string appendString:@"string "];
        }
        [string appendFormat:@"%zi",i];
        [self.dataSource addObject:[string description]];
    }

    //register cells
    [self registerCells];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn];
    [btn setTitle:@"dismiss" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn zxp_addConstraints:^(ZXPAutoLayoutMaker *layout) {
        layout.topSpace(20);
        layout.rightSpace(20);
        layout.widthValue(100);
        layout.heightValue(40);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - events

- (void)buttonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView zxp_cellHeightWithindexPath:indexPath space:10];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTestCellID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self configTestCell:cell indexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - getter

- (NSMutableArray<NSString *> *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

#pragma mark - private

- (void)registerCells {
    [self.tableView registerNib:[UINib nibWithNibName:[[TestTableViewCell class] description] bundle:nil] forCellReuseIdentifier:kTestCellID];
}

- (void)configTestCell:(TestTableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.testLabel.text = self.dataSource[indexPath.row];
}

@end
