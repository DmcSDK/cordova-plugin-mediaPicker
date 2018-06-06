//
//  PreviewCell.h
//  IOSMedaiPicker
//
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImage.h"
@interface PreviewCell : UICollectionViewCell<UIScrollViewDelegate>
 @property(nonatomic ,strong)UIImageView *imgView;
 @property(nonatomic ,strong)UIScrollView *artScrollView;
 @property(nonatomic ,strong)UIImageView *playimgView;
 @property(nonatomic ,strong)FLAnimatedImageView  *gifView;
 @property(nonatomic, copy) void (^cellTapClick)();
-(void)setImg:(UIImage *)image;
-(void)setGifImg:(NSData *)image;
@end
