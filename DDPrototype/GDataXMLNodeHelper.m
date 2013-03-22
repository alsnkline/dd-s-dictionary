//
//  GDataXMLNodeHelper.m
//  DDPrototype
//
//  Created by Alison Kline on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GDataXMLNodeHelper.h"
#import "GDataXMLNode.h"
// #import "Word+Create.h"
#import "Dictionary+Create.h"

@implementation GDataXMLNodeHelper

+ (NSString *)filePathFromDictionaryBundle:(NSBundle *)dictionaryBundle ofType:(XMLdocType)type
{
    NSString *datafile = nil;
    
    if (type == DOC_TYPE_DICTIONARY) datafile = [dictionaryBundle pathForResource:@"dictionary" ofType:@"xml"];
    if (type == DOC_TYPE_CORRECTIONS) datafile = [dictionaryBundle pathForResource:@"corrections" ofType:@"xml"];
    
    if (datafile) NSLog(@"XML %@ file found", type ? @"Corrections" : @"Dictionary");
    if (!datafile)  NSLog(@"XML %@ file NOT found", type ? @"Corrections" : @"Dictionary");
    
    return datafile;
}

+ (NSString *) dictionaryNameFor:(NSString *)element 
                      FromXMLDoc:(GDataXMLDocument *)doc
{
    NSArray *dictionaryNames = [doc.rootElement elementsForName:element];
    [dictionaryNames count] == 1? NSLog(@"dictionaryName = %@", [dictionaryNames lastObject]): NSLog(@"error getting dictionaryNames");
    if ([dictionaryNames count] == 1) {
        GDataXMLElement *dictionaryNameXML = [dictionaryNames lastObject];
        NSString *dictionaryName = dictionaryNameXML.stringValue;
        return dictionaryName;
    } else {
        NSLog(@"error getting dictionaryNames");
        return nil;
    }
}
+ (NSString *) singleSubElementForName:(NSString *)subElementName 
                   FromGDataXMLElement:(GDataXMLElement *)element
{
    NSArray *subElements = [element elementsForName:subElementName];
    if ([subElements count] == 1) {
        GDataXMLElement *subElementXML = [subElements lastObject];
        NSString *singleSubElement = subElementXML.stringValue;
        return singleSubElement;
    } else {
        NSLog(@"no %@ in %@", subElementName, element);
        return nil;
    }
}

+ (GDataXMLDocument *)loadXMLDocType:(XMLdocType)type FromXMLInDictionaryBundle:(NSBundle *)dictionaryBundle Error:(NSError *__autoreleasing *)error
{
    NSString *filePath = [self filePathFromDictionaryBundle:dictionaryBundle ofType:type];
    GDataXMLDocument *doc = nil;
    if (filePath) {
        doc = [self loadDocFromXMLWithFilePath:filePath Error:error];
    }
    return doc;
}

+ (GDataXMLDocument *) loadDocFromXMLWithFilePath:(NSString *)filePath Error:(NSError **)error
{
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData 
                                                           options:0 error:error];
    if (doc == nil) { return nil; }
    //NSLog(@"%@", doc.rootElement);
    
    return doc;
}

+ (void) processXMLfile:(GDataXMLDocument *)doc
                   type:(XMLdocType)docType
intoManagedObjectContext:(NSManagedObjectContext *)context 
{
    NSLog(@"Processing %@ XMLdoc", docType ? @"Corrections" : @"Dictionary");
    GDataXMLElement *dictionary = doc.rootElement;
    [Dictionary dictionaryFromGDataXMLElement:dictionary XMLdocType:docType inManagedObjectContext:context];
}


@end
