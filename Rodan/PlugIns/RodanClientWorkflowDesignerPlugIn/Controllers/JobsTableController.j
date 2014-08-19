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

}

- (void)awakeFromCib
{
    [[CPNotificationCenter defaultCenter] addObserver:self
                                    selector:@selector(receiveDidLoadJobs:)
                                    name:RodanDidLoadJobsNotification
                                    object:nil];

    [jobController fetchJobs];

    [jobsTableView setDataSource:self];
    [jobsTableView registerForDraggedTypes:[CPArray arrayWithObjects:JobsTableDragAndDropTableViewDataType]];

}

- (void)receiveDidLoadJobs:(CPNotification)aNotification
{

}

- (void)tableViewSelectionDidChange:(CPNotification)aNotification
{
    var row = [[[aNotification object] selectedRowIndexes] firstIndex];

    if (row === -1)
        console.info(@"Nothing selected");
    else
        console.info([CPString stringWithFormat:@"selected: %@", [[jobArrayController contentArray] objectAtIndex:row]]);
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
    return [[jobArrayController contentArray] count];
}

@end
