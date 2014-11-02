//
//  ModelManager.m
//  posibaiostest
//
//  Created by Tri Vo on 11/2/14.
//  Copyright (c) 2014 Tri Vo. All rights reserved.
//

#import "ModelManager.h"
#import "DonationModel.h"

static ModelManager *_pSharedInstance = nil;

@implementation ModelManager
@synthesize mData;

- (void)dealloc {
    if (mData != nil) {
        [mData release];
        mData = nil;
    }
    
    [super dealloc];
}

+ (ModelManager *)sharedInstance {
    if (_pSharedInstance == nil) {
        _pSharedInstance = [[ModelManager alloc] init];
    }
    return _pSharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        mData = [[NSMutableDictionary alloc] init];
        [self initDonationData];
        
    }
    return self;
}


- (BOOL) initDonationData {
    // Get JSON file path
    NSString *dbPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"posibaiostest.json"];
    NSLog(@"DBPath: %@", dbPath);
    
    NSData *pData = [[NSFileManager defaultManager] contentsAtPath:dbPath];
    NSError *pError = nil;
    NSDictionary *pJSONData = [NSJSONSerialization JSONObjectWithData:pData options:kNilOptions error:&pError];
    if (pError != nil) {
        NSLog(@"Cannot load JSON file");
        return NO;
    } else {
        NSLog(@"Load JSON file success");
        NSDictionary *pJSONDataKey = (NSDictionary *)[pJSONData objectForKey:@"data"];
        NSArray *pYearsArray = (NSArray *)[pJSONDataKey objectForKey:@"years"];
        [mData setObject:pYearsArray forKey:@"years"];
        NSLog(@"Years: %d", [pYearsArray count]);
        for (int i = 0; i < [pYearsArray count]; i++) {
            NSNumber *pYear = (NSNumber *)[pYearsArray objectAtIndex:i];
            NSArray *pMonthArray = (NSArray *)[pJSONDataKey objectForKey:[NSString stringWithFormat:@"%d", [pYear intValue]]];
            NSMutableArray *pMonthDataArray = [[NSMutableArray alloc] init];
            for (int nMonthIndex = 0; nMonthIndex < pMonthArray.count; nMonthIndex++) {
                NSDictionary *pMonthDict = (NSDictionary *)[pMonthArray objectAtIndex:nMonthIndex];
                NSNumber *pMonthValue = (NSNumber *)[pMonthDict objectForKey:@"month"];
                NSNumber *pValue = (NSNumber *)[pMonthDict objectForKey:@"value"];
//                NSLog(@"Month: %d-%d: %d", pYear.intValue, pMonthValue.intValue, pValue.intValue);
                
                DonationModel *pDonationModel = [[DonationModel alloc] initWithValue:pValue.doubleValue fromMonth:pMonthValue.intValue andYear:pYear.intValue];
                [pMonthDataArray addObject:pDonationModel];
                [pDonationModel release];
            }
            [mData setObject:pMonthDataArray forKey:[NSString stringWithFormat:@"%d",pYear.intValue]];
            [pMonthDataArray release];
        }
    }
    return YES;
}

@end
