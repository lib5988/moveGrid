//
//  MainViewController.m
//  MoveGrid
//
//  Created by Jerry.li on 14-11-6.
//  Copyright (c) 2014年 51app. All rights reserved.
//

#import "MainViewController.h"
#import "CustomGrid.h"
#import "MoreViewController.h"

#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface MainViewController ()
{
    BOOL isSelected;
    BOOL contain;
    //选中格子的起始位置
    CGPoint startPoint;
    //选中格子的起始坐标位置
    CGPoint originPoint;
}

@property(nonatomic, strong)NSMutableArray *gridListArray;
//@property(nonatomic, strong)NSMutableArray *removeGridArray;
@property(nonatomic, strong)NSMutableArray *showGridArray;
@property(nonatomic, strong)UIImage *normalGridBg;
@property(nonatomic, strong)UIImage *highlightedBg;
@property(nonatomic, strong)UIImage *deleteIcon;
@property(nonatomic, strong)UIView  *gridListView;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.gridListArray = [[NSMutableArray alloc] initWithCapacity:12];
        self.showGridArray = [[NSMutableArray alloc] initWithCapacity:12];
        //self.removeGridArray = [[NSMutableArray alloc] initWithCapacity:11];
        self.normalGridBg = [UIImage imageNamed:@"app_item_bg"];
        self.highlightedBg = [UIImage imageNamed:@"app_item_pressed_bg"];
        self.deleteIcon = [UIImage imageNamed:@"app_item_plus"];
        self.title = @"吼吼吼~~~";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.translucent = NO;
    
    //每个格子的宽度
    NSInteger gridWidth = ScreenWidth/4;
    //每个格子的高度
    NSInteger gridHeight = 95;
    //每行显示格子的列数
    NSInteger perRowGridCount = 4;
    //每列显示格子的行数
    NSInteger perColumGridCount = 3;
    //每个格子的X轴间隔
    NSInteger paddingX = 0;
    //每个格子的Y轴间隔
    NSInteger paddingY = 0;
    
    _showGridArray = [NSMutableArray arrayWithObjects:@"101", @"102", @"103", @"104", @"105", @"106", @"107", @"108", @"109", @"200", @"201", @"00", nil];
    
    _gridListView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, ScreenWidth, gridHeight * perColumGridCount)];
    [_gridListView setBackgroundColor:[UIColor whiteColor]];
    
    for (NSInteger index = 0; index < [_showGridArray count]; index++) {
        //计算每个格子的X坐标
        NSInteger pointX = (index % perRowGridCount) * (gridWidth + paddingX) + paddingX;;
        //计算每个格子的Y坐标
        NSInteger pointY = (index / perRowGridCount) * (gridHeight + paddingY) + paddingY;
        
        NSString *gridID = _showGridArray[index];
        
        CustomGrid *gridItem = [[CustomGrid alloc] initWithFrame:
                                  CGRectMake(pointX, pointY, gridWidth, gridHeight)];
        [gridItem setBackgroundImage:self.normalGridBg forState:UIControlStateNormal];
        [gridItem setBackgroundImage:self.highlightedBg forState:UIControlStateHighlighted];
        [gridItem setTitle:gridID forState:UIControlStateNormal];
        [gridItem setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        //////////
        [gridItem setGridId:[gridID integerValue]];
        [gridItem setGridIndex:index];
        [gridItem setGridCenterPoint:gridItem.center];
        //////////
        gridItem.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [gridItem addTarget:self action:@selector(gridClick:) forControlEvents:UIControlEventTouchUpInside];
        
        //最后一个格子不添加删除图标
        if (![gridID isEqualToString:@"00"]) {
            //当长按时添加删除按钮图标
            UIButton *deleteIcon = [[UIButton alloc] initWithFrame:CGRectMake(55, 10, 16, 16)];
            [deleteIcon setBackgroundColor:[UIColor clearColor]];
            [deleteIcon setBackgroundImage:self.deleteIcon forState:UIControlStateNormal];
            [deleteIcon setTag:[gridID integerValue]];
            [deleteIcon addTarget:self action:@selector(deleteGridClick:) forControlEvents:UIControlEventTouchUpInside];
            [deleteIcon setHidden:YES];
            [gridItem addSubview:deleteIcon];
            
            //添加长按手势
            UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gridLongPress:)];
            [gridItem addGestureRecognizer:longPressGesture];
        }
        
        [_gridListView addSubview:gridItem];
        [_gridListArray addObject:gridItem];
    }
    
    for (NSInteger i = 0; i < _gridListArray.count; i++) {
        CustomGrid *gridItem = _gridListArray[i];
        gridItem.gridCenterPoint = gridItem.center;
        NSLog(@"移动前所有格子的位置信息{gridIndex: %d, gridCenterPoint: %@, gridID: %d}",
              gridItem.gridIndex, NSStringFromCGPoint(gridItem.gridCenterPoint), gridItem.gridId);
    }
    
    [self.view addSubview:_gridListView];
    
}

//格子的点击事件
- (void)gridClick:(CustomGrid *)clickItem
{
    //判断是否点击的最后一个格子
    if (clickItem.gridId != 00) {
        //查看是否有选中的格子，并且比较点击的格子是否就是选中的格子
        for (NSInteger i = 0; i < [_gridListArray count]; i++) {
            CustomGrid *item = _gridListArray[i];
            if (item.isChecked && clickItem.gridId != item.gridId) {
                item.isChecked = NO;
                item.isMove = NO;
                isSelected = NO;
                //隐藏删除图标
                UIButton *removeBtn = (UIButton *)[self.gridListView viewWithTag:item.gridId];
                removeBtn.hidden = YES;
                [item setBackgroundImage:self.normalGridBg forState:UIControlStateNormal];
            }
        }
    }else{
        switch (clickItem.gridId) {
            case 00:
                [self.navigationController pushViewController:[[MoreViewController alloc] init] animated:YES];
                break;
            default:
                break;
        }
    }
    NSLog(@"您点击的格子title：%d", clickItem.gridId);
}

//响应删除格子点击事件
- (void)deleteGridClick:(UIButton *)deleteBtn
{
    NSLog(@"您删除的格子是：%d", deleteBtn.tag);
    for (NSInteger i = 0; i < _gridListArray.count; i++) {
        CustomGrid *removeGrid = _gridListArray[i];
        if (removeGrid.gridId == deleteBtn.tag) {
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
        }
    }
    for (NSInteger i = 0; i < _gridListArray.count; i++) {
        CustomGrid *gridItem = _gridListArray[i];
        gridItem.gridCenterPoint = gridItem.center;
        NSLog(@"删除后所有格子的位置信息{gridIndex: %d, gridCenterPoint: %@, gridID: %d}",
              gridItem.gridIndex, NSStringFromCGPoint(gridItem.gridCenterPoint), gridItem.gridId);
    }
    
}

//响应格子的长按事件
- (void)gridLongPress:(UILongPressGestureRecognizer *)pressGesture
{
    
    CustomGrid *item = (CustomGrid *)pressGesture.view;
    
    switch (pressGesture.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"UIGestureRecognizerStateBegan.........");
            //判断格子是否已经被选中并且是否可移动状态,如果选中就加一个放大的特效
            if (item.isChecked && item.isMove) {
                item.transform = CGAffineTransformMakeScale(1.2, 1.2);
            }else{
                //查看是否有已选中的应用，如果有就不显示特效
                for (int i = 0; i < _gridListArray.count; i++) {
                    CustomGrid *item = _gridListArray[i];
                    if (item.isChecked && item.isMove) {
                        //标记有选中的应用
                        isSelected = YES;
                    }
                }
                NSLog(@"没有一个格子选中............");
                //没有一个格子选中的时候
                if (!isSelected) {
                    item.isChecked = YES;
                    item.isMove = YES;
                    
                    //选中格子的时候显示删除图标
                    UIButton *removeBtn = (UIButton *)[pressGesture.view viewWithTag:item.gridId];
                    removeBtn.hidden = NO;
                    
                    //获取移动格子的起始位置
                    startPoint = [pressGesture locationInView:pressGesture.view];
                    //获取移动格子的起始位置中心点
                    originPoint = item.center;
                    
                    //给选中的格子添加放大的特效
                    [UIView animateWithDuration:0.5 animations:^{
                        item.transform = CGAffineTransformMakeScale(1.2, 1.2);
                        item.alpha = 0.8;
                        [item setBackgroundImage:self.highlightedBg forState:UIControlStateNormal];
                    }];
                }
            }
            break;
        case UIGestureRecognizerStateChanged:
            NSLog(@"UIGestureRecognizerStateChanged.........");
            if (!isSelected) {
                [_gridListView bringSubviewToFront:item];
                //应用移动后的新坐标
                CGPoint newPoint = [pressGesture locationInView:pressGesture.view];
                //应用移动后的X坐标
                CGFloat deltaX = newPoint.x - startPoint.x;
                //应用移动后的Y坐标
                CGFloat deltaY = newPoint.y - startPoint.y;
                //拖动的应用跟随手势移动
                item.center = CGPointMake(item.center.x + deltaX, item.center.y + deltaY);
                
                //移动的格子索引下标
                NSInteger fromIndex = item.gridIndex;
                //移动到目标格子的索引下标
                NSInteger toIndex = [self indexOfPoint:item.center withButton:item];
                
                if (toIndex < 0 || toIndex >= 11) {
                    contain = NO;
                }else{
                    //获取移动到目标格子
                    CustomGrid *targetGrid = _gridListArray[toIndex];
                    item.center = targetGrid.gridCenterPoint;
                    originPoint = targetGrid.gridCenterPoint;
                    item.gridIndex = toIndex;
                    
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
                    }
                }
            }
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"UIGestureRecognizerStateEnded.........");
            if (isSelected) {
                //判断是否有选中状态的应用，如果有就还原背景并且标记不可移动应用
                for (NSInteger i = 0; i < _gridListArray.count; i++) {
                    CustomGrid *gridItem = _gridListArray[i];
                    if (gridItem.isChecked && gridItem.tag != item.tag) {
                        UIButton *removeBtn = (UIButton *)[self.gridListView viewWithTag:item.gridId];
                        item.isChecked = NO;
                        item.isMove = NO;
                        removeBtn.hidden = YES;
                        isSelected = NO;
                        [item setBackgroundImage:self.normalGridBg forState:UIControlStateNormal];
                    }
                }
                
            }else{
                //撤销格子的放大特效
                [UIView animateWithDuration:0.5 animations:^{
                    item.transform = CGAffineTransformIdentity;
                    item.alpha = 1.0;
                    if (!contain) {
                        item.center = originPoint;
                    }
                }];
                
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
                    NSLog(@"移动后所有格子的位置信息{gridIndex: %d, gridCenterPoint: %@, gridID: %d}",
                          gridItem.gridIndex, NSStringFromCGPoint(gridItem.gridCenterPoint), gridItem.gridId);
                }
            }
            //
            break;
        default:
            break;
    }
}

- (NSInteger)indexOfPoint:(CGPoint)point withButton:(UIButton *)btn
{
    for (NSInteger i = 0;i< _gridListArray.count;i++)
    {
        UIButton *appButton = _gridListArray[i];
        if (appButton != btn)
        {
            if (CGRectContainsPoint(appButton.frame, point))
            {
                return i;
            }
        }
    }
    return -1;
}

@end
