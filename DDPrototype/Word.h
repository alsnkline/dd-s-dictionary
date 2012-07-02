//
//  Word.h
//  DDPrototype
//
//  Created by Alison Kline on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Pronunciation;

@interface Word : NSManagedObject

@property (nonatomic, retain) NSString * fetchedResultsSection;
@property (nonatomic, retain) NSString * spelling;
@property (nonatomic, retain) NSNumber * isHomophone;
@property (nonatomic, retain) NSSet *pronunciations;
@end

@interface Word (CoreDataGeneratedAccessors)

- (void)addPronunciationsObject:(Pronunciation *)value;
- (void)removePronunciationsObject:(Pronunciation *)value;
- (void)addPronunciations:(NSSet *)values;
- (void)removePronunciations:(NSSet *)values;

@end
