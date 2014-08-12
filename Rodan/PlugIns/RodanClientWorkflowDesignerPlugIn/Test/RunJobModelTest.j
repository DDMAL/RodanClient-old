@import "../../Rodan/Models/RunJob.j"
@import <Foundation/CPDate.j>
@import "../../Rodan/Transformers/RunJobSettingsTransformer.j" //used to get transformer for test
@import "../../Rodan/Transformers/JobArgumentsTransformer.j" //used to get transformer for test


//example JSONObject to test RemoteProperties
 var jsonTest = {"url":"http://localhost:8000/runjob/f7b757537b0d460cb301e6b7e2328832/",
                 "job_name":"gamera.plugins.threshold.djvu_threshold",
                 "workflow_name":"Untitled",
                 "workflow_run":"http://localhost:8000/workflowrun/c40f180955c14b2c864c94503e19ec97/",
                 "workflow_job":"http://localhost:8000/workflowjob/4e1a14fa1a884c72b23cced983b4ae38/",
                 "sequence":1,
                 "result":[],
                 "page":{"url":"http://localhost:8000/page/b9ea0ade89c04363a9276b22744dec55/",
                        "uuid":"b9ea0ade89c04363a9276b22744dec55",
                        "name":"2952609526_9fd245dfcd_q.jpg",
                        "page_order":1,
                        "medium_thumb_url":"/uploads/projects/c7771f9d1e6b421fb4e40a82230537a8/pages/b9ea0ade89c04363a9276b22744dec55/thumbnails/original_file_400.jpg",
                        "large_thumb_url":"/uploads/projects/c7771f9d1e6b421fb4e40a82230537a8/pages/b9ea0ade89c04363a9276b22744dec55/thumbnails/original_file_400.jpg"
                 },
                 "job_settings":[{"has_default":null,"name":"smoothness","default":"0.2","rng":["0.0","1.0"],"visibility":true,"choices":null,"type":"real"},{"has_default":null,"name":"max_block_size","default":512,"rng":[-1048576,1048576],"visibility":true,"choices":null,"type":"int"},{"has_default":null,"name":"min_block_size","default":64,"rng":[-1048576,1048576],"visibility":true,"choices":null,"type":"int"},{"has_default":null,"name":"block_factor","default":2,"rng":[1,8],"visibility":true,"choices":null,"type":"int"}],
                 "needs_input":false,
                 "status":0,
                 "error_summary":"",
                 "error_details":""};


@implementation RunJobModelTest : OJTestCase
{
    RunJob                          runJobTestObject       @accessors;
    Page                            pageTestObject         @accessors;
    RunJobSettingsTransformer       runJobTransformerTest;                        //use RunJob.j for reference for RunJobSettingsTransformer
    JobArgumentsTransformer         jobTransformerTest;
}

- (void)setUp
{
    //init. RunJob Model object w/ JSONObject
    runJobTestObject = [[RunJob alloc] initWithJson:jsonTest];
    pageTestObject = [[Page alloc] initWithJson:jsonTest.page];
    runJobTransformerTest = [[RunJobSettingsTransformer alloc] init];
    jobTransformerTest = [[JobArgumentsTransformer alloc] init];

    [self assertNotNull:runJobTestObject];
}


- (void)testRemoteProperties
{
    //test if JSONObject  values are equal to RunJob Model Values
    [self assert:[runJobTestObject pk] equals:jsonTest.url message:"url"];
    [self assert:[runJobTestObject jobName] equals:jsonTest.job_name message:"jobName"];
    [self assert:[runJobTestObject sequence] equals:jsonTest.sequence message:"sequence"];
    [self assert:[runJobTestObject status] equals:jsonTest.status message:"status"];
    [self assert:[runJobTestObject needsInput] equals:jsonTest.needs_input message:"needsInput"];
    [self assert:[runJobTestObject workflowName] equals:jsonTest.workflow_name message:"workflowName"];
    [self assert:[runJobTestObject jobSettings] equals:[runJobTransformerTest transformedValue:jsonTest.job_settings] message:"jobSettings"];

    // [self assert:[runJobTestObject jobSettingsArray] equals:[jobTransformerTest transformedValue:jsonTest.job_settings] message:"jobSettingsArray"];

    [self assert:[runJobTestObject result] equals:jsonTest.result message:"result"];
    [self assert:[runJobTestObject page] equals:pageTestObject message:"page"];
    [self assert:[runJobTestObject errorSummary] equals:jsonTest.error_summary message:"errorSummary"];
    [self assert:[runJobTestObject errorDetails] equals:jsonTest.error_details message:"errorDetails"];

}

- (void)testGetUUID
{
    var returnValue = [runJobTestObject getUUID];
    if (returnValue != nil)
    {
        [self assert:returnValue equals:"f7b757537b0d460cb301e6b7e2328832"];
    }
}

- (void)testDidFail
{
    var returnValue = [runJobTestObject didFail];
    //jsonTest status is equal to 0, therefore should return false
    [self assert:returnValue equals:false];
}

- (void)testRemotePath
{
    var returnValue;
    returnValue = [runJobTestObject remotePath];
    if (returnValue != "/runjobs/")
    {
        [self assert:[runJobTestObject pk] equals:returnValue];
    }
}

- (void)testCanRunInteractive
{
    var returnValue = [runJobTestObject canRunInteractive];
    //jsonTest status is equal to 0, therefore should return false
    [self assert:returnValue equals:false];
}

@end