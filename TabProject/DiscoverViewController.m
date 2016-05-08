//
//  FirstViewController.m
//  TabProject
//
//  Created by gaoyan on 3/20/16.
//  Copyright © 2016 gaoyan. All rights reserved.
//

#import "DiscoverViewController.h"
#import "DoubanImageCell.h"
#import "MJRefresh.h"
#import "DMHttpTool.h"
#import "ImageModel.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import <AVOSCloud/AVOSCloud.h>
#import <AdSupport/AdSupport.h>
#import "IDMPhotoBrowser.h"
#import "SearchViewController.h"
#import "Masonry.h"
#import "MySearchDelegate.h"
#import "DocumentManager.h"
#import "DataManager.h"
#import "MySVProgressHUD.h"

#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
@interface DiscoverViewController ()<UICollectionViewDataSource, UICollectionViewDelegate,
    CHTCollectionViewDelegateWaterfallLayout, UISearchBarDelegate, IDMPhotoBrowserDelegate, MySearchDelegate,UIGestureRecognizerDelegate>
//UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, strong) NSString *query;
@property (weak, nonatomic) IBOutlet UICollectionView *imageCollection;
@property (weak, nonatomic) IBOutlet UISearchBar *inputKeyword;

@property (nonatomic, strong) NSMutableArray *lists;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *tags;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, strong) SearchViewController *searchController;
@property (nonatomic, strong) DataManager *dbManager;

@end

@implementation DiscoverViewController
static NSString* const imageCellIdentifier = @"DoubanImageCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lists = [NSMutableArray array];
    _photos = [NSMutableArray array];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size =rect.size;
    if (isPad)
        ((CHTCollectionViewWaterfallLayout *)self.imageCollection.collectionViewLayout).columnCount = 3;
    self.width = size.width;
    self.imageCollection.delegate = self;
    self.imageCollection.dataSource = self;
    self.imageCollection.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    [self.imageCollection registerNib:[UINib nibWithNibName:@"ImageCell" bundle:nil] forCellWithReuseIdentifier: imageCellIdentifier];
//    [self.imageCollection registerClass:[DoubanImageCell class] forCellWithReuseIdentifier:@"DoubanImageCell"];
    self.offset = 0;
    self.imageCollection.mj_header = [MJRefreshNormalHeader
                                      headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    [self.imageCollection.mj_header beginRefreshing];
    self.imageCollection.mj_footer = [MJRefreshAutoFooter
                                      footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    [self getDefaultKeyWord];
    _inputKeyword.text = _query;
    _inputKeyword.delegate = self;
    [self uploadUser];
    _searchController = [[SearchViewController alloc] initWithStyle:UITableViewStylePlain];
    //[_searchController.view setFrame:CGRectMake(30, 40, 200, 0)];
    [self.view addSubview:_searchController.view];
    [self.searchController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_inputKeyword.mas_leading).with.offset(20);
        make.top.equalTo(_inputKeyword.mas_bottom);
        make.trailing.equalTo(_inputKeyword.mas_trailing).with.offset(-20);
        make.height.mas_equalTo(@0);
    }];
    [_searchController setOnItemSelect:self];
    [self getTagList];
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self.imageCollection addGestureRecognizer:lpgr];
    _dbManager = [[DataManager alloc]init];
    
}
- (void)getDefaultKeyWord
{
    DocumentManager *manager = [[DocumentManager alloc] init];
    [manager createEditableCopyOfDatabaseIfNeeded];
    _query = [manager readDocument:@"keyword"];
    if (_query == nil) {
        _query = @"校花";
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 加载新数据
-(void)loadNewData
{
    self.offset = 0;
    if (!_query) {
        self.query = @"校花";
    }
    NSDictionary *parameter = @{@"start": @(self.offset), @"q":self.query};
    [DMHttpTool GET:IMAGE_URL parameters:parameter success:^(id responseObject) {
        [self.lists removeAllObjects];
        [self.photos removeAllObjects];
        [self.imageCollection.mj_header endRefreshing];
        NSArray *data = responseObject[@"images"];
        for (NSDictionary *dict in data) {
            ImageModel *model = [ImageModel imageWithDict:dict];
            [self.lists addObject:model];
            IDMPhoto *photo = [IDMPhoto photoWithURL:[NSURL URLWithString: model.src]];
            photo.caption = model.title;
            [_photos addObject:photo];
            
        }
        [self.imageCollection reloadData];
        [self.imageCollection setContentOffset:CGPointMake(0,  -50) animated:YES];
        [SVProgressHUD revealInfoWithStatus:@"长按图片加入收藏"];
    } failure:^(NSError *error) {
        [self.imageCollection.mj_header endRefreshing];
    }];
    
}

-(void)loadMoreData
{
    self.offset += 20;
    NSDictionary *parameters = @{@"start": @(self.offset), @"q":self.query};
    [DMHttpTool GET:IMAGE_URL parameters:parameters success:^(id responseObject) {
        [self.imageCollection.mj_footer endRefreshing];
        NSArray *data = responseObject[@"images"];
        for (NSDictionary *dict in data) {
            ImageModel *model = [ImageModel imageWithDict:dict];
            [self.lists addObject:model];
            IDMPhoto *photo = [IDMPhoto photoWithURL:[NSURL URLWithString: model.src]];
            photo.caption = model.title;
            [_photos addObject:photo];
        }
        [self.imageCollection reloadData];
    } failure:^(NSError *error) {
        [self.imageCollection.mj_footer endRefreshing];
    }];
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.lists.count;
}
-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DoubanImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:imageCellIdentifier forIndexPath:indexPath];
    ImageModel *image = self.lists[indexPath.item];
    [cell setImageData:image];
    return cell;
}
#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageModel *model = [_lists objectAtIndex:indexPath.row];
    NSInteger w = _width / 2 - 20;
        NSInteger h = 0;
    if (model.height <= 0 || model.width <= 0) {
        h = w * 1.5;
    }else {
        h = w * model.height / model.width;
    }
    return CGSizeMake(w, h);
}
//定义每个UICollectionView 的 margin
//-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//    return UIEdgeInsetsMake(5, 5, 5, 5);
//}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.0f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0f;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    CGFloat picDimension = self.view.frame.size.width / 4.0f;
//    return CGSizeMake(picDimension, picDimension);
//}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}
//#pragma mark - CHTCollectionViewDelegateWaterfallLayout
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return [self.cellSizes[indexPath.item % 4] CGSizeValue];
//}
# pragma mark - 隐藏或者显示搜索下拉列表
- (void) setSearchControllerHidden:(BOOL)hidden{
    NSInteger height = hidden?0:180;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    
    [_searchController.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    [UIView commitAnimations];
}
# pragma mark - 点击搜索按钮时调用
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.query = _inputKeyword.text;
    [_inputKeyword endEditing:YES];
    [self setSearchControllerHidden:YES];
    [self loadNewData];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchBar.text.length == 0 || _tags == nil || _tags.count == 0) {
        [self setSearchControllerHidden:YES];
    }else {
        [self setSearchControllerHidden:NO];
    }
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    _inputKeyword.showsCancelButton = YES;
    for(id cc in [searchBar subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            [btn setTitle:@"取消"  forState:UIControlStateNormal];
        }
    }
    if (searchBar.text.length == 0 || _tags == nil || _tags.count == 0) {
        [self setSearchControllerHidden:YES];
    }else {
        [self setSearchControllerHidden:NO];
    }
    NSLog(@"shuould begin");
    return YES;
    
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    _inputKeyword.showsCancelButton = NO;
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [_inputKeyword endEditing:YES];
    [self setSearchControllerHidden:YES];
}

# pragma mark - 点击每张图片时调用.
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:_photos animatedFromView: collectionView];
    browser.delegate = self;
    browser.displayActionButton = YES;
    browser.displayArrowButton = YES;
    browser.displayCounterLabel = YES;
    browser.displayToolbar = YES;
    browser.usePopAnimation = YES;
    [browser setInitialPageIndex:indexPath.row];
    DoubanImageCell *cell = (DoubanImageCell *)[collectionView cellForItemAtIndexPath:indexPath];
    browser.scaleImage = [cell.iconImage image];
    [self presentViewController:browser animated:YES completion:nil];
}
//数据接口.
- (void)uploadUser
{
//    NSString *adid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
//    AVObject *user = [AVObject objectWithClassName:@"IDFA"];
//    [user setObject:adid forKey:@"user"];
//    [user save];
}
#pragma mark - 获取tag接口.
-(void) getTagList{
    AVQuery * query = [AVQuery queryWithClassName:@"Hottag"];
    [query whereKey:@"isActive" equalTo:@YES];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        NSLog(@"object is %@", objects);
        if (_tags == nil) {
            _tags = [NSMutableArray arrayWithCapacity:0];
        }else {
            [_tags removeAllObjects];
        }
        for( AVObject *obj in objects) {
            [_tags addObject:[obj objectForKey:@"tag"]];
        }
        [_searchController setTagList:_tags];
    }];
}

- (void)onSearchItemSelect:(id)content
{
    _inputKeyword.text = (NSString*)content;
    self.query = _inputKeyword.text;
    [_inputKeyword endEditing:YES];
    [self setSearchControllerHidden:YES];
    [self loadNewData];
}
-(void) handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.imageCollection];
    
    NSIndexPath *indexPath = [self.imageCollection indexPathForItemAtPoint:p];
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        // get the cell at indexPath (the one you long pressed)
        //UICollectionViewCell* cell = [self.imageCollection cellForItemAtIndexPath:indexPath];
        //[self showCollectDialog:indexPath];
        int result = [_dbManager insertSingleCoreData:[_lists objectAtIndex:indexPath.item]];
        if (result >= 0) {
            [SVProgressHUD revealSuccessWithStatus:@"图片加入收藏"];
            NSDictionary *data = [NSDictionary dictionaryWithObject:[_lists objectAtIndex:indexPath.item] forKey:@"image"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageChange" object:nil userInfo:data];
        }
        //[self.collectionView reloadData];
        // do stuff with the cell
    }
}

- (void) showCollectDialog:(NSIndexPath *)indexPath
{
    NSString *title = NSLocalizedString(@"delete_dialog_title", @"Delete Image");
    NSString *msg = NSLocalizedString(@"delete_dialog_msg", @"");
    NSString *cancel = NSLocalizedString(@"cancel", @"Cancel");
    NSString *confirm = NSLocalizedString(@"confirm", @"Confirm");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    //__weak typeof(alert) wAlert = alert;
    [alert addAction:[UIAlertAction actionWithTitle:confirm style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //点击确定时调用这个.
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    
}


@end
