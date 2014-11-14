//
//  MoreViewController.h
//  MoveGrid
//
//  Created by Jerry.li on 14-11-7.
//  Copyright (c) 2014年 51app. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MainViewController;
@interface MoreViewController : UIViewController

//显示格子的GridId
@property(nonatomic, strong)NSMutableArray *showMoreGridIdArray;
//当前首页显示格子的数量
@property(nonatomic, assign)NSInteger currentGridCount;

@end
