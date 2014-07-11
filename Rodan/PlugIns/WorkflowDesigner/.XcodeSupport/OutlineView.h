#import <Cocoa/Cocoa.h>
#import "xcc_general_include.h"

@interface OutlineView : NSOutlineView

@property (assign) IBOutlet NSOutlineView* outlineView;
@property (assign) IBOutlet NSArray* _outlineItems;
@property (assign) IBOutlet NSString* outlineName;

@end
