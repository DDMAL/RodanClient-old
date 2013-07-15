@import "../Transformers/GlyphsTransformer.j"
@import "../Models/Glyph.j"

/*
    Parent to Classifier and PageGlyphs
    Note that the GlyphsTableView uses polymorphism - it uses an object
    of type GameraGlyphs which can turn out to be a Classifier or PageGlyphs.)
*/

@implementation GameraGlyphs : WLRemoteObject
{
    CPString            pk                @accessors;  //remote
    CPArray             glyphs            @accessors;  //remote
    CPMutableDictionary symbolCollections @accessors;  //not remote, but will get clobbered if we do an update
}

+ (CPArray)remoteProperties
{
    var remoteProperties = [[CPMutableArray alloc] init];
    [remoteProperties addObjectsFromArray:[
        ['pk',     'url'],
        ['glyphs', 'glyphs', [[GlyphsTransformer alloc] init], true]  // true... I think means it's reversible
        // GlyphsTransformer isn't working!
        // ['glyphs', 'glyphs', nil, nil]
        ]];
    return remoteProperties;
}

- (id)initWithJson:(id)jsonGameraGlyphs
{
    console.log("GameraGlyphs initWithJson:");
    console.log(jsonGameraGlyphs);
    if (self = [super initWithJson:jsonGameraGlyphs])
    {
        // Note: [super initWithJson] assigns all remote properties that came in from the server .
        // We must initialize symbolCollections here
        // TODO: Are you sure??? Don't have I have to loop through remoteProperties??
        // console.log("(GameraGlyphs) glyphs is " + glyphs + "!");
        console.log("(GameraGlyphs) pk is " + pk + "!");

        var i = 0,
            glyphsCount = [glyphs count],
            newSymbolCollections = [[CPMutableDictionary alloc] init],
            prevGlyphName = nil;

        for (i = 0; i < glyphsCount; ++i)
        {
            var glyphName = [glyphs[i] idName];
            // if ([newSymbolCollections containsKey:glyphName])  // slower alternative
            if (prevGlyphName === nil || prevGlyphName !== glyphName)
            {
                // TODO: We could potentially optimize this by assuming alphabetical order.
                // (containsKey might be a bit slow.)  prevGlyph...
                // We could even write this generically, so that it doesn't clobber symbolCollections
                // if Ratatosk does an update... we lose guaranteed syncing but maybe that's okay (since
                // the client is doing the talking.)
                var newGlyphList = [[CPMutableArray alloc] init];
                [newSymbolCollections setObject:newGlyphList forKey:glyphName];
            }
            [[newSymbolCollections objectForKey:glyphName] addObject:glyphs[i]];
            [glyphs[i] addObserver:self forKeyPath:@"idName" options:nil context:nil];
            prevGlyphName = glyphName;
        }

        [self setSymbolCollections:newSymbolCollections];
        console.log("newSymbolCollections");
        console.log(newSymbolCollections);
    }

    return self;
}

- (void)observeValueForKeyPath:(CPString)aKeyPath ofObject:(id)aSymbolCollection change:(CPDictionary)aChange context:(id)aContext
{
    console.log("GameraGlyphs observered a change to a symbol collection glyph list.");  // Works
    console.log(aChange);
}

- (CPDictionary)makeSymbolCollections
{
    return nil;
}

@end
