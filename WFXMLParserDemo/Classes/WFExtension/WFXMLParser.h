//
//  WFXMLParser.h
//  WFExtension
//
//  Created by 开发者 on 15/4/8.
//  Copyright (c) 2015年 Jason. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 解析超时时间，默认 1.0s */
#define PARSER_TIMEOUT 1.0

@interface WFXMLParser : NSObject

+ (id)XMLObjectWithData:(NSData *)data;
+ (id)XMLObjectWithParser:(NSXMLParser *)parser;

@end
