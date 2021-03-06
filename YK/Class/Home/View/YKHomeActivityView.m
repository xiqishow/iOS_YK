//
//  YKHomeActivityView.m
//  YK
//
//  Created by edz on 2018/8/27.
//  Copyright © 2018年 YK. All rights reserved.
//

#import "YKHomeActivityView.h"
@interface YKHomeActivityView()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
@implementation YKHomeActivityView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.scrollEnabled = NO;
}

- (void)setImageArray:(NSArray *)imageArray{
    _imageArray = imageArray;
    
    CGFloat w = WIDHT-20;
    CGFloat h = kSuitLength_H(187); 
    NSMutableArray *a = [NSMutableArray array];
    if (imageArray.count!=0) {
        [a addObject:imageArray[0]];
    }
    if (a.count==0) {
        return;
    }
    for (int i=0; i<a.count; i++) {
        NSDictionary *dic = [NSDictionary dictionaryWithDictionary:imageArray[i]];
        UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, w, h)];
        [image setUserInteractionEnabled:YES];
        [image sd_setImageWithURL:[NSURL URLWithString:[self URLEncodedString:dic[@"specialImg"]]] placeholderImage:[UIImage imageNamed:@"商品图"]];
        [self.scrollView addSubview:image];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithActionBlock:^(id  _Nonnull sender) {
            
//            if ([Token length] == 0) {
                if (self.toDetailBlock) {
                    self.toDetailBlock(dic[@"specialLink"]);
//                }
            }
            
        }];
        [image addGestureRecognizer:tap];
        
    }
    [self.scrollView setContentSize:CGSizeMake((w+10)*imageArray.count, 0)];
    
    
}

- (NSString *)URLEncodedString:(NSString *)str
{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)str,
                                                              (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                              NULL,
                                                              kCFStringEncodingUTF8));
    return encodedString;
}

@end
