//
//  MoreViewController.m
//  MoveGrid
//
//  Created by Jerry.li on 14-11-7.
//  Copyright (c) 2014年 51app. All rights reserved.
//

#import "MoreViewController.h"
#import "CustomGrid.h"
#import "MainViewController.h"


@interface MoreViewController ()<CustomGridDelegate, UIAlertViewDelegate>
{
    //标记是否选中
    BOOL isSelected;
    //可添加格子的最大数
    NSInteger maxAddGridCount;
    
    UIImage *normalImage;
    UIImage *highlightedImage;
    
}

@property(nonatomic, strong)NSMutableArray *addGridArray;
//存放格子按钮
@property(nonatomic, strong)NSMutableArray *gridItemArray;
@property(nonatomic, strong)UIView         *showMoreGridView;

@end

@implementation MoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"更多格子";
        self.gridItemArray = [NSMutableArray arrayWithCapacity:12];
        self.addGridArray = [NSMutableArray arrayWithCapacity:12];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor orangeColor]];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"上一页" style:UIBarButtonItemStylePlain target:self action:@selector(backToPreView)];
    [self.navigationItem setLeftBarButtonItem:leftButton animated:YES];
}

- (void)backToPreView
{
    MainViewController *mainView = [self.navigationController.viewControllers objectAtIndex:0];
    mainView.addGridArray = self.addGridArray;
    [self.navigationController popToViewController:mainView animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self drawMoreGridView];
}

- (void)drawMoreGridView
{
    [_showMoreGridView removeFromSuperview];
    
    _showMoreGridView = [[UIView alloc] init];
    [_showMoreGridView setFrame:CGRectMake(0, 5, ScreenWidth, GridHeight * PerColumGridCount)];
    [_showMoreGridView setBackgroundColor:[UIColor whiteColor]];
    
    normalImage = [UIImage imageNamed:@"app_item_bg"];
    highlightedImage = [UIImage imageNamed:@"app_item_pressed_bg"];
    UIImage *deleteIconImage = [UIImage imageNamed:@"app_item_add"];
    //获取到可添加格子的最大数
    maxAddGridCount = (PerRowGridCount * PerColumGridCount) - self.currentGridCount;
    
    for (NSInteger index = 0; index < self.showMoreGridIdArray.count; index++)
    {
        NSString *gridTitle = self.showMoreGridIdArray[index];
        CustomGrid *gridItem = [[CustomGrid alloc] initWithFrame:CGRectZero title:gridTitle normalImage:normalImage highlightedImage:highlightedImage gridId:[gridTitle integerValue] atIndex:index isAddDelete:YES deleteIcon:deleteIconImage];
        gridItem.delegate = self;
        
        [self.gridItemArray addObject:gridItem];
        [self.showMoreGridView addSubview:gridItem];
    }
    
    [self.view addSubview:_showMoreGridView];
}

#pragma mark CustomGrid Delegate
//响应格子的点击事件
- (void)gridItemDidClicked:(CustomGrid *)clickItem
{
    for (NSInteger index = 0; index < self.gridItemArray.count; index++)
    {
        CustomGrid *gridItem = self.gridItemArray[index];
        if (gridItem.isChecked && gridItem.gridId != clickItem.gridId)
        {
            //隐藏删图标
            UIButton *deleteButton = (UIButton *)[self.showMoreGridView viewWithTag:gridItem.gridId];
            deleteButton.hidden = YES;
            
            [gridItem setIsChecked: NO];
            [gridItem setBackgroundImage:normalImage forState:UIControlStateNormal];
            isSelected = NO;
        }
    }
}

//响应格子删除事件
- (void)gridItemDidDeleteClicked:(UIButton *)deleteButton
{
    NSLog(@"您添加的格子GridId：%d", deleteButton.tag);
    
    //当首页显示的格子数量已经达到最大显示数量时，不能再次添加
    if (self.addGridArray.count >= maxAddGridCount) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"首页应用已满,请在移除首页某个应用后添加。"
                                                           delegate:self
                                                  cancelButtonTitle:@"ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }else{
        for (NSInteger i = 0; i < self.gridItemArray.count; i++) {
            CustomGrid *deleteGird = self.gridItemArray[i];
            if (deleteGird.gridId == deleteButton.tag) {
                //从视图上移除格子
                [deleteGird removeFromSuperview];
                
                NSInteger count = self.gridItemArray.count - 1;
                //从添加格子的索引开始，后面的格子依次往前移动一格
                for (NSInteger index = deleteGird.gridIndex; index < count; index++) {
                    CustomGrid *preGrid = self.gridItemArray[index];
                    CustomGrid *nextGrid = self.gridItemArray[index+1];
                    
                    [UIView animateWithDuration:0.5 animations:^{
                        nextGrid.center = preGrid.gridCenterPoint;
                    }];
                    nextGrid.gridIndex = index;
                }
                //将删除的格子从数组里面移除
                [self.gridItemArray removeObjectAtIndex:deleteGird.gridIndex];
                
                //删除格子的GirdID
                NSString *gridId = [NSString stringWithFormat:@"%d", deleteGird.gridId];
                [self.showMoreGridIdArray removeObject:gridId];
                [self.addGridArray addObject:gridId];
            }
        }
    }
    
    //for test print out
    for (NSInteger i = 0; i < _gridItemArray.count; i++)
    {
        CustomGrid *gridItem = _gridItemArray[i];
        gridItem.gridCenterPoint = gridItem.center;
        NSLog(@"所有格子的位置信息{gridIndex: %d, gridCenterPoint: %@, gridID: %d}",
              gridItem.gridIndex, NSStringFromCGPoint(gridItem.gridCenterPoint), gridItem.gridId);
    }
    
}

//响应格子的长安手势事件
- (void)pressGestureStateBegan:(UILongPressGestureRecognizer *)longPressGesture withGridItem:(CustomGrid *) grid
{
    //验证当前长按的按钮是否已经是选中的状态，如果是，那么只增加放大效果
    if (grid.isChecked) {
        grid.transform = CGAffineTransformMakeScale(1.2, 1.2);
    }else{
        //验证数组中所有的格子是否有选中状态的格子
        for (NSInteger i = 0; i < self.showMoreGridIdArray.count; i++) {
            CustomGrid *gridItem = self.gridItemArray[i];
            if (gridItem.isChecked) {
                isSelected = YES;
            }
        }
        
        //如果数组中有选中状态的格子，则不做任何操作，反则增加格子的选中状态
        if (!isSelected) {
            //标记该格子为选中状态
            grid.isChecked = YES;
            
            //显示格子右上角的添加图标
            UIButton *addButton = (UIButton *)[longPressGesture.view viewWithTag:grid.gridId];
            addButton.hidden = NO;
            
            //给选中的格子添加放大的特效
            [UIView animateWithDuration:0.5 animations:^{
                [grid setTransform:CGAffineTransformMakeScale(1.2, 1.2)];
                [grid setAlpha:0.8];
                [grid setBackgroundImage:highlightedImage forState:UIControlStateNormal];
            }];
        }
    }
}

- (void)pressGestureStateChangedWithPoint:(CGPoint) gridPoint gridItem:(CustomGrid *) gridItem
{
    
}

- (void)pressGestureStateEnded:(CustomGrid *) gridItem
{
    //手势结束时，还原格子的放大效果
    [UIView animateWithDuration:0.5 animations:^{
        [gridItem setTransform:CGAffineTransformIdentity];
        [gridItem setAlpha:1.0];
    }];
}

#pragma mark UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"click button index: %d", buttonIndex);
    if (buttonIndex == 0) {
        for (NSInteger index = 0; index < self.gridItemArray.count; index++)
        {
            CustomGrid *gridItem = self.gridItemArray[index];
            if (gridItem.isChecked)
            {
                //隐藏删图标
                UIButton *deleteButton = (UIButton *)[self.showMoreGridView viewWithTag:gridItem.gridId];
                deleteButton.hidden = YES;
                
                [gridItem setIsChecked: NO];
                [gridItem setBackgroundImage:normalImage forState:UIControlStateNormal];
                isSelected = NO;
            }
        }
    }
}

@end
