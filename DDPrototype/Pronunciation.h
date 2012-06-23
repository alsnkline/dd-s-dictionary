//
//  Pronunciation.h
//  DDPrototype
//
//  Created by Alison Kline on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Word;

@interface Pronunciation : NSManagedObject

@property (nonatomic, retain) NSData * pronuciation;
@property (nonatomic, retain) Word *spelling;

@end
