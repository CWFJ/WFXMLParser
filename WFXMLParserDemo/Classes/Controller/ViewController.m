//
//  ViewController.m
//  WFXMLParserDemo
//
//  Created by 开发者 on 15/4/8.
//  Copyright (c) 2015年 Jason. All rights reserved.
//

#import "ViewController.h"
#import "WFXMLParser.h"

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

- (IBAction)xmlTest {
    NSURL *xmlFilePath = [[NSBundle mainBundle] URLForResource:@"test.xml" withExtension:nil];
    NSData *xmlData = [NSData dataWithContentsOfURL:xmlFilePath options:NSDataReadingUncached error:NULL];
    NSLog(@"%@", [WFXMLParser XMLObjectWithData:xmlData]);
}
@end
