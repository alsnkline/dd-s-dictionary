//
//  GroupHelper.h
//  DDPrototype
//
//  Created by Alison KLINE on 5/16/13.
//
//

#import <Foundation/Foundation.h>

@interface GroupHelper : NSObject

+ (NSURL *)groupJSONFileDirectory;
+ (NSString *)latestGroupsJSONfileVersionNumber;
+ (NSArray *)contentsOfLatestJSONGroupsFile;

@end
