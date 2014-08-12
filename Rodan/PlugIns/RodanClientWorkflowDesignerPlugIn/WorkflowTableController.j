@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@import <RodanKit/Controllers/WorkflowController.j>
@import <RodanKit/Models/Workflow.j>


@global RodanDidLoadWorkflowsNotification
@global RodanDidLoadWorkflowNotification

var _msLOADINTERVAL = 3.0;

@implementation WorkflowTableController : CPObject
{
    @outlet             CPTableView         workflowsTableView;

    @outlet             WorkflowController  workflowController;
    @outlet             CPArrayController   workflowArrayController;
    @outlet             CPArray             workflowContentArray;

    @outlet             CPButton            createWorkflow;
    @outlet             CPButton            selectWorkflow;
    @outlet             CPButton            removeWorkflow;

                        CPBundle            theBundle;

    @outlet             Workflow            currentWorkflow;
    @outlet             CPTextField         selectedWorkflowLabel;

}

- (void)awakeFromCib
{
    workflowController = [[CPApplication sharedApplication] delegate].workflowController;
    currentWorkflow = [[CPApplication sharedApplication] delegate].workflowController.currentWorkflow;
    [selectedWorkflowLabel setStringValue:""];

    [workflowsTableView setDataSource:self];

    theBundle = [CPBundle bundleWithPath:@"PlugIns/RodanClientWorkflowDesignerPlugIn"];


    //init button images
    var addImage = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:"plus.png"] size:CGSizeMake(20.0, 20.0)];
    [createWorkflow setImage:addImage];
    [createWorkflow setBordered:NO];

    var minusImage = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:"minus.png"] size:CGSizeMake(20.0, 20.0)];
    [removeWorkflow setImage:minusImage];
    [removeWorkflow setBordered:NO];

    var selectImage = [[CPImage alloc] initWithContentsOfFile:[theBundle pathForResource:"checkbox-checked.png"] size:CGSizeMake(20.0, 20.0)];
    [selectWorkflow setImage:selectImage];
    [selectWorkflow setBordered:NO];

    //set up button actions
    [createWorkflow setAction:@selector(addWorkflowAction:)];
    [createWorkflow setTarget:self];

    [removeWorkflow setAction:@selector(removeWorkflowAction:)];
    [removeWorkflow setTarget:self];

    [selectWorkflow setAction:@selector(selectWorkflowAction:)];
    [selectWorkflow setTarget:self];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveDidLoadWorkflows:)
                                          name:RodanDidLoadWorkflowsNotification
                                          object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveDidLoadWorkflow:)
                                          name:RodanDidLoadWorkflowNotification
                                          object:nil];

    //create timed notification to continuously pull info from workflow controller
    [RKNotificationTimer setTimedNotification:_msLOADINTERVAL
                                 notification:RodanRequestWorkflowsNotification];

}

- (void)receiveDidLoadWorkflows:(CPNotification)aNotification
{
    workflowContentArray = [workflowController.workflowArrayController contentArray];
    [workflowArrayController setContent:workflowContentArray];
}

- (void)receiveDidLoadWorkflow:(CPNotification)aNotification
{
    currentWorkflow = workflowController.currentWorkflow;
    [selectedWorkflowLabel setStringValue:[currentWorkflow workflowName]];
}


- (int)numberOfRowsInTableView:(CPTableView)aTableView
{
    [workflowContentArray count];
}

- (void)tableViewSelectionDidChange:(CPNotification)aNotification
{
    var row = [[[aNotification object] selectedRowIndexes] firstIndex];
    console.info(row);

    if (row == -1)
        console.info(@"Nothing selected");

    else
        console.info([CPString stringWithFormat:@"selected: %@", [workflowContentArray objectAtIndex:row].workflowName]);
}


// ------------------------------------------------------------- //
// ------------------ BUTTON ACTIONS --------------------------- //

- (void)addWorkflowAction:(id)aSender
{
    [workflowController newWorkflow];
}

- (void)removeWorkflowAction:(id)aSender
{
    var selectedObjects = [workflowArrayController selectedObjects];
    [workflowController removeWorkflow:selectedObjects];
}

- (void)selectWorkflowAction:(id)aSender
{
    //sets current workflow as selected
    var selectionIndexes = [workflowArrayController selectionIndexes];
    if ([selectionIndexes count] > 1)
    {
        var alert = [CPAlert alertWithMessageText:@"Only one workflow can be selected to work with"
                                    defaultButton:@"Okay"
                                  alternateButton:nil
                                        otherButton:nil
                        informativeTextWithFormat:nil];

        [alert setDelegate:self];
        [alert runModal];
    }
    else
    {
        [workflowController fetchWorkflow:[selectionIndexes firstIndex]];
    }

}


@end