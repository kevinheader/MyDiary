//
//  CalendarViewController.h
//  My Diary
//
//  Created by 徐贤达 on 2017/1/15.
//  Copyright © 2017年 徐贤达. All rights reserved.
//

#import <UIKit/UIKit.h>

#define deviceWidth [UIScreen mainScreen].bounds.size.width
#define deviceHeight [UIScreen mainScreen].bounds.size.height

@protocol selectedUpdate <NSObject>

-(void)selectedUpdate:(NSString*)string;

@end

@interface CalendarViewController : UIViewController
<UITableViewDelegate,UITableViewDataSource,selectedUpdate>
{
    NSInteger selectedYear;
    NSInteger selectedMonth;
    NSInteger selectedDay;
    CGRect fuckFrame;
    int k;
}

-(void)updateTheNoteList;

@property (nonatomic,strong)NSString *stringTime;

@property (nonatomic,strong)UITableView *noteListTableView;

@property (nonatomic,strong)NSArray *noteListArray;

@property (nonatomic,strong)NSMutableArray *dataArray;

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) UIView *cellView;

@property (nonatomic,strong) UILabel *dateLabel;

@property (nonatomic,strong) UILabel *hourLabel;

@property (nonatomic,strong) NSString *time;

@property (nonatomic,strong) NSString *cellTitle;

@property int date;

@property int hour;

@property int minute;


@end
