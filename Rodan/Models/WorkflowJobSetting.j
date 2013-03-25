

@implementation WorkflowJobSetting : CPObject
{
    CPNumber    settingDefault @accessors;
    BOOL        hasDefault     @accessors;
    CPArray     range          @accessors;
    CPString    settingType    @accessors;
    CPString    settingName    @accessors;
}

- (id)init
{
    var self = [super init];
    if (self)
    {

    }

    return self;
}

+ (id)initWithSetting:(JSObject)setting
{
    var self = [[WorkflowJobSetting alloc] init];

    if (setting.name)
        [self setSettingName:setting.name];

    if (setting.has_default)
        [self setSettingDefault:setting.default];

    if (setting.rng)
        [self setRange:[CPArray arrayWithArray:setting.rng]];

    [self setSettingType:setting.type];

    return self;
}

@end