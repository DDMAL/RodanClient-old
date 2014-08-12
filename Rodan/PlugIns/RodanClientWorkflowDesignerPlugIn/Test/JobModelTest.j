@import "../../Rodan/Models/Job.j"

//example JSONObject to test RemoteProperties
 var jsonTest = {"url":"http://localhost:8000/job/9cdbb88311ce4862a8f22ddb6c4ed780/",
                    "job_name":"gamera.toolkits.background_estimation.plugins.background_estimation.wiener2_filter",
                    "settings":[{"default":5,"has_default":true,"rng":[-1048576,1048576],"name":"region_width","type":"int"},{"default":5,"has_default":true,"rng":[-1048576,1048576],"name":"region_height","type":"int"},{"default":"-1.0","has_default":true,"rng":[-1048576,1048576],"name":"noise_variance","type":"real"}],
                    "description":"\"**wiener2_filter** (int *region_width* = 5, int *region_height* = 5, float *noise_variance* = -1.00)\n\nAdaptive directional filtering\n\n*region_width*, *region_height*\n The size of the region within which to calculate the intermediate pixel value.\n\n*noise_variancee*\n noise variance. If negative, estimated automatically.\"",
                    "input_types":"{\"default\": null, \"has_default\": false, \"list_of\": false, \"pixel_types\": [1, 2, 4], \"name\": null}",
                    "output_types":"{\"default\": null, \"has_default\": false, \"list_of\": false, \"pixel_types\": [1, 2, 4], \"name\": \"output\"}",
                    "category":"Background Estimation",
                    "enabled":true,
                    "interactive":false};

@implementation JobModelTest : OJTestCase
{
    Job         jobTestObject       @accessors;

}

- (void)setUp 
{
    //init. Job Model object w/ JSONObject
    jobTestObject = [[Job alloc] initWithJson:jsonTest];

    [self assertNotNull:jobTestObject];
}

- (void)testShortJobName 
{
    var returnValue = [jobTestObject shortJobName];
    [self assert:@"Wiener2 Filter" equals:returnValue];

}

- (void)testRemoteProperties
{
    //test if JSONObject  values are equal to Job Model Values
    [self assert:[jobTestObject pk] equals:jsonTest.url message:"pk"];
    [self assert:[jobTestObject jobName] equals:jsonTest.job_name message:"jobName"];
    [self assert:[jobTestObject settings] equals:jsonTest.settings message:"settings"];
    [self assert:[jobTestObject description] equals:jsonTest.description message:"description"];
    [self assert:[jobTestObject inputTypes] equals:jsonTest.input_types message:"inputTypes"];
    [self assert:[jobTestObject outputTypes] equals:jsonTest.output_types message:"outputTypes"];
    [self assert:[jobTestObject category] equals:jsonTest.category message:"category"];
    [self assert:[jobTestObject isEnabled] equals:jsonTest.enabled message:"isEnabled"];
    [self assert:[jobTestObject isInteractive] equals:jsonTest.interactive message:"isInteractive"];

}

- (void)testRemotePath
{    
    var returnValue;
    returnValue = [jobTestObject remotePath];
    if (returnValue != "/jobs/") 
    {
        [self assert:[jobTestObject pk] equals:returnValue];
    }

}
@end