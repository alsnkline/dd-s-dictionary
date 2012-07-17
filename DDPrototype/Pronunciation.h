//
//  Pronunciation.h
//  DDPrototype
//
//  Created by Alison Kline on 7/16/12.
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
@property (nonatomic, retain) NSSet *spellings;
@end

@interface Pronunciation (CoreDataGeneratedAccessors)

- (void)addComponentSoundsObject:(ComponentSound *)value;
- (void)removeComponentSoundsObject:(ComponentSound *)value;
- (void)addComponentSounds:(NSSet *)values;
- (void)removeComponentSounds:(NSSet *)values;

- (void)addSpellingsObject:(Word *)value;
- (void)removeSpellingsObject:(Word *)value;
- (void)addSpellings:(NSSet *)values;
- (void)removeSpellings:(NSSet *)values;

@end
