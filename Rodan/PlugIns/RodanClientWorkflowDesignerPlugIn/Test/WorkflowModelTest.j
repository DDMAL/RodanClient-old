@import "../../Rodan/Models/Workflow.j"

//example JSONObject to test RemoteProperties
 var jsonTest = {"url":"http://localhost:8000/workflow/668b1332dff54a778b345b175b5f7142/",
                 "uuid":"668b1332dff54a778b345b175b5f7142",
                 "project":"http://localhost:8000/project/c7771f9d1e6b421fb4e40a82230537a8/",
                 "creator":"http://localhost:8000/user/1/",
                 "name":"Untitled",
                 "created":"2014-05-26T20:11:19.567Z",
                 "updated":"2014-05-26T20:51:39.133Z"};


@implementation WorkflowModelTest : OJTestCase
{
    Workflow         workflowTestObject       @accessors;
}

- (void)setUp 
{
    //init. Workflow Model object w/ JSONObject
    workflowTestObject = [[Workflow alloc] initWithJson:jsonTest];

    [self assertNotNull:workflowTestObject];
}


- (void)testRemoteProperties
{
    //test if JSONObject  values are equal to Workflow Model Values
    [self assert:[workflowTestObject pk] equals:jsonTest.url message:"url"];
    [self assert:[workflowTestObject uuid] equals:jsonTest.uuid message:"uuid"];
    // [self assert:[workflowTestObject runs] equals:jsonTest.runs message:"runs"];
    [self assert:[workflowTestObject workflowName] equals:jsonTest.name message:"workflowName"];
    [self assert:[workflowTestObject projectURL] equals:jsonTest.project message:"projectURL"];
    // [self assert:[workflowTestObject workflowJobs] equals:jsonTest.workflow_jobs message:"workflowJobs"];
    // [self assert:[workflowTestObject workflowRuns] equals:jsonTest.workflow_runs message:"workflowRuns"];
    // [self assert:[workflowTestObject pages] equals:jsonTest.pages message:"pages"];  
    // [self assert:[workflowTestObject description] equals:jsonTest.description message:"description"];
    // [self assert:[workflowTestObject hasStarted] equals:jsonTest.has_started message:"hasStarted"];
    [self assert:[workflowTestObject workflowCreator] equals:jsonTest.creator message:"workflowCreator"];  
}

- (void)testRemotePath
{    
    var returnValue;
    returnValue = [workflowTestObject remotePath];
    if (returnValue != "/workflows/") 
    {
        [self assert:[workflowTestObject pk] equals:returnValue];
    }

}

- (void)testAddPage
{
   //not yet implemented in Workflow.j 
}

- (void)testAddpages
{
    //not yet implemented in Workflow.j
}

- (void)testAddJob
{
    //not yet implemeted in Workflow.j
}

- (void)testAddJobs
{
    //not yet implemeted in Workflow.j

}

- (void)testTouchWorkflowJobs
{
    //yet to implement on Unit Tests
}
@end

