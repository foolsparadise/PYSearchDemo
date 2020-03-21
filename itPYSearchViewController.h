//
//  itPYSearchViewController.h
//  Demo
//
//  Created by foolsparadise on 21/1/2020.
//  Copyright © 2020 github.com/foolsparadise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYSearch.h"
#import "EVNCustomSearchBar.h"
#import "EVNCustomSearchBarHeader.h"
#import "EVNCustomSearchBarHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface itPYSearchViewController : UIViewController<EVNCustomSearchBarDelegate>
@property (strong, nonatomic) EVNCustomSearchBar *searchBar;

@end

NS_ASSUME_NONNULL_END
