//
//  GDataXMLNodeHelper.m
//  DDPrototype
//
//  Created by Alison Kline on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GDataXMLNodeHelper.h"
#import "GDataXMLNode.h"
#import "Word+Create.h"

@implementation GDataXMLNodeHelper

+ (NSString *)dataFilePath:(BOOL)forSave {
    //NSString *datafile = [[NSBundle mainBundle] pathForResource:@"TestDictionary1" ofType:@"xml"];
    NSString *datafile = [[NSBundle mainBundle] pathForResource:@"FirstGradeDictionary" ofType:@"xml"];
    NSLog(@"XML file for parsing = %@", datafile);
    return datafile;
}

+ (NSString *) dictionaryNameFromDoc:(GDataXMLDocument *)doc
{
    NSArray *dictionaryNames = [doc.rootElement elementsForName:@"displayName"];
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
        NSLog(@"error getting %@ from %@", subElementName, element);
        return nil;
    }
}


+ (GDataXMLDocument *) loadDictionaryFromXMLError:(NSError **)error
{
    NSString *filePath = [self dataFilePath:FALSE];
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData 
                                                           options:0 error:error];
    if (doc == nil) { return nil; }
    //NSLog(@"%@", doc.rootElement);
    
    return doc;
}

+ (void) processXMLfile:(GDataXMLDocument *)doc 
intoManagedObjectContext:(NSManagedObjectContext *)context
{
    NSArray *words = [doc.rootElement elementsForName:@"word"];
    for (GDataXMLElement *word in words) {
        [Word wordFromGDataXMLElement:word inManagedObjectContext:context];
    };
}


@end
