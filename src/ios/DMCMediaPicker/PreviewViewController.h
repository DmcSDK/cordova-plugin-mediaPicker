

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
@protocol DmcPreviewDelegate<NSObject>
-(void) previewResultPicker:(NSMutableArray*) selectArray;
-(void) previewDonePicker:(NSMutableArray*) selectArray;
@end
@interface PreviewViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, retain) NSMutableArray *preArray;
@property (nonatomic,weak)id<DmcPreviewDelegate> _delegate;
@end
