@import <LPKit/LPMultiLineTextField.j>

@import "../Views/WorkflowCollectionView.j"

@global RodanShouldLoadWorkflowDesignerNotification
@global RodanRemoveJobFromWorkflowNotification

JobItemType = @"JobItemType";
activeWorkflow = nil;

@implementation WorkflowDesignerController : CPObject
{
    @outlet     CPTableView             jobList;
    @outlet     CPView                  jobInfoParentView;
    @outlet     LPMultiLineTextField    jobInfo;
    @outlet     CPTableView             workflowList;
    @outlet     WorkflowCollectionView  workflowDesign;
    @outlet     CPArrayController       workflowArrayController;
    @outlet     CPArrayController       jobArrayController;

    @outlet     CPArrayController       currentWorkflow;
    @outlet     CPMutableArray          currentWorkflowContentArray;
}

- (void)awakeFromCib
{
    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(shouldLoadWorkflow:)
                                          name:RodanShouldLoadWorkflowDesignerNotification
                                          object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(removeJobFromWorkflow:)
                                          name:RodanRemoveJobFromWorkflowNotification
                                          object:nil];


    currentWorkflowContentArray = [[CPArray alloc] init];
    [workflowList setBackgroundColor:[CPColor colorWithHexString:@"DEE3E9"]];
    [jobList setBackgroundColor:[CPColor colorWithHexString:@"DEE3E9"]];

    // The actual data source for jobList is an array controller, but cappuccino
    // expects a number of methods for Drag n Drop on its datasource method,
    // so we'll need to do it partially in code.
    var jobListDataDelegate = [[JobListDelegate alloc] init];

    [jobList setDataSource:jobListDataDelegate];
    [workflowDesign setDelegate:self];

    var bgImg = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"workflow-backgroundTexture.png"]
                             size:CGSizeMake(135, 135)],
        bounds = [workflowDesign bounds];

    [workflowDesign setMinItemSize:CGSizeMake(bounds.size.width - 20, 80)];
    [workflowDesign setMaxItemSize:CGSizeMake(bounds.size.width - 20, 80)];
    [workflowDesign setBackgroundColor:[CPColor colorWithPatternImage:bgImg]];
    [workflowDesign setContent:currentWorkflowContentArray];
    [workflowDesign registerForDraggedTypes:[JobItemType]];
}

- (IBAction)addObject:(id)aSender
{
}

- (IBAction)removeJobFromWorkflow:(CPNotification)aSender
{
    [currentWorkflow removeObject:[[aSender object] representedObject]];
}

- (CPData)collectionView:(CPCollectionView)collectionView dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)aType
{
    console.log("Coll view");
}

- (BOOL)collectionView:(CPCollectionView)collectionView acceptDrop:(CPDraggingInfo)info index:(int)anIndex dropOperation:(int)aDropOperation
{
    // console.log("Accept Drop");
    var pboard = [info draggingPasteboard],
        rowData = [pboard dataForType:JobItemType],
        dragRows = [CPKeyedUnarchiver unarchiveObjectWithData:rowData],
        rowIdx = [dragRows firstIndex],
        jobObj = [[jobArrayController contentArray] objectAtIndex:rowIdx];


    var input_types = JSON.parse([jobObj inputTypes]),
        output_types = JSON.parse([jobObj outputTypes]);

    // Check to see if this job can fit in with the next or previous ones
    var input_pixel_types = [CPSet setWithArray:input_types.pixel_types],
        output_pixel_types = [CPSet setWithArray:output_types.pixel_types],
        input_type_passes = NO,
        output_type_passes = NO;


    if ([[currentWorkflow contentArray] count] == 0)
    {
        // we can't fail because we don't have anything to check against
        // console.log("Empty content array");
        input_type_passes = YES;
        output_type_passes = YES;
    }
    else
    {
        // check the previous item in the content array
        if (anIndex == 0)  // we're trying to insert it at the beginning
        {
            // console.log("At the beginning?");
            input_type_passes = YES;
        }
        else
        {
            var previousObject = [[currentWorkflow contentArray] objectAtIndex:anIndex - 1],
                prevObjJobId = [previousObject job];

            var prevJobIdx = [[jobArrayController contentArray] indexOfObjectPassingTest:function(obj, idx)
                {
                    return [obj pk] == prevObjJobId;
                }];

            var previousJob = [[jobArrayController contentArray] objectAtIndex:prevJobIdx],
                prevOutputTypes = JSON.parse([previousJob outputTypes]),
                prevOutputSet = [CPSet setWithArray:prevOutputTypes.pixel_types];

            // console.log("Previous Job");
            // console.log(prevOutputSet);
            // console.log("This Job");
            // console.log(input_pixel_types);

            if ([prevOutputSet intersectsSet:input_pixel_types])
                input_type_passes = YES;
        }

        if (anIndex == [[currentWorkflow contentArray] count])
        {
            // we're appending to the end, so the output type should pass
            // console.log("At the end?");
            output_type_passes = YES;
        }
        else
        {
            var nextObject = [[currentWorkflow contentArray] objectAtIndex:anIndex + 1],
                nextObjJobId = [nextObject job];

            var nextJobIdx = [[jobArrayController contentArray] indexOfObjectPassingTest:function(obj, idx)
                {
                    return [obj pk] == nextObjJobId;
                }];

            var nextJob = [[jobArrayController contentArray] objectAtIndex:nextJobIdx],
                nextInputTypes = JSON.parse([nextJob inputTypes]),
                nextInputSet = [CPSet setWithArray:nextInputTypes.pixel_types];

            if ([nextInputSet intersectsSet:output_pixel_types])
                output_type_passes = YES;
        }
    }

    // do not permit a drop if either the input or the output passes
    if (!input_type_passes || !output_type_passes)
    {
        return NO;
    }

    // The JSON field module we're using likes setting an empty dictionary
    // as a placeholder for fields with no values. We always want to have
    // this set as an array, even if it is blank.
    if ([jobObj arguments] === "{}")
        var jobSettings = "[{}]";
    else
        var jobSettings = [jobObj arguments];

    // create a workflow job JSON object for this new job.
    var wkObj = {
            "workflow": [activeWorkflow pk],
            "job": [jobObj pk],
            "job_settings": jobSettings,
            "sequence": anIndex
            };

    var workflowJobObject = [[WorkflowJob alloc] initWithJson:wkObj];
    [workflowJobObject ensureCreated];

    [currentWorkflow insertObject:workflowJobObject atArrangedObjectIndex:anIndex];

    return YES;
}

- (IBAction)selectWorkflow:(id)aSender
{
    activeWorkflow = [[workflowArrayController selectedObjects] objectAtIndex:0];

    [[CPNotificationCenter defaultCenter] postNotificationName:RodanShouldLoadWorkflowDesignerNotification
                                          object:nil];
}

- (void)shouldLoadWorkflow:(CPNotification)aNotification
{
    console.log("I should load the jobs for workflow " + [activeWorkflow pk]);

}

@end


@implementation JobItemView : CPView
{
    @outlet     CPString    jobName             @accessors;
    @outlet     CPTextField jobNameField        @accessors;

    @outlet     CPButton    closeButton;
                id          representedObject   @accessors;
}

- (id)initWithCoder:(CPCoder)aCoder
{
    var self = [super initWithCoder:aCoder];
    if (self)
    {
        var frame = [self frame],
            controlHeight = (frame.size.height - 30) / 2;

        jobNameField = [[CPTextField alloc] initWithFrame:CPMakeRect(frame.size.width - 320,
                                                                     5,
                                                                     300,
                                                                     22)];
        [jobNameField setAlignment:CPRightTextAlignment];
        [jobNameField setAutoresizingMask:CPViewMinXMargin];
        [jobNameField setEditable:NO];
        [jobNameField setBordered:NO];
        [jobNameField setDrawsBackground:NO];

        [self addSubview:jobNameField];
    }

    return self;
}

- (void)setJobName:(CPString)aTitle
{
    jobName = aTitle;
    [jobNameField setObjectValue:jobName];
}

- (void)setRepresentedObject:(CPString)anObject
{
    if (anObject === nil)
        return;

    console.log(anObject);

    representedObject = anObject;
}

- (IBAction)removeSelfFromWorkflow:(id)aSender
{
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanRemoveJobFromWorkflowNotification
                                          object:self];
}

@end


@implementation JobListDelegate : CPObject
{
}

- (BOOL)tableView:(CPTableView)aTableView writeRowsWithIndexes:(CPIndexSet)rowIndexes toPasteboard:(CPPasteboard)pboard
{
    var data = [CPKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[CPArray arrayWithObject:JobItemType] owner:self];
    [pboard setData:data forType:JobItemType];

    return YES;
}

- (void)pasteboard:(CPPasteboard)pboard provideDataForType:(CPString)aType
{
    console.log("Provide data for type");
}

- (int)numberOfRowsInTableView:(id)aTableView
{
    //pass
}
@end
