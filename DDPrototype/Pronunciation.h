//
//  Pronunciation.h
//  DDPrototype
//
//  Created by Alison Kline on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Phoneme, Word;

@interface Pronunciation : NSManagedObject

@property (nonatomic, retain) NSData * pronuciationData;
@property (nonatomic, retain) NSString * fileLocation;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSSet *spelling;
@property (nonatomic, retain) NSSet *phonemes;
@end

@interface Pronunciation (CoreDataGeneratedAccessors)

- (void)addSpellingObject:(Word *)value;
- (void)removeSpellingObject:(Word *)value;
- (void)addSpelling:(NSSet *)values;
- (void)removeSpelling:(NSSet *)values;

- (void)addPhonemesObject:(Phoneme *)value;
- (void)removePhonemesObject:(Phoneme *)value;
- (void)addPhonemes:(NSSet *)values;
- (void)removePhonemes:(NSSet *)values;

@end
