//
//  DisplaySection.h
//  DDPrototype
//
//  Created by Alison Kline on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Word;

@interface DisplaySection : NSManagedObject

@property (nonatomic, retain) NSString * sectionDisplayName;
@property (nonatomic, retain) NSSet *wordsInSection;
@end

@interface DisplaySection (CoreDataGeneratedAccessors)

- (void)addWordsInSectionObject:(Word *)value;
- (void)removeWordsInSectionObject:(Word *)value;
- (void)addWordsInSection:(NSSet *)values;
- (void)removeWordsInSection:(NSSet *)values;

@end
