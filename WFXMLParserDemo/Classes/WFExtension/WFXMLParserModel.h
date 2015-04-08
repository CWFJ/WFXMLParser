//
//  WFXMLParserModel.h
//  WFExtension
//
//  Created by 开发者 on 15/4/8.
//  Copyright (c) 2015年 Jason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WFXMLParserModel : NSObject

/** 当前节点最终的值 */
@property (nonatomic, strong) id                 value;
/** 子节点 */
@property (nonatomic, strong) NSMutableArray    *subNodes;
/** 父节点 */
@property (nonatomic, strong) WFXMLParserModel  *parent;
/** 节点对应的key*/
@property (nonatomic, copy  ) NSString          *key;
/** 当前节点参数 */
@property (nonatomic, strong) NSDictionary      *attribute;

@end
