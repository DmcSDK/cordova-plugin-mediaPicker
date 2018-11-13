//
//  AlbumListView.h
//  IOSMedaiPicker
//

#import <UIKit/UIKit.h>

@interface AlbumListView : UIView

/**
 所有的相册数据源
 */
@property (nonatomic ,retain)NSMutableArray  * dataSource;

/**
 所有的相册Name数据源
 */
@property (nonatomic ,retain)NSMutableArray  * dataNameSource;

/**
 select index
 */
@property (nonatomic ,assign)NSInteger nowIndex;

/**
 选择相册之后、传递相册数据源
 */
@property (nonatomic ,copy)void(^didSelectAlbumBlock)(NSInteger index);

-(void)setListDataSource:(NSMutableArray  *)dataSource  dataNameSource:(NSMutableArray  *)names nowSelectAlbum:(NSInteger)nowIndex ;
@end
