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

#define START_POINT 0
#define END_POINT 15.0

#define X_VAL @"X_VAL"
#define Y_VAL @"Y_VAL"

#define Y_START_VALUE 0
#define Y_END_VALUE 100
#define Y_MAJOR_INCREASEMENT 1

@interface MainViewController ()

@end



@implementation MainViewController
@synthesize mGraph;
@synthesize mSamples;
@synthesize mHostingView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // self.automaticallyAdjustsScrollViewInsets
    self.automaticallyAdjustsScrollViewInsets = NO;
    mDataArray = (NSArray *)[[[ModelManager sharedInstance] mData] objectForKey:@"2011"];
    for (int i = 1; i <= 12; i++) {
        [self getMonthStringBasedOnIntValue:i];
    }
    
    [self generateDataSamples];
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
    [super dealloc];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
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
//    NSLog(@"Value %d: %@", nValue,stringFromDate);
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
    
    // Set Graph Title
    NSString *pTitle = @"Chart";
    [pGraph setTitle:pTitle];
    [pGraph setTitlePlotAreaFrameAnchor:CPTRectAnchorTop];
    
    // Create and set text style for the graph
    CPTMutableTextStyle *pTitleStyle = [CPTMutableTextStyle textStyle];
    [pTitleStyle setColor:[CPTColor blackColor]];
    [pTitleStyle setFontName:@"Futura"];
    [pTitleStyle setFontSize:16.0f];
    [pGraph setTitleTextStyle:pTitleStyle];
    [pGraph setTitleDisplacement:CGPointMake(0.0f, 10.0f)];
    [pGraph setTitlePlotAreaFrameAnchor:CPTRectAnchorTop];
    
    // Set padding for plot area
    [pGraph.plotAreaFrame setPaddingLeft:60.0f];
    [pGraph.plotAreaFrame setPaddingRight:30.0f];
    [pGraph.plotAreaFrame setPaddingBottom:60.0f];
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
    
    // Create the three plots
    CPTScatterPlot *pMonthPlot = [[CPTScatterPlot alloc] init];
    [pMonthPlot setDataSource:self];
    
    [pGraph addPlot:pMonthPlot toPlotSpace:pPlotSpace];
    [pGraph setIdentifier:@"MonthPlot"];
    
    CPTPlotRange *pGlobalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0) length:CPTDecimalFromDouble(20)];
    pPlotSpace.globalYRange = pGlobalYRange;
    
    CPTPlotRange *pGlobalXRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0) length:CPTDecimalFromDouble(20)];
    pPlotSpace.globalXRange = pGlobalXRange;
}
/**
 *  Configure Axes on Graph
 */
- (void) configAxes {
    CPTGraph *pGraph = (CPTGraph *)self.mHostingView.hostedGraph;
    
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor redColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor redColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor redColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor redColor];
    tickLineStyle.lineWidth = 2.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor redColor];
    tickLineStyle.lineWidth = 1.0f;
    
    // Get Axis Set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)pGraph.axisSet;
    
    // Config X-Axis
    CPTAxis *xAxis = axisSet.xAxis;
    xAxis.title = @"Months";
    xAxis.titleOffset = 20;
    xAxis.labelOffset = 50;
    xAxis.titleTextStyle = axisTextStyle;
    xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    xAxis.labelTextStyle = axisTextStyle;
    xAxis.majorTickLineStyle = axisLineStyle;
    xAxis.majorTickLength = 1.0f;
    xAxis.majorGridLineStyle = gridLineStyle;
    xAxis.tickDirection = CPTSignNegative;
    NSMutableSet *xLabels = [NSMutableSet set];
    NSMutableSet *xLocations = [NSMutableSet set];
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
    xAxis.axisLabels = xLabels;
    xAxis.majorTickLocations = xLocations;
    
    // Config Y-Axis
    CPTAxis *yAxis = axisSet.yAxis;
    yAxis.title = @"USD";
    yAxis.titleOffset = -30;
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
    
    NSInteger majorIncrement = 100;
    NSInteger minorIncrement = 50;
    CGFloat yMax = 800.0f;  // should determine dynamically based on max price
    
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    
    NSInteger xIndex = 0;
    for (NSInteger i = minorIncrement; i <= yMax; i+= minorIncrement) {
        NSUInteger mod = i % majorIncrement;
        if (mod == 0) {
            CPTAxisLabel *pLabel = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"R%d",i] textStyle:xAxis.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(xIndex);
            pLabel.tickLocation = location;
            pLabel.offset = - 30;
            if (pLabel != nil) {
                [yLabels addObject:pLabel];
            }
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        } else {
            CPTAxisLabel *pLabel = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"R%d",i] textStyle:xAxis.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(xIndex);
            pLabel.tickLocation = location;
            pLabel.offset = - 30;
            if (pLabel != nil) {
                [yLabels addObject:pLabel];
            }
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        }
        xIndex++;
    }
    yAxis.axisLabels = yLabels;
    yAxis.majorTickLocations = yMajorLocations;
    yAxis.minorTickLocations = yMinorLocations;
}

#pragma mark - CPTPlot Data Source Methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return 15;
}

- (id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSDictionary *pSample = [mSamples objectAtIndex:index];
    switch (fieldEnum) {
        case CPTScatterPlotFieldX: {
            if (index < 10) {
                return [NSNumber numberWithUnsignedInteger:index];
            }
            break;
        }
        case CPTScatterPlotFieldY: {
            if (index < 10) {
                return [NSNumber numberWithUnsignedInteger:index];
            }
            break;
        }
        default:
            break;
    }
    return [NSDecimalNumber zero];
}

#pragma mark - Axis Delegate


- (IBAction)switchShowMode:(id)sender {
    UISegmentedControl *pSegmentControl = (UISegmentedControl *)sender;
    if (pSegmentControl.selectedSegmentIndex == 0) {
        NSLog(@"Month");
    } else {
        NSLog(@"Years");
    }
}


@end
