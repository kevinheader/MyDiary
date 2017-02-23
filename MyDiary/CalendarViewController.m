//
//  CalendarViewController.m
//  MyDiary
//
//  Created by Wujianyun on 16/01/2017.
//  Copyright © 2017 yaoyaoi. All rights reserved.
//

#import "CalendarViewController.h"
#import "NSDate+Formatter.h"
#import "myTableViewCell.h"
#import "TimeDealler.h"
#import "SqlService.h"
#define HeaderViewHeight 30
#define WeekViewHeight 40
#define INITIALHEIGHT Iphone6ScaleHeight(100)
@implementation MonthModel

@end

@interface CalendarViewController ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *dayModelArray;
@property (strong, nonatomic) UILabel *dateLabel;
@property (nonatomic,assign) NSIndexPath *selecedDay;
@property (nonatomic,assign) NSIndexPath *today;
@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *cellHeights;
@property (nonatomic,strong) NSMutableArray *elementArray;
@property (strong, nonatomic) NSDate *tempDate;

@end

@implementation CalendarViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!_selecedDay) {
        [self setData];
    }else {
        [self reloadData];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self drawView];
    
    self.tempDate = [NSDate date];
    self.dateLabel.text = self.tempDate.yyyyMMByLineWithDate;
    
    [self getDataDayModel:self.tempDate];
}
- (void)setData {
    self.elementArray=[self dateDeal:[NSDate date]];
    [self.delegate updateNumOfItems:[NSString stringWithFormat:@"%lu",(unsigned long)self.elementArray.count]];
    [self.tableView reloadData];
}
- (void)reloadData {
    self.elementArray=[self dateDeal:[self.dayModelArray[_selecedDay.row] dateValue]];
    [self.delegate updateNumOfItems:[NSString stringWithFormat:@"%lu",(unsigned long)self.elementArray.count]];
    [self.tableView reloadData];
}
- (NSMutableArray *)dateDeal:(NSDate *)date{
    NSMutableArray *arr=[[NSMutableArray alloc]init];
    NSArray *array=[[SqlService sqlInstance] queryElementDBtable:date];
    if(array.count) {
        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyyMMdd"];
        NSString *selectedDateStr=[formatter stringFromDate:date];
        for(Element *ele in array) {
            NSString *dateStr=[[ele.year stringByAppendingString:ele.month]stringByAppendingString:ele.day];
            if([selectedDateStr isEqualToString:dateStr]) {
                [arr addObject:ele];
            }
        }
    }
    return arr;
}
- (NSMutableArray *)elementArray {
    if(!_elementArray) {
        _elementArray=[[NSMutableArray alloc]init];
    }
    return _elementArray;
}
#pragma mark -view
-(void)drawView{
    [self.view setBackgroundColor:[UIColor colorWithHexValue:0XFCE7EC alpha:1]];
    _dateLabel =[[UILabel alloc]initWithFrame:CGRectMake(LL_SCREEN_WIDTH/2-50,Iphone6ScaleHeight(20), 100, 30 )];
    _dateLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:_dateLabel];
    UIButton * lastButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [lastButton setImage:[UIImage imageNamed:@"last"] forState:UIControlStateNormal];
    [lastButton setFrame:CGRectMake(Iphone6ScaleWidth(10), Iphone6ScaleHeight(20), Iphone6ScaleWidth(30), Iphone6ScaleHeight(30))];
    [lastButton setTintColor:[UIColor blackColor]];
    [self.view addSubview:lastButton];
    [lastButton addTarget:self action:@selector(lastButtonPressed) forControlEvents:UIControlEventTouchDown];
    UIButton * nextButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
    [nextButton setFrame:CGRectMake(LL_SCREEN_WIDTH-Iphone6ScaleWidth(40),Iphone6ScaleHeight(20), Iphone6ScaleWidth(30), Iphone6ScaleHeight(30))];
    [nextButton setTintColor:[UIColor blackColor]];
    [self.view addSubview:nextButton];
    [nextButton addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.collectionView];//此处注意_collectionView和self.collectionView的区别
}
- (NSMutableArray *)cellHeights {
    if(!_cellHeights) {
        _cellHeights=[[NSMutableArray alloc]init];
    }
    return _cellHeights;
}
- (UITableView *)tableView {
    if(!_tableView) {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, _collectionView.frame.size.height+Iphone6ScaleHeight(20)+HeaderViewHeight, LL_SCREEN_WIDTH, _viewHeight-_collectionView.frame.size.height-Iphone6ScaleHeight(20)-HeaderViewHeight) style:UITableViewStylePlain];
        [_tableView setBackgroundColor:[UIColor colorWithHexValue:0XFCE7EC alpha:1]];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight=Iphone6ScaleHeight(100);
        [self.view addSubview:_tableView];
    }
    return _tableView;
}
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        NSInteger width = Iphone6ScaleWidth(45);
        NSInteger height = Iphone6ScaleWidth(45);
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = CGSizeMake(width, height);
        flowLayout.headerReferenceSize = CGSizeMake(LL_SCREEN_WIDTH, HeaderViewHeight);
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(20, Iphone6ScaleHeight(50), self.view.bounds.size.width-40,Iphone6ScaleHeight(250)) collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.layer.cornerRadius=10;
        _collectionView.layer.masksToBounds = YES;
        
        [_collectionView registerClass:[CalendarCell class] forCellWithReuseIdentifier:@"CalendarCell"];
        [_collectionView registerClass:[CalendarHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CalendarHeaderView"];
        
    }
    return _collectionView;
}
#pragma mark -buttonPressed
- (void)lastButtonPressed {
    self.tempDate = [self getLastMonth:self.tempDate];
    self.dateLabel.text = self.tempDate.yyyyMMByLineWithDate;
    [self getDataDayModel:self.tempDate];
}

- (IBAction)nextButtonPressed {
    self.tempDate = [self getNextMonth:self.tempDate];
    self.dateLabel.text = self.tempDate.yyyyMMByLineWithDate;
    [self getDataDayModel:self.tempDate];
}


#pragma mark -日历数据加载
- (void)getDataDayModel:(NSDate *)date{
    NSUInteger days = [self numberOfDaysInMonth:date];
    NSInteger week = [self startDayOfWeek:date];
    self.dayModelArray = [[NSMutableArray alloc] initWithCapacity:42];
    int day = 1;
    for (int i= 1; i<days+week; i++) {
        if (i<week) {
            [self.dayModelArray addObject:@""];
        }else{
            MonthModel *mon = [MonthModel new];
            mon.dayValue = day;
            NSDate *dayDate = [self dateOfDay:day];
            mon.dateValue = dayDate;
            if ([dayDate.yyyyMMddByLineWithDate isEqualToString:[NSDate date].yyyyMMddByLineWithDate]) {
                mon.isToday = YES;
            }
            mon.isSelectedDay=NO;
            [self.dayModelArray addObject:mon];
            day++;
        }
    }
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dayModelArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CalendarCell" forIndexPath:indexPath];
    cell.dayLabel.backgroundColor = [UIColor whiteColor];
    cell.dayLabel.textColor = [UIColor blackColor];
    id mon = self.dayModelArray[indexPath.row];
    if ([mon isKindOfClass:[MonthModel class]]) {
        cell.monthModel = (MonthModel *)mon;
        MonthModel *month=(MonthModel *)self.dayModelArray[indexPath.row];
        if(month.isToday) {
            _selecedDay=indexPath;
            _today=indexPath;
        }
    }else{
        cell.dayLabel.text = @"";
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    CalendarHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"CalendarHeaderView" forIndexPath:indexPath];
    return headerView;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    id mon = self.dayModelArray[indexPath.row];
    if ([mon isKindOfClass:[MonthModel class]]) {
        self.dateLabel.text = [(MonthModel *)mon dateValue].yyyyMMddByLineWithDate;
        MonthModel* mo=self.dayModelArray[indexPath.row];
        if(mo.isSelectedDay) {
            mo.isSelectedDay=NO;
            _selecedDay=_today;
        }
        else {
            mo.isSelectedDay=YES;
            MonthModel* month= self.dayModelArray[_selecedDay.row];
            month.isSelectedDay=NO;
            //[self.dayModelArray replaceObjectAtIndex:_selecedDay.row withObject:month];
            NSArray *arr=[[NSArray alloc]initWithObjects:_selecedDay, nil];
            [_collectionView reloadItemsAtIndexPaths:arr];
            _selecedDay=indexPath;
        }
        CalendarCell* cell=(CalendarCell*)[collectionView cellForItemAtIndexPath:indexPath];
        cell.monthModel=mo;
        [self reloadData];
    }
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //NSLog(@"_elementArray.count:%lu",(unsigned long)_elementArray.count);
    return self.elementArray.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"CalendarCellForRowAtIndexPath");
    static NSString *indetifier = @"myTableViewCell";
    
    myTableViewCell *cell = (myTableViewCell *)[tableView dequeueReusableCellWithIdentifier:indetifier];
    
    if(!cell){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"myTableViewCell" owner:self options:nil] objectAtIndex:0];
        NSLog(@"%@",cell);
    }
    Element * ele=self.elementArray[indexPath.row];
    [self.elementArray replaceObjectAtIndex:indexPath.row withObject:[cell setMyElement:ele]];
    ele=self.elementArray[indexPath.row];
    if(ele.isSelected) {
        [cell drawDetailView];
        if(!(self.cellHeights.count>indexPath.row)){
            [self.cellHeights addObject:ele.cellHeight];
        }else {
            [self.cellHeights replaceObjectAtIndex:indexPath.row withObject:ele.cellHeight];
        }
    }else{
        [cell drawInitialView];
        if(!(self.cellHeights.count>indexPath.row)){
            [self.cellHeights addObject:[NSString stringWithFormat:@"%f",INITIALHEIGHT]];
        }else {
            [self.cellHeights replaceObjectAtIndex:indexPath.row withObject:[NSString stringWithFormat:@"%f",INITIALHEIGHT]];
        }
        
    }
    return cell;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"CalendarHeightForRowAtIndexPath" );
    NSString * height=(NSString *)self.cellHeights[indexPath.row];
    //NSLog(@"%@",height);
    return [height floatValue];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Element * element =self.elementArray[indexPath.row];
    if([self.cellHeights[indexPath.row] isEqualToString:[[NSString alloc]initWithFormat:@"%f",INITIALHEIGHT]]){
        element.isSelected=YES;
    }else{
        element.isSelected=NO;
        [self.delegate turnToElementPage:element];
    }
    [self.elementArray replaceObjectAtIndex:indexPath.row withObject:element];
    //NSLog(@"ElementDidSelectRowAtIndexPath");
    //NSLog(@"%@",element.cellHeight);
    NSArray * arr=[[NSArray alloc]initWithObjects:indexPath, nil];
    [self.tableView reloadRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationMiddle];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    Element * ele=self.elementArray[indexPath.row];
    [ele deleteElement];
    [self.elementArray removeObjectAtIndex:indexPath.row];
    [self reloadData];
}



#pragma mark - Private
- (NSUInteger)numberOfDaysInMonth:(NSDate *)date{
    NSCalendar *greCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    return [greCalendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;

}

- (NSDate *)firstDateOfMonth:(NSDate *)date{
    NSCalendar *greCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDateComponents *comps = [greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitWeekday | NSCalendarUnitDay
                               fromDate:date];
    comps.day = 1;
    return [greCalendar dateFromComponents:comps];
}

- (NSUInteger)startDayOfWeek:(NSDate *)date
{
    NSCalendar *greCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];//Asia/Shanghai
    NSDateComponents *comps = [greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitWeekday | NSCalendarUnitDay
                               fromDate:[self firstDateOfMonth:date]];
    return comps.weekday;
}

- (NSDate *)getLastMonth:(NSDate *)date{
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDateComponents *comps = [greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                               fromDate:date];
    comps.month -= 1;
    return [greCalendar dateFromComponents:comps];
}

- (NSDate *)getNextMonth:(NSDate *)date{
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDateComponents *comps = [greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                               fromDate:date];
    comps.month += 1;
    return [greCalendar dateFromComponents:comps];
}

- (NSDate *)dateOfDay:(NSInteger)day{
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDateComponents *comps = [greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                               fromDate:self.tempDate];
    comps.day = day;
    return [greCalendar dateFromComponents:comps];
}
@end
@implementation CalendarHeaderView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        NSArray *weekArray = [[NSArray alloc] initWithObjects:@"日",@"一",@"二",@"三",@"四",@"五",@"六", nil];
        
        for (int i=0; i<weekArray.count; i++) {
            UILabel *weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(i*(([UIScreen mainScreen].bounds.size.width-40)/7), 0, ([UIScreen mainScreen].bounds.size.width-40)/7, HeaderViewHeight)];
            weekLabel.textAlignment = NSTextAlignmentCenter;
            weekLabel.textColor = [UIColor grayColor];
            weekLabel.font = [UIFont systemFontOfSize:13.f];
            weekLabel.text = weekArray[i];
            [self addSubview:weekLabel];
        }
        
    }
    return self;
}
@end


@implementation CalendarCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        CGFloat width = self.contentView.frame.size.width*0.6;
        CGFloat height = self.contentView.frame.size.height*0.6;
        UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake( self.contentView.frame.size.width*0.4-width*0.4,  self.contentView.frame.size.height*0.4-height*0.4, width, height )];
        dayLabel.textAlignment = NSTextAlignmentCenter;
        dayLabel.layer.masksToBounds = YES;
        dayLabel.layer.cornerRadius = height * 0.5;
        
        [self.contentView addSubview:dayLabel];
        self.dayLabel = dayLabel;
        
    }
    return self;
}

- (void)setMonthModel:(MonthModel *)monthModel{
    _monthModel = monthModel;
    self.dayLabel.text = [NSString stringWithFormat:@"%02ld",monthModel.dayValue];
    if(monthModel.isSelectedDay){
        self.dayLabel.backgroundColor = [UIColor colorWithHexValue:0X69D7DD alpha:1];
        self.dayLabel.textColor = [UIColor whiteColor];
    }else{
        if (monthModel.isToday) {
            self.dayLabel.backgroundColor = [UIColor colorWithHexValue:0XFF788B alpha:1];
            self.dayLabel.textColor = [UIColor whiteColor];
        }else{
            self.dayLabel.backgroundColor = [UIColor whiteColor];
            self.dayLabel.textColor = [UIColor blackColor];
        }
    }
}


@end