//
//  WiFiViewController.h
//  LogDemo
//
//  Created by _ on 17/2/7.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WiFiViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *wifiNameLabel;

- (IBAction)tapStartServerAction:(UIButton *)sender;
- (IBAction)tapCloseAction:(UIButton *)sender;

@end
