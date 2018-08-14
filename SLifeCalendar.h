//
//  SLifeCalendar.h
//  StandardLife
//
//  Created by grx on 2018/5/29.
//  Copyright © 2018年 grx. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LXCalendarView;

@interface SLifeCalendar : UIView<UIGestureRecognizerDelegate>

@property(nonatomic,strong)LXCalendarView *calenderView;
@property(nonatomic,strong)NSMutableArray *calenderArray;
@property (copy, nonatomic) void (^calenderSelectBlock) (NSInteger year ,NSString *month ,NSString *day);
@property (copy, nonatomic) void(^closeClick)(void);

@end
