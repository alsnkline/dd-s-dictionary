//
//  ComponentSoundSpelling.h
//  DDPrototype
//
//  Created by Alison Kline on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ComponentSound;

@interface ComponentSoundSpelling : NSManagedObject

@property (nonatomic, retain) NSString * componentSoundSpelling;
@property (nonatomic, retain) NSString * silentLetters;
@property (nonatomic, retain) ComponentSound *spellingOf;

@end
