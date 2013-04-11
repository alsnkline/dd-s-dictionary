//
//  ErrorsHelper.h
//  DDPrototype
//
//  Created by Alison KLINE on 2/10/13.
//
//

#import <Foundation/Foundation.h>

@interface ErrorsHelper : NSObject

+ (void) showExplanationForFrozenUI;
+ (void) showErrorTooManyDictionaries;
+ (void) showErrorMuteOn; //not used
+ (void) showXMLParsingError:(NSError *)error;

@end
