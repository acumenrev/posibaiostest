//
//  DonationModel.h
//  posibaiostest
//
//  Created by Tri Vo on 11/2/14.
//  Copyright (c) 2014 Tri Vo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DonationModel : NSObject

@property int mYear;
@property int mMonth;
@property double mValue;

- (id) initWithValue:(double)value fromMonth:(int)nMonth andYear:(int)nYear;


@end
