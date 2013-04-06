//
//  Dictionary+Create.h
//  DyDictionary
//
//  Created by Alison Kline on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Dictionary.h"
#import "GDataXMLNodeHelper.h"

@class GDataXMLElement;

@interface Dictionary (Create)


+ (Dictionary *)dictionaryFromGDataXMLElement:(GDataXMLElement *)dictionaryXML
                                   XMLdocType:(XMLdocType)docType
                       inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void) processDetailsOfDictionaryXML:(GDataXMLElement *)dictionaryXML
                                  into:(Dictionary *)dictionary
                        XMLdocType:(XMLdocType)docType
                inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)removeEmptyDictionariesInManagedObjectContext:(NSManagedObjectContext *)context;
@end
