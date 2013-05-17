//
//  Group+Create.h
//  DDPrototype
//
//  Created by Alison KLINE on 5/15/13.
//
//

#import "Group.h"

@interface Group (Create)

+ (void) processGroupsFile:(NSArray *)name
                inManagedObjectContext:(NSManagedObjectContext *)context;

@end
