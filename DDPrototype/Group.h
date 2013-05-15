//
//  Group.h
//  DDPrototype
//
//  Created by Alison KLINE on 5/15/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Word;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSSet *words;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addWordsObject:(Word *)value;
- (void)removeWordsObject:(Word *)value;
- (void)addWords:(NSSet *)values;
- (void)removeWords:(NSSet *)values;

@end
