

#import "DmcPickerViewController.h"
#import "CollectionViewCell.h"
#import <Photos/Photos.h>
#define fDeviceWidth ([UIScreen mainScreen].bounds.size.width)  //设备高度的宏
#define fDeviceHeight ([UIScreen mainScreen].bounds.size.height)
@interface DmcPickerViewController ()
@property (strong, nonatomic) PHImageManager *manager;
@end

@implementation DmcPickerViewController

- (void)viewDidLoad {
    //init config
    self.maxSelectCount=self.maxSelectCount>0?self.maxSelectCount:15;
    self.selectMode=self.selectMode>0?self.selectMode:101;
    //config end
    
    [super viewDidLoad];
    [self initView];
    [self requestPermission];
    
   
}

-(void)initView{
    
    [[self view]setBackgroundColor:[UIColor greenColor]];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done",nil) style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel",nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    [self setDoneBtnStatus];
    self.navigationItem.leftBarButtonItem=leftButtonItem;
    self.navigationItem.title=NSLocalizedString(@"all",nil);
    
    [self.view addSubview:self.collectionView];
}

-(void) done{
    [self._delegate resultPicker:selectArray];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) cancel{
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

    // 获取所有资源的集合，并按资源的创建时间排序
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    if(self.selectMode==100){
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    }else if(self.selectMode==102){
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
    }
    fetchResult = [PHAsset fetchAssetsWithOptions:options];
    
    _manager = [PHImageManager defaultManager];
    
    [_collectionView reloadData];
}



#pragma mark - 创建collectionView并设置代理
- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        

        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, fDeviceWidth, fDeviceHeight) collectionViewLayout:flowLayout];
        
        int count=3;
        if([[UIDevice currentDevice].model isEqualToString:@"iPad"]){
            count=8;
        }
        //定义每个UICollectionView 的大小
        flowLayout.itemSize = CGSizeMake((fDeviceWidth-2)/count, (fDeviceWidth-2)/count);
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
    [_manager requestImageForAsset:asset
                        targetSize:CGSizeMake(200 , 200)
                       contentMode:PHImageContentModeAspectFill
                           options:nil
                     resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                         cell.imgView.image = result;
                     }];
    NSInteger i=[self isSelect:asset];
    if(asset.mediaType==PHAssetMediaTypeVideo){
        cell.labelL.hidden=NO;
        cell.labelR.hidden=NO;
        
        NSString *dtime=[NSString stringWithFormat:@"%.0f",asset.duration];
        cell.labelL.text=[@"\t"stringByAppendingString:NSLocalizedString(@"Video",nil)];
        cell.labelR.text=[[self getNewTimeFromDurationSecond:dtime.integerValue]stringByAppendingString:@"\t"];
    }else{
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
    NSLog(@"%ld",(long)indexPath.row);
    PHAsset * asset=fetchResult[indexPath.row];
    NSInteger i=[self isSelect:asset];
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if([selectArray count]>=self.maxSelectCount&&i<0){
        [self alertMax];
    }else{
        if([selectArray count]>self.maxSelectCount){
            [self alertMax];
        }else{
            i<0?[selectArray addObject:asset]:[selectArray removeObject:asset];
            i<0?[self showSelectView:cell]:[self hidenSelectView:cell];
        }
    }
    
    [self setDoneBtnStatus];
}

-(void)setDoneBtnStatus{
    if([selectArray count]>0){
        self.navigationItem.rightBarButtonItem.enabled= YES;
    }else{
        self.navigationItem.rightBarButtonItem.enabled= NO;
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
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                             message:NSLocalizedString(@"maxSelectAlert",nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];
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
