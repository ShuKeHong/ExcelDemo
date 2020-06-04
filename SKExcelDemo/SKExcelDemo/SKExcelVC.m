//
//  SKExcelVC.m
//  SKExcelDemo
//
//  Created by ShuKe on 2020/6/4.
//  Copyright © 2020 Da魔王_舒克. All rights reserved.
//

#import "SKExcelVC.h"
#import <WebKit/WebKit.h>
#import "xlsxwriter.h"

@interface SKExcelVC () <WKNavigationDelegate, WKUIDelegate, UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) UIButton *excelBtn;
@property (nonatomic, strong) WKWebView *testWebView;
@property (nonatomic, strong) UIButton *exportBtn;
@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UIDocumentInteractionController *documentController;

@property (nonatomic, assign) int rowNum; // 已加载到的行数

@end

static lxw_workbook  *workbook;
static lxw_worksheet *worksheet;

static lxw_format *contentformat; // 文本内容的样式
static lxw_format *moneyformat; // 金钱内容的样式

@implementation SKExcelVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.excelBtn];
    [self.view addSubview:self.exportBtn];
    [self.view addSubview:self.testWebView];
    [self.view addSubview:self.backBtn];
    
}


#pragma mark - 生成excel
- (void)generateClick
{
    // 模拟表格数据
    NSMutableArray *trafficArray = [NSMutableArray array];
    NSMutableArray *mealsArray = [NSMutableArray array];
    NSMutableArray *travelArray = [NSMutableArray array];
    for (int i = 0; i < 5; i++) {
        NSDictionary *dic = @{
                              @"time": @"2020-06-04",
                              @"phone": @"12345678910", // 测试尾数是0的场景
                              @"money": @"5.00" // 测试尾数是.00的场景
                              };
        [trafficArray addObject:dic];
        [mealsArray addObject:dic];
        [travelArray addObject:dic];
    }
    NSDictionary *dataDic = @{
                              @"traffic": trafficArray
                              };
    
    // 生成excel
    [self createXlsxFileWith:dataDic];
    
    // 简单展示
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [documentPath stringByAppendingPathComponent:@"sk测试报表.xlsx"];
    NSURL *url = [NSURL fileURLWithPath:filePath]; // 注意：使用[NSURL URLWithString:filePath]无效
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [_testWebView loadRequest:urlRequest];
    
}

- (void)createXlsxFileWith:(NSDictionary *)dataDic
{
    self.rowNum = 0;

    // 文件保存的路径
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]; // 这里也可以储存在NSDocumentDirectory
    NSString *filename = [documentPath stringByAppendingPathComponent:@"sk测试报表.xlsx"];
    NSLog(@"== filename_path:%@", filename);
    workbook  = workbook_new([filename UTF8String]); // 创建新xlsx文件，路径需要转成c字符串
    worksheet = workbook_add_worksheet(workbook, [@"测试报表sheet" cStringUsingEncoding:NSUTF8StringEncoding]); // 创建sheet（多sheet页就add多个）
    
    [self setupFormat];
    
    [self createTrafficForm:dataDic[@"traffic"]];
    
    workbook_close(workbook);
}

// 单元格样式
- (void)setupFormat
{
    contentformat = workbook_add_format(workbook);
    format_set_font_size(contentformat, 10);
    format_set_border(contentformat, LXW_BORDER_THIN);
    
    moneyformat = workbook_add_format(workbook);
    format_set_font_size(moneyformat, 10); // 字体大小
    format_set_border(moneyformat, LXW_BORDER_THIN); // 边框（四周）
    format_set_num_format(moneyformat, "0.00"); // 格式
    
    /* 其他属性
    format_set_bold(moneyformat); // 加粗
    format_set_font_color(moneyformat, LXW_COLOR_RED); // 颜色
    format_set_align(moneyformat, LXW_ALIGN_CENTER); // 水平居中
    format_set_align(moneyformat, LXW_ALIGN_VERTICAL_CENTER); // 垂直居中
    format_set_top(moneyformat, LXW_BORDER_THIN); // 上边框
    format_set_left(moneyformat, LXW_BORDER_THIN); // 左边框
    format_set_bottom(moneyformat, LXW_BORDER_THIN); // 下边框
    format_set_right(moneyformat, LXW_BORDER_THIN); // 右边框
     */
}

- (void)createTrafficForm:(NSArray *)dataArray
{
    [self setupFormContent:dataArray];
}

- (void)setupFormContent:(NSArray *)dataArray
{
    // 设置列宽
    worksheet_set_column(worksheet, 1, 2, 30, NULL); // B、C两列宽度（1:起始列 2:终始列 30:列宽）
    worksheet_set_column(worksheet, 3, 3, 25, NULL); // D列宽度（3:起始列 3:终始列 25:列宽）
    
    worksheet_write_string(worksheet, ++self.rowNum, 1, "日期", contentformat);
    worksheet_write_string(worksheet, self.rowNum, 2, "电话", contentformat);
    worksheet_write_string(worksheet, self.rowNum, 3, "金额", contentformat);
    
    for (int i = 0; i < dataArray.count; i++) {
        NSDictionary *dic = dataArray[i];
        worksheet_write_string(worksheet, ++self.rowNum, 1, [dic[@"time"] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
        worksheet_write_string(worksheet, self.rowNum, 2,  [dic[@"phone"] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
        worksheet_write_number(worksheet, self.rowNum, 3, [dic[@"money"] doubleValue], moneyformat);
    }
    
}

#pragma mark - 导出excel
- (void)exportClick
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [documentPath stringByAppendingPathComponent:@"sk测试报表.xlsx"];
    NSURL *url = [NSURL fileURLWithPath:filePath]; // 注意：使用[NSURL URLWithString:filePath]无效
    
    _documentController = [UIDocumentInteractionController interactionControllerWithURL:url];
    _documentController.delegate = self;
    
    [self presentOpenInMenu];
}

- (void)presentOpenInMenu
{
    [_documentController presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES]; // 菜单操作
}


#pragma mark - Click
- (void)backClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - WKWebView Delegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"页面开始加载时调用");
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    NSLog(@"当内容开始返回时调用");
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"页面加载完成之后调用");
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"页面加载失败时调用");
}

// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"接收到服务器跳转请求之后调用");
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - Getter And Setter
- (UIButton *)excelBtn
{
    if (_excelBtn) return _excelBtn;
    _excelBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, NAV_H, (ScreenWidth-150)/2.0, 45)];
    [_excelBtn setTitle:@"生成excel" forState:UIControlStateNormal];
    _excelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:22];
    _excelBtn.backgroundColor = [UIColor orangeColor];
    _excelBtn.layer.cornerRadius = 22.5;
    [_excelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_excelBtn addTarget:self action:@selector(generateClick) forControlEvents:UIControlEventTouchUpInside];
    return _excelBtn;
}

- (UIButton *)exportBtn
{
    if (_exportBtn) return _exportBtn;
    _exportBtn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth/2.0+25, NAV_H, (ScreenWidth-150)/2.0, 45)];
    [_exportBtn setTitle:@"导出excel" forState:UIControlStateNormal];
    _exportBtn.titleLabel.font = [UIFont boldSystemFontOfSize:22];
    _exportBtn.backgroundColor = [UIColor orangeColor];
    _exportBtn.layer.cornerRadius = 22.5;
    [_exportBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_exportBtn addTarget:self action:@selector(exportClick) forControlEvents:UIControlEventTouchUpInside];
    return _exportBtn;
}

- (WKWebView *)testWebView
{
    if (_testWebView) return _testWebView;
    _testWebView = [[WKWebView alloc]initWithFrame:CGRectMake(0, NAV_H+60, ScreenWidth, ScreenHeight-NAV_H-60-SBA_H-55)];
    _testWebView.navigationDelegate = self;
    _testWebView.UIDelegate = self;
    _testWebView.backgroundColor = [UIColor purpleColor];
    return _testWebView;
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
