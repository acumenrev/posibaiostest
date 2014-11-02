//
//  MainViewController.m
//  posibaiostest
//
//  Created by Tri Vo on 11/1/14.
//  Copyright (c) 2014 Tri Vo. All rights reserved.
//

#import "MainViewController.h"
#import "ModelManager.h"
#import "DonationModel.h"

@interface MainViewController ()

@end



@implementation MainViewController
@synthesize mGraph;
@synthesize mSamples;
@synthesize mHostingView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // Get Years exist in json file
    NSArray *pYearsArray = (NSArray *)[[[ModelManager sharedInstance] mData] objectForKey:@"years"];
    for (NSNumber *pYearValue in pYearsArray) {
        // Get Monthly Data for each year
        NSArray *pMonthArray = (NSArray *)[[[ModelManager sharedInstance] mData] objectForKey:[NSString stringWithFormat:@"%d", pYearValue.intValue]];
        // Calculate average sum of value
        double dTotalValue = 0;
        for (DonationModel *pDonationData in pMonthArray) {
            dTotalValue += pDonationData.mValue;
        }
        dTotalValue /= pMonthArray.count;
        // Create a new DonationModel to store average sum value for each year
        DonationModel *pDonationModel = [[DonationModel alloc] initWithValue:dTotalValue fromMonth:0 andYear:pYearValue.intValue];
        if (pDonationModel != nil) {
            if (mYearDataArray == nil) {
                mYearDataArray = [[NSMutableArray alloc] init];
            }
            
            [mYearDataArray addObject:pDonationModel];
        }
    }
    
    // Choose what will show to user first when display this view controller
    mShowType = ShowType_Month;
    if (mShowType == ShowType_Month) {
        NSArray *pYears = (NSArray *)[[[ModelManager sharedInstance] mData] objectForKey:@"years"];
        if (pYears.count > 0) {
            NSNumber *pNumber = (NSNumber *)[pYears objectAtIndex:0];
            mDataArray = (NSArray *)[[[ModelManager sharedInstance] mData] objectForKey:[NSString stringWithFormat:@"%d", pNumber.intValue]];
            nSelectedDonationIndex = 0;
            [mYearLabel setText:[NSString stringWithFormat:@"%d", pNumber.intValue]];
            [btnPrev setEnabled:NO];
        }
        
    }
    
    // Config Graph
    [self configHost];
    [self configGraph];
    [self configAxes];
    [self configPlots];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [mChartView release];
    [self.mHostingView release];
    [mYearLabel release];
    [btnPrev release];
    [btnNext release];
    [super dealloc];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Other Methods

/**
 *  Get month string based on given-number
 *
 *  @param nValue Month number in integer value
 *
 *  @return Month string represent for given-number
 */
- (NSString *) getMonthStringBasedOnIntValue:(int)nValue {
    NSString * dateString = [NSString stringWithFormat: @"%d", nValue];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM"];
    NSDate* myDate = [dateFormatter dateFromString:dateString];
    [dateFormatter release];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM"];
    NSString *stringFromDate = [formatter stringFromDate:myDate];
    [formatter release];
    return stringFromDate;
    
}

#pragma mark - Core Plot Configs

/**
 *  Configure Hosting View
 */
- (void) configHost {
    // Craete hosting view
    self.mHostingView = [[CPTGraphHostingView alloc] initWithFrame:mChartView.bounds];
    [mChartView addSubview:self.mHostingView];
    self.mHostingView.allowPinchScaling = YES;
}

/**
 *  Configure Graph
 */
- (void) configGraph {
    // Create Graph
    CPTGraph *pGraph = [[CPTXYGraph alloc] initWithFrame:self.view.bounds];
    [pGraph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    [self.mHostingView setHostedGraph:pGraph];
    
    // Create and set text style for the graph
    CPTMutableTextStyle *pTitleStyle = [CPTMutableTextStyle textStyle];
    [pTitleStyle setColor:[CPTColor blackColor]];
    [pTitleStyle setFontName:@"Futura"];
    [pTitleStyle setFontSize:16.0f];
    [pGraph setTitleTextStyle:pTitleStyle];
    [pGraph setTitleDisplacement:CGPointMake(0.0f, 10.0f)];
    [pGraph setTitlePlotAreaFrameAnchor:CPTRectAnchorTop];
    
    // Set padding for plot area
    [pGraph.plotAreaFrame setPaddingLeft:50.0f];
    [pGraph.plotAreaFrame setPaddingRight:30.0f];
    [pGraph.plotAreaFrame setPaddingBottom:40.0f];
    self.mHostingView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    // Enable user interaction for plot space
    CPTXYPlotSpace *pPlotSpace = (CPTXYPlotSpace *)pGraph.defaultPlotSpace;
    [pPlotSpace setAllowsUserInteraction:YES];
}

/**
 *  Configure Plots On Graph
 */
- (void) configPlots {
    
    // Get graph and plot space
    CPTGraph *pGraph = self.mHostingView.hostedGraph;
    CPTXYPlotSpace *pPlotSpace = (CPTXYPlotSpace *)pGraph.defaultPlotSpace;
    
    // Create the plot
    CPTScatterPlot *pMonthPlot = [[CPTScatterPlot alloc] init];
    [pMonthPlot setDataSource:self];
    [pGraph addPlot:pMonthPlot toPlotSpace:pPlotSpace];
    [pGraph setIdentifier:@"MonthPlot"];
    
    CPTColor *pMonthColor = [CPTColor blueColor];
    
    CPTMutableLineStyle *pMonthDataLineStyle = [pMonthPlot.dataLineStyle mutableCopy];
    pMonthDataLineStyle.lineWidth = 2.5;
    pMonthDataLineStyle.lineColor = pMonthColor;
    pMonthPlot.dataLineStyle = pMonthDataLineStyle;
    
    // Set Global Range for Plot
    double xRange = 0;
    double yRange = 105;
    if (mShowType == ShowType_Month) {
        xRange = 13;
    } else {
        NSArray *pYearsArray = [[[ModelManager sharedInstance] mData] objectForKey:@"years"];
        xRange = pYearsArray.count + 1;
    }
    
    CPTPlotRange *pGlobalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0) length:CPTDecimalFromDouble(yRange)];
    pPlotSpace.globalYRange = pGlobalYRange;
    
    CPTPlotRange *pGlobalXRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0) length:CPTDecimalFromDouble(xRange)];
    pPlotSpace.globalXRange = pGlobalXRange;
}
/**
 *  Configure Axes on Graph
 */
- (void) configAxes {
    CPTGraph *pGraph = (CPTGraph *)self.mHostingView.hostedGraph;
    
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor redColor];
    axisTitleStyle.fontName = @"Futura";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor grayColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor blackColor];
    axisTextStyle.fontName = @"Futura";
    axisTextStyle.fontSize = 12.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor redColor];
    tickLineStyle.lineWidth = 2.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor grayColor];
    tickLineStyle.lineWidth = 1.0f;
    
    // Get Axis Set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)pGraph.axisSet;
    
    // Config X-Axis
    CPTAxis *xAxis = axisSet.xAxis;
    if (mShowType == ShowType_Month) {
        xAxis.title = @"Months";
    } else {
        xAxis.title = @"Years";
    }
    
    xAxis.titleOffset = 20;
    xAxis.labelOffset = 50;
    xAxis.titleTextStyle = axisTextStyle;
    xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    xAxis.labelTextStyle = axisTextStyle;
    xAxis.majorTickLineStyle = axisLineStyle;
    xAxis.majorTickLength = 1.0f;
    xAxis.majorGridLineStyle = gridLineStyle;
    xAxis.tickDirection = CPTSignNegative;
    
    // Customized label on axis
    NSMutableSet *xLabels = [NSMutableSet set];
    NSMutableSet *xLocations = [NSMutableSet set];
    if (mShowType == ShowType_Month) {
        // Month
        for (int i = 1; i <= 12; i ++) {
            NSString *pMonthString = [self getMonthStringBasedOnIntValue:i];
            CPTAxisLabel *pLabel = [[CPTAxisLabel alloc] initWithText:pMonthString textStyle:xAxis.labelTextStyle];
            CGFloat location = i - 1;
            pLabel.tickLocation = CPTDecimalFromCGFloat(location);
            pLabel.offset = xAxis.majorTickLength;
            if (pLabel != nil) {
                [xLabels addObject:pLabel];
                [xLocations addObject:[NSNumber numberWithFloat:location]];
            }
        }
    } else {
        // Year
        for (int i = 0; i < mYearDataArray.count; i++) {
            DonationModel *pDonationModel = (DonationModel *)[mYearDataArray objectAtIndex:i];
            NSString *pYearString = [NSString stringWithFormat:@"%d", pDonationModel.mYear];
            CPTAxisLabel *pLabel = [[CPTAxisLabel alloc] initWithText:pYearString textStyle:xAxis.labelTextStyle];
            CGFloat location = i;
            pLabel.tickLocation = CPTDecimalFromCGFloat(location);
            pLabel.offset = xAxis.majorTickLength;
            if (pLabel != nil) {
                [xLabels addObject:pLabel];
                [xLocations addObject:[NSNumber numberWithFloat:location]];
            }
            [pLabel release];
        }
    }
    // Assign axis labels
    xAxis.axisLabels = xLabels;
    xAxis.majorTickLocations = xLocations;
    
    // Config Y-Axis
    CPTAxis *yAxis = axisSet.yAxis;
    yAxis.title = @"USD";
    yAxis.titleOffset = -45;
    yAxis.labelOffset = 16;
    yAxis.axisLineStyle = axisLineStyle;
    yAxis.titleTextStyle = axisTextStyle;
    yAxis.majorGridLineStyle = gridLineStyle;
    yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    yAxis.labelTextStyle = axisTextStyle;
    yAxis.majorTickLineStyle = axisLineStyle;
    yAxis.majorTickLength = 1.0f;
    yAxis.majorGridLineStyle = gridLineStyle;
    yAxis.tickDirection = CPTSignPositive;
    yAxis.minorTicksPerInterval = 4;
    NSInteger majorIncrement = 5000;
    NSInteger minorIncrement = 1000;
    CGFloat yMax = 100000.0f;  // should determine dynamically based on max price
    
    // Customize axis label
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    
    NSInteger xIndex = 0;
    for (NSInteger i = 0; i <= yMax; i+= minorIncrement) {
        NSUInteger mod = i % majorIncrement;
        if (mod == 0) {
            NSString *pContent;
            if (xIndex == 0) {
                pContent = @"0";
            } else {
                pContent = [NSString stringWithFormat:@"%dK",xIndex];
            }
            CPTAxisLabel *pLabel = [[CPTAxisLabel alloc] initWithText:pContent textStyle:xAxis.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(xIndex);
            pLabel.tickLocation = location;
            pLabel.offset = - 30;
            if (pLabel != nil) {
                [yLabels addObject:pLabel];
            }
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
            [pLabel release];
        } else {
            [yMinorLocations addObject:[NSDecimalNumber numberWithInt:xIndex]];
        }
        xIndex++;
    }
    yAxis.axisLabels = yLabels;
    yAxis.majorTickLocations = yMajorLocations;
    yAxis.minorTickLocations = yMinorLocations;
}

#pragma mark - CPTPlot Data Source Methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    int nCount = 0;
    if (mShowType == ShowType_Month) {
        // Months
        nCount = mDataArray.count;
    } else {
        // Years
        nCount = mYearDataArray.count;
    }
    return nCount;
}

- (id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    DonationModel *pDonationModel;
    if (mShowType == ShowType_Month) {
        pDonationModel = (DonationModel *)[mDataArray objectAtIndex:index];
    } else {
        pDonationModel = (DonationModel *)[mYearDataArray objectAtIndex:index];
    }
    switch (fieldEnum) {
        case CPTScatterPlotFieldX: {
            // Month
            if (mShowType == ShowType_Month) {
                return [NSNumber numberWithUnsignedInteger:pDonationModel.mMonth - 1];
            } else {
                return [NSNumber numberWithUnsignedInteger:index];
            }
            
            break;
        }
        case CPTScatterPlotFieldY: {
            // Value
            if (mShowType == ShowType_Month) {
                int nYPlot = pDonationModel.mValue/1000;
                return [NSNumber numberWithUnsignedInteger:nYPlot];
            } else {
                int nYPlot = pDonationModel.mValue/1000;
                return [NSNumber numberWithUnsignedInteger:nYPlot];
            }
            
            break;
        }
        default:
            break;
    }
    return [NSDecimalNumber zero];
}

#pragma mark - Axis Delegate

- (IBAction)btnNext_Clicked:(id)sender {
    if (nSelectedDonationIndex < mYearDataArray.count - 1) {
        nSelectedDonationIndex++;
    }
    
    if (nSelectedDonationIndex == mYearDataArray.count - 1) {
        [btnNext setEnabled:false];
    } else if (nSelectedDonationIndex < mYearDataArray.count - 1) {
        [btnNext setEnabled:true];
    }
    [btnPrev setEnabled:true];
    DonationModel *pModel = (DonationModel *)[mYearDataArray objectAtIndex:nSelectedDonationIndex];
    [mYearLabel setText:[NSString stringWithFormat:@"%d", pModel.mYear]];
    NSArray *pYears = (NSArray *)[[[ModelManager sharedInstance] mData] objectForKey:@"years"];
    if (pYears.count > 0) {
        NSNumber *pNumber = (NSNumber *)[pYears objectAtIndex:nSelectedDonationIndex];
        mDataArray = (NSArray *)[[[ModelManager sharedInstance] mData] objectForKey:[NSString stringWithFormat:@"%d", pNumber.intValue]];
    }
    [self performSelectorOnMainThread:@selector(forceReloadData) withObject:nil waitUntilDone:NO];
}

- (IBAction)btnPrev_Clicked:(id)sender {
    if (nSelectedDonationIndex >= 1) {
        nSelectedDonationIndex--;
    }
    
    if (nSelectedDonationIndex == 0) {
        [btnPrev setEnabled:false];
    } else if (nSelectedDonationIndex >= 1) {
        [btnPrev setEnabled:true];
    }
    [btnNext setEnabled:true];
    
    DonationModel *pModel = (DonationModel *)[mYearDataArray objectAtIndex:nSelectedDonationIndex];
    [mYearLabel setText:[NSString stringWithFormat:@"%d", pModel.mYear]];
    NSArray *pYears = (NSArray *)[[[ModelManager sharedInstance] mData] objectForKey:@"years"];
    if (pYears.count > 0) {
        NSNumber *pNumber = (NSNumber *)[pYears objectAtIndex:nSelectedDonationIndex];
        mDataArray = (NSArray *)[[[ModelManager sharedInstance] mData] objectForKey:[NSString stringWithFormat:@"%d", pNumber.intValue]];
    }
    [self performSelectorOnMainThread:@selector(forceReloadData) withObject:nil waitUntilDone:NO];
    
}

- (IBAction)switchShowMode:(id)sender {
    UISegmentedControl *pSegmentControl = (UISegmentedControl *)sender;
    if (pSegmentControl.selectedSegmentIndex == 0) {
        mShowType = ShowType_Month;
        // Show Buttons
        [btnPrev setHidden:NO];
        [btnNext setHidden:NO];
        [mYearLabel setHidden:NO];
        [self performSelectorOnMainThread:@selector(forceReloadData) withObject:nil waitUntilDone:NO];
    } else {
        mShowType = ShowType_Year;
        
        // Hide buttons
        [btnPrev setHidden:YES];
        [btnNext setHidden:YES];
        [mYearLabel setHidden:YES];
        
        [self performSelectorOnMainThread:@selector(forceReloadData) withObject:nil waitUntilDone:NO];
    }
}

/**
 *  Reload data on chart
 */
- (void) forceReloadData {
    
    // Reload Axis
    [self configAxes];
    // Reload Data
    [self.mHostingView.hostedGraph reloadData];
}


@end
