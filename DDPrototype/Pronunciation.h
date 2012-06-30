//
//  Pronunciation.h
//  DDPrototype
//
//  Created by Alison Kline on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ComponentSound, Word;

@interface Pronunciation : NSManagedObject

@property (nonatomic, retain) NSString * fileLocation;
@property (nonatomic, retain) NSData * pronuciationData;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSSet *componentSounds;
@property (nonatomic, retain) NSSet *spelling;
@end

@interface Pronunciation (CoreDataGeneratedAccessors)

- (void)addComponentSoundsObject:(ComponentSound *)value;
- (void)removeComponentSoundsObject:(ComponentSound *)value;
- (void)addComponentSounds:(NSSet *)values;
- (void)removeComponentSounds:(NSSet *)values;

- (void)addSpellingObject:(Word *)value;
- (void)removeSpellingObject:(Word *)value;
- (void)addSpelling:(NSSet *)values;
- (void)removeSpelling:(NSSet *)values;

@end
