//
//  LTXMLParser.m
//  LentaTest
//
//  Created by Пользователь on 15/03/15.
//  Copyright (c) 2015 DOTCAPITAL. All rights reserved.
//

#import "LTXMLParser.h"

@interface LTXMLParser()<NSXMLParserDelegate>
{
    NSXMLParser *_xmlParser;
    NSMutableArray *_resItems;
    
    NSMutableDictionary *_curItem;
    NSString *_startedItemField;
    NSMutableString *_itemFieldValue;
}

@end

@implementation LTXMLParser

-(id)init
{
    return nil;
}

-(instancetype)initWithData:(NSData *)data
{
    if (self=[super init])
    {
        _xmlParser = [[NSXMLParser alloc]initWithData:data];
        [_xmlParser setDelegate:self];
        if (!_xmlParser)
            return nil;
    }
    
    return self;
}

-(void)startParse
{
    [_xmlParser parse];
}


#pragma mark - NSXMLParserDelegate
// sent when the parser begins parsing of the document.
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    _resItems= [NSMutableArray new];
}

// sent when the parser has completed parsing. If this is encountered, the parse was successful.
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if ([self completionBlock])
        [self completionBlock](_resItems,nil);
}


// DTD handling methods for various declarations.
- (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID
{
    
}

- (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName
{
    
}

- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue
{
    
}

- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model
{
    
}

- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value
{
    
}

- (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID
{
    
}

// sent when the parser finds an element start tag.
// In the case of the cvslog tag, the following is what the delegate receives:
//   elementName == cvslog, namespaceURI == http://xml.apple.com/cvslog, qualifiedName == cvslog
// In the case of the radar tag, the following is what's passed in:
//    elementName == radar, namespaceURI == http://xml.apple.com/radar, qualifiedName == radar:radar
// If namespace processing >isn't< on, the xmlns:radar="http://xml.apple.com/radar" is returned as an attribute pair, the elementName is 'radar:radar' and there is no qualifiedName.
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    
    
    if ([elementName isEqualToString:@"item"]){
        _curItem = [NSMutableDictionary new];
    }else if (_curItem){
        if ([elementName isEqualToString:@"title"]||
            [elementName isEqualToString:@"guid"]||
            [elementName isEqualToString:@"link"]||
            [elementName isEqualToString:@"description"]||
            [elementName isEqualToString:@"pubDate"]){
            _startedItemField = elementName;
            _itemFieldValue = [NSMutableString new];
        }else if ([elementName isEqualToString:@"enclosure"]){
            NSString *urlValue=[attributeDict valueForKey:@"url"];
            NSString *urlType=[attributeDict valueForKey:@"type"];
            
            if ([urlType containsString:@"image/"] && urlValue && [urlValue length]>0)
            {
                _curItem[@"imageUrl"] = urlValue;
                _curItem[@"imageType"] = urlType;
            }
        }
    }
}

// sent when an end tag is encountered. The various parameters are supplied as above.
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
    
    if ([elementName isEqualToString:@"item"])
    {
        if (_curItem && [_curItem count]>0)
            [_resItems addObject:_curItem];
        _curItem = nil;
    }else if (_curItem){
        if ([elementName isEqualToString:_startedItemField]){
            
            if (_itemFieldValue)
                _curItem[elementName] = _itemFieldValue;
            
            _startedItemField = nil;
            _itemFieldValue = nil;
        }
    }
}


// sent when the parser first sees a namespace attribute.
// In the case of the cvslog tag, before the didStartElement:, you'd get one of these with prefix == @"" and namespaceURI == @"http://xml.apple.com/cvslog" (i.e. the default namespace)
// In the case of the radar:radar tag, before the didStartElement: you'd get one of these with prefix == @"radar" and namespaceURI == @"http://xml.apple.com/radar"
- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI
{
    
}

// sent when the namespace prefix in question goes out of scope.
- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix
{
    
}

// This returns the string of the characters encountered thus far. You may not necessarily get the longest character run. The parser reserves the right to hand these to the delegate as potentially many calls in a row to -parser:foundCharacters:
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (_startedItemField && _itemFieldValue)
        [_itemFieldValue appendString:string];
}

// The parser reports ignorable whitespace in the same way as characters it's found.
- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString
{
    
}

// The parser reports a processing instruction to you using this method. In the case above, target == @"xml-stylesheet" and data == @"type='text/css' href='cvslog.css'"
- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data
{
    
}

// A comment (Text in a <!-- --> block) is reported to the delegate as a single string
- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment
{
    
}

// this reports a CDATA block to the delegate as an NSData.
- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    if (_startedItemField && _itemFieldValue){
        NSString *str = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
        if (str)
            [_itemFieldValue appendString:str];
    }
    
}

// this gives the delegate an opportunity to resolve an external entity itself and reply with the resulting data.
//- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(NSString *)systemID
//{
//  
//    
//}

// ...and this reports a fatal error to the delegate. The parser will stop parsing.
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if ([self completionBlock])
        [self completionBlock](nil,parseError);
}

// If validation is on, this will report a fatal validation error to the delegate. The parser will stop parsing.
- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
    if ([self completionBlock])
        [self completionBlock](nil,validationError);
}




@end
