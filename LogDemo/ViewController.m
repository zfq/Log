//
//  ViewController.m
//  LogDemo
//
//  Created by _ on 17/2/4.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "ViewController.h"
#import "ZFQLog.h"
#import "WiFiViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [startBtn setTitle:@"打开WiFi上传页面" forState:UIControlStateNormal];
    startBtn.frame = CGRectMake(50, 100, 180, 44);
    [self.view addSubview:startBtn];
    [startBtn addTarget:self action:@selector(showWiFiPage) forControlEvents:UIControlEventTouchUpInside];
}

- (void)showWiFiPage
{
    WiFiViewController *wfVC = [[WiFiViewController alloc] init];
    [self presentViewController:wfVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)tapSaveBtnAction:(id)sender
{
    ZFQLog(self.myTextField.text);
}

@end
