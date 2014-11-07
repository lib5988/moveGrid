//
//  CustomGrid.h
//  MoveGrid
//
//  Created by Jerry.li on 14-11-6.
//  Copyright (c) 2014年 51app. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomGrid : UIButton

//格子的ID
@property(nonatomic, assign)NSInteger gridId;
//格子的选中状态
@property(nonatomic, assign)BOOL isChecked;
//格子的移动状态
@property(nonatomic, assign)BOOL isMove;
//格子的排列索引位置
@property(nonatomic, assign)NSInteger gridIndex;
//格子的位置坐标
@property(nonatomic, assign)CGPoint gridCenterPoint;

@end
