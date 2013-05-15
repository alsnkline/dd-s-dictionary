//
//  Word.h
//  DDPrototype
//
//  Created by Alison KLINE on 5/15/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Dictionary, Group, Pronunciation;

@interface Word : NSManagedObject

@property (nonatomic, retain) NSString * doubleMetaphonePrimaryCode;
@property (nonatomic, retain) NSString * fetchedResultsSection;
@property (nonatomic, retain) NSNumber * isHomophone;
@property (nonatomic, retain) NSString * spelling;
@property (nonatomic, retain) NSString * doubleMetaphoneSecondaryCode;
@property (nonatomic, retain) NSString * spellingUK;
@property (nonatomic, retain) Dictionary *inDictionary;
@property (nonatomic, retain) NSSet *pronunciations;
@property (nonatomic, retain) NSSet *inGroups;
@end

@interface Word (CoreDataGeneratedAccessors)

- (void)addPronunciationsObject:(Pronunciation *)value;
- (void)removePronunciationsObject:(Pronunciation *)value;
- (void)addPronunciations:(NSSet *)values;
- (void)removePronunciations:(NSSet *)values;

- (void)addInGroupsObject:(Group *)value;
- (void)removeInGroupsObject:(Group *)value;
- (void)addInGroups:(NSSet *)values;
- (void)removeInGroups:(NSSet *)values;

@end
