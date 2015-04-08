//
//  WFXMLParserModel.m
//  WFExtension
//
//  Created by 开发者 on 15/4/8.
//  Copyright (c) 2015年 Jason. All rights reserved.
//

#import "WFXMLParserModel.h"

@implementation WFXMLParserModel

/**
 *  重写init方法，主要是初始化subNodes
 */
- (instancetype)init {
    if(self = [super init]) {
        self.subNodes = [NSMutableArray array];
    }
    return self;
}
@end
