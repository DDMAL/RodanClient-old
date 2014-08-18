@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>


ResourcesTableDragAndDropTableViewDataType = @"ResourcesTableDragAndDropTableViewDataType";

@global RodanDidLoadResourcesNotification

@implementation ResourceTableController : CPObject
{
    @outlet             CPTableView             resourceTableView;

    @outlet             CPArrayController       resourceController;
    @outlet             CPArray                 resourceTableContent;
}

- (void)awakeFromCib
{
    [[CPNotificationCenter defaultCenter] addObserver:self
                                    selector:@selector(receiveDidLoadResources:)
                                    name:RodanDidLoadResourcesNotification
                                    object:nil];

    //fetch resources that have been added


    [resourceTableView setDataSource:self];
    [resourceTableView registerForDraggedTypes:[CPArray arrayWithObjects:ResourcesTableDragAndDropTableViewDataType]];


}

- (BOOL)tableView:(CPTableView)aTableView writeRowsWithIndexes:(CPIndexSet)rowIndexes toPasteboard:(CPPasteboard)pasteboard
{
    [pasteboard declareTypes:[CPArray arrayWithObject:ResourcesTableDragAndDropTableViewDataType] owner:self];
    [pasteboard setData:rowIndexes forType:ResourcesTableDragAndDropTableViewDataType];

    return YES;
}

- (void)tableViewSelectionDidChange:(CPNotification)aNotification
{
    var row = [[[aNotification object] selectedRowIndexes] firstIndex];
    console.info(row);

    if (row == -1)
        console.info(@"Nothing selected");

    else
        console.info([CPString stringWithFormat:@"selected: %@", [resourceTableContent objectAtIndex:row]]);
}

- (int)numberOfRowsInTableView:(CPTableView)aTableView
{
    return [resoureTableContent count];
}

// - (void)tableView:(CPTableView)aTableView viewForTableColumn:(CPTableColumn)aTableColumn row:(CPUInteger)aRow
// {
//     var tableColumnID = [aTableColumn identifier],

//         view = jobA;
//         // view = [aTableView makeViewWithIdentifier:"JOBA" owner:self];

//     if (view = nil)
//     {
//         view = [[CPTableCellView alloc] initWithFrame:CGRectMakeZero()];
//         [view setIdentifier:"JOBA"];
//     }

//     [view setObjectValue:("Column " + tableColumnID + " Row " + aRow )];

//     return view;
// }

@end