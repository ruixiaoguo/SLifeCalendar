//
//  SLifeCalendar.m
//  StandardLife
//
//  Created by grx on 2018/5/29.
//  Copyright © 2018年 grx. All rights reserved.
//

#import "SLifeCalendar.h"
#import "LXCalender.h"

@implementation SLifeCalendar

-(id)initWithFrame:(CGRect)frame{
    
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        [self createView];
    }
    return self;
}

-(void)createView{
    /** 添加手势 */
    UITapGestureRecognizer* singleRecognizer;
    singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgCouponClickTap:)];
    singleRecognizer.numberOfTapsRequired = 1;
    singleRecognizer.delegate = self;
    [self addGestureRecognizer:singleRecognizer];
    /** 背景 */    
    UIView *bgview = [[UIView alloc]initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20, 415)];
    bgview.backgroundColor = UIColorWhite;
    bgview.layer.cornerRadius = 5;
    bgview.layer.masksToBounds = YES;
    bgview.centerY = Main_Screen_Height/2;
    [self addSubview:bgview];
    /** 日历 */
    self.calenderView = [[LXCalendarView alloc]initWithFrame:CGRectMake(0, 0, Main_Screen_Width-20, 415)];
//    self.calenderView.todayTitleColor = [UIColor redColor];
//    self.calenderView.isCanScroll = NO;
    self.calenderView.isHaveAnimation = YES;
    self.calenderView.isShowLastAndNextBtn = YES;
    self.calenderView.isShowLastAndNextDate = YES;
    [self.calenderView dealData];
    [bgview addSubview:self.calenderView];
    WeakSelf(weakSelf);
    self.calenderView.selectBlock = ^(NSInteger year, NSString *month, NSString *day) {
        NSLog(@"%ld年 - %@月 - %@日",year,month,day);
        if (weakSelf.calenderSelectBlock) {
            weakSelf.calenderSelectBlock(year, month, day);
        }
    };
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([touch.view isDescendantOfView:self.calenderView]) {
        return NO;
    }
    return YES;
}

-(void)bgCouponClickTap:(UITapGestureRecognizer *)recognizer
{
    if (self.closeClick) {
        self.closeClick();
    }
}

-(void)setCalenderArray:(NSMutableArray *)calenderArray
{
    self.calenderView.allDataArray = calenderArray;
}

@end
