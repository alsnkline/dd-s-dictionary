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

typedef enum XMLdocType {DOC_TYPE_DICTIONARY, DOC_TYPE_CORRECTIONS} XMLdocType;

@interface GDataXMLNodeHelper : NSObject

+ (NSString *)filePathFromDictionaryBundle:(NSBundle *)dictionaryBundle ofType:(XMLdocType)type;

+ (GDataXMLDocument *) loadXMLDocType:(XMLdocType)type
            FromXMLInDictionaryBundle:(NSBundle *)dictionaryBundle
                                Error:(NSError **)error;
+ (GDataXMLDocument *) loadDocFromXMLWithFilePath:(NSString *)filePath 
                                            Error:(NSError **)error; //creates the GDataXMLDocument * to be parsed

+ (NSString *) dictionaryNameFor:(NSString *)element
                      FromXMLDoc:(GDataXMLDocument *)doc;

+ (NSString *) singleSubElementForName:(NSString *)subElementName
                   FromGDataXMLElement:(GDataXMLElement *)element;

+ (void) processXMLfile:(GDataXMLDocument *)doc
                   type:(XMLdocType)docType
intoManagedObjectContext:(NSManagedObjectContext *)context;

@end
