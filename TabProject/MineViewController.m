//
//  MineViewController.m
//  TabProject
//
//  Created by gaoyan on 3/22/16.
//  Copyright © 2016 gaoyan. All rights reserved.
//

#import "MineViewController.h"
#import "AFNetworking.h"
#import "DMHttpTool.h"
#import <AVOSCloud/AVOSCloud.h>
#import <AdSupport/AdSupport.h>
#import "SKTagView.h"
#import <UIKit/UIKit.h>
#import "Masonry.h"
#import "DocumentManager.h"
#import "DataManager.h"

@interface MineViewController()
{
    
}
@property (weak, nonatomic) IBOutlet UIScrollView *rootView;
@property (nonatomic, strong) SKTagView *tagView;

@property (weak, nonatomic) IBOutlet UIView *keywordView;

@property (weak, nonatomic) IBOutlet UIButton *keywordBtn;
@property (weak, nonatomic) IBOutlet UILabel *localCount;
@property (weak, nonatomic) IBOutlet UILabel *remoteCount;

@property (weak, nonatomic) IBOutlet UIButton *syncBtn;
@property (weak, nonatomic) IBOutlet UILabel *remoteLable;
@property (weak, nonatomic) IBOutlet UIView *seperator;

@property (nonatomic, strong) NSMutableArray *tags;

@property (nonatomic, strong) DocumentManager *manager;

@property (nonatomic, strong) DataManager *dbManager;

@end


@implementation MineViewController

-(void) viewDidLoad{
    [super viewDidLoad];
    NSString *keyword = [self readKeyword];
    [self.keywordBtn setTitle:keyword forState:UIControlStateNormal];
    [self setupTagView];
    [self getTagList];
    [_syncBtn setHidden:YES];
    [_remoteCount setHidden:YES];
    [_remoteLable setHidden:YES];
    [_seperator setHidden:YES];
    _dbManager = [[DataManager alloc] init];
    [self getLocalCount];
    [self registerImageNotification];
    
}
- (void) setupTagView {
    _tagView = [SKTagView new];
    _tagView.backgroundColor = [UIColor whiteColor];
    _tagView.padding = UIEdgeInsetsMake(10, 25, 10, 25);
    _tagView.interitemSpacing = 8;
    _tagView.lineSpacing = 10;
    
    [self.rootView addSubview:_tagView];
    [self.tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_rootView);
        make.leading.equalTo(_keywordView);
        make.trailing.equalTo(_keywordView);
        make.top.equalTo(_keywordView.mas_bottom).with.offset(24);
    }];
    

}
- (void) initTagViewWithArray:(NSArray *) textArray {
    [textArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SKTag *tag = [SKTag tagWithText:(NSString *)obj];
        tag.textColor = UIColor.whiteColor;
        tag.bgColor = UIColor.orangeColor;
        tag.cornerRadius = 3;
        tag.fontSize = 15;
        tag.padding = UIEdgeInsetsMake(4, 8, 4, 8);
        [self.tagView addTag:tag];
    }];
    
}

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
            NSLog(@"object is %@", [obj objectForKey:@"tag"]);
            [_tags addObject:[obj objectForKey:@"tag"]];
        }
        [self initTagViewWithArray:[_tags copy]];
        __weak typeof(_tags) wTags = _tags;
        __weak typeof(_keywordBtn) wKeywordBtn = _keywordBtn;
        __weak typeof(self) wSelf = self;
        _tagView.didTapTagAtIndex = ^(NSUInteger index){
            NSString *tag = [wTags objectAtIndex:index];
            [wKeywordBtn setTitle: tag forState: UIControlStateNormal];
            [wSelf writeKeyword:tag];
        };
    }];
}

- (void) showInputDialog
{
    NSString *title = NSLocalizedString(@"keyword_dialog_title", @"Input keyword");
    NSString *msg = NSLocalizedString(@"keyword_dialog_msg", @"");
    NSString *cancel = NSLocalizedString(@"cancel", @"Cancel");
    NSString *confirm = NSLocalizedString(@"confirm", @"Confirm");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    //__weak typeof(alert) wAlert = alert;
    [alert addAction:[UIAlertAction actionWithTitle:confirm style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //点击确定时调用这个.
        NSString *input = alert.textFields.firstObject.text;
        [_keywordBtn setTitle:input forState:UIControlStateNormal];
        [self writeKeyword:input];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:nil]];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = title;
    }];
    [self presentViewController:alert animated:YES completion:nil];
    
}
- (IBAction)onClickKeywordButton:(id)sender {
    [self showInputDialog];
}

-(void) writeKeyword:(NSString *)value
{
    if (_manager == nil) {
        _manager = [[DocumentManager alloc]init];
    }
    [_manager writeDocument:value withKey:@"keyword"];
}
- (NSString *)readKeyword
{
    if (_manager == nil) {
        _manager = [[DocumentManager alloc]init];
    }
    return [_manager readDocument:@"keyword"];
}

- (void) getLocalCount
{
    NSInteger count = [_dbManager getDataCount];
    _localCount.text = [NSString stringWithFormat:@"%ld", count];
}
-(void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ImageChange" object:nil];
    
}
- (void) registerImageNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLocalCount) name:@"ImageChange" object:nil];
}
@end
