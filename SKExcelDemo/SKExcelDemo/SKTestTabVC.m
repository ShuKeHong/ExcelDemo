//
//  SKTestTabVC.m
//  SKExcelDemo
//
//  Created by ShuKe on 2020/6/3.
//  Copyright © 2020 Da魔王_舒克. All rights reserved.
//

#import "SKTestTabVC.h"

@interface SKTestTabVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UIButton *backBtn;

@end

@implementation SKTestTabVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _dataSource = [NSMutableArray array];
    for (int i = 0; i < 5; i++) {
        [_dataSource addObject:@{
            @"id": [NSString stringWithFormat:@"%d", i],
            @"name": [NSString stringWithFormat:@"name%d", i]
        }];
    }
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.backBtn];
    
}


#pragma mark - Click
- (void)backClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"s%dr%dIdentifier", (int)indexPath.section, (int)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *cellDic = _dataSource[indexPath.row];
    cell.textLabel.text = cellDic[@"name"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 50;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark - Getter And Setter
- (UITableView *)tableView
{
    if (_tableView) return _tableView;
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-SBA_H-55) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor purpleColor];
    return _tableView;
}

- (UIButton *)backBtn
{
    if (_backBtn) return _backBtn;
    _backBtn = [[UIButton alloc]initWithFrame:CGRectMake(52.5, ScreenHeight-SBA_H-50, ScreenWidth-105, 45)];
    [_backBtn setTitle:@"back" forState:UIControlStateNormal];
    _backBtn.titleLabel.font = [UIFont boldSystemFontOfSize:22];
    _backBtn.backgroundColor = [UIColor orangeColor];
    _backBtn.layer.cornerRadius = 22.5;
    [_backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    return _backBtn;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
