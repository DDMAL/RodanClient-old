
@import <Foundation/CPObject.j>

// Controllers
@import "Controllers/AbstractController.j"
@import "Controllers/JobController.j"

// Models
@import "Models/Connection.j"
@import "Models/Input.j"
@import "Models/InputPort.j"
@import "Models/InputPortType.j"
@import "Models/Job.j"
@import "Models/Output.j"
@import "Models/OutputPort.j"
@import "Models/OutputPortType.j"
@import "Models/Page.j"
@import "Models/Project.j"
@import "Models/Resource.j"
@import "Models/Result.j"
@import "Models/ResultsPackage.j"
@import "Models/RunJob.j"
@import "Models/TreeNode.j"
@import "Models/User.j"
@import "Models/Workflow.j"
@import "Models/WorkflowJob.j"
@import "Models/WorkflowJobSetting.j"
@import "Models/WorkflowRun.j"

// Transformers
@import "Transformers/ArrayCountTransformer.j"
@import "Transformers/ByteCountTransformer.j"
@import "Transformers/CheckBoxTransformer.j"
@import "Transformers/DateFormatTransformer.j"
@import "Transformers/JobTypeTransformer.j"
@import "Transformers/JobArgumentsTransformer.j"
@import "Transformers/PngTransformer.j"
@import "Transformers/RunJobSettingsTransformer.j"
@import "Transformers/RunJobStatusTransformer.j"
@import "Transformers/UsernameTransformer.j"

@implementation RodanKit : CPObject
+ (void)initialize
{
	[RodanKit _registerValueTransformers];
}

+ (int)version
{
    var bundle = [CPBundle bundleForClass:[self class]];
    return [bundle objectForInfoDictionaryKey:@"CPBundleInfoDictionaryVersion"];
}

+ (void)_registerValueTransformers
{
    arrayCountTransformer = [[ArrayCountTransformer alloc] init];
    [ArrayCountTransformer setValueTransformer:arrayCountTransformer forName:@"ArrayCountTransformer"];

    dateFormatTransformer = [[DateFormatTransformer alloc] init];
    [DateFormatTransformer setValueTransformer:dateFormatTransformer forName:@"DateFormatTransformer"];

    runJobStatusTransformer = [[RunJobStatusTransformer alloc] init];
    [RunJobStatusTransformer setValueTransformer:runJobStatusTransformer forName:@"RunJobStatusTransformer"];
}
@end
