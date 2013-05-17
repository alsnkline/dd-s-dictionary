//
//  Word+Create.h
//  DDPrototype
//
//  Created by Alison Kline on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Word.h"
#import "GDataXMLNodeHelper.h"

@class GDataXMLElement;

@interface Word (Create)

+ (Word *)wordWithSpellingFromGDataXMLElement:(GDataXMLElement *)wordXML
                       inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Word *)wordWithSpelling:(NSString *)spelling
    inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Word *)wordFromGDataXMLElement:(GDataXMLElement *)wordXML
                   processingType:(XMLdocType)docType
           inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void) processDetailsOfWordXML:(GDataXMLElement *)wordXML
                            into:(Word *)word
          inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)removeWordWithSpellingFromGDataXMLElement:(GDataXMLElement *)wordXML
                         fromManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)removeWordWithSpelling:(NSString *)spelling
    fromManagedObjectContext:(NSManagedObjectContext *)context;

@end
