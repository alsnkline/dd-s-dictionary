//
//  Dictionary.h
//  DDPrototype
//
//  Created by Alison KLINE on 3/21/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Word;

@interface Dictionary : NSManagedObject

@property (nonatomic, retain) NSString * bundleName;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSSet *words;
@end

@interface Dictionary (CoreDataGeneratedAccessors)

- (void)addWordsObject:(Word *)value;
- (void)removeWordsObject:(Word *)value;
- (void)addWords:(NSSet *)values;
- (void)removeWords:(NSSet *)values;

@end
