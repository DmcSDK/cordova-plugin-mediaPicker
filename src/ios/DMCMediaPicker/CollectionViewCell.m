

#import "CollectionViewCell.h"

@implementation CollectionViewCell
- (id)initWithFrame:(CGRect)frame
    {
        self = [super initWithFrame:frame];
        if (self) {
            CGFloat width=CGRectGetWidth(self.frame);
            
            self.imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, width)];
            self.imgView.contentMode=UIViewContentModeScaleAspectFill;
            self.imgView.clipsToBounds=YES;
            
            CGFloat checkWidth=width/5;
            self.checkView=[[UIImageView alloc]initWithFrame:CGRectMake(width-checkWidth-5, 5, checkWidth, checkWidth)];
            self.whiteView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, width)];
            
            
            CGFloat labelH=width/6;
            self.labelL = [[UILabel alloc]initWithFrame:CGRectMake(0, width-labelH, width/2, labelH)];
            self.labelL.textColor=[UIColor whiteColor];
            self.labelL.font=[UIFont systemFontOfSize:(labelH-5)*0.68];
            self.labelL.backgroundColor= [[UIColor blackColor] colorWithAlphaComponent:0.3f];
            
            
            self.labelR = [[UILabel alloc]initWithFrame:CGRectMake(width/2, width-labelH, width/2, labelH)];
            self.labelR.textColor=[UIColor whiteColor];
            self.labelR.font=[UIFont systemFontOfSize:(labelH-5)*0.68];
            //self.labelR.textAlignment=NSTextAlignmentRight;
            self.labelR.backgroundColor= [[UIColor blackColor] colorWithAlphaComponent:0.3f];
            

            self.labeGIF = [[UILabel alloc] initWithFrame:CGRectMake(width-width/5-5, width-labelH-2, width/5, labelH-5)];
            self.labeGIF.backgroundColor = [UIColor clearColor];
            self.labeGIF.textColor=[UIColor whiteColor];
         
            NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:@" GIF " attributes:@{ NSParagraphStyleAttributeName : [[NSParagraphStyle defaultParagraphStyle] mutableCopy]}];
            self.labeGIF.attributedText = attrText;
            self.labeGIF.layer.cornerRadius = 4;
            self.labeGIF.layer.masksToBounds  = YES;
            self.labeGIF.font=[UIFont systemFontOfSize:(labelH-5)*0.68];
            self.labeGIF.adjustsFontSizeToFitWidth = YES;
            self.labeGIF.backgroundColor= [[UIColor blackColor] colorWithAlphaComponent:0.4f];
            
            
            [self addSubview:self.imgView];
            [self addSubview:self.whiteView];
            [self addSubview:self.checkView];
            [self addSubview:self.labelL];
            [self addSubview:self.labelR];
            [self addSubview:self.labeGIF];
            
        }
        return self;
    }
    @end
