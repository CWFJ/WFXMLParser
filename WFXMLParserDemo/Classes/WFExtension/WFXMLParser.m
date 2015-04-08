//
//  WFXMLParser.m
//  WFExtension
//
//  Created by 开发者 on 15/4/8.
//  Copyright (c) 2015年 Jason. All rights reserved.
//  XML解析，采用SAX解析方式

#import "WFXMLParser.h"
#import "WFXMLParserModel.h"

@interface WFXMLParser () <NSXMLParserDelegate>

/** 解析结束标志 */
@property (nonatomic, assign) BOOL               parserEnd;
/** 解析结果 */
@property (nonatomic, strong) id                 parserResult;
/** 当前解析到的节点 */
@property (nonatomic, strong) WFXMLParserModel  *currNode;
/** 当前节点字符串内容 */
@property (nonatomic, copy  ) NSMutableString   *nodeString;
/** 解析超时定时器 */
@property (nonatomic, strong) NSTimer           *timer;

@end
@implementation WFXMLParser

/**
 *  XML解析
 *
 *  @param data 待解析的二进制数据
 *
 *  @return 解析结果
 */
+ (id)XMLObjectWithData:(NSData *)data {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    return [self XMLObjectWithParser:parser];
}

/**
 *  XML解析
 *
 *  @param parser 带解析的parser
 *
 *  @return 解析结果
 */
+ (id)XMLObjectWithParser:(NSXMLParser *)parser {
    WFXMLParser *wfParser = [[self alloc] init];
    /** 配置解析代理 */
    parser.delegate = wfParser;
    /** 开始解析 */
    [parser parse];
    
    /** 创建定时器，用于判断解析超时 */
    wfParser.timer = [NSTimer scheduledTimerWithTimeInterval:PARSER_TIMEOUT target:wfParser selector:@selector(timeOut) userInfo:nil repeats:NO];
    [wfParser.timer fire];

    // 等待解析结束
    while (!wfParser.parserEnd);
    // 返回解析结果
    return wfParser.parserResult;
}

/**
 *  解析超时回调，可能是由于XML文件格式错误，导致SAX解析无法结束！
 */
- (void)timeOut {
    if(!self.parserEnd) {
        NSLog(@"解析超时：可能是由于XML文件格式错误！");
        self.parserEnd = TRUE;
    }
}
/********************************************************************
 *
 *                             解析过程
 *
 *******************************************************************/
/**
 *  打开文档
 */
- (void)parserDidStartDocument:(NSXMLParser *)parser {
//    NSLog(@"打开文档%@", parser);
}

/**
 *  开始节点
 *
 *  @param elementName   节点名称
 *  @param attributeDict 节点参数
 *  @note  生成新的节点对象，记录父子关系
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

    /** 创建新的节点 */
    WFXMLParserModel *newNode = [[WFXMLParserModel alloc] init];
    
    newNode.attribute = attributeDict.copy;

    if(_currNode) {
        /** 存储当前节点到父节点 */
        NSDictionary *dict = @{@"key":elementName, @"value":newNode};
        [_currNode.subNodes addObject:dict];
        if(!_currNode.key) {
            _currNode.key = elementName;
        }
        if((_currNode.key != elementName) && ![_currNode.key isEqualToString:@"-1"]) {
            _currNode.key = @"-1";
        }
        newNode.parent = _currNode;
    }
    /** 记录新的节点为当前节点 */
    _currNode = newNode;

    /** 初始化拼接字符串 */
    _nodeString = [NSMutableString string];
}

/**
 *  遍历节点内容
 *
 *  @param string 节点内容
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    // 拼接节点内容
    [_nodeString appendString:string];
}

/**
 *  结束节点
 *
 *  @param elementName  结束节点名称
 *  @note  根据节点内容，判断当前节点类型：
            1.没有参数，且没有子节点           ---- NSString （例：<test>abc</test>）
            2.含有子节点，且子节点key值不同     ---- NSArray (例：<test>  <sub1>abc</sub1>  <sub2>cde</sub2>  </test>)
            3.含有参数或者子节点key值唯一       ---- NSDictionary (例：<test> <sub1>abc</sub1> <sub1>abc</sub1> </test>或<test para="p" />)
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if(_currNode.subNodes.count == 0 && _currNode.attribute.allKeys.count == 0) {
        
        /** 没有参数，且没有子节点 */
        _currNode.value = (NSString *)_nodeString.copy;
    }
    else if((_currNode.key != nil) && ![_currNode.key isEqualToString:@"-1"]) {
        
        /** 含有参数或者子节点key值唯一 */
        NSMutableArray *subNods = [NSMutableArray array];
        [_currNode.subNodes enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
            WFXMLParserModel *subNode = dict[@"value"];
            [subNods addObject:subNode.value];
        }];
        _currNode.value = subNods.copy;
    }
    else {
        
        /** 含有子节点，且子节点key值不同 */
        NSMutableDictionary *subNodes = [NSMutableDictionary dictionaryWithDictionary:_currNode.attribute];
        [_currNode.subNodes enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
            WFXMLParserModel *subNode = dict[@"value"];
            [subNodes setValue:subNode.value forKey:dict[@"key"]];
        }];
        _currNode.value = subNodes.copy;
    }
    if(_currNode.parent) {
        _currNode = _currNode.parent;
    }
}

/**
 *  关闭文件
 *
 *  @note 设置结束标志位，设置解析结果
 */
-(void)parserDidEndDocument:(NSXMLParser *)parser {
    self.parserResult = _currNode.value;
    self.parserEnd    = TRUE;
    /** 停止定时器 */
    [_timer invalidate];
}
@end

