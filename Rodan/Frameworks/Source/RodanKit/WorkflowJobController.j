@import <AppKit/CPAlert.j>
@import "RKController.j"
@import "WorkflowJob.j"

RodanDidLoadWorkflowJobNotification = @"RodanDidLoadWorkflowJobNotification"

@implementation WorkflowJobController : RKController
{
    @outlet     CPArrayController       currentWorkflowJobsArrayController;
}

- (void)awakeFromCib
{
    currentWorkflowJobsArrayController = [[CPArrayController alloc] init];
}


- (void)remoteActionDidFinish:(WLRemoteAction)anAction
{
    //fetch workflowjob response

    var workflowJob = [WorkflowJob objectsFromJson:[anAction result]];

    [currentWorkflowJobsArrayController addObject:workflowJob];

    [[CPNotificationCenter defaultCenter] postNotificationName:RodanDidLoadWorkflowJobNotification
                                                        object:[anAction result]];
}

- (void)fetchWorkflowJob:(CPString)aUUID
{
    [WLRemoteAction schedule:WLRemoteActionGetType
                        path:[self serverHost] + "/workflowjob" + aUUID + "/"
                    delegate:self
                     message:"Loading WorkflowJob"
             withCredentials:YES];
}

@end