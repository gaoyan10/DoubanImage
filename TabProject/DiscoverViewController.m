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

#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
@interface DiscoverViewController ()<UICollectionViewDataSource, UICollectionViewDelegate,
    CHTCollectionViewDelegateWaterfallLayout>
//UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, strong) NSString *query;
@property (weak, nonatomic) IBOutlet UICollectionView *imageCollection;
@property (nonatomic, strong) NSMutableArray *lists;
@property (nonatomic, assign) CGFloat width;

@end

@implementation DiscoverViewController
static NSString* const imageCellIdentifier = @"DoubanImageCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lists = [NSMutableArray array];
    
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
    
    // Do any additional setup after loading the view, typically from a nib.
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
        [self.imageCollection.mj_header endRefreshing];
        NSArray *data = responseObject[@"images"];
        for (NSDictionary *dict in data) {
            ImageModel *model = [ImageModel imageWithDict:dict];
            [self.lists addObject:model];
            
        }
        [self.imageCollection reloadData];
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
        h = w;
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

@end
