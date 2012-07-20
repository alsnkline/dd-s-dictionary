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
           inManagedObjectContext:(NSManagedObjectContext *)context 
                               showProgressIn:(UILabel *)label
{
    Dictionary *dictionary = nil;
    //    NSLog(@"GDataXMLElement = %@", wordXML);
    //    NSString *spelling = [GDataXMLNodeHelper spellingFromGDataXMLWordElement:wordXML];
    NSString *displayName = [GDataXMLNodeHelper singleSubElementForName:@"displayName" FromGDataXMLElement:dictionaryXML];
    
    NSString *bundleName = [GDataXMLNodeHelper singleSubElementForName:@"bundleName" FromGDataXMLElement:dictionaryXML];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Dictionary"];
    request.predicate = [NSPredicate predicateWithFormat:@"bundleName = %@", bundleName];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        //handle error
    } else if ([matches count] == 0) {
        dictionary = [NSEntityDescription insertNewObjectForEntityForName:@"Dictionary" inManagedObjectContext:context];
        //                [dictionary setValue:string forKey:@"Dictionary"]; //only if you don't use the subclass
        dictionary.displayName = displayName;
        dictionary.bundleName = bundleName;
        
        NSArray *XMLWords = [dictionaryXML elementsForName:@"word"];
        NSMutableSet *words = [NSMutableSet set];
        for (GDataXMLElement *word in XMLWords) {
            Word *wordForElement = [Word wordFromGDataXMLElement:word inManagedObjectContext:context];
            [words addObject:wordForElement];
            label.text = [NSString stringWithFormat:@"added word '%@'", wordForElement.spelling];
            [label setNeedsDisplay];
        };

        dictionary.words = words;
        
    } else {
        dictionary = [matches lastObject];
    }
    NSLog(@"Dictionary named %@", dictionary.displayName);
    
    return dictionary;
}


@end
