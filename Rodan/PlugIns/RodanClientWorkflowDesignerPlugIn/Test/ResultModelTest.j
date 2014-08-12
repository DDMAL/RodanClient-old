@import "../../Rodan/Models/Result.j"
@import <Foundation/CPDate.j>

//example JSONObject to test RemoteProperties
 var jsonTest = {"url":"http://localhost:8000/result/e2c863a2390a4e5fa6defbd2fe2d76f5/",
                 "result":"/uploads/projects/c7771f9d1e6b421fb4e40a82230537a8/workflows/668b1332dff54a778b345b175b5f7142/runs/94a80729660e4785b85146e7c1f3c3dd/1_251706881aa446768e7ff2d2f372df6c/e2c863a2390a4e5fa6defbd2fe2d76f5.png",
                 "run_job":"http://localhost:8000/runjob/251706881aa446768e7ff2d2f372df6c/",
                 "run_job_name":"gamera.plugins.threshold.djvu_threshold",
                 "small_thumb_url":"/uploads/projects/c7771f9d1e6b421fb4e40a82230537a8/workflows/668b1332dff54a778b345b175b5f7142/runs/94a80729660e4785b85146e7c1f3c3dd/1_251706881aa446768e7ff2d2f372df6c/thumbnails/e2c863a2390a4e5fa6defbd2fe2d76f5_150.jpg",
                 "medium_thumb_url":"/uploads/projects/c7771f9d1e6b421fb4e40a82230537a8/workflows/668b1332dff54a778b345b175b5f7142/runs/94a80729660e4785b85146e7c1f3c3dd/1_251706881aa446768e7ff2d2f372df6c/thumbnails/e2c863a2390a4e5fa6defbd2fe2d76f5_400.jpg",
                 "large_thumb_url":"/uploads/projects/c7771f9d1e6b421fb4e40a82230537a8/workflows/668b1332dff54a778b345b175b5f7142/runs/94a80729660e4785b85146e7c1f3c3dd/1_251706881aa446768e7ff2d2f372df6c/thumbnails/e2c863a2390a4e5fa6defbd2fe2d76f5_1500.jpg",
                 "created":"2014-05-26T20:48:26.842Z",
                 "updated":"2014-05-26T20:48:27.218Z",
                 "processed":true};


@implementation ResultModelTest : OJTestCase
{
    Result         resultTestObject       @accessors;
}

- (void)setUp
{
    //init. Result Model object w/ JSONObject
    resultTestObject = [[Result alloc] initWithJson:jsonTest];

    [self assertNotNull:resultTestObject];
}


- (void)testRemoteProperties
{
    //test if JSONObject  values are equal to Result Model Values
    [self assert:[resultTestObject pk] equals:jsonTest.url message:"url"];
    [self assert:[resultTestObject runJob] equals:jsonTest.run_job message:"runJob"];
    [self assert:[resultTestObject runJobName] equals:jsonTest.run_job_name message:"runJobName"];
    [self assert:[resultTestObject resultURL] equals:jsonTest.result message:"resultURL"];
    [self assert:[resultTestObject thumbURL] equals:jsonTest.medium_thumb_url message:"thumbURL"];
    [self assert:[resultTestObject mediumThumbURL] equals:jsonTest.medium_thumb_url message:"mediumThumbURL"];
    [self assert:[resultTestObject result] equals:jsonTest.result message:"result"]
    [self assertTrue:[[resultTestObject created] isEqualToDate:jsonTest.created] message:"created"];
    [self assertTrue:[[resultTestObject updated] isEqualToDate:jsonTest.updated] message:"updated"];
    [self assert:[resultTestObject processed] equals:jsonTest.processed message:"processed"];
}

- (void)testRemotePath
{
    var returnValue;
    returnValue = [resultTestObject remotePath];
    if (returnValue != "/results/")
    {
        [self assert:[resultTestObject pk] equals:returnValue];
    }

}

@end