//
//  PhonemeSpelling.h
//  DDPrototype
//
//  Created by Alison Kline on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Phoneme;

@interface PhonemeSpelling : NSManagedObject

@property (nonatomic, retain) NSString * phonemeSpelling;
@property (nonatomic, retain) NSString * silentLetters;
@property (nonatomic, retain) Phoneme *phoneme;

@end
