@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import <RodanKit/JobController.j>

@global RodanDidLoadJobsNotification

JobsTableDragAndDropTableViewDataType = @"JobsTableDragAndDropTableViewDataType";

@implementation JobsTableController : CPObject
{
    @outlet             CPTableView                 jobsTableView;

    @outlet             JobController               jobController;
    @outlet             CPArrayController           jobArrayController;
    @outlet             CPArray                     jobContentArray;
}

- (void)awakeFromCib
{
    [[CPNotificationCenter defaultCenter] addObserver:self
                                    selector:@selector(receiveDidLoadJobs:)
                                    name:RodanDidLoadJobsNotification
                                    object:nil];

    jobController = [[CPApplication sharedApplication] delegate].jobController;
    [jobController fetchJobs];

    [jobsTableView setDataSource:self];
    [jobsTableView registerForDraggedTypes:[CPArray arrayWithObjects:JobsTableDragAndDropTableViewDataType]];

}

- (void)receiveDidLoadJobs:(CPNotification)aNotification
{
   jobContentArray = [jobController.jobArrayController contentArray];
   [jobArrayController addObjects:jobContentArray];
}

- (void)tableViewSelectionDidChange:(CPNotification)aNotification
{
    var row = [[[aNotification object] selectedRowIndexes] firstIndex];
    console.info(row);

    if (row === -1)
        console.info(@"Nothing selected");
    else
        console.info([CPString stringWithFormat:@"selected: %@", [jobContentArray objectAtIndex:row]]);
}

    //drag & drop implementation for Table View
- (BOOL)tableView:(CPTableView)aTableView writeRowsWithIndexes:(CPIndexSet)rowIndexes toPasteboard:(CPPasteboard)pasteboard
{
    [pasteboard declareTypes:[CPArray arrayWithObject:JobsTableDragAndDropTableViewDataType] owner:self];
    [pasteboard setData:rowIndexes forType:JobsTableDragAndDropTableViewDataType];

    return YES;
}

- (int)numberOfRowsInTableView:(CPTableView)aTableView
{
    return [jobContentArray count];
}

@end
