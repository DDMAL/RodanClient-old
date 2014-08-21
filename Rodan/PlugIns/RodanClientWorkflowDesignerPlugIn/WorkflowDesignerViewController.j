@import <Foundation/CPObject.j>
@import <RodanKit/RodanKit.j>

@import "Views/DesignerView.j"
@import "Controllers/DesignerViewController.j"
@import "Controllers/JobsTableController.j"
@import "Controllers/WorkflowTableController.j"


//import controllers to access database
@import <RodanKit/JobController.j>

//need to create delegate class
@import <RodanKit/Resource.j>
@import <RodanKit/Job.j>


JobsTableDragAndDropTableViewDataType = @"JobsTableDragAndDropTableViewDataType";
CustomOutlineViewDragType = @"CustomOutlineViewDragType";

var _msLOADINTERVAL = 5.0;

@implementation WorkflowDesignerViewController : CPViewController
{
    // --------------------------------------------------------------- //
    //-------------------- GRAPHICAL PROPERTIES ---------------------- //
    // --------------------------------------------------------------- //
                        CPWindow                mainWindow;
    @outlet             CPToolbar               mainToolbar @accessors(property=toolbar);

    @outlet             CPView                  contentView;
                        CGRect                  viewBounds;

    @outlet             CPSplitView             workflowDesignerView    @accessors;
    @outlet             CPSplitView             leftSideBar             @accessors;
    @outlet             CPSplitView             rightSideBar            @accessors;
    @outlet             CPScrollView            designerScrollView      @accessors;
    @outlet             DesignerViewController  designerViewController  @accessors;

    //jobs View
    @outlet             CPScrollView            jobScrollView           @accessors;
    // @outlet             CPView                  jobsView                @accessors;

    @outlet             CPScrollView            leftScrollView          @accessors;

    @outlet             CPScrollView            rightUpperScrollView    @accessors;
    @outlet             CPView                  rightUpperView          @accessors;
    @outlet             CPTableView             settingsView            @accessors;
    @outlet             CPView                  settingsViewBase        @accessors;


    //bundle to access resources (.png files)
                        CPBundle                theBundle               @accessors;

    //toolbar icons (can be moved to separate class?)
    @outlet             CPToolbarItem           leftSideBarIcon         @accessors;
    @outlet             CPToolbarItem           rightSideBarIcon        @accessors;
    @outlet             CPToolbarItem           toolsIcon               @accessors;
    @outlet             CPToolbarItem           helpIcon                @accessors;


    //toolbar buttons (can be moved to separate class ?)
    @outlet             CPButton                connectButton           @accessors;
    @outlet             CPButton                settingsButton          @accessors;
    @outlet             CPButton                pagesButton             @accessors;
    @outlet             CPButton                runsButton              @accessors;
    @outlet             CPButton                saveButton              @accessors;

    @outlet             CPPanel                 attributesPanel;
    @outlet             CPTableHeaderView       attributesTableHeader;
    @outlet             CPOutlineView           attributesOutlineView;
    @outlet             CPScrollView            attributesScrollView;
    @outlet             CPDictionary            attributesSettings;

}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    // console.log("Workflow Designer Plugin Successfully launched");
}


- (void)awakeFromCib
{

    var center = [CPNotificationCenter defaultCenter];

    //to refresh scroll view
    [center addObserver:self
            selector:@selector(receiveRefreshScrollView:)
            name:@"RefreshScrollView"
            object:nil];



    mainWindow  = [[CPApplication sharedApplication] mainWindow];   //get mainWindow from instance of running application
    theBundle = [CPBundle bundleWithPath:@"PlugIns/RodanClientWorkflowDesignerPlugIn/"];

    viewBounds = [contentView bounds];

    [workflowDesignerView setFrame:viewBounds];
    [workflowDesignerView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [contentView addSubview:workflowDesignerView];


    [designerScrollView setFrame:CGRectMake(200.0, 0.0, CGRectGetWidth(viewBounds) - 400.0, CGRectGetHeight(viewBounds))];
    [designerScrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [designerScrollView setAutoresizesSubviews:YES];
    [designerScrollView setBackgroundColor:[CPColor colorWithHexString:"999999"]];


    [[designerViewController designerView] setFrame:CGRectMake(0.0, 0.0, 2000, 2000)];        //NOTE -> must autoadjust to size of canvas
    [[designerViewController designerView] setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [designerScrollView setDocumentView:[designerViewController designerView]]; //scroll view that holds the designerView

    //left Side Bar
    [leftSideBar setFrame:CGRectMake(0.0, 0.0, 200.0, CGRectGetHeight(viewBounds))];
    [leftSideBar setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [leftSideBar setBackgroundColor:[CPColor colorWithHexString:"BDC2C7"]];
    [leftSideBar setDelegate:self];


    //Right Side Bar
    [rightSideBar setFrame:CGRectMake(CGRectGetWidth(viewBounds) - 200.0, 0.0, 200.0, CGRectGetHeight(viewBounds))];
    [rightSideBar setAutoresizingMask:CPViewHeightSizable | CPViewWidthSizable];
    [rightSideBar setBackgroundColor:[CPColor colorWithHexString:"BDC2C7"]];
    [rightSideBar setDelegate:self];

    var leftSideBarImageIcon = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"indent-increase.png"] size:CGSizeMake(20.0, 20.0)],
        rightSideBarImageIcon = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"indent-decrease.png"] size:CGSizeMake(20.0, 20.0)],
        toolsImageIcon = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"wrench.png"] size:CGSizeMake(20.0, 20.0)],
        helpImageIcon = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"help.png"] size:CGSizeMake(20.0, 20.0)];

    [leftSideBarIcon setImage:leftSideBarImageIcon];
    [rightSideBarIcon setImage:rightSideBarImageIcon];
    [toolsIcon setImage:toolsImageIcon];
    [helpIcon setImage:helpImageIcon];


    // connectImage = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"connect.png"]];
    var connectImage = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"connect.png"] size:CGSizeMake(20.0, 20.0)];
    [connectButton setImage:connectImage];
    [connectButton setBordered:NO];

    var settingsImage = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"cog.png"] size:CGSizeMake(20.0, 20.0)];
    [settingsButton setImage:settingsImage];
    [settingsButton setBordered:NO];

    var pagesImage = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"file.png"] size:CGSizeMake(20.0, 20.0)];
    [pagesButton setImage:pagesImage];
    [pagesButton setBordered:NO];

    var runsImage = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"arrow-down.png"] size:CGSizeMake(20.0, 20.0)];
    [runsButton setImage:runsImage];
    [runsButton setBordered:NO];

    var diskImage = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"disk.png"] size:CGSizeMake(20.0, 20.0)];
    [saveButton setImage:diskImage];
    [saveButton setBordered:NO];


// ----------------------------------------------- //
/* ---------- Button action & target setup ------ */
// ----------------------------------------------- //

    [runsButton setAction:@selector(runsAction:)];
    [runsButton setTarget:self];

    [connectButton setAction:@selector(connectAction:)];
    [connectButton setTarget:self];

    [settingsButton setAction:@selector(settingsAction:)];
    [settingsButton setTarget:self];

    [pagesButton setAction:@selector(pagesAction:)];
    [pagesButton setTarget:self];

    [saveButton setAction:@selector(saveAction:)];
    [saveButton setTarget:self];

    [leftSideBarIcon setAction:@selector(leftSideBarAction:)];
    [leftSideBarIcon setTarget:self];

    [rightSideBarIcon setAction:@selector(rightSideBarAction:)];
    [rightSideBarIcon setTarget:self];

    [toolsIcon setAction:@selector(toolsAction:)];
    [toolsIcon setTarget:self];

    [helpIcon setAction:@selector(helpAction:)];
    [helpIcon setTarget:self];



/* ------------------------------------------------ */
// ------------------------------------------------- //

    [rightUpperScrollView setBackgroundColor:[CPColor colorWithHexString:"8492A1"]];
    [rightUpperScrollView setDocumentView:rightUpperView];

    [jobScrollView setBackgroundColor:[CPColor colorWithHexString:"8492A1"]];

    [leftScrollView setBackgroundColor:[CPColor colorWithHexString:"8492A1"]];

    [attributesPanel setBackgroundColor:[CPColor colorWithHexString:"4C4C4C"]];

    [attributesTableHeader setBackgroundColor:[CPColor colorWithHexString:"4C4C4C"]];
    [attributesOutlineView setBackgroundColor:[CPColor colorWithHexString:"4C4C4C"]];
    [attributesScrollView setBackgroundColor:[CPColor colorWithHexString:"4C4C4C"]];
    [attributesPanel close];

//end of awakeFromCib
}

- (void)receiveRefreshScrollView:(CPNotification)aNotification
{
    [[designerScrollView documentView] setNeedsDisplay:YES];
}


//------------- ICON ACTION BUTTONS ----------------- //
// -------------------------------------------------- //

- (void)runsAction:(id)aSender
{
    console.log("Runs");
}

- (void)pagesAction:(id)aSender
{
    console.log("Pages");
}

//NOTE - partial implementation
- (void)toolsAction:(id)aSender
{
    console.log("Tools");

    var i,
        workflowJobsCount = [[[designerViewController workflowJobs] contentArray] count];
    for (i = 0 ; i < workflowJobsCount; i++)
    {
        if ([[designerViewController workflowJobs][i] firstResponder])
        {
            //set up attributes panel to link with the selected workflow job
            [[[designerViewController workflowJobs][i] workflowJob] jobSettings];
            [attributesPanel orderFront:self];
        }
    }
    [attributesPanel orderFront:self];
}

- (void)saveAction:(id)aSender
{
    //TO DO:
    console.log("save");
}

- (void)leftSideBarAction:(id)aSender
{
    console.log("LeftSideBar");
    var leftViewCollapsed = [[self workflowDesignerView] isSubviewCollapsed:[[[self workflowDesignerView] subviews] objectAtIndex:0]];

    if (leftViewCollapsed)
        [workflowDesignerView setPosition:300.0 ofDividerAtIndex:0];
    else
        [workflowDesignerView setPosition:0.0 ofDividerAtIndex:0];
}

- (void)rightSideBarAction:(id)aSender
{
    console.log("RightSideBar");
    var rightViewCollapsed = [[self workflowDesignerView] isSubviewCollapsed:[[[self workflowDesignerView] subviews] objectAtIndex:2]],
        overallFrame = [workflowDesignerView frame];

    if (rightViewCollapsed)
        [workflowDesignerView setPosition:overallFrame.origin.x + overallFrame.size.width - 300 ofDividerAtIndex:1];

    else
        [workflowDesignerView setPosition:overallFrame.origin.x + overallFrame.size.width ofDividerAtIndex:1];
}

// -------- split View method constrain & helper methods --------- //
- (float)splitView:(CPSplitView)splitView constrainMinCoordinate:(float)minCoord ofSubviewAt:(CPInteger)index
{
    if (index == 0)
        return 200;
    else
        return minCoord;

}

- (float)splitView:(CPSplitView)splitView constrainMaxCoordinate:(float)minCoord ofSubviewAt:(CPInteger)index
{
    if (index == 0)
        return 500;

    else
        return minCoord;
}

- (float)splitView:(CPSplitView)splitView canCollapseSubview:(CPView)subview
{
    var rightView = [[splitView subviews] objectAtIndex:0];
    return ([subview isEqual:rightView]);
}

- (BOOL)splitView:(CPSplitView)splitView shouldHideDividerAtIndex:(CPInteger)dividerIndex
{
    return YES;
}


//will collapse on doubleClick
- (BOOL)splitView:(CPSplitView)splitView shouldCollapseSubview:(CPView)subview forDoubleClickOnDividerAtIndex:(CPInteger)dividerIndex
{
    var rightView = [[splitView subviews] objectAtIndex:0];
    return ([subview isEqual:rightView]);
}

 // ----------- END split view constraint helper methods ------- //




- (void)helpAction:(id)aSender
{
    console.log("Help");
}

- (void)connectAction:(id)aSender
{
    console.log("Connection");
}

- (void)settingsAction:(id)aSender
{
    console.log("Settings");
}

- (IBAction)newResourceListAction:(id)aSender
{
    [[CPNotificationCenter defaultCenter] postNotificationName:@"ResourceListIsBeingCreatedNotification" object:nil];
}


@end

