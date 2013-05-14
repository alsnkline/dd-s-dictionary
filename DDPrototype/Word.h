//
//  Word.h
//  DDPrototype
//
//  Created by Alison KLINE on 5/14/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Dictionary, Pronunciation;

@interface Word : NSManagedObject

@property (nonatomic, retain) NSString * fetchedResultsSection;
@property (nonatomic, retain) NSNumber * isHomophone;
@property (nonatomic, retain) NSString * spelling;
@property (nonatomic, retain) NSString * doubleMetaphoneCode;
@property (nonatomic, retain) Dictionary *inDictionary;
@property (nonatomic, retain) NSSet *pronunciations;
@end

@interface Word (CoreDataGeneratedAccessors)

- (void)addPronunciationsObject:(Pronunciation *)value;
- (void)removePronunciationsObject:(Pronunciation *)value;
- (void)addPronunciations:(NSSet *)values;
- (void)removePronunciations:(NSSet *)values;

@end
