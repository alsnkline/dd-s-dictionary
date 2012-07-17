//
//  ComponentSound.h
//  DDPrototype
//
//  Created by Alison Kline on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ComponentSoundSpelling, Pronunciation;

@interface ComponentSound : NSManagedObject

@property (nonatomic, retain) NSString * fileLocation;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * pronunciationData;
@property (nonatomic, retain) ComponentSoundSpelling *componentSoundSpelling;
@property (nonatomic, retain) Pronunciation *usedIn;

@end
