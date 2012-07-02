//
//  Pronunciation+Create.m
//  DDPrototype
//
//  Created by Alison Kline on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Pronunciation+Create.h"
#import "GDataXMLNode.h"
#import "GDataXMLNodeHelper.h"

@implementation Pronunciation (Create)

+ (Pronunciation *)pronunciationWithFileLocation:(NSString *)fileLocation   //never used!
                              andUnique:(NSString *)unique 
                 inManagedObjectContext:(NSManagedObjectContext *)context
{
    Pronunciation *pronunciation = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Pronunciation"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"unique" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        //handle error
    } else if ([matches count] == 0) {
        pronunciation = [NSEntityDescription insertNewObjectForEntityForName:@"Pronunciation" inManagedObjectContext:context];
        //                [pronunciation setValue:string forKey:@"Pronunciation"]; //only if you don't use the subclass
        pronunciation.unique = unique;
        pronunciation.fileLocation = fileLocation;
        
        //have to add phonemes and correct phonemeSpelling for this pronunciation
        
    } else {
        pronunciation = [matches lastObject];
    }
    NSLog(@"Pronunciation in dictionary %@", pronunciation);
    return pronunciation;
}

+ (Pronunciation *)pronunciationFromGDataXMLElement:(GDataXMLElement *)pronunciationXML 
           inManagedObjectContext:(NSManagedObjectContext *)context
{
    
    NSString *unique = [GDataXMLNodeHelper singleSubElementForName:@"unique" FromGDataXMLElement:pronunciationXML];
    
    return [self pronunciationFromString:unique inManagedObjectContext:context];
}

+ (Pronunciation *)pronunciationFromString:(NSString *)string
                    inManagedObjectContext:(NSManagedObjectContext *)context
{
    Pronunciation *pronunciation = nil;
    NSString *unique = string;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Pronunciation"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"unique" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        //handle error
    } else if ([matches count] == 0) {
        pronunciation = [NSEntityDescription insertNewObjectForEntityForName:@"Pronunciation" inManagedObjectContext:context];
        //                [pronunciation setValue:string forKey:@"Pronunciation"]; //only if you don't use the subclass
        pronunciation.unique = unique;
        
        //have to add phonemes and correct phonemeSpelling for this pronunciation
        
    } else {
        pronunciation = [matches lastObject];
    }
    NSLog(@"Pronunciation in dictionary %@", pronunciation);
    
    return pronunciation;
}



@end
