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
    NSString *datafile = [[NSBundle mainBundle] pathForResource:@"TestDictionary1" ofType:@"xml"];
    NSLog(@"XML file for parsing = %@", datafile);
    return datafile;
}

+ (NSString *) dictionaryNameFromDoc:(GDataXMLDocument *)doc
{
    NSArray *dictionaryNames = [doc.rootElement elementsForName:@"name"];
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

+ (NSString *) spellingFromGDataXMLWordElement:(GDataXMLElement *)word
{
    NSArray *spellings = [word elementsForName:@"spelling"];
    if ([spellings count] == 1) {
        GDataXMLElement *spellingXML = [spellings lastObject];
        NSString *spelling = spellingXML.stringValue;
        return spelling;
    } else {
        NSLog(@"error getting spelling");
        return nil;
    }
}

+ (GDataXMLDocument *) loadDictionaryFromXML
{
    NSString *filePath = [self dataFilePath:FALSE];
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData 
                                                           options:0 error:&error];
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
