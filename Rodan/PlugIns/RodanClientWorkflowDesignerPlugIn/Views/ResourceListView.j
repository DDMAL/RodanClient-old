@import <AppKit/CPWindowController.j>
@import <Foundation/CPObject.j>

@import "OutputPortView.j"
@import "../Controllers/ResourceListViewController.j"

var DEFAULT_SIZE = CGRectMake(30.0, 30.0);

@implementation ResourceListView : CPView
{
    CPBox                       resourceList                @accessors;
    CGRect                      resourceListSize            @accessors;
    CPUInteger                  outputNum                   @accessors;

    CPView                      infoView                    @accessors;

    BOOL                        _firstResponder;

    ResourceListViewController  resourceListViewController  @accessors;
}


- (id)initWithPoint:(CGPoint)aPoint outputNum:(CPUInteger)aNumber
{
    var aRect = CGRectMake(aPoint.x, aPoint.y, resourceListSize.height, resourceListSize.width);
    self = [super initWithFrame:aRect];

    if (self)
    {
        resourceList = [[CPBox alloc] initWithFrame:aRect];
        outputNum = aNumber;

        [resourceListsContentArray[i] changeBoxAttributes:2 cornerRadius:5 fillColor:[CPColor colorWithHexString:"333333"] boxType:CPBoxPrimary title:"Resource List A"];

        [self addSubview:resourceList];
        [self setBounds:aRect];

        [infoView = [[CPView alloc] initWithFrame:CGRectMake(aPoint.x + resourceListSize.height, aPoint.y, 55.0, 20.0)]];
        [infoView setBackgroundColor:[CPColor colorWithHexString:"FFFF99"]];
        var label = [[CPTextField alloc] initWithFrame:CGRectMake(aPoint.x + resourceListSize.height, aPoint.y, 55.0, 20.0)];
        [label setStringValue:"Resources: "];

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