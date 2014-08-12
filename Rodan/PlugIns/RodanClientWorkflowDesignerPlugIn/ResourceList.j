@import <AppKit/CPWindowController.j>
@import <Foundation/CPObject.j>

@import "OutputPortView.j"

@implementation ResourceList : CPView
{
    CPBox               resourceList        @accessors;
    CPUInteger          numberOfPages       @accessors;
    CPArray             outputPorts         @accessors;
    CPUInteger          outputNum           @accessors;

    CPArray             pages               @accessors;

    CPButton            attributesButton    @accessors;

    CPView              infoView            @accessors;
    CPUInteger          listRef             @accessors;

    BOOL                _firstResponder;

}

- (id)initWithPoint:(CGPoint)aPoint size:(CGSize)aSize pageNum:(CPUInteger)pageNum resourceListRef:(CPUInteger)aSeedRef outputNum:(CPUInteger)aNum
{
    var aRect = CGRectMake(aPoint.x, aPoint.y, aSize.height, aSize.width);
    self = [super initWithFrame:aRect];
    // self = [super initWithFrame:CGRectMake(aPoint.x, aPoint.y, aSize.height + 100, aSize.width + 100.0)];


    if (self)
    {
        resourceList = [[CPBox alloc] initWithFrame:aRect];
        outputPorts = [[CPArray alloc] init];
        listRef = aSeedRef;
        outputNum = aNum;

        var subsection = aSize.width;

        //create outputports on resourceList

        for (var i = 0; i < outputNum; i++)
        {
            outputPorts[i] = [[OutputPortView alloc] init:aPoint size:aSize type:"resourceList" subsection:subsection iteration:i workflowJobID:-1 resourceListID:listRef];
        }

        // attributesButton = [[CPButton alloc] initWithFrame:CGRectMake(12.5, 2.5, 7.5, 7.5)];

        [self addSubview:resourceList];
        [self setBounds:aRect];
        // [self addSubview:attributesButton];

        [infoView = [[CPView alloc] initWithFrame:CGRectMake(aPoint.x + aSize.height, aPoint.y, 55.0, 20.0)]];
        [infoView setBackgroundColor:[CPColor colorWithHexString:"FFFF99"]];
        var label = [[CPTextField alloc] initWithFrame:CGRectMake(aPoint.x + aSize.height, aPoint.y, 55.0, 20.0)];
        [label setStringValue:"Pages: "];

    }
    return self;
}

- (void)changeBoxAttributes:(float)borderWidth cornerRadius:(float)cornerRadius fillColor:(CPColor)aColor boxType:(CPBoxType)type title:(CPString)aTitle
{
        [resourceList setBorderWidth:borderWidth];
        [resourceList setCornerRadius:cornerRadius];
        [resourceList setFillColor:aColor];
        [resourceList setBoxType:type];
        [resourceList setBorderColor:[CPColor colorWithHexString:"CC3300"]];
        [resourceList setTitle:aTitle];
        // [resourceList setTitlePosition:6];
}

- (void)mouseEntered:(CPEvent)anEvent
{
    [resourceList setBorderColor:[CPColor colorWithHexString:"FF9933"]];
    [self addSubview:infoView];
}

- (void)mouseExited:(CPEvent)anEvent
{
    if (!_firstResponder)
    {
        [resourceList setBorderColor:[CPColor colorWithHexString:"CC3300"]];
        [infoView removeFromSuperview];
    }
}

- (void)mouseDown:(CPEvent)anEvent
{
    console.log("resourceList");
    //for key down events
    [[self window] makeFirstResponder:self];
}

- (void)mouseDragged:(CPEvent)anEvent
{
    [[CPNotificationCenter defaultCenter] postNotificationName:@"ResourceListViewIsBeingDraggedNotification" object:nil userInfo:[[CPDictionary alloc] initWithObjects:[listRef, anEvent] forKeys:[@"resource_list_position", @"event"]]];

}

//key down events - (delete function)
- (BOOL)acceptsFirstResponder
{
    _firstResponder = YES;
    return YES;
}

- (BOOL)resignFirstResponder
{
    [resourceList setBorderColor:[CPColor colorWithHexString:"CC3300"]];
    [resourceList setBorderWidth:2.0];

    _firstResponder = NO;
    return YES;
}

- (void)keyDown:(CPEvent)anEvent
{
    var key = [[anEvent charactersIgnoringModifiers] characterAtIndex:0];
    if (key == CPDeleteCharacter)
    {
        // ask user
         var alert = [CPAlert alertWithMessageText:@"Are you sure you want to delete this resource list? This action cannot be undone."
                                    defaultButton:@"Cancel"
                                  alternateButton:@"Yes"
                                      otherButton:nil
                        informativeTextWithFormat:nil];

        [alert setDelegate:self];
        [alert runModal];
    }
}

- (void)alertDidEnd:(CPAlert)theAlert returnCode:(int)returnCode
{
    if (returnCode == 1) //second button (YES)
    {
        [[CPNotificationCenter defaultCenter] postNotificationName:@"ResourceListIsBeingDeletedNotification" object:nil userInfo:[[CPDictionary alloc] initWithObjects:[listRef] forKeys:[@"resource_list_number"]]];
    }
}

@end