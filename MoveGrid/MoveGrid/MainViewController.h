//
//  MainViewController.h
//  MoveGrid
//
//  Created by Jerry.li on 14-11-6.
//  Copyright (c) 2014年 51app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomGrid.h"

@interface MainViewController : UIViewController<CustomGridDelegate>

@property(nonatomic, strong)NSMutableArray *addGridArray;

@end
