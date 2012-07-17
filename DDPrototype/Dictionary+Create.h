//
//  Dictionary+Create.h
//  DyDictionary
//
//  Created by Alison Kline on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Dictionary.h"

@class GDataXMLElement;

@interface Dictionary (Create)


+ (Dictionary *)dictionaryFromGDataXMLElement:(GDataXMLElement *)dictionaryXML 
                       inManagedObjectContext:(NSManagedObjectContext *)context;
@end
