//
//  MainViewController.m
//  posibaiostest
//
//  Created by Tri Vo on 11/1/14.
//  Copyright (c) 2014 Tri Vo. All rights reserved.
//

#import "MainViewController.h"

#define START_POINT 0
#define END_POINT 15.0

#define X_VAL @"X_VAL"
#define Y_VAL @"Y_VAL"

@interface MainViewController ()

@end



@implementation MainViewController
@synthesize mGraph;
@synthesize mSamples;
@synthesize mHostingView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self generateDataSamples];
    [self configGraph];
    [self configPlots];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [mMainScrollView release];
    [super dealloc];
}

#pragma mark - Other Methods

- (void) generateDataSamples {
    double dLength = (END_POINT - START_POINT);
    double dDelta = dLength/(NUM_TEST - 1);
    
    mSamples = [[NSMutableArray alloc] initWithCapacity:NUM_TEST];
    
    for (int i = 0; i < NUM_TEST; i++) {
        double dX = START_POINT + (dDelta*i);
        
        // x^2
        double dY = dX * dX;
        NSDictionary *pSample = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithDouble:dX], X_VAL,
                                 [NSNumber numberWithDouble:dY], Y_VAL,nil];
        [mSamples addObject:pSample];
    }
}

#pragma mark - Core Plot Configs

- (void) configGraph {
    // Create the graph
    double xAxisStart = START_POINT;
    double xAxisLength = END_POINT - START_POINT;
    
    double maxY = 900;
    double yAxisStart = 0;
    double yAxisLength = 2*maxY;

    // Craete hosting view
    self.mHostingView = [[CPTGraphHostingView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.mHostingView];
    
    // Create Graph
    CPTGraph *pGraph = [[CPTXYGraph alloc] initWithFrame:self.view.bounds xScaleType:CPTScaleTypeLinear yScaleType:CPTScaleTypeLinear];
    [pGraph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    [self.mHostingView setHostedGraph:pGraph];
    
    // Set Graph Title
    NSString *pTitle = @"Longer";
    [pGraph setTitle:pTitle];
    
    // Create and set text style for the graph
    CPTMutableTextStyle *pTitleStyle = [CPTMutableTextStyle textStyle];
    [pTitleStyle setColor:[CPTColor blackColor]];
    [pTitleStyle setFontName:@"Futura"];
    [pTitleStyle setFontSize:16.0f];
    [pGraph setTitleTextStyle:pTitleStyle];
    [pGraph setTitleDisplacement:CGPointMake(0.0f, 10.0f)];
    [pGraph setTitlePlotAreaFrameAnchor:CPTRectAnchorTop];
    
    // Set padding for plot area
    [pGraph.plotAreaFrame setPaddingLeft:30.0f];
    [pGraph.plotAreaFrame setPaddingRight:30.0f];
    
    // Enable user interaction for plot space
    CPTXYPlotSpace *pPlotSpace = (CPTXYPlotSpace *)pGraph.defaultPlotSpace;
    [pPlotSpace setAllowsUserInteraction:YES];
    
    
    // Config Graph
    CPTXYAxisSet *pAxisSet = (CPTXYAxisSet *)[pGraph axisSet];
    
    // xAxis Config
    CPTXYAxis *pXAxis = [pAxisSet xAxis];
    [pXAxis setLabelingPolicy:CPTAxisLabelingPolicyFixedInterval];
    
    NSString *pDateComponetns = @"MMMYY";
    NSString *pLocalDateFormat = [NSDateFormatter dateFormatFromTemplate:pDateComponetns options:0 locale:[NSLocale currentLocale]];
    NSDateFormatter *pLabelDateFormatter = [[NSDateFormatter alloc] init];
    pLabelDateFormatter.dateFormat = pLocalDateFormat;
    
    // Set xAxis Date Formatter
    CPTCalendarFormatter *pXDateYearFormatter = [[CPTCalendarFormatter alloc] initWithDateFormatter:pLabelDateFormatter];
    
    //Keep in mind this reference date, it will be used to calculate NSNumber in dataSource method
    pXDateYearFormatter.referenceDate = [NSDate dateWithTimeIntervalSince1970:0];
    pXDateYearFormatter.referenceCalendarUnit = NSMonthCalendarUnit;
    [pXAxis setLabelFormatter:pXDateYearFormatter];
    
    NSNumberFormatter *axisFormatter = [[NSNumberFormatter alloc] init];
    [axisFormatter setMinimumIntegerDigits:1];
    [axisFormatter setMaximumFractionDigits:0];
    
    // yAxis Config
    CPTXYAxis *pYAxis = [pAxisSet yAxis];
    [pYAxis setMajorIntervalLength:CPTDecimalFromInt(10)];
    [pYAxis setMinorTickLineStyle:nil];
    [pYAxis setLabelingPolicy:CPTAxisLabelingPolicyFixedInterval];
    [pYAxis setLabelTextStyle:pTitleStyle];
    [pYAxis setLabelFormatter:axisFormatter];
    
    
    
    
    
    /*
     [yAxis setMajorIntervalLength:CPTDecimalFromInt(1)];
     [yAxis setMinorTickLineStyle:nil];
     [yAxis setLabelingPolicy:CPTAxisLabelingPolicyFixedInterval];
     [yAxis setLabelTextStyle:textStyle];
     [yAxis setLabelFormatter:axisFormatter];
     */
    
    /*
    [pYAxis setMajorIntervalLength:CPTDecimalFromFloat(10)];
    [pYAxis setLabelingPolicy:CPTAxisLabelingPolicyFixedInterval];
    
    pYAxis.labelTextStyle = pTitleStyle;
    pYAxis.majorTickLength = 0.0f;
    pYAxis.tickDirection = CPTSignNegative;
    
    NSInteger majorIncrement = 10;
    CGFloat yMax = 20;
    NSMutableSet *pYLabels = [NSMutableSet set];
    NSMutableSet *pYMajorLocations = [NSMutableSet set];
    
    int nMaxLocation = 0;
    
    for (NSInteger j = 0; j <= yMax + majorIncrement; j+= majorIncrement) {
        CPTAxisLabel *pLabel = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i",j] textStyle:pYAxis.labelTextStyle];
        NSDecimal location = CPTDecimalFromInt(j);
        pLabel.tickLocation = location;
        pLabel.offset = 125;
        if (pLabel != nil) {
            [pYLabels addObject:pLabel];
        }
        
        [pYMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        if (nMaxLocation < [[NSDecimalNumber decimalNumberWithDecimal:location] intValue]) {
            nMaxLocation = [[NSDecimalNumber decimalNumberWithDecimal:location] intValue];
        }
    }
    
    pYAxis.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(0) length:CPTDecimalFromInteger(nMaxLocation)];
    pYAxis.axisLabels = pYLabels;
    pYAxis.majorTickLocations = pYMajorLocations;
     */
}

- (void) configPlots {
    // Get graph and plot space
    CPTGraph *pGraph = self.mHostingView.hostedGraph;
    CPTXYPlotSpace *pPlotSpace = (CPTXYPlotSpace *)pGraph.defaultPlotSpace;
    pPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromDouble(15.0f)];
    pPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromDouble(15.0f)];
    // Create the three plots
    CPTScatterPlot *pMonthPlot = [[CPTScatterPlot alloc] init];
    [pMonthPlot setDataSource:self];
    
    CPTColor *pMonthColor = [CPTColor redColor];
    [pGraph addPlot:pMonthPlot toPlotSpace:pPlotSpace];
    [pGraph setIdentifier:@"MonthPlot"];
    
}

#pragma mark - CPTPlot Data Source Methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return 15;
}

- (id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx {
    NSDictionary *pSample = [mSamples objectAtIndex:idx];
    if (fieldEnum == CPTScatterPlotFieldX) {
        return [pSample valueForKey:X_VAL];
    }
    return [pSample valueForKey:Y_VAL];
}
- (IBAction)switchShowMode:(id)sender {
    UISegmentedControl *pSegmentControl = (UISegmentedControl *)sender;
    if (pSegmentControl.selectedSegmentIndex == 0) {
        NSLog(@"Month");
    } else {
        NSLog(@"Years");
    }
}
@end
