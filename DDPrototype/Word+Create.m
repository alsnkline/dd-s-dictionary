//
//  Word+Create.m
//  DDPrototype
//
//  Created by Alison Kline on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Word+Create.h"
#import "GDataXMLNode.h"
#import "GDataXMLNodeHelper.h"

@implementation Word (Create)

+ (Word *)wordFromString:(NSString *)string
  inManagedObjectContext:(NSManagedObjectContext *)context   //method used during app development for simple word * creation.
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
        
        // no other prameters in this simple word implementation
    } else {
        word = [matches lastObject];
    }
    NSLog(@"Word in dictionary %@", word);
    return word;
}

+ (Word *)wordFromGDataXMLElement:(GDataXMLElement *)wordXML 
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Word *word = nil;
    NSString *spelling = [GDataXMLNodeHelper spellingFromGDataXMLWordElement:wordXML];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    request.predicate = [NSPredicate predicateWithFormat:@"spelling = %@",spelling];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"spelling" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        //handle error
    } else if ([matches count] == 0) {
        word = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:context];
        //                [word setValue:string forKey:@"Word"]; //only if you don't use the subclass
        word.spelling = spelling;
        
        // need to set the rest of the data model for each pronunciations in the word and for their phonemes.
        
    } else {
        word = [matches lastObject];
    }
    NSLog(@"Word in dictionary %@", word);
    
    return word;
}

@end
