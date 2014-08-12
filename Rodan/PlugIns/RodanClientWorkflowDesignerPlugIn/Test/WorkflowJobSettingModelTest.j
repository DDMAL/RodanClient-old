@import "../../Rodan/Models/WorkflowJobSetting.j"

//example JSONObject to test RemoteProperties

var aSetting = {"default":5,"has_default":true,"rng":[-1048576,1048576],"name":"region_width","type":"int"};

@implementation WorkflowJobSettingModelTest : OJTestCase
{
    WorkflowJobSetting          workflowJobSettingTestObject        @accessors;
    // JSObject                    aSetting                            @accessors;

}

- (void)setUp 
{
    
}


// - (void)testInitWithSetting
// {
//     workflowJobSettingTestObject = [[WorkflowJobSetting alloc] initWithSetting:aSetting];

//     [self assert:[workflowJobSettingTestObject settingDefault] equals:aSetting.default];
//     [self assert:[workflowJobSettingTestObject hasDefault] equals:aSetting.has_default];
//     [self assert:[workflowJobSettingTestObject range] equals:aSetting.rng];
//     [self assert:[workflowJobSettingTestObject settingType] equals:aSetting.type];
//     [self assert:[workflowJobSettingTestObject settingName] equals:aSetting.name];
//     [self assert:[workflowJobSettingTestObject choices] equals:aSetting.choices];
//     [self assert:[workflowJobSettingTestObject visibility] equals:aSetting.visibility];

// }


@end

