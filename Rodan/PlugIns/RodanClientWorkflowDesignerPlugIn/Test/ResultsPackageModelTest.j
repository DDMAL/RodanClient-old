@import "../../Rodan/Models/ResultsPackage.j"
@import <Foundation/CPDate.j>

//example JSONObject to test RemoteProperties
 var jsonTest = {"url":"http://localhost:8000/ResultsPackage/e2c863a2390a4e5fa6defbd2fe2d76f5/",
                 "download_url":"/uploads/projects/c7771f9d1e6b421fb4e40a82230537a8/workflows/668b1332dff54a778b345b175b5f7142/runs/94a80729660e4785b85146e7c1f3c3dd/1_251706881aa446768e7ff2d2f372df6c/e2c863a2390a4e5fa6defbd2fe2d76f5.png",
                 "name": "ResultsPackage1",
                 "page_urls":["http://localhost:8000/pages/e2c863a2390a4e5fa6defbd2fe2d76f5/", "http://localhost:8000/pages/e2c863a234550a4e5fa6defbd2fe2d76f5/"],
                 "job_urls":["http://localhost:8000/jobs/e2c863a2390a4e5fa6defbd2fe2d76f5/", "http://localhost:8000/jobs/e2c863a2394534e5fa6defbd2fe2d76f5/"],
                 "workflow_run_url":"http://localhost:8000/workflows/e2c863a2390a4e5fa6defbd2fe2d76f5/",
                 "creator":"HMSimmonds",
                 "percent_completed":23,
                 "created":"2014-05-26T20:48:26.842Z",
                 "updated":"2014-05-26T20:48:27.218Z"};


@implementation ResultsPackageModelTest : OJTestCase
{
    ResultsPackage         resultPackageTestObject       @accessors;
}

- (void)setUp
{
    //init. ResultsPackage Model object w/ JSONObject
    resultPackageTestObject = [[ResultsPackage alloc] initWithJson:jsonTest];

    [self assertNotNull:resultPackageTestObject];
}


- (void)testRemoteProperties
{
    //test if JSONObject  values are equal to ResultsPackage Model Values
    [self assert:[resultPackageTestObject pk] equals:jsonTest.url message:"url"];
    [self assert:[resultPackageTestObject downloadUrl] equals:jsonTest.download_url message:"downloadUrl"];
    [self assert:[resultPackageTestObject name] equals:jsonTest.name message:"name"];
    [self assert:[resultPackageTestObject pageUrls] equals:jsonTest.page_urls message:"pageUrls"];
    [self assert:[resultPackageTestObject jobUrls] equals:jsonTest.job_urls message:"jobUrls"];
    [self assert:[resultPackageTestObject workflowRunUrl] equals:jsonTest.workflow_run_url message:"workflowRunUrl"];
    [self assert:[resultPackageTestObject creator] equals:jsonTest.creator message:"creator"]
    [self assertTrue:[[resultPackageTestObject created] isEqualToDate:jsonTest.created] message:"created"];
    [self assertTrue:[[resultPackageTestObject updated] isEqualToDate:jsonTest.updated] message:"updated"];
    [self assert:[resultPackageTestObject percentCompleted] equals:jsonTest.percent_completed message:"percentCompleted"];
}

- (void)testRemotePath
{
    var returnValue;
    returnValue = [resultPackageTestObject remotePath];
    if (returnValue != "/resultspackages/")
    {
        [self assert:[resultPackageTestObject pk] equals:returnValue];
    }

}

@end