

#import "DmcPickerViewController.h"
#import "CollectionViewCell.h"
#import "PreviewViewController.h"
#import "AlbumListView.h"
#import <Photos/Photos.h>
#define fDeviceWidth ([UIScreen mainScreen].bounds.size.width)  //设备高度的宏
#define fDeviceHeight ([UIScreen mainScreen].bounds.size.height)
@interface DmcPickerViewController (){
     UIBarButtonItem *preview;
     int litemCount;
     UICollectionViewFlowLayout *flowLayout ;
     UILabel * titleNameLabel;
     UIView * titleView;
     UIButton * titleArrow;
     UIView * darkView;
     AlbumListView *albumlistView;
     NSMutableArray  *albumsTitlelist;
     NSMutableArray  * dataSource;
     NSInteger nowSelectAlbum;
}

@property (strong, nonatomic) PHImageManager *manager;
@end

@implementation DmcPickerViewController
    
- (void)viewDidLoad {
    //init config
    self.maxSelectCount=self.maxSelectCount>0?self.maxSelectCount:15;
    self.maxSelectSize=self.maxSelectSize>0?self.maxSelectSize:1048576;
    self.selectMode=self.selectMode>0?self.selectMode:101;
    //config end
    
    [super viewDidLoad];
    [self initView];
    [self requestPermission];
}
    
-(void)initView{
    self.view.backgroundColor=[UIColor whiteColor];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done",nil) style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel",nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    self.navigationItem.leftBarButtonItem=leftButtonItem;
    
    
    //[self setTitleView:self.selectMode==102?NSLocalizedString(@"Video",nil):NSLocalizedString(@"All",nil)];
    
    //bottom bar
    [self.navigationController  setToolbarHidden:NO animated:YES];
    preview = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Preview",nil) style:UIBarButtonItemStylePlain target:self action:@selector(preview)];
    [self setToolbarItems:@[preview] animated:YES];
    [self setBtnStatus];
    [self.view addSubview:self.collectionView];
}

-(void)setTitleView:(NSString *) title{

    float arrowHeight=self.navigationController.navigationBar.frame.size.height/3;
    if(!titleNameLabel){
        titleNameLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, self.navigationController.navigationBar.frame.size.height)];
        titleNameLabel.textColor=[UIColor blackColor];
        titleNameLabel.font=[UIFont systemFontOfSize:17.5];
        titleNameLabel.text=title;
        [titleNameLabel sizeToFit];
        titleView=[[UIView alloc]init];
        
        titleNameLabel.center=CGPointMake(titleNameLabel.bounds.size.width/2,titleView.bounds.size.height/2);
        [titleView addSubview:titleNameLabel];
        
        titleArrow=[UIButton buttonWithType:UIButtonTypeCustom];
        titleArrow.frame=CGRectMake(titleNameLabel.frame.size.width+2, 0, arrowHeight, arrowHeight);
        titleArrow.userInteractionEnabled=NO;
        [titleArrow setImage:[UIImage imageNamed:@"dmcPicker.bundle/down_arrow.png"] forState:UIControlStateNormal];
        [titleArrow setImage:[UIImage imageNamed:@"dmcPicker.bundle/up_arrow.png"] forState:UIControlStateSelected];
        [titleView addSubview:titleArrow];
        titleArrow.center=CGPointMake(titleNameLabel.frame.size.width+arrowHeight/2+2,titleView.bounds.size.height/2);
        
        //添加点击手势
        UITapGestureRecognizer * tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(titleTap:)];
        [titleView addGestureRecognizer:tapGesture];
        self.navigationItem.titleView=titleView;
    }
    titleNameLabel.text=title;
    [titleNameLabel sizeToFit];

    titleView.frame=CGRectMake(0, 0, titleNameLabel.frame.size.width+arrowHeight+2, self.navigationController.navigationBar.frame.size.height);
    titleNameLabel.center=CGPointMake(titleNameLabel.bounds.size.width/2,titleView.bounds.size.height/2);
    titleArrow.frame=CGRectMake(titleNameLabel.frame.size.width+2, 0, arrowHeight, arrowHeight);
    titleArrow.center=CGPointMake(titleNameLabel.frame.size.width+arrowHeight/2+2,titleView.bounds.size.height/2);
}

- (void)titleTap:(UITapGestureRecognizer *)tap {

    if(!albumlistView){
        CGFloat y=self.navigationController.navigationBar.frame.origin.y+self.navigationController.navigationBar.frame.size.height;
        darkView=[[UIView alloc]initWithFrame:CGRectMake(0, y, self.navigationController.navigationBar.frame.size.width, fDeviceHeight)];
        darkView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.4f];
        UITapGestureRecognizer * tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(darkViewTap:)];
        [darkView addGestureRecognizer:tapGesture];
        [self.view addSubview:darkView];
        albumlistView=[[AlbumListView alloc]initWithFrame:CGRectMake(0, y, self.navigationController.navigationBar.frame.size.width, fDeviceHeight*0.6)];
        [albumlistView setListDataSource:dataSource dataNameSource:albumsTitlelist nowSelectAlbum:nowSelectAlbum];
        __weak DmcPickerViewController* weakSelf = self;
        //设置选择相册之后的block回调
        [albumlistView setDidSelectAlbumBlock:^(NSInteger index) {
            
            [weakSelf show:index];
            
        }];
        [self.view addSubview:albumlistView];
        titleArrow.selected=YES;
//        albumlist.transform = CGAffineTransformScale(CGAffineTransformIdentity,self.navigationController.navigationBar.frame.size.width, CGFLOAT_MIN);
//        [UIView animateWithDuration:0.8 animations:^{
//            albumlist.transform =  CGAffineTransformScale(CGAffineTransformIdentity,self.navigationController.navigationBar.frame.size.width, 1.0);
//        }];
//        self.navigationController.toolbar.alpha=0.4;
        [self.navigationController  setToolbarHidden:YES  animated:YES];
        
    }else{
        [self hiddenAlbumlistView];
    }
}

- (void)darkViewTap:(UITapGestureRecognizer *)tap {
    darkView.hidden=YES;
    [self hiddenAlbumlistView];
}


-(void)hiddenAlbumlistView{
    titleArrow.selected=NO;
    [darkView setHidden:YES];
    [albumlistView setHidden:YES];
    albumlistView=nil;
    darkView=nil;
    [self.navigationController  setToolbarHidden:NO  animated:YES];
}

    
-(void) preview{
    PreviewViewController * dmc=[[PreviewViewController alloc] init];
    dmc._delegate=self;
    dmc.preArray=selectArray;
    [self.navigationController pushViewController:dmc animated:YES]; // 调用pushViewController
}
    
-(void) done{
    [self._delegate resultPicker:selectArray];
    [self dismissViewControllerAnimated:YES completion:nil];
}
    
-(void) cancel{
    NSMutableArray *nilArray=[[NSMutableArray alloc] init];
    [self._delegate resultPicker:nilArray];
    [self dismissViewControllerAnimated:YES completion:nil];
}
    
-(void)requestPermission{
    //监测权限
    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Unable to access album",nil) message:NSLocalizedString(@"Please allow to access your album",nil) preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil) style:UIAlertActionStyleDefault handler:nil]];
                [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Setting",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }]];
                [self presentViewController:alert animated:YES completion:nil];
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self getAlassetData];
                });
            }
        }];
    }else {
        [self getAlassetData];
    }
}
    
-(void) getAlassetData{
    
    selectArray=[[NSMutableArray alloc] init];
    albumsTitlelist=[[NSMutableArray alloc] init];
    dataSource=[[NSMutableArray alloc] init];
   
    
    //获取相册
    PHFetchResult *smartAlbums = [PHAssetCollection       fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                                subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                           subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    PHFetchResult *userCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    NSArray *allAlbums  = @[smartAlbums, userCollections, syncedAlbums];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];

    if(self.selectMode==100){
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    }else if(self.selectMode==102){
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
    }
    
    int defaultSelection, i = 0; //为了进入选择界面默认显示CameraRoll下的图片

    for (PHFetchResult *fetchResult in allAlbums) {
        for (PHAssetCollection *collection in fetchResult) {
            // 有可能是PHCollectionList类的的对象，过滤掉
            if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
            // 过滤空相册
            if (collection.estimatedAssetCount <= 0) continue;
            if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden) continue; //包含隐藏照片或视频的文件夹
            if (collection.assetCollectionSubtype == 1000000201) continue; //『最近删除』相册
            if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                defaultSelection = i;
            }
            PHFetchResult *group = [PHAsset fetchAssetsInAssetCollection:collection options:options];
            if([group count]>0){
                [albumsTitlelist addObject:collection.localizedTitle];
                [dataSource addObject:group];
                i++;
            }
        }
    }
    
    _manager = [PHImageManager defaultManager];
    [self show: defaultSelection];
}

-(void)show:(NSInteger) index {
    if([dataSource count]>0){
        fetchResult = dataSource[index];
        [self setTitleView:albumsTitlelist[index]];
        [_collectionView reloadData];
        [self hiddenAlbumlistView];
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]  atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        nowSelectAlbum=index;
    }
}


// TO DO
//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
//
//    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
//    [coordinator animateAlongsideTransition:^(id  _Nonnull context) {
//        [_collectionView.collectionViewLayout invalidateLayout];
//        [UIView performWithoutAnimation:^{
//            CGFloat w= [UIScreen mainScreen].bounds.size.width;
//            CGFloat h= [UIScreen mainScreen].bounds.size.height;
//            _collectionView.frame=CGRectMake(0, 0,w, h);
//
//            flowLayout.itemSize =CGSizeMake((w-(litemCount-1))/litemCount, (w-(litemCount-1))/litemCount);
//
//            [_collectionView setCollectionViewLayout:flowLayout];
//
//            [_collectionView layoutIfNeeded];
//        }];
//        [UIView performWithoutAnimation:^{
//
//            [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
//        }];
//    } completion:^(id  _Nonnull context) {
//
//    }];
//}

#pragma mark - 创建collectionView并设置代理
- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        
        flowLayout = [[UICollectionViewFlowLayout alloc] init];
        
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, fDeviceWidth, fDeviceHeight) collectionViewLayout:flowLayout];
        
        litemCount=3;
        if([[UIDevice currentDevice].model isEqualToString:@"iPad"]){
            litemCount=8;
        }
        //定义每个UICollectionView 的大小
        flowLayout.itemSize = CGSizeMake((fDeviceWidth-(litemCount-1))/litemCount, (fDeviceWidth-(litemCount-1))/litemCount);
        //定义每个UICollectionView 横向的间距
        flowLayout.minimumLineSpacing = 1;
        //定义每个UICollectionView 纵向的间距
        flowLayout.minimumInteritemSpacing = 1;
        //定义每个UICollectionView 的边距距
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 5, 0);//上左下右
        
        //注册cell和ReusableView（相当于头部）
        [_collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        //[_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView"];
        
        //设置代理
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        //背景颜色
        _collectionView.backgroundColor = [UIColor whiteColor];
        //自适应大小
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
    }
    return _collectionView;
}
    
    
    
    
#pragma mark - UICollectionView delegate dataSource
#pragma mark 定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return fetchResult.count;
}
    
#pragma mark 定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
    
#pragma mark 每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    [cell sizeToFit];
    PHAsset *asset=fetchResult[indexPath.item];
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = YES;
    [_manager requestImageForAsset:asset targetSize:CGSizeMake(200 , 200)  contentMode:PHImageContentModeAspectFill options:option
                     resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                        if (downloadFinined && result) { 
                            cell.imgView.image = result;
                        }
                     }];
    NSInteger i=[self isSelect:asset];
    if(asset.mediaType==PHAssetMediaTypeVideo){
        cell.labelL.hidden=NO;
        cell.labelR.hidden=NO;
        cell.labeGIF.hidden=YES;
        
        NSString *dtime=[NSString stringWithFormat:@"%.0f",asset.duration];
        cell.labelL.text = [@" "stringByAppendingString:NSLocalizedString(@"Video",nil)];
        //Uilable默认会去除尾部空格所以处理一下
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        style.tailIndent = -3.0f;
        style.alignment=NSTextAlignmentRight;
        NSString *dtimeStr=[self getNewTimeFromDurationSecond:dtime.integerValue];
        NSAttributedString *attrTextR = [[NSAttributedString alloc] initWithString:dtimeStr attributes:@{ NSParagraphStyleAttributeName : style}];
        cell.labelR.attributedText=attrTextR;
    }else{
        NSString *fileName =[asset valueForKey:@"filename"];
        NSString * fileExtension = [fileName pathExtension];
        cell.labeGIF.hidden=[@"GIF" caseInsensitiveCompare:fileExtension]?YES:NO;
        cell.labelL.hidden=YES;
        cell.labelR.hidden=YES;
    }
    
    if(i<0){
        [self hidenSelectView:cell];
    }else{
        [self showSelectView:cell];
    }
    return cell;
}
    
    
    //UICollectionView被选中时调用的方法
-( void )collectionView:( UICollectionView *)collectionView didSelectItemAtIndexPath:( NSIndexPath *)indexPath{
    
    PHAsset * asset=fetchResult[indexPath.row];
    NSInteger i=[self isSelect:asset];
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if([selectArray count] >= self.maxSelectCount && i < 0){
        [self alertMax];
    }else{
        if([selectArray count] > self.maxSelectCount){
            [self alertMax];
        }else if([self assetFileSize:asset] > self.maxSelectSize) {
            [self alertSize];
        } else {
            i<0?[selectArray addObject:asset]:[selectArray removeObject:asset];
            i<0?[self showSelectView:cell]:[self hidenSelectView:cell];
        }
    }
    
    [self setBtnStatus];
}
    
-(void)setBtnStatus{
    if([selectArray count]>0){
        self.navigationItem.rightBarButtonItem.enabled= YES;
        preview.enabled= YES;
        preview.title= [NSLocalizedString(@"Preview",nil)stringByAppendingString:[NSString stringWithFormat:@"(%lu)",(unsigned long)[selectArray count]]];
    }else{
        self.navigationItem.rightBarButtonItem.enabled= NO;
        preview.title= NSLocalizedString(@"Preview",nil);
        preview.enabled= NO;
    }
}
    
-(void)showSelectView:( CollectionViewCell *)cell{
    cell.checkView.hidden=NO;
    cell.whiteView.hidden=NO;
    cell.whiteView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    cell.checkView.image=[UIImage imageNamed:@"dmcPicker.bundle/select80.png"];
}
    
-(void)hidenSelectView:( CollectionViewCell *)cell{
    cell.checkView.hidden=YES;
    cell.whiteView.hidden=YES;
}
    
-(void) previewResultPicker:(NSMutableArray*) srray
{
    selectArray=srray;
    [self setBtnStatus];
    [_collectionView reloadData];
}

-(void) previewDonePicker:(NSMutableArray*) srray
{
    [self._delegate resultPicker:srray];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(long) assetFileSize:(PHAsset *)asset
{
	__block long imageSize = 0;

	if(asset.mediaType == PHAssetMediaTypeVideo) {
		PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
		options.version = PHVideoRequestOptionsVersionOriginal;

		[[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
			if([asset isKindOfClass:[AVURLAsset class]]) {
				AVURLAsset* urlAsset = (AVURLAsset*)asset;
				NSNumber *size;

				[urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
				NSLog(@"%lu", (unsigned long)size);
				imageSize = (unsigned long)size;
			}
		}];
	} else {
		// Fetch image data to retrieve file size and path
		PHImageRequestOptions * options = [[PHImageRequestOptions alloc] init];
		options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
		options.resizeMode = PHImageRequestOptionsResizeModeExact;
		options.synchronous = YES; //Set this to NO if is needed

    	[[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
		    NSLog(@"%lu", (unsigned long)imageData.length);
		    imageSize = (unsigned long)imageData.length;
		}];
	}
    return imageSize;
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
    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
    
-(void)alertMax{
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"maxSelectAlert", nil), self.maxSelectCount];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok",nil) style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)alertSize{
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"maxSizeAlert", nil), (float)self.maxSelectSize/1048576];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok",nil) style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration {
    NSString *newTime;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"0:0%ld",(long)duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"0:%ld",(long)duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%ld:0%ld",(long)min,(long)sec];
        } else {
            newTime = [NSString stringWithFormat:@"%ld:%ld",(long)min,(long)sec];
        }
    }
    return newTime;
}

@end
