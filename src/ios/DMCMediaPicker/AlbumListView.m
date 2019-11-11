//
//  AlbumListView.m
//  IOSMedaiPicker
//

#import "AlbumListView.h"
#import <Photos/Photos.h>
@interface AlbumListView ()<UITableViewDelegate,UITableViewDataSource>


@property (nonatomic ,weak)UITableView * tableView;

//cell高度
@property (nonatomic ,assign)CGFloat cellHeight;

@end

@implementation AlbumListView

#pragma mark - 懒加载


-(UITableView *)tableView
{
    if (!_tableView) {
        self.cellHeight=self.bounds.size.width/5;
        UITableView *tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) style:UITableViewStyleGrouped];
        
        [tableView setBackgroundColor:[UIColor whiteColor]];
        tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLineEtched;
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView.delegate=self;
        tableView.dataSource=self;
        
        [self addSubview:tableView];
        _tableView=tableView;
    }
    return _tableView;
}


#pragma mark - setter
-(void)setListDataSource:(NSMutableArray  *)dataSource  dataNameSource:(NSMutableArray  *)names nowSelectAlbum: (NSInteger)nowIndex
{
    _dataSource=dataSource;
    _dataNameSource=names;
    _nowIndex=nowIndex;
    [self.tableView reloadData];
    NSInteger scrolltoIndex = 0;
    //下面代码是让下拉选中了有个居中的感觉
    if(_nowIndex > [_dataNameSource count]-4){
        scrolltoIndex = [_dataNameSource count]-1;
    }else{
        scrolltoIndex=(_nowIndex+3);
    }
    if([_dataNameSource count]>3){
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:scrolltoIndex inSection:0]  atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}



#pragma mark - tableView的代理方法

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellString = @"cellString";//cell的重用
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellString];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellString];
        CGFloat margin=20;
        UIImageView *cellImageView = [[UIImageView alloc]initWithFrame:CGRectMake(margin, 10, _cellHeight-20, _cellHeight-20)];
        cellImageView.backgroundColor = [UIColor brownColor];
        cellImageView.contentMode=UIViewContentModeScaleAspectFill;
        cellImageView.clipsToBounds=YES;
        cellImageView.tag = 101;
        [cell addSubview:cellImageView];
        
        UILabel *cellText = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(cellImageView.frame)+margin, 0, self.bounds.size.width, _cellHeight)];
        cellText.textColor = [UIColor blackColor];
        cellText.tag = 102;
        [cell addSubview:cellText];
    }
    
    if(_nowIndex==indexPath.item){
        cell.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.13f];
    }else{
        cell.backgroundColor=[UIColor whiteColor];
    }
    
    //图标
    NSString *titileName = _dataNameSource[indexPath.item];
    NSString *count =  [NSString stringWithFormat:@"%ld",[_dataSource[indexPath.item] count]];
    PHAsset *asset=_dataSource[indexPath.item][0];
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:CGSizeMake(200 , 200)
                                              contentMode:PHImageContentModeAspectFill
                                                  options:nil
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:101];
                                                
                                                cellImageView.image = result;
                                                //标题
                                                UILabel *cellText = (UILabel *)[cell viewWithTag:102];
                                                //创建一个带有属性的字符串比如说颜色，字体等文字的属性
                                                NSString * str=[NSString stringWithFormat:@"%@  %@",titileName,count];
                                                NSMutableAttributedString * attrStr=[[NSMutableAttributedString alloc]initWithString:str];
                                                
                                                [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:[str rangeOfString:titileName]];
                                                 
                                                [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:[str rangeOfString:count]];
                                                cellText.attributedText =attrStr;
                                                
                                            }];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _cellHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.00001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.00001;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.didSelectAlbumBlock) {
        self.didSelectAlbumBlock(indexPath.item);
    }
    
}


@end
