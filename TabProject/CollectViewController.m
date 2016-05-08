//
//  SecondViewController.m
//  TabProject
//
//  Created by gaoyan on 3/20/16.
//  Copyright © 2016 gaoyan. All rights reserved.
//

#import "CollectViewController.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "ImageModel.h"
#import "MJRefresh.h"
#import "DMHttpTool.h"
#import "IDMPhotoBrowser.h"
#import "SelectImageCell.h"
#import "DataManager.h"
#import "MySVProgressHUD.h"

#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
@interface CollectViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, IDMPhotoBrowserDelegate, CHTCollectionViewDelegateWaterfallLayout, UIGestureRecognizerDelegate>
{
    BOOL _isEdit;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *lists;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, strong) DataManager *dbManager;
@end

@implementation CollectViewController
static NSString* const imageCellIdentifier = @"DoubanImageCell";

- (void)viewDidLoad {
    [super viewDidLoad];
     _lists = [[NSMutableArray alloc]init];
    _photos = [[NSMutableArray alloc]init];
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    _dbManager = [[DataManager alloc]init];
    if (isPad)
        ((CHTCollectionViewWaterfallLayout*)self.collectionView.collectionViewLayout).columnCount = 3;
    self.width = size.width;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SelectImageCell" bundle:nil] forCellWithReuseIdentifier:imageCellIdentifier];
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.collectionView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    [self.collectionView.mj_header beginRefreshing];
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self.collectionView addGestureRecognizer:lpgr];
    [self registerImageNotification];
    
}
- (void) loadNewData
{
    int offset = 0;
    int limit = 10;
    [self.lists removeAllObjects];
    [_photos removeAllObjects];
    NSMutableArray *result = [_dbManager selectData:limit andOffset:offset];
    [self.lists addObjectsFromArray:result];
    
    for (ImageModel *model in result) {
        IDMPhoto *photo = [IDMPhoto photoWithURL:[NSURL URLWithString: model.src]];
        photo.caption = model.title;
        [_photos addObject:photo];
    }
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointMake(0,  -50) animated:YES];
    
//    NSString * query;
//    if (!query) {
//        query = @"校花";
//    }
//    NSDictionary *parameter = @{@"start": @(offset), @"q":query};
//    [DMHttpTool GET:IMAGE_URL parameters:parameter success:^(id responseObject) {
//        [self.lists removeAllObjects];
//        [self.photos removeAllObjects];
//        [self.collectionView.mj_header endRefreshing];
//        NSArray *data = responseObject[@"images"];
//        for (NSDictionary *dict in data) {
//            ImageModel *model = [ImageModel imageWithDict:dict];
//            [self.lists addObject:model];
//            IDMPhoto *photo = [IDMPhoto photoWithURL:[NSURL URLWithString: model.src]];
//            photo.caption = model.title;
//            [_photos addObject:photo];
//
//        }
//        [self.collectionView reloadData];
//        [self.collectionView setContentOffset:CGPointMake(0,  -50) animated:YES];
//    } failure:^(NSError *error) {
//        [self.collectionView.mj_header endRefreshing];
//    }];

}
- (void) loadMoreData
{
    int offset = [_lists count];
    int limit = 10;
    NSMutableArray *result = [_dbManager selectData:limit andOffset:offset];
    [self.lists addObjectsFromArray:result];
    
    for (ImageModel *model in result) {
        IDMPhoto *photo = [IDMPhoto photoWithURL:[NSURL URLWithString: model.src]];
        photo.caption = model.title;
        [_photos addObject:photo];
    }
    [self.collectionView.mj_footer endRefreshing];
    [self.collectionView reloadData];

}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _lists.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
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
// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
     SelectImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:imageCellIdentifier forIndexPath:indexPath];
    if (_isEdit) {
        cell.deleteBtn.hidden = YES;
    }else {
        cell.deleteBtn.hidden = YES;
    }
    ImageModel *image = self.lists[indexPath.item];
    [cell setImageData:image];
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.0f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0f;
}


-(void) handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.collectionView];
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        // get the cell at indexPath (the one you long pressed)
        UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        //_isEdit = !_isEdit;
        [self showDeleteDialog:indexPath];
        //[self.collectionView reloadData];
        // do stuff with the cell
    }
}
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:_photos animatedFromView: collectionView];
    browser.delegate = self;
    browser.displayActionButton = YES;
    browser.displayArrowButton = YES;
    browser.displayCounterLabel = YES;
    browser.displayToolbar = YES;
    browser.usePopAnimation = YES;
    [browser setInitialPageIndex:indexPath.row];
    SelectImageCell *cell = (SelectImageCell *)[collectionView cellForItemAtIndexPath:indexPath];
    browser.scaleImage = [cell.image image];
    [self presentViewController:browser animated:YES completion:nil];
}

- (void) showDeleteDialog:(NSIndexPath *)indexPath
{
    NSString *title = NSLocalizedString(@"delete_dialog_title", @"Delete Image");
    NSString *msg = NSLocalizedString(@"delete_dialog_msg", @"");
    NSString *cancel = NSLocalizedString(@"cancel", @"Cancel");
    NSString *confirm = NSLocalizedString(@"confirm", @"Confirm");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    //__weak typeof(alert) wAlert = alert;
    [alert addAction:[UIAlertAction actionWithTitle:confirm style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //点击确定时调用这个.
        int result = [_dbManager deleteData:[_lists objectAtIndex:indexPath.item]];
        if (result >= 0) {
            [_lists removeObjectAtIndex:indexPath.item];
            [_collectionView reloadData];
        }else {
            [SVProgressHUD revealErrorWithStatus:@"删除失败，请稍后再试"];
        }
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    
}
- (void) registerImageNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageChangeNotification:) name:@"ImageChange" object:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
//接收到通知，并将数据加入瀑布流.
- (void)imageChangeNotification:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    ImageModel* model = [dict objectForKey:@"image"];
    if (model != nil) {
        for (ImageModel *item in _lists) {
            if (item._id == model._id) {
                return;
            }
        }
    }
    [_lists addObject:model];
    [_collectionView reloadData];
}
@end
