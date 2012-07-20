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


+ (NSString *)dataFilePathFromDictionaryBundle:(NSBundle *)dictionaryBundle :(BOOL)forSave {
    
    NSString *datafile = [dictionaryBundle pathForResource:@"dictionary" ofType:@"xml"];
    NSLog(@"XML file for parsing = %@", datafile);
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

+ (GDataXMLDocument *) loadDictionaryFromXMLInDictionaryBundle:(NSBundle *)dictionaryBundle Error:(NSError **)error
{    
    NSString *filePath = [self dataFilePathFromDictionaryBundle:dictionaryBundle :FALSE];
    GDataXMLDocument *doc = [self loadDictionaryFromXMLWithFilePath:filePath Error:error];
    
    return doc;
}

+ (GDataXMLDocument *) loadDictionaryFromXMLWithFilePath:(NSString *)filePath Error:(NSError **)error
{
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData 
                                                           options:0 error:error];
    if (doc == nil) { return nil; }
    //NSLog(@"%@", doc.rootElement);
    
    return doc;
}

+ (void) processXMLfile:(GDataXMLDocument *)doc 
intoManagedObjectContext:(NSManagedObjectContext *)context 
           showProgressIn:(UILabel *)label
{
    
    GDataXMLElement *dictionary = doc.rootElement;
    [Dictionary dictionaryFromGDataXMLElement:dictionary inManagedObjectContext:context showProgressIn:(UILabel *)label];
    
//    NSArray *words = [doc.rootElement elementsForName:@"word"];
//    for (GDataXMLElement *word in words) {
//        [Word wordFromGDataXMLElement:word inManagedObjectContext:context];
//    };
}


@end
