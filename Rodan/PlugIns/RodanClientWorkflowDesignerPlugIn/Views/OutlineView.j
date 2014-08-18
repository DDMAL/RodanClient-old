@import <Foundation/CPObject.j>
@import "Menu.j"

CustomOutlineViewDragType = @"CustomOutlineViewDragType";

@implementation OutlineView : CPObject
{
                        Menu                    _menu @accessors(property=menu);
    @outlet             CPOutlineView           _outlineView;
                        CPArray                 _draggedItems;
    @outlet             CPTableColumn           column;
}

- (void)awakeFromCib
{

     _menu = [Menu menuWithTitle:@"Top" children:[
        [Menu menuWithTitle:@"Seed A" children:[
            [Menu menuWithTitle:@"GreyScale" children:[
                [Menu menuWithTitle:@"Niblack Threshold"],
                [Menu menuWithTitle:@"Crop Border Removal"],
            ]],
            [Menu menuWithTitle:@"Rdn Despeckle" children:[
                [Menu menuWithTitle:@"To Onebit" children:[
                    [Menu menuWithTitle:@"Crop Border Removal"],
                    [Menu menuWithTitle:@"Niblack Threshold"],
                    [Menu menuWithTitle:@"GreyScale"],
                ]],
                [Menu menuWithTitle:@"Binarization"],
                [Menu menuWithTitle:@"Crop Border Removal"]
            ]]
        ]],
         [Menu menuWithTitle:@"Seed B" children:nil],
         [Menu menuWithTitle:@"Seed C" children:[
          [Menu menuWithTitle:@"Mean Filter" children:[
              [Menu menuWithTitle:@"Niblack Threshold"],
              [Menu menuWithTitle:@"To Onebit"],
              [Menu menuWithTitle:@"Crop Border Removal"],
          ]],
          [Menu menuWithTitle:@"To Onebit" children:[
              [Menu menuWithTitle:@"Weiner Filter"],
              [Menu menuWithTitle:@"Lyric Extraction"],
              [Menu menuWithTitle:@"Paper Estimation"],
              [Menu menuWithTitle:@"Edge Detection"],
          ]],
          [Menu menuWithTitle:@"To Float" children:[
              [Menu menuWithTitle:@"To Rgb"],
              [Menu menuWithTitle:@"Segmentation"],
              [Menu menuWithTitle:@"Grey Convert"],
              [Menu menuWithTitle:@"Resize"],
              [Menu menuWithTitle:@"Lyric Line Fit"],
          ]]
         ]]
    ]];

    [_outlineView addTableColumn:column];
    //[_outlineView setOutlineTableColumn:column];
    setTimeout(function(){
    [column setWidth:50];
    },0);

    // [_outlineView addTableColumn:[[CPTableColumn alloc] initWithIdentifier:@"Two"]];
    // [_outlineView addTableColumn:[[CPTableColumn alloc] initWithIdentifier:@"Three"]];

    // [_outlineView registerForDraggedTypes:[CustomOutlineViewDragType]];

    [_outlineView setDataSource:self];
    [_outlineView setDelegate:self];
    // [_outlineView setAllowsMultipleSelection:YES];
    [_outlineView expandItem:nil expandChildren:YES];
    // [_outlineView setRowHeight:50.0];
    // [_outlineView setIntercellSpacing:CGSizeMake(0.0, 10.0)]

    // [column setWidth:CGRectGetWidth([_outlineView bounds])];
}


// ------------------------------------------- //
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