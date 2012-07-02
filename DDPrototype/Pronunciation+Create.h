//
//  Pronunciation+Create.h
//  DDPrototype
//
//  Created by Alison Kline on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Pronunciation.h"

@class GDataXMLElement;

@interface Pronunciation (Create)

+ (Pronunciation *)pronunciationWithFileLocation:(NSString *)fileLocation 
                                       andUnique:(NSString *)unique 
                          inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Pronunciation *)pronunciationFromGDataXMLElement:(GDataXMLElement *)pronunciationXML 
                             inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Pronunciation *)pronunciationFromString:(NSString *)string
                    inManagedObjectContext:(NSManagedObjectContext *)context;

@end
