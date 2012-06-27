//
//  Pronunciation+Create.h
//  DDPrototype
//
//  Created by Alison Kline on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Pronunciation.h"

@interface Pronunciation (Create)

+ (Pronunciation *)pronunciationWithFileLocation:(NSString *)fileLocation 
                                       andUnique:(NSString *)unique 
                          inManagedObjectContext:(NSManagedObjectContext *)context;

@end
