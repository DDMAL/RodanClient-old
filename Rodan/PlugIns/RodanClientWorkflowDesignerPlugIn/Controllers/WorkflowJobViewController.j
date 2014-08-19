@import <Foundation/Foundation.j>

@import <RodanKit/WorkflowJob.j>
@import "InputPortViewController.j"
@import "OutputPortViewController.j"
@import "../Views/WorkflowJobView.j"
@import "../Views/OutputPortView.j"
@import "../View/InputPortView.j"



@implementation WorkflowJobViewController : CPObject
{
    CPUInteger              outputPortNumber            @accessors;
    CPUInteger              inputPortNumber             @accessors;

    CPArrayController       inputPorts                  @accessors;
    CPArrayController       outputPorts                 @accessors;

    WorkflowJob             workflowJob                 @accessors;
    CPObject                associatedJob               @accessors;

    //associated view
    WorkflowJobView         workflowJobView             @accessors;

    CPString                workflowJobType             @accessors;

}

- (id)initWithJob:(CPObject)aJob
{
    if (self = [super init])
    {
        inputPorts = [[CPArrayController alloc] init];
        outputPorts = [[CPArrayController alloc] init];

        associatedJob = aJob;

        var inputPortTypes = [aJob inputPortTypes],
            outputPortTypes = [aJob outputPortTypes],

            totalOutputNum = 0,
            totalInputNum = 0,

            jobType = aJob.jobType;

        workflowJobType = jobType;

        //NOTE: using minimum for defuault instance
        var inputLoop = [inputPortTypes count],
            outputLoop = [outputPortTypes count];

        for (var i = 0; i < inputLoop; i++)
            totalInputNum += inputPortTypes[i].minimum;

        for (var j = 0; j < outputLoop; j++)
            totalOutputNum += outputPortTypes[j].minimum;

        outputPortNumber = totalOutputNum;
        inputPortNumber = totalInputNum;
    }

    return self;
}
// -------------------- LOCAL METHODS --------------------------- //

- (void)createWorkflowJobViewWithPoint:(CGPoint)aPoint
{
    var portNumber = (outputPortNumber > inputPortNumber) ? outputPortNumber : inputPortNumber;

    workflowJobView = [[WorkflowJobView alloc] initWithpoint:aPoint
                                       withInitialPortNumber:portNumber
                                    workflowJobControllerRef:self];

}

- (void)createInputPorts:(CGPoint)aPoint
{
    var inputPortTypes = [associatedJob inputPortTypes],
        inputLoop = [inputPortTypes count],
        workflowJobSize = [workflowJobView workflowJobSize],
        subsection = (workflowJobSize.width / inputPortNumber),
        counter = 0,
        resourceType,
        innerLoopCount,
        contentArray = [inputPorts contentArray];

    for (var i = 0; i < inputLoop; i++)
    {
        innerLoopCount = inputPortTypes[i].minimum;
        for (var k = 0; k < innerLoopCount; k++)
        {
            resourceType = inputPortTypes[i].resourceType;
            var inputPortViewController  = [[InputPortViewController alloc] initWithType:resourceType
                                                                          workflowJobRef:self];

            contentArray[counter] = inputPortViewController;

            //create associated inputPort View
            var inputPortView = [[InputPortView alloc] initWithPoint:aPoint
                                                                size:workflowJobSize
                                                          subsection:subsection
                                                           iteration:counter
                                          inputPortViewControllerRef:inputPortViewController];

            [contentArray[counter] setInputPortView:inputPortView];
            counter++;
        }
    }
}

- (void)createOutputPorts:(CGPoint)aPoint
{
    var outputPortTypes = [associatedJob outputPortTypes],
        outputLoop = [outputPortTypes count],
        workflowJobSize = [workflowJobView workflowJobSize],
        subsection = (workflowJobSize.width / outputPortNumber),
        counter = 0,
        resourceType,
        innerLoopCount,
        contentArray = [outputPorts contentArray];

    for (var i = 0; i < outputLoop; i++)
    {
        innerLoopCount = outputPortTypes[i].minimum;
        for (var k = 0; k < innerLoopCount; k++)
        {
            resourceType = outputPortTypes[i].resourceType;
            var outputPortViewController = [[OutputPortViewController alloc] initWithType:resourceType
                                                                           workflowJobRef:self
                                                                          resourceListRef:nil];

            contentArray[counter] = outputPortViewController;

            //create associated inputPort View
            var outputPortView = [[OutputPortView alloc] initWithPoint:aPoint
                                                                  size:workflowJobSize
                                                            subsection:subsection
                                                             iteration:counter
                                           outputPortViewControllerRef:outputPortViewController];

            [contentArray[counter] setOutputPortView:outputPortView];
            counter++;
        }
    }
}

- (void)createAssociatedViewsAtPoint:(CGPoint)aPoint
{
    [self createWorkflowJobViewWithPoint:aPoint];
    [self createInputPorts:aPoint];
    [self createOutputPorts:aPoint];
}

@end