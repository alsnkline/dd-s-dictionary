//
//  Pronunciation.h
//  DDPrototype
//
//  Created by Alison KLINE on 3/21/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Word;

@interface Pronunciation : NSManagedObject

@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSSet *spellings;
@end

@interface Pronunciation (CoreDataGeneratedAccessors)

- (void)addSpellingsObject:(Word *)value;
- (void)removeSpellingsObject:(Word *)value;
- (void)addSpellings:(NSSet *)values;
- (void)removeSpellings:(NSSet *)values;

@end
