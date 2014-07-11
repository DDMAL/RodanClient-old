@import "../../Rodan/Models/WorkflowJob.j"

//example JSONObject to test RemoteProperties
 var jsonTest = {"url":"http://localhost:8000/workflowjob/1c61c27b35b04fa29d02dbf689d13ec5/",
                 "workflow":null,
                 "input_pixel_types":[0,4,2,3,5],
                 "output_pixel_types":[1],
                 "job_name":"gamera.plugins.image_conversion.to_greyscale",
                 "job_description":"\"**to_greyscale** ()\n\nConverts the given image to a GREYSCALE image according to the\nfollowing rules:\n\n- for ONEBIT images, 0 is mapped to 255 and everything else to 0.\n- for FLOAT images, the range [min,max] is linearly scaled to [0,255]\n- for GREY16 images, the range [0,max] is linearly scaled to [0,255]\n- for RGB images, the luminance is used, which is defined in VIGRA as 0.3*R + 0.59*G + 0.11*B\n\nConverting an image to one of the same type performs a copy operation.\"",
                 "job_type":0,
                 "job":"http://localhost:8000/job/2457a4d452a14539858e5434d460bbe5/",
                 "sequence":1,
                 "job_settings":[],
                 "created":"2014-05-22T20:45:41.501Z",
                 "updated":"2014-05-23T13:09:07.575Z"};

@implementation WorkflowJobModelTest : OJTestCase
{
    WorkflowJob         workflowJobTestObject       @accessors;
}

- (void)setUp 
{
    //init. WorkflowJob Model object w/ JSONObject
    workflowJobTestObject = [[WorkflowJob alloc] initWithJson:jsonTest];

    [self assertNotNull:workflowJobTestObject];
}


- (void)testRemoteProperties
{
    //test if JSONObject  values are equal to WorkflowJob Model Values
    [self assert:[workflowJobTestObject pk] equals:jsonTest.url message:"url"];
    [self assert:[workflowJobTestObject workflow] equals:jsonTest.workflow message:"workflow"];
    [self assert:[workflowJobTestObject jobName] equals:jsonTest.job_name message:"jobName"];
    [self assert:[workflowJobTestObject jobDescription] equals:jsonTest.job_description message:"jobDescription"];
    [self assert:[workflowJobTestObject job] equals:jsonTest.job message:"job"];
    [self assert:[workflowJobTestObject sequence] equals:jsonTest.sequence message:"sequence"];
    [self assert:[workflowJobTestObject jobSettings] equals:jsonTest.job_settings message:"jobSettings"];
    [self assert:[workflowJobTestObject inputPixels] equals:jsonTest.input_pixel_types message:"inputPixels"];  
    [self assert:[workflowJobTestObject outputPixels] equals:jsonTest.output_pixel_types message:"outputPixels"];
    [self assert:[workflowJobTestObject jobType] equals:jsonTest.job_type message:"jobType"];
}

- (void)testRemotePath
{    
    var returnValue;
    returnValue = [workflowJobTestObject remotePath];
    if (returnValue != "/workflowjobs/") 
    {
        [self assert:[workflowJobTestObject pk] equals:returnValue];
    }

}

- (void)testRemoveFromWorkflow
{
    //yet to implement in WorkflowJobModelTest.j
}

- (void)testShortJobName 
{
    var returnValue = [workflowJobTestObject shortJobName];
    [self assert:@"To Greyscale" equals:returnValue];

}


@end

