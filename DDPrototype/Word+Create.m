//
//  Word+Create.m
//  DDPrototype
//
//  Created by Alison Kline on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Word+Create.h"

@implementation Word (Create)

+ (Word *)wordFromString:(NSString *)string
  inManagedObjectContext:(NSManagedObjectContext *)context
{
    Word *word = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    request.predicate = [NSPredicate predicateWithFormat:@"spelling = %@", string];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"spelling" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        //handle error
    } else if ([matches count] == 0) {
        word = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:context];
        //                [word setValue:string forKey:@"Word"]; //only if you don't use the subclass
        word.spelling = string;
        // have to set a pronunciation
//        NSSet *pronuns = [NSSet setWithObject: "create data from sound file"
        // use create catagory also.
        //word.pronunciations = pronuns;
        
        //start creating objects in document's context
    } else {
        word = [matches lastObject];
    }
    return word;
}

@end
