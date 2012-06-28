//
//  Word+Create.h
//  DDPrototype
//
//  Created by Alison Kline on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Word.h"

@class GDataXMLElement;

@interface Word (Create)

+ (Word *)wordFromString:(NSString *)string
  inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Word *)wordFromGDataXMLElement:(GDataXMLElement *)wordXML 
        inManagedObjectContext:(NSManagedObjectContext *)context;

@end
