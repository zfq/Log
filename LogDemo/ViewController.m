//
//  ViewController.m
//  LogDemo
//
//  Created by _ on 17/2/4.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "ViewController.h"
#import "ZFQLog.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)tapSaveBtnAction:(id)sender
{
    [ZFQLog logMsg:self.myTextField.text];
    //[ZFQLog logFormat:@"这是我人生的第%d和%@",123,@"你妹的"];
}

@end
