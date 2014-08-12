@implementation BooleanToTextTransformer : CPValueTransformer
{
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    if (value)
    {
        return "yes";
    }
    return "no";
}
@end
