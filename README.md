# PYSearchDemo  
PYSearch + tableview上拉分页添加 ViewController  
基于 https://github.com/ko1o/PYSearch 的二次开发，我fork了一份原代码在 https://github.com/foolsparadise/PYSearch ，本工程为修改后的版本  
以下为ViewController所有代码  
```usage  
[self.navigationController pushViewController:[PYSearchDemo new] animated:YES];
```  
``` .h  
#import <UIKit/UIKit.h>
#import "EVNCustomSearchBar.h"
@interface PYSearchDemo : UIViewController<EVNCustomSearchBarDelegate>
@property (strong, nonatomic) EVNCustomSearchBar *searchBar;
@end
``` 
``` .m  
#import "PYSearchDemo.h"
#import "PYSearch.h"

@interface PYSearchDemo () <UITableViewDelegate,UITableViewDataSource,PYSearchViewControllerDelegate>
@property(nonatomic,strong)NSString *PYSearchKey;
@property(nonatomic, strong)UITableView *PYSearchTableView;
@property (nonatomic, assign) NSInteger PYSearchPage;
@property (nonatomic, assign) NSInteger PYSearchPagesize;
@property(nonatomic, strong)NSMutableArray *PYSearchResultList;
@end
#define iOSVersionGreaterThanOrEqualTo(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
@implementation PYSearchDemo
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 弹出键盘
    [self.searchBar becomeFirstResponder];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    __weak typeof(self) weakSelf = self;
    self.PYSearchPage = 1;
    self.PYSearchPagesize = 20;
    
    [self.view addSubview:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.view.mas_left);
        make.top.mas_equalTo(weakSelf.view.mas_top).mas_offset(APP_STATUSBAR_HEIGHT);
        make.right.mas_equalTo(weakSelf.view.mas_right);
        make.bottom.mas_equalTo(weakSelf.view.mas_top).mas_offset(APP_STATUSBAR_HEIGHT+50);
    }];
    [self initSearchBar];
    
    self.PYSearchTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.PYSearchTableView.delegate = self;
    self.PYSearchTableView.dataSource = self;
    [self.view addSubview:_PYSearchTableView];
    _PYSearchTableView.separatorColor = [UIColor containerColor];
    _PYSearchTableView.backgroundColor = [UIColor containerColor];
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
            [weakSelf.PYSearchResultList addObject:obj];
            weakSelf.PYSearchPage = weakSelf.PYSearchPage+1;
            [weakSelf.PYSearchTableView reloadData];
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
        _searchBar.backgroundColor = [UIColor clearColor]; // 清空searchBar的背景色
        _searchBar.iconImage = [UIImage imageNamed:@"EVNCustomSearchBar.bundle/searchImageBlue.png"];;
        _searchBar.iconAlign = EVNCustomSearchBarIconAlignCenter;
        [_searchBar setPlaceholder:@"  在此输入搜索关键字"];  // 搜索框的占位符
        _searchBar.placeholderColor = TextGrayColor;
        _searchBar.delegate = self; // 设置代理
        [_searchBar sizeToFit];
    }
    return _searchBar;
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
    Select1exLrcTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
        cell = [[SelectedTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    IDObject *obj = [self.PYSearchResultList objectAtIndex:indexPath.row];
    NSString *title = obj.objtitle;
    //[cell configWithTitle:obj.objtitle withSubTitle:obj.objbody];
    cell.selectedBackgroundView = [[UIView alloc] init];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellColor];
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
    IDObject *obj = [self.PYSearchResultList objectAtIndex:indexPath.row];
    NSLog(@"%@", obj);
    NSArray *vcs = [weakSelf.rt_navigationController rt_viewControllers];
    for (UIViewController *vc in vcs) {
        if ([vc isKindOfClass:[NSClassFromString(@"someRootViewController") class]]
            )
        {
            someRootViewController *view = (someRootViewController *)vc;
            view.IDObject = obj; //传此object
            [weakSelf.navigationController popToViewController:view animated:YES];
            return;
        }
    }
    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark - PYSearchViewControllerDelegate
- (void)searchViewController:(PYSearchViewController *)searchViewController searchTextDidChange:(UISearchBar *)seachBar searchText:(NSString *)searchText
{
    if (searchText.length) {
        __weak typeof(self) weakSelf = self;
        //search block and ... { } like ...
        {
            {
                weakSelf.searchItems = [[NSMutableArray alloc] initWithCapacity:999];
                NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:999];
                for (NSDictionary *dic in resultArray)
                {
                    IDObject *obj = [[IDObject alloc] initWithDictionary:dic];
                    [arr addObject:obj.objtitle];
                    [weakSelf.searchItems addObject:obj];
                    searchViewController.searchSuggestions = arr;
                }
            }
        }];
    }
}

@end
```  
