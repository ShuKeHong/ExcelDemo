//
//  SKTestSeaVC.m
//  SKExcelDemo
//
//  Created by ShuKe on 2020/6/3.
//  Copyright © 2020 Da魔王_舒克. All rights reserved.
//

#import "SKTestSeaVC.h"

@interface SKTestSeaVC () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *alphaView; // searchBar输入时盖住self.view
@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource; // 全部数据
@property (nonatomic, strong) NSMutableArray *showDataSource; // 展示的数据（默认为全部，搜索后要模糊查询）

@property (nonatomic, strong) UIButton *backBtn;

@end

@implementation SKTestSeaVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = HEX_COLOR(0xf7f7f7);
    
    _dataSource = [NSMutableArray array];
    for (int i = 0; i < 100; i++) {
        [_dataSource addObject:@{
            @"id": [NSString stringWithFormat:@"%d", i],
            @"name": [NSString stringWithFormat:@"name%d", i]
        }];
    }
    _showDataSource = [NSMutableArray arrayWithArray:_dataSource];
    
    [self.view addSubview:self.searchView];
    [self.searchView addSubview:self.searchBar];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.backBtn];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.alphaView];
    
}

#pragma mark - Click
// 点击_alphaView，关闭搜索状态
- (void)closeView
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    
    _alphaView.hidden = YES;
    _searchBar.text = @"";
    _showDataSource = [NSMutableArray arrayWithArray:_dataSource];
    [_searchBar endEditing:YES];
    _searchBar.showsCancelButton = NO;
    [_tableView reloadData];
    
    [UIView commitAnimations];
}

// 模糊搜索刷新tableView
- (void)refreshDataSource:(NSString *)searchStr
{
    _showDataSource = [NSMutableArray array];
    for (NSDictionary *dataDic in _dataSource) {
        NSString *nameStr = dataDic[@"name"];
        NSRange range = [nameStr rangeOfString:searchStr];
        if (range.location != NSNotFound) {
            [_showDataSource addObject:dataDic];
        }
    }
    [_tableView reloadData];
}

- (void)backClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_showDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"%dIdentifier",(int)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    
    NSDictionary *cellDic = _showDataSource[indexPath.row];
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
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark - SearchBar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.view bringSubviewToFront:self.alphaView];
    _alphaView.hidden = NO;
    _searchBar.showsCancelButton = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    _alphaView.hidden = YES;
    _searchBar.showsCancelButton = NO;
    
    [self refreshDataSource:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self closeView];
}


#pragma mark - Getter And Setter
- (UIView *)searchView
{
    if (_searchView) return _searchView;
    _searchView = [[UIView alloc]initWithFrame:CGRectMake(0, NAV_H, ScreenWidth, 44)];
    _searchView.backgroundColor = [UIColor whiteColor];
    return _searchView;
}

- (UISearchBar *)searchBar
{
    if (_searchBar) return _searchBar;
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(16, (44-29)/2.0, ScreenWidth-32, 29)];
    _searchBar.placeholder = @"请输入关键字";
    _searchBar.delegate = self;
    _searchBar.barTintColor = HEX_COLOR(0xf7f7f7);
    _searchBar.tintColor = HEX_COLOR(0x666666);
    _searchBar.searchBarStyle = UISearchBarStyleDefault;
    _searchBar.barStyle = UIBarStyleDefault;
    _searchBar.backgroundColor = HEX_COLOR(0xf7f7f7);
    _searchBar.returnKeyType = UIReturnKeySearch;
    _searchBar.layer.masksToBounds = YES;
    _searchBar.layer.borderColor = HEX_COLOR(0xf7f7f7).CGColor;
    _searchBar.layer.borderWidth = 1;
    _searchBar.layer.cornerRadius = 4;
    
    /* 20200521，xcode升级后iOS13引起的闪退优化 */
    UITextField *searchField;
    if (@available(iOS 13.0, *)) {
        searchField = _searchBar.searchTextField;
    }else {
        // Fallback on earlier versions
        UITextField *searchTextField = [_searchBar valueForKey:@"_searchField"];
        searchField = searchTextField;
    }
    searchField.attributedPlaceholder = [[NSMutableAttributedString alloc] initWithString:@" " attributes:@{NSForegroundColorAttributeName: HEX_COLOR(0xf7f7f7)}];
    
    [searchField setBackground:nil];
    [searchField setBorderStyle:UITextBorderStyleNone];
    searchField.backgroundColor = HEX_COLOR(0xf7f7f7);
    searchField.textColor = HEX_COLOR(0x666666);
    searchField.layer.cornerRadius = 0;
    searchField.layer.masksToBounds = NO;
    return _searchBar;
}

- (UITableView *)tableView
{
    if (_tableView) return _tableView;
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, NAV_H+44+10, ScreenWidth, ScreenHeight-NAV_H-44-10-SBA_H-55) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    return _tableView;
}

- (UIView *)alphaView
{
    if (_alphaView) return _alphaView;
    _alphaView = [[UIView alloc]initWithFrame:CGRectMake(0, NAV_H+44, ScreenWidth, ScreenHeight-NAV_H-44)];
    _alphaView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    _alphaView.hidden = YES;
    // 加手势，关闭搜索框
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeView)];
    tap.delegate = self;
    [_alphaView addGestureRecognizer:tap];
    return _alphaView;
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
