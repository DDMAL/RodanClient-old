@import <Foundation/CPObject.j>
@import <Foundation/CPIndexSet.j>
@import <Foundation/CPRange.j>

@import "WorkflowDesignerView.j"
@import "ToolPanel.j"
@import "Menu.j"


TableTestDragAndDropTableViewDataType = @"TableTestDragAndDropTableViewDataType";
CustomOutlineViewDragType = @"CustomOutlineViewDragType";


@implementation WorkflowDesignerViewController : CPViewController
{

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
    @outlet             CPToolbarItem           statusIcon              @accessors;
    @outlet             CPToolbarItem           userIcon                @accessors;
    @outlet             CPToolbarItem           pagesIcon               @accessors;
    @outlet             CPToolbarItem           designerIcon            @accessors;
    @outlet             CPToolbarItem           jobsIcon                @accessors;
    @outlet             CPToolbarItem           resultsIcon             @accessors;

    //toolbar buttons (can be moved to separate class ?)
    @outlet             CPButton                connectButton           @accessors;
    @outlet             CPButton                settingsButton          @accessors;
    @outlet             CPButton                pagesButton             @accessors;
    @outlet             CPButton                runsButton              @accessors;

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


    @outlet             CPView                  jobA                    @accessors;
    @outlet             CPView                  jobB                    @accessors;
    @outlet             CPView                  jobC                    @accessors;
    @outlet             CPView                  jobD                    @accessors;
    @outlet             CPView                  jobE                    @accessors;
    @outlet             CPView                  jobF                    @accessors;
    @outlet             CPView                  jobG                    @accessors;
    @outlet             CPView                  jobH                    @accessors;
    @outlet             CPView                  jobI                    @accessors;

    //images for nested views of jobs
    @outlet             CPImageView             imageA;
    @outlet             CPImageView             imageB;
    @outlet             CPImageView             imageC;
    @outlet             CPImageView             imageD;
    @outlet             CPImageView             imageE;
    @outlet             CPImageView             imageF;
    @outlet             CPImageView             imageG;
    @outlet             CPImageView             imageH;
    @outlet             CPImageView             imageI;

    //images for view based table view for jobs
    @outlet             CPImageView             imageA2;
    @outlet             CPImageView             imageB2;
    @outlet             CPImageView             imageC2;
    @outlet             CPImageView             imageD2;
    @outlet             CPImageView             imageE2;
    @outlet             CPImageView             imageF2;
    @outlet             CPImageView             imageG2;
    @outlet             CPImageView             imageH2;
    @outlet             CPImageView             imageI2;

    //resources for view based table view
    @outlet             CPView                  pageA                    @accessors;
    @outlet             CPView                  pageB                    @accessors;
    @outlet             CPView                  pageC                    @accessors;
    @outlet             CPView                  pageD                    @accessors;
    @outlet             CPView                  pageE                    @accessors;
    @outlet             CPView                  pageF                    @accessors;
    @outlet             CPView                  pageG                    @accessors;
    @outlet             CPView                  pageH                    @accessors;
    @outlet             CPView                  pageI                    @accessors;

    //imagefor views
    @outlet             CPImageView             pageImageA;
    @outlet             CPImageView             pageImageB;
    @outlet             CPImageView             pageImageC;
    @outlet             CPImageView             pageImageD;
    @outlet             CPImageView             pageImageE;
    @outlet             CPImageView             pageImageF;
    @outlet             CPImageView             pageImageG;
    @outlet             CPImageView             pageImageH;
    @outlet             CPImageView             pageImageI;

    @outlet             CPPanel                 attributesPanel;
    @outlet             CPTableHeaderView       attributesTableHeader;
    @outlet             CPOutlineView           attributesOutlineView;
    @outlet             CPScrollView            attributesScrollView;


    //Table View
    @outlet             CPTableView             jobsTableView;
    @outlet             CPArray                 _tableContent;
                        CPArray                 rowList;

    //Outline View
                        Menu                    _menu @accessors(property=menu);
    @outlet             CPOutlineView           _outlineView;
                        CPArray                 _draggedItems;

    //Table View (Resources)
    @outlet             CPTableView             pagesTableView;
    @outlet             CPArrayController       pagesArrayController;

}
    
- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    // This is called when the application is done loading.

    

}

- (void)awakeFromCib
{
    //init. Bundle to resources
    theBundle = [CPBundle mainBundle];
    viewBounds = [self bounds];

    var center = [CPNotificationCenter defaultCenter];
    
    [workflowDesignerView setFrame:viewBounds];
    [workflowDesignerView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [self addSubview:workflowDesignerView];



    [designerView setFrame:CGRectMake(300.0, 0.0, CGRectGetWidth(viewBounds) - 600.0, CGRectGetHeight(viewBounds))];
    [designerView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [designerView setAutoresizesSubviews:YES];
    [designerView setBackgroundColor:[CPColor colorWithHexString:"FFFFFF"]];
    
    //create instance of WorkflowDesignerView
    workflowDiagram = [[WorkflowDesignerView alloc] initDesigner];
    [workflowDiagram setFrame:CGRectMake(0.0, 0.0, 1200, 1200)];        //NOTE -> must autoadjust to size of canvas
    [workflowDiagram setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [designerView setDocumentView:workflowDiagram];

    //left Side Bar
    [leftSideBar setFrame:CGRectMake(0.0, 0.0, 300.0, CGRectGetHeight(viewBounds))];
    [leftSideBar setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [leftSideBar setBackgroundColor:[CPColor colorWithHexString:"E6E6E6"]];
    [leftSideBar setDelegate:self];


    //Right Side Bar
    [rightSideBar setFrame:CGRectMake(CGRectGetWidth(viewBounds) - 300.0, 0.0, 300.0, CGRectGetHeight(viewBounds))];
    [rightSideBar setAutoresizingMask:CPViewHeightSizable | CPViewWidthSizable];
    [rightSideBar setBackgroundColor:[CPColor colorWithHexString:"E6E6E6"]];
    [rightSideBar setDelegate:self];
    // [rightSideBar splitView:rightSideBar constrainMinCoordinate:2 ofSubviewAt:0];

    var leftSideBarImageIcon = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"indent-increase.png"] size:CGSizeMake(15.0, 15.0)],
        rightSideBarImageIcon = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"indent-decrease.png"] size:CGSizeMake(15.0, 15.0)],
        toolsImageIcon = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"wrench.png"] size:CGSizeMake(15.0, 15.0)],
        helpImageIcon = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"help.png"] size:CGSizeMake(15.0, 15.0)],
        statusImageIcon = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"toolbar-status.png"] size:CGSizeMake(15.0, 15.0)],
        usersImageIcon = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"toolbar-users.png"] size:CGSizeMake(15.0, 15.0)],
        pagesImageIcon = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"toolbar-users.png"] size:CGSizeMake(15.0, 15.0)],
        designerImageIcon = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"toolbar-workflow-designer.png"] size:CGSizeMake(15.0, 15.0)],
        jobsImageIcon = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"toolbar-jobs.png"] size:CGSizeMake(15.0, 15.0)],
        resultsImageIcon = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"toolbar-workflows.png"] size:CGSizeMake(15.0, 15.0)];

        [leftSideBarIcon setImage:leftSideBarImageIcon];
        [rightSideBarIcon setImage:rightSideBarImageIcon];
        [toolsIcon setImage:toolsImageIcon];
        [helpIcon setImage:helpImageIcon];
        [statusIcon setImage:statusImageIcon];
        [userIcon setImage:usersImageIcon];
        [pagesIcon setImage:pagesImageIcon];
        [designerIcon setImage:designerImageIcon];
        [jobsIcon setImage:jobsImageIcon];
        [resultsIcon setImage:resultsImageIcon];


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

/* ---------- Button action & target setup ------ */
    [runsButton setAction:@selector(runsAction:)];
    [runsButton setTarget:self];

    [connectButton setAction:@selector(connectAction:)];
    [connectButton setTarget:self];

    [settingsButton setAction:@selector(settingsAction:)];
    [settingsButton setTarget:self];

    [pagesButton setAction:@selector(pagesAction:)];
    [pagesButton setTarget:self];

    [leftSideBarIcon setAction:@selector(leftSideBarAction:)];
    [leftSideBarIcon setTarget:self];

    [rightSideBarIcon setAction:@selector(rightSideBarAction:)];
    [rightSideBarIcon setTarget:self];

    [toolsIcon setAction:@selector(toolsAction:)];
    [toolsIcon setTarget:self];

    [helpIcon setAction:@selector(helpAction:)];
    [helpIcon setTarget:self];
    
/* ------------------------------------------------ */
    [rightUpperScrollView setBackgroundColor:[CPColor colorWithHexString:"A6A6A6"]];
    [rightUpperScrollView setDocumentView:rightUpperView];

    // var scrollBounds = [jobScrollView bounds];

    // [jobsView setFrame:CGRectMake(scrollBounds.origin.x, scrollBounds.origin.y + 10.0, scrollBounds.size.x, [jobsView bounds].size.y)];

    [jobScrollView setBackgroundColor:[CPColor colorWithHexString:"A6A6A6"]];
    // [jobScrollView setDocumentView:jobsView];

    

    var image1 = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"contrast.png"] size:CGSizeMake(32.0, 32.0)],
        image2 = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"crop.png"] size:CGSizeMake(32.0, 32.0)],
        image3 = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"expand.png"] size:CGSizeMake(32.0, 32.0)],
        image4 = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"expand2.png"] size:CGSizeMake(32.0, 32.0)],
        image5 = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"image.png"] size:CGSizeMake(32.0, 32.0)],
        image6 = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"libreoffice.png"] size:CGSizeMake(32.0, 32.0)],
        image7 = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"music.png"] size:CGSizeMake(32.0, 32.0)],
        image8 = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"pen.png"] size:CGSizeMake(32.0, 32.0)],
        image9 = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"table.png"] size:CGSizeMake(32.0, 32.0)];

    [imageA setImage:image1];
    [imageB setImage:image2];
    [imageC setImage:image3];
    [imageD setImage:image4];
    [imageE setImage:image5];
    [imageF setImage:image6];
    [imageG setImage:image7];
    [imageH setImage:image8];
    [imageI setImage:image9];

    [imageA2 setImage:image1];
    [imageB2 setImage:image2];
    [imageC2 setImage:image3];
    [imageD2 setImage:image4];
    [imageE2 setImage:image5];
    [imageF2 setImage:image6];
    [imageG2 setImage:image7];
    [imageH2 setImage:image8];
    [imageI2 setImage:image9];


    jobsViewArray = [[CPArray alloc] init]; //used to keep track of jobs. could use controller ? 
    jobsViewArray[0] = jobA;
    jobsViewArray[1] = jobB;
    jobsViewArray[2] = jobC;
    jobsViewArray[3] = jobD;
    jobsViewArray[4] = jobE;
    jobsViewArray[5] = jobF;
    jobsViewArray[6] = jobG;
    jobsViewArray[7] = jobH;
    jobsViewArray[8] = jobI;

    for (var i = 0; i < [jobsViewArray count]; i++)
    {
        [jobsViewArray[i] setBackgroundColor:[CPColor colorWithHexString:"A6A6A6"]];
    };

    [leftScrollView setBackgroundColor:[CPColor colorWithHexString:"A6A6A6"]];
    // [leftScrollView setDocumentView:runsView];
    
    // [leftScrollView setDocumentView:pagesView];

    [pageImageA setImage:[[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"file.png"] size:CGSizeMake(32.0, 32.0)]];
    [pageImageB setImage:[[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"file.png"] size:CGSizeMake(32.0, 32.0)]];
    [pageImageC setImage:[[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"file.png"] size:CGSizeMake(32.0, 32.0)]];
    [pageImageD setImage:[[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"file.png"] size:CGSizeMake(32.0, 32.0)]];
    [pageImageE setImage:[[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"file.png"] size:CGSizeMake(32.0, 32.0)]];
    [pageImageF setImage:[[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"file.png"] size:CGSizeMake(32.0, 32.0)]];
    [pageImageG setImage:[[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"file.png"] size:CGSizeMake(32.0, 32.0)]];
    [pageImageH setImage:[[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"file.png"] size:CGSizeMake(32.0, 32.0)]];
    [pageImageI setImage:[[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:@"file.png"] size:CGSizeMake(32.0, 32.0)]];

    pagesViewArray = [[CPArray alloc] init];
    pagesViewArray[0] = pageA;
    pagesViewArray[0] = pageB;
    pagesViewArray[0] = pageC;
    pagesViewArray[0] = pageD;
    pagesViewArray[0] = pageE;
    pagesViewArray[0] = pageF;
    pagesViewArray[0] = pageG;
    pagesViewArray[0] = pageH;
    pagesViewArray[0] = pageI;

    for (var i = 0; i < [pagesViewArray count]; i++)
    {
        [pagesViewArray[i] setBackgroundColor:[CPColor colorWithHexString:"A6A6A6"]];
    };


    [attributesPanel setBackgroundColor:[CPColor colorWithHexString:"4C4C4C"]];

    [attributesTableHeader setBackgroundColor:[CPColor colorWithHexString:"4C4C4C"]];
    [attributesOutlineView setBackgroundColor:[CPColor colorWithHexString:"4C4C4C"]];
    [attributesScrollView setBackgroundColor:[CPColor colorWithHexString:"4C4C4C"]];
    [attributesPanel close];
    

    /* --------- TABLE VIEW IMPLMENTATION ------- */
    _tableContent = [[CPArray alloc] init];
    //put content into _tableContent
    for (var i = 0; i < [jobsViewArray count]; i++)
    {
        [_tableContent addObject:jobsViewArray[i]];
    };



    [jobsTableView setDataSource:self];
    [jobsTableView setDelegate:self];
    // [jobsTableView setUsesAlternatingRowBackgroundColor:YES];
    [jobsTableView registerForDraggedTypes:[CPArray arrayWithObjects:TableTestDragAndDropTableViewDataType]];

    [jobsTableView setGridStyleMask:CPTableViewSolidVerticalGridLineMask | CPTableViewSolidHorizontalGridLineMask];
    [jobsTableView setAllowsMultipleSelection:NO];

    [jobsTableView setIntercellSpacing:CGSizeMake(0, 0)];

    // var column = [[CPTableColumn alloc] initWithIdentifier:@"workflowJobs"];
    // [[column headerView] setStringValue:@"workflowJobs"];
    // [jobsTableView addTableColumn:column];

    /* -------------------------------------------- */




    /* -------- OUTLINE VIEW IMPLEMENTATION --- */
    //menu for outline view

    _menu = [Menu menuWithTitle:@"Top" children:[
        [Menu menuWithTitle:@"1" children:[
            [Menu menuWithTitle:@"1.1" children:[
                [Menu menuWithTitle:@"1.1.1"],
                [Menu menuWithTitle:@"1.1.2"],
            ]],
            [Menu menuWithTitle:@"1.2" children:[
                [Menu menuWithTitle:@"1.2.1" children:[
                    [Menu menuWithTitle:@"1.2.1.1"],
                    [Menu menuWithTitle:@"1.2.1.2"],
                    [Menu menuWithTitle:@"1.2.1.3"],
                ]],
                [Menu menuWithTitle:@"1.2.2"],
                [Menu menuWithTitle:@"1.2.3"]
            ]]
        ]],
         [Menu menuWithTitle:@"2" children:nil],
         [Menu menuWithTitle:@"3" children:[
          [Menu menuWithTitle:@"3.1" children:[
              [Menu menuWithTitle:@"3.1.1"],
              [Menu menuWithTitle:@"3.1.2"],
              [Menu menuWithTitle:@"3.1.3"],
          ]],
          [Menu menuWithTitle:@"3.2" children:[
              [Menu menuWithTitle:@"3.2.1"],
              [Menu menuWithTitle:@"3.2.2"],
              [Menu menuWithTitle:@"3.2.3"],
              [Menu menuWithTitle:@"3.2.4"],
          ]],
          [Menu menuWithTitle:@"3.3" children:[
              [Menu menuWithTitle:@"3.3.1"],
              [Menu menuWithTitle:@"3.3.2"],
              [Menu menuWithTitle:@"3.3.3"],
              [Menu menuWithTitle:@"3.3.4"],
              [Menu menuWithTitle:@"3.3.5"],
          ]]
         ]]
    ]];

    var column = [[CPTableColumn alloc] initWithIdentifier:@"One"];
    [_outlineView addTableColumn:column];
    //[_outlineView setOutlineTableColumn:column];
    setTimeout(function(){
    [column setWidth:50];
    },0);

    [_outlineView addTableColumn:[[CPTableColumn alloc] initWithIdentifier:@"Two"]];
    [_outlineView addTableColumn:[[CPTableColumn alloc] initWithIdentifier:@"Three"]];

    [_outlineView registerForDraggedTypes:[CustomOutlineViewDragType]];

    [_outlineView setDataSource:self];
    [_outlineView setDelegate:self];
    [_outlineView setAllowsMultipleSelection:YES];
    [_outlineView expandItem:nil expandChildren:YES];
    // [_outlineView setRowHeight:50.0];
    // [_outlineView setIntercellSpacing:CGSizeMake(0.0, 10.0)]

    // [column setWidth:CGRectGetWidth([_outlineView bounds])];



    /* ----------------------------------------- */
}

/* --------- Button Actions -------------- */
- (void)runsAction:(id)aSender
{
    console.log("Runs");
}

- (void)pagesAction:(id)aSender
{
    console.log("Pages");
}

- (void)toolsAction:(id)aSender
{
    console.log("Tools");
    [attributesPanel orderFront:self];

}

- (void)leftSideBarAction:(id)aSender
{
    console.log("LeftSideBar");
    var leftViewCollapsed = [[self workflowDesignerView] isSubviewCollapsed:[[[self workflowDesignerView] subviews] objectAtIndex:0]];
    
    console.log(leftViewCollapsed);
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
 
    console.log(overallFrame.origin.x);
 
    if (rightViewCollapsed)
        [workflowDesignerView setPosition:overallFrame.origin.x + overallFrame.size.width - 300 ofDividerAtIndex:1];
 
    else
        [workflowDesignerView setPosition:overallFrame.origin.x + overallFrame.size.width ofDividerAtIndex:1];
}

//split View method constrain & helper methods ---------
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
 
// - (BOOL)splitView:(CPSplitView)splitView shouldHideDividerAtIndex:(CPInteger)dividerIndex
// {
//     return YES;
// }
 
 
//will collapse on doubleClick
- (BOOL)splitView:(CPSplitView)splitView shouldCollapseSubview:(CPView)subview forDoubleClickOnDividerAtIndex:(CPInteger)dividerIndex
{
    console.log("hi");
    var rightView = [[splitView subviews] objectAtIndex:0];
    return ([subview isEqual:rightView]);
}
 
 // END split view constraint helper methods -------


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
/* -------------------------------------- */

/* ------- TABLE VIEW HELPER METHODS --------- */
- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPtableColumn)aTableColumn row:(int)aRow 
{
    return [_tableContent objectAtIndex:aRow];
}

- (int)numberOfRowsInTableView:(CPTableView)aTableView
{
    return [_tableContent count];
}

- (void)tableViewSelectionDidChange:(CPNotification)aNotification
{
    var row = [[[aNotification object] selectedRowIndexes] firstIndex];
    console.info(row);

    if (row == -1)
        console.info(@"Nothing selected");

    else 
        console.info([CPString stringWithFormat:@"selected: %@", [_tableContent objectAtIndex:row]]);
}

    //drag & drop implementation for Table View
- (BOOL)tableView:(CPTableView)aTableView writeRowsWithIndexes:(CPIndexSet)rowIndexes toPasteboard:(CPPasteboard)pasteboard
{
    var encodedData = [CPKeyedArchiver arhivedDataWithRootObject:rowIndexes];
    [pasteboard declareTypes:[CPArray arrayWithObject:TableTestDragAndDropTableViewDataType] owner:self];
    [pasteboard setData:encodedData forType:TableTestDragAndDropTableViewDataType];

    return YES;
}

- (CPDragOperation)tableView:(CPTableView)aTableView validateDrop:(id)info propsedRow:(CPInteger)row propsedDropOperation:(CPTableViewDropOperation)operation 
{
    [aTableView setDropRow:row dropOperation:CPTableViewDropAbove];
    return CPDragOperationMove;
}

- (BOOL)tableView:(CPTableView)aTableView acceptDrop:(id)info row:(CPInteger)row dropOperation:(CPTableViewDropOperation)operation
{
    var pasteboard = [info draggingPasteboard],
        encodedData = [pasteboard dataForType:TableTestDragAndDropTableViewDataType],
        sourceIndexes = [CPKeyedUnarchiver unarchiveObjectWithData:encodedData],
        firstDestinationObject,
        destinationRange,
        destinationIndexes;

    if (operation == CPTableViewDropAbove)
    {
        firstDestinationObject = [rowList objectAtIndex:[sourceIndexes firstIndex]];

        [rowList moveIndexes:sourceIndexes toIndex:row];

        destinationRange = CPMakeRange([rowList indexOfObject:firstDestinationObject], [sourceIndexes count]);
        destinationIndexes = [CPIndexSet indexSetWithIndexesInRange:destinationRange];
        [aTableView selectRowIndexes:destinationIndexes byExtendingSelection:NO];
    }

    return YES;
}


// not working - yet to fix
// - (CPView)tableView:(CPTableView)aTableView viewForTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)aRow
// {
//     var tableColumnId = [aTableColumn identifier],
//         view = [aTableView makeViewWithIdentifier:tableColumnId owner:self];

//     if (view == nil)
//     {
//         view = [[CPTableCellView alloc] initWithFrame:CGRectMakeZero()];
//         [view setIdentifier:@"Jobs"];
//     }

//     [[view textField] setStringValue:aRow];

//     return view;
// }

// - (void)tableView:(CPTableView)aTableView viewForTableColumn:(CPTableColumn)aTableColumn row:(int)aRow
// {
//     var aView = [aTableView makeViewWithIdentifier:@"workflowJob" owner:self];

//     return aView;
// }

// - (IBAction)reload:(id)aSender
// {
//     [jobsTableView reloadData];
// }

/* ------------------------------------------- */






/* ---------- OUTLINE VIEW SETUP -------------- */
- (id)outlineView:(CPOutlineView)theOutlineView child:(int)theIndex ofItem:(id)theItem
{
    if (theItem === nil)
        theItem = [self menu];

    // CPLog.debug(@"child: %i ofItem:%@ : %@", theIndex, theItem, [[theItem children] objectAtIndex:theIndex]);

    return [[theItem children] objectAtIndex:theIndex];
}

- (BOOL)outlineView:(CPOutlineView)theOutlineView isItemExpandable:(id)theItem
{
    if (theItem === nil)
        theItem = [self menu];

    // CPLog.debug(@"isItemExpandable:%@ : %@", theItem, [[theItem children] count] > 0);

    return [[theItem children] count] > 0;
}

- (int)outlineView:(CPOutlineView)theOutlineView numberOfChildrenOfItem:(id)theItem
{
    if (theItem === nil)
        theItem = [self menu];

    // CPLog.debug(@"numberOfChildrenOfItem:%@ : %i", theItem, [[theItem children] count]);

    return [[theItem children] count];
}

- (id)outlineView:(CPOutlineView)anOutlineView objectValueForTableColumn:(CPTableColumn)theColumn byItem:(id)theItem
{
    // if ([theColumn identifier] === @"Two")
    //  return @"Two";

    if (theItem === nil)
        theItem = [self menu];

    // CPLog.debug(@"objectValueForTableColumn:%@ byItem:%@ : %@", theColumn, theItem, [theItem title]);

    return [theItem title];
}

- (BOOL)outlineView:(CPOutlineView)anOutlineView writeItems:(CPArray)theItems toPasteboard:(CPPasteBoard)thePasteBoard
{
    _draggedItems = theItems;
    [thePasteBoard declareTypes:[CustomOutlineViewDragType] owner:self];
    [thePasteBoard setData:[CPKeyedArchiver archivedDataWithRootObject:theItems] forType:CustomOutlineViewDragType];

    return YES;
}

- (CPDragOperation)outlineView:(CPOutlineView)anOutlineView validateDrop:(id /*< CPDraggingInfo >*/)theInfo proposedItem:(id)theItem proposedChildIndex:(int)theIndex
{
    CPLog.debug(@"validate item: %@ at index: %i", theItem, theIndex);

    if (theItem === nil)
        [anOutlineView setDropItem:nil dropChildIndex:theIndex];

    [anOutlineView setDropItem:theItem dropChildIndex:theIndex];

    return CPDragOperationEvery;
}

- (BOOL)outlineView:(CPOutlineView)outlineView acceptDrop:(id /*< CPDraggingInfo >*/)theInfo item:(id)theItem childIndex:(int)theIndex
{
    if (theItem === nil)
        theItem = [self menu];

    // CPLog.debug(@"drop item: %@ at index: %i", theItem, theIndex);

    var menuIndex = [_draggedItems count];

    while (menuIndex--)
    {
        var menu = [_draggedItems objectAtIndex:menuIndex];

        // CPLog.debug(@"move item: %@ to: %@ index: %@", menu, theItem, theIndex);

        if (menu === theItem)
            continue;

        [menu removeFromMenu];
        [theItem insertSubmenu:menu atIndex:theIndex];
        theIndex += 1;
    }

    return YES;
}

- (int)outlineView:(CPOutlineView)outlineView heightOfRowByItem:(id)anItem
{
    if (!anItem.customHeight)
        anItem.customHeight = /*20 + RAND() * 190*/ 30;

    return anItem.customHeight;
}

/* --------------------------------------------- */


@end

@implementation CPArray (MoveIndexes)

- (void)moveIndexes:(CPIndexSet)indexes toIndex:(int)insertIndex
{
    var aboveCount = 0,
        object,
        removeIndex;

    var index = [indexes lastIndex];

    while (index != CPNotFound)
    {
        if (index >= insertIndex)
        {
            removeIndex = index + aboveCount;
            aboveCount ++;
        }
        else
        {
            removeIndex = index;
            insertIndex --;
        }

        object = [self objectAtIndex:removeIndex];
        [self removeObjectAtIndex:removeIndex];
        [self insertObject:object atIndex:insertIndex];

        index = [indexes indexLessThanIndex:index];
    }
}

@end

