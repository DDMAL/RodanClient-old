@import <Foundation/CPValueTransformer.j>

@implementation RunJobSettingsTransformer : CPObject
{

}

+ (Class)transformedValueClass
{
    return [CPMutableDictionary class];
}

- (CPArray)transformedValue:(CPArray)jsonArrayOfJobSettings
{
    var settingsCount = [jsonArrayOfJobSettings count],
        settingsDict = [[CPMutableDictionary alloc] init],
        i = 0;
    for (; i < settingsCount; ++i)
    {
        if (jsonArrayOfJobSettings[i]['default'])
        {
            [settingsDict setObject:jsonArrayOfJobSettings[i]['default'] forKey:jsonArrayOfJobSettings[i]['name']];
        }
    }
    return settingsDict;
}

@end
