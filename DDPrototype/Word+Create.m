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
                   processingType:(XMLdocType)docType
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Word *word = nil;
//    NSLog(@"GDataXMLElement = %@", wordXML);

    NSString *spelling = [GDataXMLNodeHelper singleSubElementForName:@"spelling" FromGDataXMLElement:wordXML];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    request.predicate = [NSPredicate predicateWithFormat:@"spelling = %@",spelling];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"spelling" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    BOOL processedNewWord = NO; //to protect from processing a new correction twice
    
    if (!matches || ([matches count] > 1)) {
        //handle error
    } else if ([matches count] == 0) {
        word = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:context];
        //                [word setValue:string forKey:@"Word"]; //only if you don't use the subclass
        word.spelling = spelling;
        word.fetchedResultsSection = [[spelling substringWithRange:NSRangeFromString(@"0 1")] uppercaseString];
        
        [Word processDetailsOfWordXML:wordXML into:word inManagedObjectContext:context];
        NSLog(@"processed details of new word:%@",word.spelling);
        processedNewWord = YES;

        
    } else {
        word = [matches lastObject];
    }
    
    //reprocessing the word passed in if it is a correction
    if (docType == DOC_TYPE_CORRECTIONS && !processedNewWord) {
        [Word processDetailsOfWordXML:wordXML into:word inManagedObjectContext:context];
        NSLog(@"processed details of corrected word:%@",word.spelling);
    }
    
    NSLog(@"Word in dictionary %@", word);
    
    return word;
}

+ (void) processDetailsOfWordXML:(GDataXMLElement *)wordXML
                            into:(Word *)word
          inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSString *isHomophone = [GDataXMLNodeHelper singleSubElementForName:@"isHomophone" FromGDataXMLElement:wordXML];
    word.isHomophone = [isHomophone isEqualToString:@"yes"]? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    
    // set all pronunciations in the word.
    NSArray *XMLPronunciations = [wordXML elementsForName:@"pronunciation"];
    int pronunciationCount = [XMLPronunciations count];
    if (pronunciationCount>1) {
        NSLog(@"more than 1 pronunciation in XML");
    }
    
    //        pronunciationCount < 1? pronunciationCount = 1 : pronunciationCount;
    
    NSMutableSet *pronunciations = [NSMutableSet set];
    for (GDataXMLElement *pronunciation in XMLPronunciations) {
        Pronunciation *pronunciationForElement = [Pronunciation pronunciationFromGDataXMLElement:pronunciation forWord:word inManagedObjectContext:context];
        [pronunciations addObject:pronunciationForElement];
    };
    if ([XMLPronunciations count] == 0) {
        //create pronunciation with unique = spelling
        Pronunciation *pronunciationForElement = [Pronunciation pronunciationFromString:word.spelling forWord:word inManagedObjectContext:context];
        [pronunciations addObject:pronunciationForElement];
    }
    word.pronunciations = pronunciations;
}


@end
