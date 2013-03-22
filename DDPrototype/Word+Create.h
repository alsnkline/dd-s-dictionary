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

+ (Word *)wordFromString:(NSString *)string
  inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Word *)wordFromGDataXMLElement:(GDataXMLElement *)wordXML
                   processingType:(XMLdocType)docType
           inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void) processDetailsOfWordXML:(GDataXMLElement *)wordXML
                            into:(Word *)word
          inManagedObjectContext:(NSManagedObjectContext *)context;

@end
