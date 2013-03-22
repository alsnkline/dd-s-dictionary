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
    
    NSString *bundleName = [GDataXMLNodeHelper singleSubElementForName:@"bundleName" FromGDataXMLElement:dictionaryXML];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Dictionary"];
    request.predicate = [NSPredicate predicateWithFormat:@"bundleName = %@", bundleName];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    BOOL processedNewDictionary = NO; //to protect from processing a new correction twice
    
    if (!matches || ([matches count] > 1)) {
        //handle error
    } else if ([matches count] == 0) {
        dictionary = [NSEntityDescription insertNewObjectForEntityForName:@"Dictionary" inManagedObjectContext:context];
        //                [dictionary setValue:string forKey:@"Dictionary"]; //only if you don't use the subclass
        dictionary.bundleName = bundleName;
        
        [Dictionary processDetailsOfDictionaryXML:dictionaryXML into:dictionary processingType:docType inManagedObjectContext:context];
        NSLog(@"processed details of new dictionary:%@", dictionary.displayName);
        processedNewDictionary = YES;
        
//        NSArray *XMLWords = [dictionaryXML elementsForName:@"word"];
//        NSMutableSet *words = [NSMutableSet set];
//        for (GDataXMLElement *word in XMLWords) {
//            Word *wordForElement = [Word wordFromGDataXMLElement:word inManagedObjectContext:context];
//            [words addObject:wordForElement];
//            
//        };
//
//        dictionary.words = words;
        
    } else {
        dictionary = [matches lastObject];
    }
    
    //reprocessing the dictionary passed in if it is a correction
    if (docType == DOC_TYPE_CORRECTIONS && !processedNewDictionary)
    {
        [Dictionary processDetailsOfDictionaryXML:dictionaryXML into:dictionary processingType:docType inManagedObjectContext:context];
    }
    
    
    NSLog(@"Dictionary named %@", dictionary.displayName);
    
    return dictionary;
}

+ (void) processDetailsOfDictionaryXML:(GDataXMLElement *)dictionaryXML
                            into:(Dictionary *)dictionary
                        processingType:(XMLdocType)docType
          inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSString *displayName = [GDataXMLNodeHelper singleSubElementForName:@"displayName" FromGDataXMLElement:dictionaryXML];
    if (displayName) dictionary.displayName = displayName;
    
    NSArray *XMLWords = [dictionaryXML elementsForName:@"word"];
    NSMutableSet *words = [NSMutableSet set];
    for (GDataXMLElement *word in XMLWords) {
        Word *wordForElement = [Word wordFromGDataXMLElement:word processingType:docType inManagedObjectContext:context];
        [words addObject:wordForElement];
        
    };
    
    dictionary.words = words;
}

@end
