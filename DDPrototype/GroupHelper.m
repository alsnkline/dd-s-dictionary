//
//  GroupHelper.m
//  DDPrototype
//
//  Created by Alison KLINE on 5/16/13.
//
//

#import "GroupHelper.h"

@implementation GroupHelper

+ (NSURL *)groupJSONFileDirectory
{
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSURL *bundleUrl = [[NSBundle mainBundle] bundleURL];
    NSURL *dirUrl = [NSURL URLWithString:@"resources.bundle/json/" relativeToURL:bundleUrl];
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"resources.bundle/json/FunWordGroupsv01" ofType:@"json"];
    NSLog(@"Group Json file directory: %@", dirUrl);

    
    BOOL isDir = YES;
    [localFileManager fileExistsAtPath:[dirUrl path] isDirectory:&isDir];
    
    if (!isDir ) {
        NSLog(@"no JSON directory in resource files");
    }
    return dirUrl;
}

+ (NSString *)latestGroupsJSONfileVersionNumber
{
    NSError *error = nil;
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSURL *directoryURL = [GroupHelper groupJSONFileDirectory];
    NSArray *currentDirectoryContents = [localFileManager contentsOfDirectoryAtURL:directoryURL includingPropertiesForKeys:nil options: NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    //    NSLog(@"currentCache = %@",currentCache);
    
    if (error) {
        NSLog(@"error getting contentsOfDirectoryAtPath = %@",error);
        return 0;
    }
    NSInteger currentFileVersion = 0;
    NSString *rtnValue;
    for (NSURL *fileURL in currentDirectoryContents) {
        NSString *fileName = [fileURL lastPathComponent];
        NSRange rangeOfVersionNumber = NSMakeRange([fileName length]-7, 2);
        NSString *versionOfFile = [fileName substringWithRange:rangeOfVersionNumber];
        NSLog(@"Version # of file : %@", versionOfFile);
        if (currentFileVersion < [versionOfFile integerValue]) {
            currentFileVersion = [versionOfFile integerValue];
            rtnValue = versionOfFile;
        }
    }
    return rtnValue;
}

+ (NSArray *)contentsOfLatestJSONGroupsFile
{
    NSLog(@"Processing the Group JSON file");
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"resources.bundle/json/FunWordGroupsv01" ofType:@"json"];
//    NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:path];
    
    NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"FunWordGroupsv%@.json", [GroupHelper latestGroupsJSONfileVersionNumber]] relativeToURL:[GroupHelper groupJSONFileDirectory]];
    NSLog(@"fileURL = %@", fileURL);
    NSError *error;
    
    if (![[[NSFileManager alloc] init] fileExistsAtPath:[fileURL path]])
    {
        NSLog(@"No file found: %@", fileURL);
        return nil;
        
    } else {
    
        NSData *fileData = [NSData dataWithContentsOfURL:fileURL options:NSDataReadingUncached error:&error];
        
        //print out the data contents
        if (PROCESS_VERBOSELY) {
            NSString *jsonSummarytext = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
            NSLog(@"NSData fileData %@", jsonSummarytext);
        }
        
        NSError *error2;
        NSArray *json = [NSJSONSerialization JSONObjectWithData:fileData options:kNilOptions error:&error2];
        if (error2) {
            NSLog(@"error = %@", error2);
        }
        if (PROCESS_VERBOSELY) NSLog(@"groups from file json = %@",json);
        
        return json;
    }
}


// test code for creating JSON programatically
+ (void)createAJSONFile
{
    NSArray *groups = [GroupHelper createTestGroupsJson];
    [GroupHelper testJSON:groups];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:groups options:kNilOptions error:&error];


    //print out the data contents
    NSString *jsonSummarytext = [[NSString alloc] initWithData:jsonData
                                             encoding:NSUTF8StringEncoding];
    NSLog(@"my programatically created Json %@", jsonSummarytext);
}

+ (void)testJSON:(id)object         //create some valid json! Also use http://jsonlint.com/ to validate :-)
{
    BOOL isTurnableToJSON = [NSJSONSerialization isValidJSONObject:object];
    NSLog(@"isTurnableToJSON = %@", isTurnableToJSON? @"YES" : @"NO");
}


+ (NSArray *)createTestGroupsJson
{
    NSArray *ightWords = @[@"bright",@"fight",@"fright",@"frighten"];
    NSDictionary *ightGroup = @{
                                @"words": ightWords,
                                @"display_name": @"'ight'"};
    NSArray *awWords = @[@"paw",@"saw",@"draw",@"yawn"];
    NSDictionary *awGroup = @{
                              @"words": awWords,
                              @"display_name": @"'aw'"};
    NSArray *groups = @[ightGroup,awGroup];
    
    return groups;
}


@end
