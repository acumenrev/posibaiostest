//
//  MainViewController.h
//  posibaiostest
//
//  Created by Tri Vo on 11/1/14.
//  Copyright (c) 2014 Tri Vo. All rights reserved.
//

#import "BaseViewController.h"
#import "CorePlot-CocoaTouch.h"


#define NUM_TEST 16

@interface MainViewController : BaseViewController <CPTPlotDataSource, CPTAxisDelegate> {
    NSArray *mDataArray;
    IBOutlet UIView *mChartView;
    CPTXYGraph *mGraph;
    NSMutableArray *mSamples;
    double mXXX[NUM_TEST];
    double mYYY[NUM_TEST];
}

@property (nonatomic, retain) CPTXYGraph *mGraph;
@property (nonatomic, retain) NSMutableArray *mSamples;
@property (nonatomic, retain) CPTGraphHostingView *mHostingView;

- (IBAction)switchShowMode:(id)sender;
@end
