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
typedef enum {
    ShowType_Month = 1,
    ShowType_Year = 2
} ShowType;

@interface MainViewController : BaseViewController <CPTPlotDataSource, CPTAxisDelegate> {
    ShowType mShowType;
    int nSelectedDonationIndex;
    NSArray *mDataArray;
    NSMutableArray *mYearDataArray;
    CPTXYGraph *mGraph;
    NSMutableArray *mSamples;
    
    IBOutlet UIView *mChartView;
    IBOutlet UILabel *mYearLabel;
    IBOutlet UIButton *btnPrev;
    IBOutlet UIButton *btnNext;
}

@property (nonatomic, retain) CPTXYGraph *mGraph;
@property (nonatomic, retain) NSMutableArray *mSamples;
@property (nonatomic, retain) CPTGraphHostingView *mHostingView;

/**
 *  Handle Touch Event of Btn Prev
 *
 *  @param sender Btn Prev
 */
- (IBAction)btnPrev_Clicked:(id)sender;
/**
 *  Handle Touch Event of Btn Next
 *
 *  @param sender Btn Next
 */
- (IBAction)btnNext_Clicked:(id)sender;

/**
 *  Switch Chart View Mode to Month or Year
 *
 *  @param sender
 */
- (IBAction)switchShowMode:(id)sender;
@end
