//
//  itPYSearchViewController.h
//  Demo
//
//  Created by foolsparadise on 21/1/2020.
//  Copyright © 2020 github.com/foolsparadise. All rights reserved.

#import "itPYSearchViewController.h"

@interface itPYSearchViewController () <UITableViewDelegate,UITableViewDataSource,PYSearchViewControllerDelegate>
@property(nonatomic,strong)NSString *PYSearchKey;
@property(nonatomic, strong)UITableView *PYSearchTableView;
@property (nonatomic, assign) NSInteger PYSearchPage;
@property (nonatomic, assign) NSInteger PYSearchPagesize;
@property(nonatomic, strong)NSMutableArray *PYSearchResultList;
@property(nonatomic, strong)NSMutableArray *textItems;

@end
#define iOSVersionGreaterThanOrEqualTo(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
@implementation itPYSearchViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.tabBarController.tabBar.hidden = YES;
    
    // 弹出键盘
    [self.searchBar becomeFirstResponder];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.view.backgroundColor = [UIColor whiteColor];//[UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:0.99];
    __weak typeof(self) weakSelf = self;
    
    self.PYSearchPage = 1;
    self.PYSearchPagesize = 20;
    
    [self.view addSubview:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.view.mas_left).mas_offset(10);
        make.right.mas_equalTo(weakSelf.view.mas_right).mas_offset(-10);
        make.top.mas_equalTo(weakSelf.view.mas_top).mas_offset(APP_STATUSBAR_HEIGHT);
        make.bottom.mas_equalTo(weakSelf.view.mas_top).mas_offset(APP_STATUSBAR_HEIGHT+50);
    }];
    [self initSearchBar];
    
    self.PYSearchTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.PYSearchTableView.delegate = self;
    self.PYSearchTableView.dataSource = self;
    [self.view addSubview:_PYSearchTableView];
    _PYSearchTableView.separatorColor = [UIColor whiteColor];
    _PYSearchTableView.backgroundColor = [UIColor whiteColor];
    //_PYSearchTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    _PYSearchTableView.mj_header.automaticallyChangeAlpha = YES;
    // 上拉刷新
    _PYSearchTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        __weak typeof(self) weakSelf = self;
        NSLog(@"%@ %ld %ld", weakSelf.PYSearchKey, weakSelf.PYSearchPage, weakSelf.PYSearchPagesize);
        if(weakSelf.PYSearchKey.length<1) { [_PYSearchTableView.mj_footer endRefreshing]; return; }
        //search block and ... { } like ...
        {
//            //todo
//            [weakSelf.PYSearchResultList addObject:obj];
//            weakSelf.PYSearchPage = weakSelf.PYSearchPage+1;
//            [weakSelf.PYSearchTableView reloadData];
        }
        [_PYSearchTableView.mj_footer endRefreshing];

    }];
    [_PYSearchTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.view.mas_left);
        make.top.mas_equalTo(weakSelf.view.mas_top).mas_offset(APP_STATUSBAR_HEIGHT+50);
        make.width.mas_equalTo(weakSelf.view.mas_width);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom);
    }];
    
}
#pragma mark: 设置顶部导航搜索部分
- (void)initSearchBar
{
    //self.navigationItem.titleView = self.searchBar;
    //if (@available(iOS 11.0, *))
    if(iOSVersionGreaterThanOrEqualTo(@"11"))
    {
        [self.searchBar.heightAnchor constraintLessThanOrEqualToConstant:kEVNScreenNavigationBarHeight].active = YES;
    }
    else
    {
        
    }
    
    
}

#pragma mark: getter method EVNCustomSearchBar
- (EVNCustomSearchBar *)searchBar
{
    if (!_searchBar)
    {
//        _searchBar = [[EVNCustomSearchBar alloc] initWithFrame:CGRectMake(0, 0, kEVNScreenWidth, kEVNScreenNavigationBarHeight)];
        _searchBar = [EVNCustomSearchBar new];
        _searchBar.backgroundColor = [UIColor whiteColor]; // 清空searchBar的背景色
        _searchBar.iconImage = [UIImage imageNamed:@"EVNCustomSearchBar.bundle/searchImageDark.png"];;
        _searchBar.iconAlign = EVNCustomSearchBarIconAlignCenter;
        [_searchBar setPlaceholder:NSStringLocalizedInfoPlist(@"  在此输入搜索关键字")];  // 搜索框的占位符
        _searchBar.placeholderColor = [self colorWithHexString:@"#666666" alpha:1.0];
        _searchBar.delegate = self; // 设置代理
        [_searchBar sizeToFit];
    }
    return _searchBar;
}
- (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears

    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }

    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];

    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}
#pragma mark: EVNCustomSearchBar delegate method
- (BOOL)searchBarShouldBeginEditing:(EVNCustomSearchBar *)searchBar
{
//    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
    return YES;
}

- (void)searchBarTextDidBeginEditing:(EVNCustomSearchBar *)searchBar
{
//    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
}

- (BOOL)searchBarShouldEndEditing:(EVNCustomSearchBar *)searchBar
{
//    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
    return YES;
}

- (void)searchBarTextDidEndEditing:(EVNCustomSearchBar *)searchBar
{
//    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
}

- (void)searchBar:(EVNCustomSearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //NSLog(@"class: %@ function:%s (%@)", NSStringFromClass([self class]), __func__, searchText);
    __weak typeof(self) weakSelf = self;
    weakSelf.PYSearchKey = searchText;
    //search block and ... { } like ...
    weakSelf.PYSearchResultList = nil;
    weakSelf.PYSearchResultList = [[NSMutableArray alloc] initWithCapacity:999];
    {
//        //todo
//        NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:999];
//        for (NSDictionary *dic in resultArray)
//        {
//            IDObject *obj = [[IDObject alloc] initWithDictionary:dic];
//            [weakSelf.PYSearchResultList addObject:obj];
//        }
    }
    [weakSelf.PYSearchTableView reloadData];

}

- (BOOL)searchBar:(EVNCustomSearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
//    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
    return YES;
}

- (void)searchBarSearchButtonClicked:(EVNCustomSearchBar *)searchBar
{
//    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
}

- (void)searchBarCancelButtonClicked:(EVNCustomSearchBar *)searchBar
{
//    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.searchBar resignFirstResponder];
}
- (void)leftClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSMutableArray *)PYSearchResultList
{
    if (!_PYSearchResultList) {
        _PYSearchResultList = [[NSMutableArray alloc] initWithCapacity:999];
    }
    return _PYSearchResultList;
}
- (NSMutableArray *)textItems
{
    if (!_textItems) {
        _textItems = [[NSMutableArray alloc] initWithCapacity:999];
    }
    return _textItems;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDelegate
// view
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellId = @"CellId";
    UITableViewCell *cell;
//    //todo
//    Select1exLrcTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
//    if (!cell)
//        cell = [[SelectedTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
//    IDObject *obj = [self.PYSearchResultList objectAtIndex:indexPath.row];
//    NSString *title = obj.objtitle;
//    //[cell configWithTitle:obj.objtitle withSubTitle:obj.objbody];
//    cell.selectedBackgroundView = [[UIView alloc] init];
//    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellColor];
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.PYSearchResultList.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.PYSearchTableView deselectRowAtIndexPath:indexPath animated:YES];
    __weak typeof(self) weakSelf = self;
    //选中了
//    //todo
//    IDObject *obj = [self.PYSearchResultList objectAtIndex:indexPath.row];
//    NSLog(@"%@", obj);
//    NSArray *vcs = [weakSelf.rt_navigationController rt_viewControllers];
//    for (UIViewController *vc in vcs) {
//        if ([vc isKindOfClass:[NSClassFromString(@"someRootViewController") class]]
//            )
//        {
//            someRootViewController *view = (someRootViewController *)vc;
//            view.IDObject = obj; //传此object
//            [weakSelf.navigationController popToViewController:view animated:YES];
//            return;
//        }
//    }
//    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark - PYSearchViewControllerDelegate
- (void)searchViewController:(PYSearchViewController *)searchViewController searchTextDidChange:(UISearchBar *)seachBar searchText:(NSString *)searchText
{
    if (searchText.length) {
        __weak typeof(self) weakSelf = self;
        //search block and ... { } like ...
        {
            {
//                //todo
//                weakSelf.searchItems = [[NSMutableArray alloc] initWithCapacity:999];
//                NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:999];
//                for (NSDictionary *dic in resultArray)
//                {
//                    IDObject *obj = [[IDObject alloc] initWithDictionary:dic];
//                    [arr addObject:obj.objtitle];
//                    [weakSelf.searchItems addObject:obj];
//                    searchViewController.searchSuggestions = arr;
//                }
            }
        }
    }
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
