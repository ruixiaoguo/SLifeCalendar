//
//  LXCalendarView.m
//  LXCalendar
//
//  Created by chenergou on 2017/11/2.
//  Copyright © 2017年 漫漫. All rights reserved.
//

#import "LXCalendarView.h"
#import "LXCalendarHearder.h"
#import "LXCalendarWeekView.h"
#import "LXCalenderCell.h"
#import "LXCalendarMonthModel.h"
#import "NSDate+GFCalendar.h"
#import "LXCalendarDayModel.h"
#import "LxButton.h"
#import "UIColor+Expanded.h"
#import "UILabel+LXLabel.h"
#import "UIView+LX_Frame.h"
#import "UIView+FTCornerdious.h"
@interface LXCalendarView()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic,strong)LXCalendarHearder *calendarHeader; //头部
@property(nonatomic,strong)LXCalendarWeekView *calendarWeekView;//周
@property(nonatomic,strong)UICollectionView *collectionView;//日历
@property(nonatomic,strong)NSMutableArray *monthdataA;//当月的模型集合
@property(nonatomic,strong)NSDate *currentMonthDate;//当月的日期
@property(nonatomic,strong)UISwipeGestureRecognizer *leftSwipe;//左滑手势
@property(nonatomic,strong)UISwipeGestureRecognizer *rightSwipe;//右滑手势
@property(nonatomic,strong)NSMutableArray *nowMonthArray;

@end
@implementation LXCalendarView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.nowMonthArray = [NSMutableArray arrayWithCapacity:0];
        self.currentMonthDate = [NSDate date];
        [self setup];
        
    }
    return self;
}
-(void)dealData{
    
    
    [self responData];
}
-(void)setup{
    [self addSubview:self.calendarHeader];
    
    WeakSelf(weakSelf);
    self.calendarHeader.leftClickBlock = ^{
        if (weakSelf.nowMonthArray.count!=0) {
            /** 获取返回的最早月份 */
            NSString *startDate = weakSelf.nowMonthArray[0];
            NSArray *startArray = [startDate componentsSeparatedByString:@"-"];
            NSInteger startYearStr  = [startArray[0] integerValue];
            NSInteger startMonthStr  = [startArray[1] integerValue];
            
            /** 获取当前的月份 */
            NSString *nextData = [NSString stringWithFormat:@"%@",[weakSelf.currentMonthDate previousMonthDate]];
            NSArray *nextArray = [nextData componentsSeparatedByString:@"-"];
            NSInteger nextYearStr  = [nextArray[0] integerValue];
            NSInteger nextMonthStr  = [nextArray[1] integerValue];
            if (nextYearStr<startYearStr) {
                [SLifeProgressHUD showMessage:weakSelf.superview labelText:@"无法预约更早的日期" mode:MBProgressHUDModeText];
                return ;
            }else if (nextMonthStr<startMonthStr) {
                [SLifeProgressHUD showMessage:weakSelf.superview labelText:@"无法预约更早的日期" mode:MBProgressHUDModeText];
                return ;
                }
        }
        [weakSelf rightSlide];
    };
    
    self.calendarHeader.rightClickBlock = ^{
        if (weakSelf.nowMonthArray.count!=0) {
            /** 获取返回的最晚月份 */
            NSString *endDate = weakSelf.nowMonthArray[weakSelf.nowMonthArray.count-1];
            NSArray *endArray = [endDate componentsSeparatedByString:@"-"];
            NSInteger endMonthStr  = [endArray[1] integerValue];
            /** 获取当前的月份 */
            NSString *nextData = [NSString stringWithFormat:@"%@",[weakSelf.currentMonthDate nextMonthDate]];
            NSArray *nextArray = [nextData componentsSeparatedByString:@"-"];
            NSInteger nextMonthStr  = [nextArray[1] integerValue];
            DDLog(@"endMonthStr=====%ld===%ld",(long)endMonthStr,(long)nextMonthStr);
            if(nextMonthStr>endMonthStr){
                [SLifeProgressHUD showMessage:weakSelf.superview labelText:@"无法预约之后的日期" mode:MBProgressHUDModeText];

                return ;
                }
        }
        [weakSelf leftSlide];
    };
    [self addSubview:self.calendarWeekView];
    
    [self addSubview:self.collectionView];
    
    self.lx_height = self.collectionView.lx_bottom;
    
    //添加左滑右滑手势
   self.leftSwipe =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftSwipe:)];
   self.leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.collectionView addGestureRecognizer:self.leftSwipe];
    
    self.rightSwipe =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipe:)];
    self.rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.collectionView addGestureRecognizer:self.rightSwipe];
}
#pragma mark --左滑手势--
-(void)leftSwipe:(UISwipeGestureRecognizer *)swipe{
    if (self.nowMonthArray.count!=0) {
        /** 获取返回的最晚月份 */
        NSString *endDate = self.nowMonthArray[self.nowMonthArray.count-1];
        NSArray *endArray = [endDate componentsSeparatedByString:@"-"];
        NSInteger endMonthStr  = [endArray[1] integerValue];
        /** 获取当前的月份 */
        NSString *nextData = [NSString stringWithFormat:@"%@",[self.currentMonthDate nextMonthDate]];
        NSArray *nextArray = [nextData componentsSeparatedByString:@"-"];
        NSInteger nextMonthStr  = [nextArray[1] integerValue];
        DDLog(@"endMonthStr=====%ld===%ld",(long)endMonthStr,(long)nextMonthStr);
        if(nextMonthStr>endMonthStr){
            [SLifeProgressHUD showMessage:self.superview labelText:@"无法预约之后的日期" mode:MBProgressHUDModeText];
            return ;
        }
    }
    [self leftSlide];
}
#pragma mark --左滑处理--
-(void)leftSlide{
    self.currentMonthDate = [self.currentMonthDate nextMonthDate];
    [self performAnimations:kCATransitionFromRight];
    [self responData];
}
#pragma mark --右滑处理--
-(void)rightSlide{
    
    self.currentMonthDate = [self.currentMonthDate previousMonthDate];
    [self performAnimations:kCATransitionFromLeft];
    
    [self responData];
}
#pragma mark --右滑手势--
-(void)rightSwipe:(UISwipeGestureRecognizer *)swipe{
    if (self.nowMonthArray.count!=0) {
        /** 获取返回的最早月份 */
        NSString *startDate = self.nowMonthArray[0];
        NSArray *startArray = [startDate componentsSeparatedByString:@"-"];
        NSInteger startYearStr  = [startArray[0] integerValue];
        NSInteger startMonthStr  = [startArray[1] integerValue];
        
        /** 获取当前的月份 */
        NSString *nextData = [NSString stringWithFormat:@"%@",[self.currentMonthDate previousMonthDate]];
        NSArray *nextArray = [nextData componentsSeparatedByString:@"-"];
        NSInteger nextYearStr  = [nextArray[0] integerValue];
        NSInteger nextMonthStr  = [nextArray[1] integerValue];
        if (nextYearStr<startYearStr) {
            [SLifeProgressHUD showMessage:self.superview labelText:@"无法预约更早的日期" mode:MBProgressHUDModeText];
            return ;
        }else if (nextMonthStr<startMonthStr) {
            [SLifeProgressHUD showMessage:self.superview labelText:@"无法预约更早的日期" mode:MBProgressHUDModeText];
            return ;
        }
    }
    [self rightSlide];
}
#pragma mark--动画处理--
- (void)performAnimations:(NSString *)transition{
    CATransition *catransition = [CATransition animation];
    catransition.duration = 0.5;
    [catransition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    catransition.type = kCATransitionPush; //choose your animation
    catransition.subtype = transition;
    [self.collectionView.layer addAnimation:catransition forKey:nil];
}

#pragma mark--数据以及更新处理--
-(void)responData{
    
    [self.monthdataA removeAllObjects];
    
    NSDate *previousMonthDate = [self.currentMonthDate previousMonthDate];
    
//    NSDate *nextMonthDate = [self.currentMonthDate  nextMonthDate];
    
    LXCalendarMonthModel *monthModel = [[LXCalendarMonthModel alloc]initWithDate:self.currentMonthDate];
    
    LXCalendarMonthModel *lastMonthModel = [[LXCalendarMonthModel alloc]initWithDate:previousMonthDate];
    
//     LXCalendarMonthModel *nextMonthModel = [[LXCalendarMonthModel alloc]initWithDate:nextMonthDate];
    
    self.calendarHeader.dateStr = [NSString stringWithFormat:@"%ld年%ld月",monthModel.year,monthModel.month];
    
    NSInteger firstWeekday = monthModel.firstWeekday;
    
    NSInteger totalDays = monthModel.totalDays;

    for (int i = 0; i <42; i++) {
        
        LXCalendarDayModel *model =[[LXCalendarDayModel alloc]init];
        
        //配置外面属性
        [self configDayModel:model];
        
        model.firstWeekday = firstWeekday;
        model.totalDays = totalDays;
        
        model.month = monthModel.month;
        
        model.year = monthModel.year;
        
        //上个月的日期
        if (i < firstWeekday) {
            model.day = lastMonthModel.totalDays - (firstWeekday - i) + 1;
            model.isLastMonth = YES;
        }
        
        //当月的日期
        if (i >= firstWeekday && i < (firstWeekday + totalDays)) {
            
            model.day = i -firstWeekday +1;
            model.isCurrentMonth = NO;
            
            //标识是今天
            if ((monthModel.month == [[NSDate date] dateMonth]) && (monthModel.year == [[NSDate date] dateYear])) {
                if (i == [[NSDate date] dateDay] + firstWeekday - 1) {
                    model.isToday = YES;
                    model.isSelected = YES;
                }                 
            }
            
        }
        NSInteger nextMonthStarDay = firstWeekday + monthModel.totalDays -1;
         //下月的日期
        if (i >= (firstWeekday + monthModel.totalDays)) {
            
            model.day = i - nextMonthStarDay;
            model.isNextMonth = YES;
            
        }
        
        /** 约得的可预约日期 */
        NSString *monthStr;
        if (model.month<10) {
            monthStr = [NSString stringWithFormat:@"0%ld",(long)model.month];
        }else{
            monthStr = [NSString stringWithFormat:@"%ld",(long)model.month];
        }
        NSString *dayStr;
        if (model.day<10) {
            dayStr = [NSString stringWithFormat:@"0%ld",(long)model.day];
        }else{
            dayStr = [NSString stringWithFormat:@"%ld",(long)model.day];
        }
        NSString *yueDageStr = [NSString stringWithFormat:@"%ld-%@-%@",(long)model.year,monthStr,dayStr];
        for (NSString *selDate in self.nowMonthArray) {
            if ([yueDageStr isEqualToString:selDate]) {
                model.isCurrentMonth = YES;
            }
            /** 显示默认日期 */
            if ([self isContantToday:self.nowMonthArray]==NO) {
                if ([yueDageStr isEqualToString:self.nowMonthArray[0]]&&model.isNextMonth == NO&&model.isLastMonth == NO) {
                    model.isDefaule = YES;
                }
            }
        }
        [self.monthdataA addObject:model];
    }
    [self.collectionView reloadData];
}
-(void)configDayModel:(LXCalendarDayModel *)model{
    

    //配置外面属性
    model.isHaveAnimation = self.isHaveAnimation;
    
    model.currentMonthTitleColor = self.currentMonthTitleColor;
    
    model.lastMonthTitleColor = self.lastMonthTitleColor;
    
    model.nextMonthTitleColor = self.nextMonthTitleColor;
    
    model.selectBackColor = self.selectBackColor;
    
    model.isHaveAnimation = self.isHaveAnimation;
    
    model.todayTitleColor = self.todayTitleColor;
    
    model.isShowLastAndNextDate = self.isShowLastAndNextDate;

}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.monthdataA.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIndentifier = @"cell";
    LXCalenderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIndentifier forIndexPath:indexPath];
    if (!cell) {
        cell =[[LXCalenderCell alloc]init];
    }
    
    cell.model = self.monthdataA[indexPath.row];

    cell.backgroundColor =[UIColor whiteColor];
    
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
   
    LXCalendarDayModel *model = self.monthdataA[indexPath.row];
    model.isSelected = YES;
    [self.monthdataA enumerateObjectsUsingBlock:^(LXCalendarDayModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj != model) {
            obj.isSelected = NO;
            obj.isDefaule = NO;
        }
    }];
    NSString *monthStr;
    if (model.month<10) {
        monthStr = [NSString stringWithFormat:@"0%ld",(long)model.month];
    }else{
        monthStr = [NSString stringWithFormat:@"%ld",(long)model.month];
    }
    NSString *dayStr;
    if (model.day<10) {
        dayStr = [NSString stringWithFormat:@"0%ld",(long)model.day];
    }else{
        dayStr = [NSString stringWithFormat:@"%ld",(long)model.day];
    }
    if (self.selectBlock) {
        self.selectBlock(model.year, monthStr, dayStr);
    }
    [collectionView reloadData];
    
}
-(void)layoutSubviews{
    [super layoutSubviews];
    self.calendarHeader.frame = CGRectMake(0, 0, self.lx_width, 50);
}
#pragma mark---懒加载
-(LXCalendarHearder *)calendarHeader{
    if (!_calendarHeader) {
        _calendarHeader =[LXCalendarHearder showView];
        _calendarHeader.frame = CGRectMake(0, 0, self.lx_width, 50);
        _calendarHeader.backgroundColor =[UIColor whiteColor];
    }
    return _calendarHeader;
}
-(LXCalendarWeekView *)calendarWeekView{
    if (!_calendarWeekView) {
        _calendarWeekView =[[LXCalendarWeekView alloc]initWithFrame:CGRectMake(0, self.calendarHeader.lx_bottom, self.lx_width, 50)];
        _calendarWeekView.weekTitles = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
    }
    return _calendarWeekView;
}
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flow =[[UICollectionViewFlowLayout alloc]init];
        //325*403
        flow.minimumInteritemSpacing = 0;
        flow.minimumLineSpacing = 0;
        flow.sectionInset =UIEdgeInsetsMake(0 , 0, 0, 0);
        
        flow.itemSize = CGSizeMake(self.lx_width/7, 50);
        _collectionView =[[UICollectionView alloc]initWithFrame:CGRectMake(0, self.calendarWeekView.lx_bottom, self.lx_width, 6 * 50) collectionViewLayout:flow];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.scrollsToTop = YES;
        _collectionView.backgroundColor = [UIColor whiteColor];
        UINib *nib = [UINib nibWithNibName:@"LXCalenderCell" bundle:nil];
        [_collectionView registerNib:nib forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}
-(NSMutableArray *)monthdataA{
    if (!_monthdataA) {
        _monthdataA =[NSMutableArray array];
    }
    return _monthdataA;
}

/*
 * 当前月的title颜色
 */
-(void)setCurrentMonthTitleColor:(UIColor *)currentMonthTitleColor{
    _currentMonthTitleColor = currentMonthTitleColor;
}
/*
 * 上月的title颜色
 */
-(void)setLastMonthTitleColor:(UIColor *)lastMonthTitleColor{
    _lastMonthTitleColor = lastMonthTitleColor;
}
/*
 * 下月的title颜色
 */
-(void)setNextMonthTitleColor:(UIColor *)nextMonthTitleColor{
    _nextMonthTitleColor = nextMonthTitleColor;
}

/*
 * 选中的背景颜色
 */
-(void)setSelectBackColor:(UIColor *)selectBackColor{
    _selectBackColor = selectBackColor;
}

/*
 * 选中的是否动画效果
 */

-(void)setIsHaveAnimation:(BOOL)isHaveAnimation{
    
    _isHaveAnimation  = isHaveAnimation;
}

/*
 * 是否禁止手势滚动
 */
-(void)setIsCanScroll:(BOOL)isCanScroll{
    _isCanScroll = isCanScroll;
    
    self.leftSwipe.enabled = self.rightSwipe.enabled = isCanScroll;
}

/*
 * 是否显示上月，下月的按钮
 */

-(void)setIsShowLastAndNextBtn:(BOOL)isShowLastAndNextBtn{
    _isShowLastAndNextBtn  = isShowLastAndNextBtn;
    self.calendarHeader.isShowLeftAndRightBtn = isShowLastAndNextBtn;
}


/*
 * 是否显示上月，下月的的数据
 */
-(void)setIsShowLastAndNextDate:(BOOL)isShowLastAndNextDate{
    _isShowLastAndNextDate =  isShowLastAndNextDate;
}
/*
 * 今日的title颜色
 */

-(void)setTodayTitleColor:(UIColor *)todayTitleColor{
    _todayTitleColor = todayTitleColor;
}

-(void)setAllDataArray:(NSMutableArray *)allDataArray{
    [self.nowMonthArray removeAllObjects];
    self.nowMonthArray = allDataArray;
    for (LXCalendarDayModel *model in self.monthdataA) {
        /** 约得的可预约日期 */
        NSString *monthStr;
        if (model.month<10) {
            monthStr = [NSString stringWithFormat:@"0%ld",(long)model.month];
        }else{
            monthStr = [NSString stringWithFormat:@"%ld",(long)model.month];
        }
        NSString *dayStr;
        if (model.day<10) {
            dayStr = [NSString stringWithFormat:@"0%ld",(long)model.day];
        }else{
            dayStr = [NSString stringWithFormat:@"%ld",(long)model.day];
        }
        NSString *yueDageStr = [NSString stringWithFormat:@"%ld-%@-%@",(long)model.year,monthStr,dayStr];
        NSString *firstDate = allDataArray[0];
        for (NSString *selDate in allDataArray) {
            if ([yueDageStr isEqualToString:selDate]) {
                model.isCurrentMonth = YES;
            }
             /** 显示默认日期 */
            if ([self isContantToday:allDataArray]==NO) {
                if ([yueDageStr isEqualToString:firstDate]&&model.isNextMonth == NO&&model.isLastMonth == NO) {
                    model.isDefaule = YES;
                }
            }
        }
    }
    [self jumtToCanSelectMonthView];
    [self.collectionView reloadData];
}

#pragma mark - 自动定位到可以选择的月份View
-(void)jumtToCanSelectMonthView
{
    /** 获取返回的最早月份 */
    NSString *startDate = self.nowMonthArray[0];
    NSArray *startArray = [startDate componentsSeparatedByString:@"-"];
    NSInteger startMonthStr  = [startArray[1] integerValue];
    /** 获取当前的月份 */
    NSString *nowData = [NSString stringWithFormat:@"%@",self.currentMonthDate];
    NSArray *nowArray = [nowData componentsSeparatedByString:@"-"];
    NSInteger nowMonthStr  = [nowArray[1] integerValue];
    NSInteger index = startMonthStr-nowMonthStr;
    if (startMonthStr>nowMonthStr) {
        for (int i=0; i<index; i++) {
            self.currentMonthDate = [self.currentMonthDate nextMonthDate];
        }
    }
    [self responData];
}

-(BOOL)isContantToday:(NSMutableArray *)allDayArray
{
    NSString *todayStr = [self gaintNowDay];
    BOOL isContantDay = NO;
    for (NSString *selDate in allDayArray) {
        if ([selDate isEqualToString:todayStr]) {
            isContantDay = YES;
        }
    }
    return isContantDay;
}

-(NSString *)gaintNowDay
{
    NSString *monthStr;
    if ([[NSDate date] dateMonth]<10) {
        monthStr = [NSString stringWithFormat:@"0%ld",(long)[[NSDate date] dateMonth]];
    }else{
        monthStr = [NSString stringWithFormat:@"%ld",(long)[[NSDate date] dateMonth]];
    }
    NSString *dayStr;
    if ([[NSDate date] dateDay]<10) {
        dayStr = [NSString stringWithFormat:@"0%ld",(long)[[NSDate date] dateDay]];
    }else{
        dayStr = [NSString stringWithFormat:@"%ld",(long)[[NSDate date] dateDay]];
    }
    NSString *todayDay = [NSString stringWithFormat:@"%ld-%@-%@",(long)[[NSDate date] dateYear],monthStr,dayStr];
    return todayDay;
}

@end
