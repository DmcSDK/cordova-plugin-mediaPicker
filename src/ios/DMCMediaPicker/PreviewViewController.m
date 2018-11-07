

#import "PreviewViewController.h"
#import "PreviewCell.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#define SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define SCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface PreviewViewController (){
    UICollectionView* collectionView;
    UIButton *selectButton;
    NSMutableArray *selectArray;
    UILabel * titleView;
    int nowIndex;
    UICollectionViewFlowLayout *flowLayout ;
}
@end

@implementation PreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    selectArray=[[NSMutableArray alloc]init];
    [selectArray addObjectsFromArray:_preArray];
    [self initView];
}

-(void)setTitleStr:(PHAsset*)asset{
    if(!titleView){
        titleView=[[UILabel alloc]init];
        titleView.frame = CGRectMake(0, 0, 0, self.navigationController.navigationBar.frame.size.height);
        titleView.textAlignment=NSTextAlignmentCenter;
        titleView.numberOfLines=3;
        titleView.adjustsFontSizeToFitWidth = true;
        self.navigationItem.titleView=titleView;
    }


    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:@"yyyy-MM-dd"];

    NSString * day=[dateFormatter stringFromDate:asset.creationDate];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString * time =[dateFormatter stringFromDate:asset.creationDate];
    //获取标题的字符串
    NSString * str=[NSString stringWithFormat:@"%@\n%@",day,time];
    //创建一个带有属性的字符串比如说颜色，字体等文字的属性
    NSMutableAttributedString * attrStr=[[NSMutableAttributedString alloc]initWithString:str];
    
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:[str rangeOfString:day]];
    
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:[str rangeOfString:time]];

    titleView.attributedText=attrStr;
    
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id  _Nonnull context) {
        [collectionView.collectionViewLayout invalidateLayout];
        [UIView performWithoutAnimation:^{
            CGFloat w= [UIScreen mainScreen].bounds.size.width;
            CGFloat h= [UIScreen mainScreen].bounds.size.height;
            collectionView.frame=CGRectMake(0, 0,w, h);
            flowLayout.itemSize = CGSizeMake(w, h);
            [collectionView setCollectionViewLayout:flowLayout];
            PreviewCell *cell = (PreviewCell*)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:nowIndex inSection:0]];
            cell.frame=CGRectMake(0, 0,w, h);
            [cell.artScrollView setZoomScale:1.0 animated:NO];
            cell.artScrollView.frame=CGRectMake(0, 0,w, h);
            cell.imgView.frame=CGRectMake(0, 0,w, h);
            cell.gifView.frame=CGRectMake(0, 0,w, h);
            [collectionView setContentOffset:CGPointMake(nowIndex*w, 0)];
            [collectionView layoutIfNeeded];
        }];
        [UIView performWithoutAnimation:^{
            [collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:nowIndex inSection:0]]];
        }];
    } completion:^(id  _Nonnull context) {

    }];
}



-(void)initView{
    [self setTitleStr:_preArray[0]];
    UIWindow *window=[UIApplication sharedApplication].keyWindow;

    flowLayout= [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(window.bounds.size.width, window.bounds.size.height);
    //定义每个UICollectionView 横向的间距
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    collectionView =[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0,window.bounds.size.width, window.bounds.size.height) collectionViewLayout:flowLayout];
    collectionView.backgroundColor=[UIColor whiteColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.pagingEnabled = YES;
    collectionView.scrollsToTop = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    //collectionView.contentOffset = CGPointMake(0, 0);
    //collectionView.contentSize = CGSizeMake([_preArray count] * window.bounds.size.width,0);
    [collectionView registerClass:[PreviewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.view addSubview: collectionView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // 创建使用自定义图片的UIBarButtonItem
    CGFloat toolH=[self.navigationController toolbar].bounds.size.height*0.65;
    selectButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, toolH, toolH)];
    [selectButton.widthAnchor constraintEqualToConstant:toolH].active = YES;
    [selectButton.heightAnchor constraintEqualToConstant:toolH].active = YES;
    [selectButton setImage:[UIImage imageNamed:@"dmcPicker.bundle/select80.png"] forState:UIControlStateNormal];
    [selectButton addTarget:self action:@selector(setSelectView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * selectButtonItem =[[UIBarButtonItem alloc] initWithCustomView:selectButton];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    [self setToolbarItems:@[selectButtonItem,flexibleSpace,doneButton] animated:YES];
}

#pragma mark collectionView代理方法
//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_preArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    __weak PreviewViewController* weakSelf = self;
    static NSString *identify = @"cell";
    PreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    PHAsset *asset=_preArray[indexPath.item];//访问已释放的对象
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    option.networkAccessAllowed = YES;
    NSString *fileName =[asset valueForKey:@"filename"];
    NSString * fileExtension = [fileName pathExtension];
    if([@"GIF" caseInsensitiveCompare:fileExtension]){
        cell.gifView.hidden=YES;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(SCREEN_WIDTH*3 , SCREENH_HEIGHT*3) contentMode:PHImageContentModeAspectFill options:option                         resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            if (downloadFinined && result) { 
                [cell setImg:result];
            }            
        }];
    }else{
        cell.imgView.hidden=YES;
        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            if (downloadFinined && imageData) { 
                [cell setGifImg:imageData];
            }              
        }];
    }
    
    cell.playimgView.hidden=asset.mediaType==PHAssetMediaTypeVideo?NO:YES;
    [cell setCellTapClick:^{
        asset.mediaType!=PHAssetMediaTypeVideo?[weakSelf barStatus]:[weakSelf playVideo:asset];
    }];
    return cell;
}

-(Boolean) getOrientation
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return YES;
    }else if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft){
        return NO;
    }
    return YES;
}


-(void)playVideo:(PHAsset *)asset
{
    if(asset.mediaType!=PHAssetMediaTypeVideo){
        return;
    }
    [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            AVPlayerViewController *playerViewController = [AVPlayerViewController new];
            playerViewController.player =   [[AVPlayer alloc]initWithPlayerItem:playerItem];
            [self presentViewController:playerViewController animated:YES completion:nil];
            [playerViewController.player play];
        });
        
    }];
}

- ( void)scrollViewDidScroll:( UIScrollView *)scrollView
{
    int lasetSeIndex=nowIndex;
    nowIndex =[self getNowIndex];
    if(lasetSeIndex!=nowIndex){
        [self setTitleStr:_preArray[nowIndex]];
        Boolean select=[self isSelect:_preArray[nowIndex]]<0?YES:NO;
        if(select){
            [selectButton setImage:[UIImage imageNamed:@"dmcPicker.bundle/check_box_default.png"] forState:UIControlStateNormal];
        }else{
            [selectButton setImage:[UIImage imageNamed:@"dmcPicker.bundle/select80.png"] forState:UIControlStateNormal];
        }
    }
}



-(int)getNowIndex{
    // 将collectionView在控制器view的中心点转化成collectionView上的坐标
    CGPoint pInView = [self.view convertPoint:collectionView.center toView:collectionView];
    // 获取这一点的indexPath
    NSIndexPath *visiablePath = [collectionView indexPathForItemAtPoint:pInView];
    return visiablePath.item;
}

-(void)barStatus{
    if([self.navigationController isNavigationBarHidden]){
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        [self.navigationController  setToolbarHidden:NO  animated:NO];
        collectionView.backgroundColor=[UIColor whiteColor];
        
    }else{
       // [self prefersStatusBarHidden];
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        [self.navigationController  setToolbarHidden:YES  animated:NO];
        collectionView.backgroundColor=[UIColor blackColor];
    }
}

-(void)setSelectView{
    Boolean select=[self isSelect:_preArray[nowIndex]]<0?NO:YES;
    if(select){
        [selectButton setImage:[UIImage imageNamed:@"dmcPicker.bundle/check_box_default.png"] forState:UIControlStateNormal];
        [selectArray removeObject:_preArray[nowIndex]];
    }else{
        [selectButton setImage:[UIImage imageNamed:@"dmcPicker.bundle/select80.png"] forState:UIControlStateNormal];
        [selectArray addObject:_preArray[nowIndex]];
    }
}

-(NSInteger)isSelect:(PHAsset *)asset
{
    int is=-1;
    if([selectArray count]<=0){
        return is;
    }
    for(NSInteger i=0;i<[selectArray count];i++){
        PHAsset *now=selectArray[i];
        if ([asset.localIdentifier isEqualToString:now.localIdentifier]) {
            return i;
        }
    }
    return is;
}
    
-(void)done {
   
    [self._delegate previewDonePicker:selectArray];
    
    [self.navigationController popViewControllerAnimated:true];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}
    
- (void)viewWillDisappear:(BOOL)animated {
    [self._delegate previewResultPicker:selectArray];
    [self.navigationController  setToolbarHidden:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
