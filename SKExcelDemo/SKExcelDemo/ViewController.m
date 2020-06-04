//
//  ViewController.m
//  SKExcelDemo
//
//  Created by ShuKe on 2020/6/3.
//  Copyright © 2020 Da魔王_舒克. All rights reserved.
//

#import "ViewController.h"
#import "SKTestWebVC.h"
#import "SKTestTabVC.h"
#import "SKTestSeaVC.h"
#import "SKExcelVC.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *skTestBtn;
@property (nonatomic, strong) UIButton *skExcelBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 判断是否刘海屏幕
    NSLog(@"== %@", IsBangsScreen ? @"刘海屏幕" : @"非刘海屏幕");
    
    [self.view addSubview:self.skTestBtn];
    [self.view addSubview:self.skExcelBtn];
    
}


#pragma mark - Click
- (void)testClick
{
    [self showTestAlert];
}

- (void)toSKTestWebVC
{
    SKTestWebVC *vc = [[SKTestWebVC alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)toSKTestTabVC
{
    SKTestTabVC *vc = [[SKTestTabVC alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)toSKTestSeaVC
{
    SKTestSeaVC *vc = [[SKTestSeaVC alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)excelClick
{
    SKExcelVC *vc = [[SKExcelVC alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}


#pragma mark - Alert
- (void)showTestAlert
{
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"选择test内容" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *webAction = [UIAlertAction actionWithTitle:@"webView" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self toSKTestWebVC];
    }];
    UIAlertAction *tabAction = [UIAlertAction actionWithTitle:@"tableView" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self toSKTestTabVC];
    }];
    UIAlertAction *seaAction = [UIAlertAction actionWithTitle:@"searchBar" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self toSKTestSeaVC];
    }];
    [alertCon addAction:webAction];
    [alertCon addAction:tabAction];
    [alertCon addAction:seaAction];
    [self presentViewController:alertCon animated:YES completion:nil];
}


#pragma mark - Getter And Setter
- (UIButton *)skTestBtn
{
    if (_skTestBtn) return _skTestBtn;
    _skTestBtn = [[UIButton alloc]initWithFrame:CGRectMake(52.5, 200, ScreenWidth-105, 45)];
    [_skTestBtn setTitle:@"test" forState:UIControlStateNormal];
    _skTestBtn.titleLabel.font = [UIFont boldSystemFontOfSize:22];
    _skTestBtn.backgroundColor = [UIColor orangeColor];
    _skTestBtn.layer.cornerRadius = 22.5;
    [_skTestBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_skTestBtn addTarget:self action:@selector(testClick) forControlEvents:UIControlEventTouchUpInside];
    return _skTestBtn;
}

- (UIButton *)skExcelBtn
{
    if (_skExcelBtn) return _skExcelBtn;
    _skExcelBtn = [[UIButton alloc]initWithFrame:CGRectMake(52.5, 400, ScreenWidth-105, 45)];
    [_skExcelBtn setTitle:@"excel" forState:UIControlStateNormal];
    _skExcelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:22];
    _skExcelBtn.backgroundColor = [UIColor orangeColor];
    _skExcelBtn.layer.cornerRadius = 22.5;
    [_skExcelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_skExcelBtn addTarget:self action:@selector(excelClick) forControlEvents:UIControlEventTouchUpInside];
    return _skExcelBtn;
}



@end
