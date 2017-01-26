//
//  DiaryViewController.m
//  MyDiary
//
//  Created by Wujianyun on 18/01/2017.
//  Copyright © 2017 yaoyaoi. All rights reserved.
//

#import "DiaryViewController.h"
#import "diaryTableViewCell.h"
#import "Diary.h"
#import "DiaryPage.h"
#import "TimeDealler.h"
@interface DiaryViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation DiaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setMyTableView];
    
    //假数据
    Diary * dia=[[Diary alloc]init];
    [dia setDate:[TimeDealler getCurrentDate]];
    [dia setDates];
    [dia setTime:[TimeDealler getCurrentTime]];
    [dia setTitle:@"今天的日记"];
    [dia setContent:@"今天很开心哦"];
    NSMutableArray * arr=[[NSMutableArray alloc]initWithObjects:dia, nil];
    _diaryForMonthArray=[[NSMutableArray alloc]init];
    [_diaryForMonthArray addObject:arr];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(instancetype)initWithBackgroundColor:(UIColor *)color{
    self=[self init];

    return self;
}
-(void)setMyTableView{
    _tableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [_tableView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-155)];
    [self.view addSubview:_tableView];
    UIImageView* backgroundView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background1"]];
    [backgroundView setFrame:self.view.bounds];
    [_tableView setBackgroundView:backgroundView];
    
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _diaryForMonthArray[section].count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *indetifier = @"myTableViewCell";
    
    diaryTableViewCell *cell = (diaryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:indetifier];
    
    if(!cell){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"diaryTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    Diary *diary=_diaryForMonthArray[indexPath.section][indexPath.row];
    [cell setDiary:diary];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 300;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _diaryForMonthArray.count;
}// Default is 1 if not implemented

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    Diary * diary= _diaryForMonthArray[section][0];
    NSString * month=[diary.month stringByAppendingString:@"月"];
    return month;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end