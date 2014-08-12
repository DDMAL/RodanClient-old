@import <Foundation/CPObject.j>
@import <Foundation/CPIndexSet.j>
@import <Foundation/CPRange.j>
@import <RodanKit/RodanKit.j>

@import "WorkflowDesignerView.j"
@import "ToolPanel.j"
@import "JobsTableController.j"
@import "OutlineView.j"
@import "WorkflowTableController.j"

//import controllers to access database
@import <RodanKit/Controllers/JobController.j>
@import "../../Delegates/LoadActiveWorkflowDelegate.j"

//need to create delegate class
@import "WorkflowDesignerDelegate.j"
@import <RodanKit/Models/Resource.j>
@import <RodanKit/Models/WorkflowJobSetting.j>

@import <RodanKit/Models/Job.j>

@global activeUser
@global RodanHasFocusWorkflowDesignerViewNotification
@global RodanShouldLoadWorkflowDesignerNotification
@global RodanShouldLoadPagesNotification
@global RodanDidLoadWorkflowNotification
@global RodanRemoveJobFromWorkflowNotification
@global RodanRequestWorkflowsNotification

@global RodanDidLoadJobsNotification


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


    @outlet             CPScrollView            designerView            @accessors;
    @outlet             CPSplitView             leftSideBar             @accessors;
    @outlet             CPSplitView             rightSideBar            @accessors;

                        WorkflowDesignerView    workflowDiagram         @accessors;

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


    //bundle to access resources (.png files)
                        CPBundle                theBundle               @accessors;

    //jobs View
    @outlet             CPScrollView            jobScrollView           @accessors;
    @outlet             CPView                  jobsView                @accessors;
    @outlet             CPArray                 jobsViewArray           @accessors;

    @outlet             CPScrollView            leftScrollView          @accessors;

    @outlet             CPView                  pagesView               @accessors;
    @outlet             CPArray                 pagesViewArray          @accessors;
    @outlet             CPView                  runsView                @accessors;
    @outlet             CPArray                 runsViewArray           @accessors;

    @outlet             CPScrollView            rightUpperScrollView    @accessors;
    @outlet             CPView                  rightUpperView          @accessors;
    @outlet             CPTableView             settingsView            @accessors;
    @outlet             CPView                  settingsViewBase        @accessors;


    //NOTE VIEWS FOR VIEW BASED TABLES
    // @outlet             CPView                  jobA                    @accessors;
    // @outlet             CPView                  jobB                    @accessors;
    // @outlet             CPView                  jobC                    @accessors;
    // @outlet             CPView                  jobD                    @accessors;
    // @outlet             CPView                  jobE                    @accessors;
    // @outlet             CPView                  jobF                    @accessors;
    // @outlet             CPView                  jobG                    @accessors;
    // @outlet             CPView                  jobH                    @accessors;
    // @outlet             CPView                  jobI                    @accessors;

    // //images for nested views of jobs
    // @outlet             CPImageView             imageA;
    // @outlet             CPImageView             imageB;
    // @outlet             CPImageView             imageC;
    // @outlet             CPImageView             imageD;
    // @outlet             CPImageView             imageE;
    // @outlet             CPImageView             imageF;
    // @outlet             CPImageView             imageG;
    // @outlet             CPImageView             imageH;
    // @outlet             CPImageView             imageI;

    // //images for view based table view for jobs
    // @outlet             CPImageView             imageA2;
    // @outlet             CPImageView             imageB2;
    // @outlet             CPImageView             imageC2;
    // @outlet             CPImageView             imageD2;
    // @outlet             CPImageView             imageE2;
    // @outlet             CPImageView             imageF2;
    // @outlet             CPImageView             imageG2;
    // @outlet             CPImageView             imageH2;
    // @outlet             CPImageView             imageI2;

    //resources for view based table view
    // @outlet             CPView                  pageA                    @accessors;
    // @outlet             CPView                  pageB                    @accessors;
    // @outlet             CPView                  pageC                    @accessors;
    // @outlet             CPView                  pageD                    @accessors;
    // @outlet             CPView                  pageE                    @accessors;
    // @outlet             CPView                  pageF                    @accessors;
    // @outlet             CPView                  pageG                    @accessors;
    // @outlet             CPView                  pageH                    @accessors;
    // @outlet             CPView                  pageI                    @accessors;

    //imagefor views
    // @outlet             CPImageView             pageImageA;
    // @outlet             CPImageView             pageImageB;
    // @outlet             CPImageView             pageImageC;
    // @outlet             CPImageView             pageImageD;
    // @outlet             CPImageView             pageImageE;
    // @outlet             CPImageView             pageImageF;
    // @outlet             CPImageView             pageImageG;
    // @outlet             CPImageView             pageImageH;
    // @outlet             CPImageView             pageImageI;

    @outlet             CPPanel                 attributesPanel;
    @outlet             CPTableHeaderView       attributesTableHeader;
    @outlet             CPOutlineView           attributesOutlineView;
    @outlet             CPScrollView            attributesScrollView;

    //attributes panel settings
    @outlet             CPDictionary            settings;

    //Table View (Resources)
    @outlet             CPTableView             pagesTableView;
    @outlet             CPArray                 pagesRowList;

    // ----------------------------------------------------------------- //
    // ------------------- DATABASES AND INFO -------------------------- //
    // ----------------------------------------------------------------- //

    @outlet             CPArrayController           workflowArrayController;
    @outlet             CPArrayController           currentWorkflowArrayController;

    @outlet             LoadActiveWorkflowDelegate  loadActiveWorkflowDelegate;

    @outlet             CPArrayController           resourceArrayController;
    @outlet             CPView                      resourceThumbnailView;


    @outlet             CPArrayController           runArrayController;

    //tab view - settings + description OR Attributes panel ??
    @outlet             TNTabView                   workflowJobTabView;
    @outlet             CPView                      selectedWorkflowJobSettingsTab;
    @outlet             CPView                      selectedWorkflowJobDescriptionTab;



}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    // console.log("Workflow Designer Plugin Successfully launched");
}

// ---------------------------------------- //
// ----------- NOTIFICATIONS -------------- //

- (void)receiveRefreshScrollView:(CPNotification)aNotification
{
    [[designerView documentView] setNeedsDisplay:YES];
}

// --------------------------------------------- //

- (void)awakeFromCib
{

    var center = [CPNotificationCenter defaultCenter];

    //to refresh scroll view
    [center addObserver:self
            selector:@selector(receiveRefreshScrollView:)
            name:@"RefreshScrollView"
            object:nil];



    mainWindow  = [[CPApplication sharedApplication] mainWindow];   //get mainWindow from instance of running application

    //init. Bundle to resources
    theBundle = [CPBundle bundleWithPath:@"PlugIns/RodanClientWorkflowDesignerPlugIn/"];
    // timeInterval = [[CPTimeInterval alloc] init];
    // timer = [CPDate dateWithTimeIntervalsSinceNow:timeInterval];

    viewBounds = [contentView bounds];

    [workflowDesignerView setFrame:viewBounds];
    [workflowDesignerView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [contentView addSubview:workflowDesignerView];


    [designerView setFrame:CGRectMake(200.0, 0.0, CGRectGetWidth(viewBounds) - 400.0, CGRectGetHeight(viewBounds))];
    [designerView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [designerView setAutoresizesSubviews:YES];
    [designerView setBackgroundColor:[CPColor colorWithHexString:"999999"]];


    //create instance of WorkflowDesignerViewhow did
    workflowDiagram = [[WorkflowDesignerView alloc] initDesignerWithFrame:CGRectMake(0.0, 0.0, 2000, 2000)];
    [workflowDiagram setFrame:CGRectMake(0.0, 0.0, 2000, 2000)];        //NOTE -> must autoadjust to size of canvas
    [workflowDiagram setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [designerView setDocumentView:workflowDiagram];

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
    // [rightSideBar splitView:rightSideBar constrainMinCoordinate:2 ofSubviewAt:0];

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

    // var scrollBounds = [jobScrollView bounds];

    // [jobsView setFrame:CGRectMake(scrollBounds.origin.x, scrollBounds.origin.y + 10.0, scrollBounds.size.x, [jobsView bounds].size.y)];

    [jobScrollView setBackgroundColor:[CPColor colorWithHexString:"8492A1"]];
    // [jobScrollView setDocumentView:jobsView];



    // var image1 = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"contrast.png"] size:CGSizeMake(32.0, 32.0)],
    //     image2 = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"crop.png"] size:CGSizeMake(32.0, 32.0)],
    //     image3 = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"expand.png"] size:CGSizeMake(32.0, 32.0)],
    //     image4 = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"expand2.png"] size:CGSizeMake(32.0, 32.0)],
    //     image5 = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"image.png"] size:CGSizeMake(32.0, 32.0)],
    //     image6 = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"libreoffice.png"] size:CGSizeMake(32.0, 32.0)],
    //     image7 = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"music.png"] size:CGSizeMake(32.0, 32.0)],
    //     image8 = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"pen.png"] size:CGSizeMake(32.0, 32.0)],
    //     image9 = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"table.png"] size:CGSizeMake(32.0, 32.0)];

    // [imageA setImage:image1];
    // [imageB setImage:image2];
    // [imageC setImage:image3];
    // [imageD setImage:image4];
    // [imageE setImage:image5];
    // [imageF setImage:image6];
    // [imageG setImage:image7];
    // [imageH setImage:image8];
    // [imageI setImage:image9];

    // [imageA2 setImage:image1];
    // [imageB2 setImage:image2];
    // [imageC2 setImage:image3];
    // [imageD2 setImage:image4];
    // [imageE2 setImage:image5];
    // [imageF2 setImage:image6];
    // [imageG2 setImage:image7];
    // [imageH2 setImage:image8];
    // [imageI2 setImage:image9];

    // [jobA setIdentifier:"JOBA"];

    // jobsViewArray = [[CPArray alloc] init]; //used to keep track of jobs. could use controller ?
    // jobsViewArray[0] = jobA;
    // jobsViewArray[1] = jobB;
    // jobsViewArray[2] = jobC;
    // jobsViewArray[3] = jobD;
    // jobsViewArray[4] = jobE;
    // jobsViewArray[5] = jobF;
    // jobsViewArray[6] = jobG;
    // jobsViewArray[7] = jobH;
    // jobsViewArray[8] = jobI;

    // for (var i = 0; i < [jobsViewArray count]; i++)
    // {
    //     [jobsViewArray[i] setBackgroundColor:[CPColor colorWithHexString:"A6A6A6"]];
    // };

    [leftScrollView setBackgroundColor:[CPColor colorWithHexString:"8492A1"]];
    // [leftScrollView setDocumentView:runsView];
  // [leftScrollView setDocumentView:pagesView];

    // [pageImageA setImage:[[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"file.png"] size:CGSizeMake(32.0, 32.0)]];
    // [pageImageB setImage:[[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"file.png"] size:CGSizeMake(32.0, 32.0)]];
    // [pageImageC setImage:[[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"file.png"] size:CGSizeMake(32.0, 32.0)]];
    // [pageImageD setImage:[[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"file.png"] size:CGSizeMake(32.0, 32.0)]];
    // [pageImageE setImage:[[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"file.png"] size:CGSizeMake(32.0, 32.0)]];
    // [pageImageF setImage:[[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"file.png"] size:CGSizeMake(32.0, 32.0)]];
    // [pageImageG setImage:[[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"file.png"] size:CGSizeMake(32.0, 32.0)]];
    // [pageImageH setImage:[[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"file.png"] size:CGSizeMake(32.0, 32.0)]];
    // [pageImageI setImage:[[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"file.png"] size:CGSizeMake(32.0, 32.0)]];

    // pagesViewArray = [[CPArray alloc] init];
    // pagesViewArray[0] = pageA;
    // pagesViewArray[0] = pageB;
    // pagesViewArray[0] = pageC;
    // pagesViewArray[0] = pageD;
    // pagesViewArray[0] = pageE;
    // pagesViewArray[0] = pageF;
    // pagesViewArray[0] = pageG;
    // pagesViewArray[0] = pageH;
    // pagesViewArray[0] = pageI;

    // for (var i = 0; i < [pagesViewArray count]; i++)
    // {
    //     [pagesViewArray[i] setBackgroundColor:[CPColor colorWithHexString:"A6A6A6"]];
    // };


    [attributesPanel setBackgroundColor:[CPColor colorWithHexString:"4C4C4C"]];

    [attributesTableHeader setBackgroundColor:[CPColor colorWithHexString:"4C4C4C"]];
    [attributesOutlineView setBackgroundColor:[CPColor colorWithHexString:"4C4C4C"]];
    [attributesScrollView setBackgroundColor:[CPColor colorWithHexString:"4C4C4C"]];
    [attributesPanel close];

//end of awakeFromCib
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
        workflowJobsCount = [workflowDiagram.workflowJobs count];
    for (i = 0 ; i < workflowJobsCount; i++)
    {
        if ([workflowDiagram.workflowJobs[i] firstResponder])
        {
            //set up attributes panel to link with the selected workflow job
            [[workflowDiagram.workflowJobs[i] wkJob] jobSettings];
            [attributesPanel orderFront:self];
        }
    }

}

- (void)saveAction:(id)aSender
{
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










// @implementation CPArray (MoveIndexes)

// - (void)moveIndexes:(CPIndexSet)indexes toIndex:(int)insertIndex
// {
//     var aboveCount = 0,
//         object,
//         removeIndex;

//     var index = [indexes lastIndex];

//     while (index != CPNotFound)
//     {
//         if (index >= insertIndex)
//         {
//             removeIndex = index + aboveCount;
//             aboveCount ++;
//         }
//         else
//         {
//             removeIndex = index;
//             insertIndex --;
//         }

//         object = [self objectAtIndex:removeIndex];
//         [self removeObjectAtIndex:removeIndex];
//         [self insertObject:object atIndex:insertIndex];

//         index = [indexes indexLessThanIndex:index];
//     }
// }

// @end

