//
//  Dictionary+Create.m
//  DyDictionary
//
//  Created by Alison Kline on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Dictionary+Create.h"
#import "GDataXMLNode.h"
#import "GDataXMLNodeHelper.h"
#import "Word+Create.h"

@implementation Dictionary (Create)

+ (Dictionary *)dictionaryFromGDataXMLElement:(GDataXMLElement *)dictionaryXML
                                   XMLdocType:(XMLdocType)docType
           inManagedObjectContext:(NSManagedObjectContext *)context
{
    Dictionary *dictionary = nil;
    //    NSLog(@"GDataXMLElement = %@", wordXML);
    //    NSString *spelling = [GDataXMLNodeHelper spellingFromGDataXMLWordElement:wordXML];
    
    NSMutableSet *words = [NSMutableSet set];       // empty set to put words for the 'dictionary' into
    
    NSString *bundleName = [GDataXMLNodeHelper singleSubElementForName:@"bundleName" FromGDataXMLElement:dictionaryXML];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Dictionary"];
    request.predicate = [NSPredicate predicateWithFormat:@"bundleName = %@", bundleName];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    //setting the displayName and processing or getting the dictionary for dictionary XML files.
    if (docType == DOC_TYPE_DICTIONARY) {
        NSString *displayName = [GDataXMLNodeHelper singleSubElementForName:@"displayName" FromGDataXMLElement:dictionaryXML];
    
        if (!matches || ([matches count] > 1)) {
            //handle error
        } else if ([matches count] == 0) {
            dictionary = [NSEntityDescription insertNewObjectForEntityForName:@"Dictionary" inManagedObjectContext:context];
            //                [dictionary setValue:string forKey:@"Dictionary"]; //only if you don't use the subclass
            dictionary.bundleName = bundleName;
            dictionary.displayName = displayName;
            
    //        [Dictionary processDetailsOfDictionaryXML:dictionaryXML into:dictionary processingType:docType inManagedObjectContext:context];
    //        NSLog(@"processed new dictionary:%@", dictionary.displayName);
            
            NSArray *XMLWords = [dictionaryXML elementsForName:@"word"];
            
            for (GDataXMLElement *word in XMLWords) {
                Word *wordForElement = [Word wordFromGDataXMLElement:word processingType:docType inManagedObjectContext:context];
                [words addObject:wordForElement];
                
            };
            
        } else {
            dictionary = [matches lastObject];
        }
    } else if (docType == DOC_TYPE_CORRECTIONS) {
    
        //reprocessing the dictionary passed in if it is a correction
        if (docType == DOC_TYPE_CORRECTIONS)
        {
            if ([matches count] !=1) NSLog(@"we have a problem corrections but no dictionary");
            
            dictionary = [matches lastObject];
            
            //Processing the document passed in
            NSArray *XMLWords = [dictionaryXML elementsForName:@"word"];
            NSMutableSet *spellings = [NSMutableSet set];
            
            //processing the word passed in if it is a correction
            for (GDataXMLElement *word in XMLWords) {
                Word *wordForElement = [Word wordFromGDataXMLElement:word processingType:docType inManagedObjectContext:context];
                [words addObject:wordForElement];
                [spellings addObject:wordForElement.spelling];
            };
//            [Dictionary processDetailsOfDictionaryXML:dictionaryXML into:dictionary processingType:docType inManagedObjectContext:context];
            
            for (Word *word in dictionary.words) {
                if (![spellings member:word.spelling]) {
                    [words addObject:word];     //setting set to contain all current words not corrected
                }
            }
            
            NSLog(@"processed details of corrections to :%@", dictionary.displayName);
        }
    }
    
    dictionary.words = words;
    
    NSLog(@"Dictionary named %@", dictionary.displayName);
//    NSLog(@"Dictionary verbose %@", dictionary);
    
    return dictionary;
}

+ (void) processDetailsOfDictionaryXML:(GDataXMLElement *)dictionaryXML //not used now
                            into:(Dictionary *)dictionary
                        XMLdocType:(XMLdocType)docType
          inManagedObjectContext:(NSManagedObjectContext *)context
{
    //setting the displayName for dictionary XML files.
    NSString *displayName = nil;
    if (docType == DOC_TYPE_DICTIONARY) {  //if we do this and restrict only DOC_TYPE_DICTIONARIES to haveing display name then you can't correct that either
        displayName = [GDataXMLNodeHelper singleSubElementForName:@"displayName" FromGDataXMLElement:dictionaryXML];
        dictionary.displayName = displayName;
    }
    
    //Processing the document passed in
    NSArray *XMLWords = [dictionaryXML elementsForName:@"word"];
    NSMutableSet *words = [NSMutableSet set];       // this will wipe out exsisting words in the 'dictionary'
    
    if (docType == DOC_TYPE_CORRECTIONS) {
        for (Word *word in dictionary.words) {
            [words addObject:word];     //setting set to contain all current words in the 'dictionary'
        }
    }
    
    for (GDataXMLElement *word in XMLWords) {
        if (docType == DOC_TYPE_CORRECTIONS) {
//            Word *wordInCurrent = [Word wordWithSpellingFromGDataXMLElement:word inManagedObjectContext:context];
//            [Word removeWordWithSpelling:wordInCurrent.spelling fromManagedObjectContext:context];
            [Word removeWordWithSpellingFromGDataXMLElement:word fromManagedObjectContext:context];
        }
        Word *wordForElement = [Word wordFromGDataXMLElement:word processingType:docType inManagedObjectContext:context];
        [words addObject:wordForElement];
        
    };
    
    dictionary.words = words;
}

+ (void)removeEmptyDictionariesInManagedObjectContext:(NSManagedObjectContext *)context     //not used yet!
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Dictionary"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"bundleName" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *dictionaries = [context executeFetchRequest:request error:&error];
    
    for (Dictionary *dictionary in dictionaries) {
        if ([dictionary.words count] == 0) {
            NSLog(@"deleting Dictionary %@", dictionary),
            [context deleteObject:dictionary];
        }
    }
}


@end
