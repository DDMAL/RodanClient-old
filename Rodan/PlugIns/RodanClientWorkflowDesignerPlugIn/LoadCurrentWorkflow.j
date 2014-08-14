@import <RodanKit/RodanKit.j>

@implementation LoadCurrentWorkflow : CPObject
{
    @outlet     CPArray         workflowJobs        @accessors;
    @outlet     CPArray         links               @accessors;
    @outlet     CPArray         resourceLists       @accessors;
}

- (void)awakeFromCib
{
    console.log(workflowJobs);
    console.log(links);
    console.log(resourceLists);
}

@end