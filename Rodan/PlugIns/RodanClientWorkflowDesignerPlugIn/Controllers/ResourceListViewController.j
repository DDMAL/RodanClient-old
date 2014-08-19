@import <Foundation/Foundation.j>

@import "OutputPortViewController.j"
@import "../Views/OutputPortView.j"

@import "../Views/ResourceListView.j"
@import "ConnectionViewController.j"


@implementation ResourceListViewController : CPObject
{
    CPUInteger          numberOfPages       @accessors;
    CPArrayController   outputPorts         @accessors;
    CPUInteger          outputNum           @accessors;
    CPArray             outputPortTypes     @accessors;

    CPArrayController   resources           @accessors;

    //associated view
    ResourceListView    resourceListView    @accessors;

    ConnectionViewController connection     @accessors;

}

- (id)initWithOutputNumber:(CPUInteger)aNumber outputPortTypes:(CPArray)oPortTypes
{
    self = [super init];

    if (self)
    {
        outputPorts = [[CPArrayController alloc] init];
        outputPortTypes = [[CPArray alloc] init];
        outputNum = aNumber;

        outputPortTypes = oPortTypes;

    }
    return self;
}

- (void)createResourceListViewWithPoint:(CGPoint)aPoint
{
    resourceListView = [[ResourceListView alloc] initWithPoint:aPoint outputNum:outputNum];
}


- (void)createOutputPortsAtPoint:(CGPoint)aPoint
{
    var resourceListSize = [resourceListView resourceListSize],
        subsection = resourceListSize.width,
        contentArray = [outputPorts contentArray];

    for (var i = 0; i < outputNum; i++)
    {
        var outputPortViewController = [[OutputPortViewController alloc] initWithType:outputPortTypes[i]
                                                                       workflowJobRef:nil
                                                                      resourceListRef:self];
        contentArray[i] = outputPortViewController;

        var outputPortView = [[OutputPortView alloc] initWithPoint:aPoint
                                                              size:resourceListSize
                                                        subsection:subsection
                                                         iteration:i
                                       outputPortViewControllerRef:outputPortViewController];

        [contentArray[i] setOutputPortView:outputPortView];
    }
}

- (void)createAssociatedViewsAtPoint:(CGPoint)aPoint
{
    [self createResourceListViewWithPoint:aPoint];
    [self createOutputPortsAtPoint:aPoint];
}


@end