//
//  ModelManager.h
//  posibaiostest
//
//  Created by Tri Vo on 11/2/14.
//  Copyright (c) 2014 Tri Vo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ModelManager : NSObject {
}

@property (nonatomic, retain) NSMutableDictionary *mData;

+ (ModelManager *) sharedInstance;

@end
