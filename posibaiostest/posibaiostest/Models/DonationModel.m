//
//  DonationModel.m
//  posibaiostest
//
//  Created by Tri Vo on 11/2/14.
//  Copyright (c) 2014 Tri Vo. All rights reserved.
//

#import "DonationModel.h"

@implementation DonationModel

@synthesize mMonth;
@synthesize mValue;
@synthesize mYear;

- (id)initWithValue:(double)value fromMonth:(int)nMonth andYear:(int)nYear {
    if (self = [super init]) {
        self.mMonth = nMonth;
        self.mValue = value;
        self.mYear = nYear;
    }
    return self;
}

@end
