//
//  MainViewController.m
//  MoveGrid
//
//  Created by Jerry.li on 14-11-6.
//  Copyright (c) 2014年 51app. All rights reserved.
//

#import "MainViewController.h"
#import "MoreViewController.h"

@interface MainViewController ()
{
    BOOL isSelected;
    BOOL contain;
    //是否可跳转应用对应的详细页面
    BOOL isSkip;
    
    //选中格子的起始位置
    CGPoint startPoint;
    //选中格子的起始坐标位置
    CGPoint originPoint;
    
    UIImage *normalImage;
    UIImage *highlightedImage;
    UIImage *deleteIconImage;
}

@property(nonatomic, strong)NSMutableArray *gridListArray;
@property(nonatomic, strong)NSMutableArray *showGridArray;

//更多页面显示应用
@property(nonatomic, strong)NSMutableArray *moreGridIdArray;
@property(nonatomic, strong)UIView  *gridListView;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.gridListArray = [[NSMutableArray alloc] initWithCapacity:12];
        self.showGridArray = [[NSMutableArray alloc] initWithCapacity:12];
        self.moreGridIdArray = [[NSMutableArray alloc] initWithCapacity:12];
        self.title = @"吼吼吼~~~";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    self.navigationController.navigationBar.translucent = NO;
    
    normalImage = [UIImage imageNamed:@"app_item_bg"];
    highlightedImage = [UIImage imageNamed:@"app_item_pressed_bg"];
    deleteIconImage = [UIImage imageNamed:@"app_item_plus"];
    
    _showGridArray = [NSMutableArray arrayWithObjects:@"101", @"102", @"103", @"104", @"105", @"106", @"107", @"108", @"109", @"200", @"201", @"0", nil];
    
    _moreGridIdArray = [NSMutableArray arrayWithObjects:@"202", @"203", @"204", @"205", @"206", @"207", nil];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"=====================: %d", self.addGridArray.count);
    [self.gridListView removeFromSuperview];
    [self.gridListArray removeAllObjects];
    isSelected = NO;
    
    //
    if (self.addGridArray.count > 0) {
        for (NSInteger i = 0; i < self.addGridArray.count; i++) {
            NSInteger count = self.showGridArray.count - 1;
            [self.showGridArray insertObject:self.addGridArray[i] atIndex:count];
        }
    }
    
    for (NSInteger i = 0; i < self.showGridArray.count; i++) {
        NSString *gridId = self.showGridArray[i];
        NSLog(@"new add grid is gridId: %@", gridId);
    }

    [self drawGridView];
}

- (void)drawGridView
{
    _gridListView = [[UIView alloc] init];
    [_gridListView setFrame:CGRectMake(0, 60, ScreenWidth, GridHeight * PerColumGridCount)];
    [_gridListView setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:_gridListView];
    
    for (NSInteger index = 0; index < [_showGridArray count]; index++)
    {
        NSString *gridTitle = _showGridArray[index];
        BOOL isAddDelete = YES;
        
        if ([gridTitle isEqualToString:@"0"]) {
            isAddDelete = NO;
        }
        CustomGrid *gridItem = [[CustomGrid alloc] initWithFrame:CGRectZero title:gridTitle normalImage:normalImage highlightedImage:highlightedImage gridId:[gridTitle integerValue] atIndex:index isAddDelete:isAddDelete deleteIcon:deleteIconImage];
        gridItem.delegate = self;
        
        [self.gridListView addSubview:gridItem];
        [self.gridListArray addObject:gridItem];
    }
    
    //for test print out
    for (NSInteger i = 0; i < _gridListArray.count; i++) {
        CustomGrid *gridItem = _gridListArray[i];
        gridItem.gridCenterPoint = gridItem.center;
        NSLog(@"所有格子的位置信息{gridIndex: %d, gridCenterPoint: %@, gridID: %d}",
              gridItem.gridIndex, NSStringFromCGPoint(gridItem.gridCenterPoint), gridItem.gridId);
    }
}

#pragma mark CustomGrid Delegate

//响应格子的点击事件
- (void)gridItemDidClicked:(CustomGrid *)gridItem
{
    NSLog(@"您点击的格子Tag是：%d", gridItem.gridId);
    isSkip = YES;
    
    //查看是否有选中的格子，并且比较点击的格子是否就是选中的格子
    for (NSInteger i = 0; i < [_gridListArray count]; i++) {
        CustomGrid *item = _gridListArray[i];
        if (item.isChecked && item.gridId != gridItem.gridId) {
            item.isChecked = NO;
            item.isMove = NO;
            isSelected = NO;
            isSkip = NO;
            
            //隐藏删除图标
            UIButton *removeBtn = (UIButton *)[self.gridListView viewWithTag:item.gridId];
            removeBtn.hidden = YES;
            [item setBackgroundImage:normalImage forState:UIControlStateNormal];
            
            if (gridItem.gridId == 0) {
                isSkip = YES;
            }
            break;
        }
    }
    
    if (isSkip) {
        switch (gridItem.gridId) {
            case 0:
            {
                MoreViewController *otherView = [[MoreViewController alloc] init];
                otherView.showMoreGridIdArray = self.moreGridIdArray;
                otherView.currentGridCount = self.gridListArray.count;
                [self.navigationController pushViewController:otherView animated:YES];
                break;
            }
            default:
                break;
        }
    }
}

//响应点击格子删除事件
- (void)gridItemDidDeleteClicked:(UIButton *)deleteButton
{
    NSLog(@"您删除的格子是GridId：%d", deleteButton.tag);
    
    for (NSInteger i = 0; i < _gridListArray.count; i++) {
        CustomGrid *removeGrid = _gridListArray[i];
        if (removeGrid.gridId == deleteButton.tag) {
            [removeGrid removeFromSuperview];
            NSInteger count = _gridListArray.count - 1;
            for (NSInteger index = removeGrid.gridIndex; index < count; index++) {
                CustomGrid *preGrid = _gridListArray[index];
                CustomGrid *nextGrid = _gridListArray[index+1];
                [UIView animateWithDuration:0.5 animations:^{
                    nextGrid.center = preGrid.gridCenterPoint;
                }];
                nextGrid.gridIndex = index;
            }
            [_gridListArray removeObjectAtIndex:removeGrid.gridIndex];
            NSString *gridID = [NSString stringWithFormat:@"%d", removeGrid.gridId];
            //删除的应用添加到更多应用数组
            [_moreGridIdArray addObject:gridID];
            [_showGridArray removeObject:gridID];
        }
    }
}

- (void)pressGestureStateBegan:(UILongPressGestureRecognizer *)longPressGesture withGridItem:(CustomGrid *) grid
{
    NSLog(@"UIGestureRecognizerStateBegan.........");
    NSLog(@"isSelected: %d", isSelected);
    
    //判断格子是否已经被选中并且是否可移动状态,如果选中就加一个放大的特效
    if (isSelected && grid.isChecked) {
        grid.transform = CGAffineTransformMakeScale(1.2, 1.2);
    }
    
    //没有一个格子选中的时候
    if (!isSelected) {
        
        NSLog(@"没有一个格子选中............");
        grid.isChecked = YES;
        grid.isMove = YES;
        isSelected = YES;
        
        //选中格子的时候显示删除图标
        UIButton *removeBtn = (UIButton *)[longPressGesture.view viewWithTag:grid.gridId];
        removeBtn.hidden = NO;
        
        //获取移动格子的起始位置
        startPoint = [longPressGesture locationInView:longPressGesture.view];
        //获取移动格子的起始位置中心点
        originPoint = grid.center;
        
        //给选中的格子添加放大的特效
        [UIView animateWithDuration:0.5 animations:^{
            grid.transform = CGAffineTransformMakeScale(1.2, 1.2);
            grid.alpha = 0.8;
            [grid setBackgroundImage:highlightedImage forState:UIControlStateNormal];
        }];
    }
}

- (void)pressGestureStateChangedWithPoint:(CGPoint) gridPoint gridItem:(CustomGrid *) gridItem
{
    if (isSelected && gridItem.isChecked) {
        NSLog(@"UIGestureRecognizerStateChanged.........");
        
        [_gridListView bringSubviewToFront:gridItem];
        //应用移动后的X坐标
        CGFloat deltaX = gridPoint.x - startPoint.x;
        //应用移动后的Y坐标
        CGFloat deltaY = gridPoint.y - startPoint.y;
        //拖动的应用跟随手势移动
        gridItem.center = CGPointMake(gridItem.center.x + deltaX, gridItem.center.y + deltaY);
        
        //移动的格子索引下标
        NSInteger fromIndex = gridItem.gridIndex;
        //移动到目标格子的索引下标
        NSInteger toIndex = [CustomGrid indexOfPoint:gridItem.center withButton:gridItem gridArray:_gridListArray];
        
        NSInteger borderIndex = [_showGridArray indexOfObject:@"0"];
        NSLog(@"borderIndex: %d", borderIndex);
        
        if (toIndex < 0 || toIndex >= borderIndex) {
            contain = NO;
        }else{
            //获取移动到目标格子
            CustomGrid *targetGrid = _gridListArray[toIndex];
            gridItem.center = targetGrid.gridCenterPoint;
            originPoint = targetGrid.gridCenterPoint;
            gridItem.gridIndex = toIndex;
            
            //判断格子的移动方向，是从后往前还是从前往后拖动
            if ((fromIndex - toIndex) > 0) {
                NSLog(@"从后往前拖动格子.......");
                //从移动格子的位置开始，始终获取最后一个格子的索引位置
                NSInteger lastGridIndex = fromIndex;
                for (NSInteger i = toIndex; i < fromIndex; i++) {
                    CustomGrid *lastGrid = _gridListArray[lastGridIndex];
                    CustomGrid *preGrid = _gridListArray[lastGridIndex-1];
                    [UIView animateWithDuration:0.5 animations:^{
                        preGrid.center = lastGrid.gridCenterPoint;
                    }];
                    //实时更新格子的索引下标
                    preGrid.gridIndex = lastGridIndex;
                    lastGridIndex--;
                }
                //排列格子顺序和更新格子坐标信息
                [self sortGridList];
                
            }else if((fromIndex - toIndex) < 0){
                //从前往后拖动格子
                NSLog(@"从前往后拖动格子.......");
                //从移动格子到目标格子之间的所有格子向前移动一格
                for (NSInteger i = fromIndex; i < toIndex; i++) {
                    CustomGrid *topOneGrid = _gridListArray[i];
                    CustomGrid *nextGrid = _gridListArray[i+1];
                    [UIView animateWithDuration:0.5 animations:^{
                        nextGrid.center = topOneGrid.gridCenterPoint;
                    }];
                    //实时更新格子的索引下标
                    nextGrid.gridIndex = i;
                }
                //排列格子顺序和更新格子坐标信息
                [self sortGridList];
            }
        }
    }
}

- (void)pressGestureStateEnded:(CustomGrid *) gridItem
{
    NSLog(@"UIGestureRecognizerStateEnded.........");
    if (isSelected && gridItem.isChecked) {
        //撤销格子的放大特效
        [UIView animateWithDuration:0.5 animations:^{
            gridItem.transform = CGAffineTransformIdentity;
            gridItem.alpha = 1.0;
            if (!contain) {
                gridItem.center = originPoint;
            }
        }];
        
        //排列格子顺序和更新格子坐标信息
        [self sortGridList];
    }
}

- (void)sortGridList
{
    //重新排列数组中存放的格子顺序
    [_gridListArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CustomGrid *tempGrid1 = (CustomGrid *)obj1;
        CustomGrid *tempGrid2 = (CustomGrid *)obj2;
        return tempGrid1.gridIndex > tempGrid2.gridIndex;
    }];
    
    //更新所有格子的中心点坐标信息
    for (NSInteger i = 0; i < _gridListArray.count; i++) {
        CustomGrid *gridItem = _gridListArray[i];
        gridItem.gridCenterPoint = gridItem.center;
        
        //for test print
        //NSLog(@"移动后所有格子的位置信息{gridIndex: %d, gridCenterPoint: %@, gridID: %d}",
        //gridItem.gridIndex, NSStringFromCGPoint(gridItem.gridCenterPoint), gridItem.gridId);
    }
}

@end
