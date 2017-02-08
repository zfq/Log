//
//  WiFiViewController.m
//  LogDemo
//
//  提示IP地址
//  Created by _ on 17/2/7.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "WiFiViewController.h"
#import "WiFiUploadFileManager.h"

@interface WiFiViewController ()
@property (nonatomic, strong) WiFiUploadFileManager *manager;
@end

@implementation WiFiViewController

- (WiFiUploadFileManager *)manager
{
    if (!_manager) {
        _manager = [[WiFiUploadFileManager alloc] init];
    }
    return _manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapStartServerAction:(UIButton *)sender
{
    [self.manager startHttpServer];
}

- (IBAction)tapCloseAction:(UIButton *)sender
{
    [self.manager stopHttpServer];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
