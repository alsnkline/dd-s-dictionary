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
                                processVerbosely:(BOOL)processVerbosely
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
        pronunciation.fileName = fileLocation;
        
        //have to add phonemes and correct phonemeSpelling for this pronunciation
        
    } else {
        pronunciation = [matches lastObject];
    }
    if (processVerbosely) NSLog(@"Pronunciation in dictionary %@", pronunciation);
    return pronunciation;
}

+ (Pronunciation *)pronunciationFromGDataXMLElement:(GDataXMLElement *)pronunciationXML 
                                            forWord:(Word *)word
                                   processVerbosely:(BOOL)processVerbosely
           inManagedObjectContext:(NSManagedObjectContext *)context
{
    
    NSString *unique = [GDataXMLNodeHelper singleSubElementForName:@"unique" FromGDataXMLElement:pronunciationXML processVerbosely:processVerbosely];
    Pronunciation *pronunciation = [self pronunciationFromString:unique forWord:word processVerbosely:processVerbosely inManagedObjectContext:context];
    
    //get fileName if it exsists
    NSString *newFileName = [GDataXMLNodeHelper singleSubElementForName:@"fileName" FromGDataXMLElement:pronunciationXML processVerbosely:processVerbosely];
    
    if (newFileName) {
        
        NSString *oldFileName = pronunciation.fileName;
        //delete old file from sounds directory in app. - not done yet as sounds are still all stored in the main app bundle.
        
        //override pronunciation.fileName with one from element if it exsits.
        pronunciation.fileName = newFileName;
        if (processVerbosely) NSLog(@"Pronunciateion fileName changed from %@ to %@",oldFileName, newFileName);
    }
    
    return pronunciation;
}

+ (Pronunciation *)pronunciationFromString:(NSString *)string 
                                   forWord:(Word *)word
                          processVerbosely:(BOOL)processVerbosely
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
        pronunciation.fileName = unique;
        NSMutableSet *spellings = [NSMutableSet set];
        [spellings addObject:word];
        pronunciation.spellings = spellings;
        
    } else {
        pronunciation = [matches lastObject];
        
    }
    if (processVerbosely) NSLog(@"Pronunciation in dictionary %@", pronunciation);
    
    return pronunciation;
}

+ (void)removeUnusedPronunciationsinManagedObjectContext:(NSManagedObjectContext *)context  //not used yet
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Pronunciation"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"unique" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *pronunciations = [context executeFetchRequest:request error:&error];
    
    for (Pronunciation *pronunciation in pronunciations) {
        if ([pronunciation.spellings count] == 0) {
            NSLog(@"deleting Pronunciation %@", pronunciation);
            [context deleteObject:pronunciation];
        }
    }
}



@end
