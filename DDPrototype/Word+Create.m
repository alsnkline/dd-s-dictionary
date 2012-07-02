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
#import "Pronunciation+Create.h"

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
//    NSString *spelling = [GDataXMLNodeHelper spellingFromGDataXMLWordElement:wordXML];
    NSString *spelling = [GDataXMLNodeHelper singleSubElementForName:@"spelling" FromGDataXMLElement:wordXML];
    
    NSString *isHomophone = [GDataXMLNodeHelper singleSubElementForName:@"isHomophone" FromGDataXMLElement:wordXML];
    
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
        word.fetchedResultsSection = [[spelling substringWithRange:NSRangeFromString(@"0 1")] uppercaseString];
        word.isHomophone = [isHomophone isEqualToString:@"YES"]? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
        
        // set all pronunciations in the word.
        NSArray *XMLPronunciations = [wordXML elementsForName:@"pronunciations"];
        int pronunciationCount = [XMLPronunciations count];
        
        pronunciationCount < 1? pronunciationCount = 1 : pronunciationCount;
        
        NSMutableSet *pronunciations = [NSMutableSet setWithCapacity:pronunciationCount];
        for (GDataXMLElement *pronunciation in XMLPronunciations) {
            Pronunciation *pronunciationForElement = [Pronunciation pronunciationFromGDataXMLElement:pronunciation forWord:word inManagedObjectContext:context];
            [pronunciations addObject:pronunciationForElement];
        };
        if ([XMLPronunciations count] == 0) {
            //create pronunciation with unique = spelling
            Pronunciation *pronunciationForElement = [Pronunciation pronunciationFromString:spelling forWord:word inManagedObjectContext:context];
            [pronunciations addObject:pronunciationForElement];
        }
        word.pronunciations = pronunciations;
        
    } else {
        word = [matches lastObject];
    }
    NSLog(@"Word in dictionary %@", word);
    
    return word;
}

@end
