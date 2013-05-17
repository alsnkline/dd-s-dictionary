//
//  Group+Create.m
//  DDPrototype
//
//  Created by Alison KLINE on 5/15/13.
//
//

#import "Group+Create.h"
#import "Word+Create.h"

@implementation Group (Create)

+ (void) processGroupsFile:(NSArray *)array
    inManagedObjectContext:(NSManagedObjectContext *)context
{
    Group *group = nil;
    
    for (NSDictionary *groupDict in array) {
        
        NSString *displayName = [groupDict objectForKey:@"displayName"];
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
        request.predicate = [NSPredicate predicateWithFormat:@"displayName = %@",displayName];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
        request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        NSError *error = nil;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || ([matches count] > 1)) {
            //handle error
        } else if ([matches count] == 0) {
            group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
            group.displayName = displayName;
            
            NSArray *wordsFromArray = [groupDict objectForKey:@"words"];
            NSMutableSet *words = [NSMutableSet setWithCapacity:[wordsFromArray count]];
            for (NSString *wordString in wordsFromArray) {
                Word *word = [Word wordWithSpelling:wordString inManagedObjectContext:context];
                if (word) [words addObject:word];
            }
            group.words = words;
        }
        if (PROCESS_VERBOSELY) NSLog(@"Group in UIManagedDocument %@", group);
    }
}

@end
