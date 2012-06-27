//
//  Phoneme.h
//  DDPrototype
//
//  Created by Alison Kline on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PhonemeSpelling, Pronunciation;

@interface Phoneme : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * pronunciationData;
@property (nonatomic, retain) NSString * fileLocation;
@property (nonatomic, retain) Pronunciation *usedIn;
@property (nonatomic, retain) NSSet *spelling;
@end

@interface Phoneme (CoreDataGeneratedAccessors)

- (void)addSpellingObject:(PhonemeSpelling *)value;
- (void)removeSpellingObject:(PhonemeSpelling *)value;
- (void)addSpelling:(NSSet *)values;
- (void)removeSpelling:(NSSet *)values;

@end
