//
//  ComponentSound.h
//  DDPrototype
//
//  Created by Alison Kline on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ComponentSoundSpelling, Pronunciation;

@interface ComponentSound : NSManagedObject

@property (nonatomic, retain) NSString * fileLocation;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * pronunciationData;
@property (nonatomic, retain) Pronunciation *usedIn;
@property (nonatomic, retain) ComponentSoundSpelling *componentSoundSpelling;

@end
