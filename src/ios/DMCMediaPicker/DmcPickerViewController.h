
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "PreviewViewController.h"
@protocol DmcPickerDelegate<NSObject>
-(void) resultPicker:(NSMutableArray*) selectArray;
@end

@interface DmcPickerViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,DmcPreviewDelegate>{
    NSMutableArray *_cellArray;     //collectionView数据
    PHFetchResult * fetchResult;
    NSMutableArray *selectArray;
}
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic,weak)id<DmcPickerDelegate> _delegate;
/// Default is 9 / 默认最大可选9张图片
@property (nonatomic, assign) NSInteger maxSelectCount;
//'selectMode':101,//101=PICKER_IMAGE_VIDEO , 100=PICKER_IMAGE , 102=PICKER_VIDEO
@property (nonatomic, assign) NSInteger selectMode;
@property (nonatomic, assign) NSInteger maxSelectSize;
@end
