//
//  GDataXMLNodeHelper.h
//  DDPrototype
//
//  Created by Alison Kline on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GDataXMLDocument;
@class GDataXMLElement;

@interface GDataXMLNodeHelper : NSObject

+ (GDataXMLDocument *) loadDictionaryFromXML;
+ (NSString *) dictionaryNameFromDoc:(GDataXMLDocument *)doc;
+ (NSString *) singleSubElementForName:(NSString *)subElementName 
                   FromGDataXMLElement:(GDataXMLElement *)element;
+ (void) processXMLfile:(GDataXMLDocument *)doc 
 intoManagedObjectContext:(NSManagedObjectContext *)context;

@end
