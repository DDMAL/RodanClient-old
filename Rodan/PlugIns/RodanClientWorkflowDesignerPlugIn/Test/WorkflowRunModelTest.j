@import "../../Rodan/Models/WorkflowRun.j"

//example JSONObject to test RemoteProperties
 var jsonTest = {"url":"http://localhost:8000/workflowrun/c40f180955c14b2c864c94503e19ec97/",
                 "uuid":"c40f180955c14b2c864c94503e19ec97",
                 "workflow":"http://localhost:8000/workflow/668b1332dff54a778b345b175b5f7142/",
                 "run":2,"created":"2014-05-26T20:12:01.252Z",
                 "updated":"2014-05-26T20:12:01.259Z",
                 "test_run":false,
                 "creator":"http://localhost:8000/user/1/",
                 "cancelled":false};

@implementation WorkflowRunModelTest : OJTestCase
{
    WorkflowRun         workflowRunTestObject       @accessors;
}

- (void)setUp 
{
    //init. WorkflowRun Model object w/ JSONObject
    workflowRunTestObject = [[WorkflowRun alloc] initWithJson:jsonTest];

    [self assertNotNull:workflowRunTestObject];
}


- (void)testRemoteProperties
{
    //test if JSONObject  values are equal to WorkflowRun Model Values
    [self assert:[workflowRunTestObject pk] equals:jsonTest.url message:"url"];
    [self assert:[workflowRunTestObject uuid] equals:jsonTest.uuid message:"uuid"];
    [self assert:[workflowRunTestObject workflowURL] equals:jsonTest.workflow message:"workflowURL"];
    // [self assert:[workflowRunTestObject pages] equals:jsonTest.pages message:"pages"];
    // [self assert:[workflowRunTestObject runCreator] equals:jsonTest.creator message:"runCreator"];
    [self assert:[workflowRunTestObject run] equals:jsonTest.run message:"run"];
    [self assertTrue:[[workflowRunTestObject created] isEqualToDate:jsonTest.created] message:"created"];
    [self assertTrue:[[workflowRunTestObject updated] isEqualToDate:jsonTest.updated] message:"updated"];
    [self assert:[workflowRunTestObject testRun] equals:jsonTest.test_run message:"testRun"];  
    [self assert:[workflowRunTestObject cancelled] equals:jsonTest.cancelled message:"cancelled"];
}

- (void)testRemotePath
{    
    var returnValue;
    returnValue = [workflowRunTestObject remotePath];
    if (returnValue != "/workflowruns/") 
    {
        [self assert:[workflowRunTestObject pk] equals:returnValue];
    }

}

- (void)testPostPath
{
    //testRun is false, so should return jsonTest.url
    var returnValue = [workflowRunTestObject postPath];
    [self assert:returnValue equals:jsonTest.url];
}

- (void)testIsEqual 
{
    //yet to implement in WorkflowRunModelTest.j
}

- (void)testRemoteActionDidFail
{
    //yet to implement in WorkflowRunModelTest.j
}


@end

