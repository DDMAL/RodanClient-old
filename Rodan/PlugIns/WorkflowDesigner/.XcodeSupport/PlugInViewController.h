#import <Cocoa/Cocoa.h>
#import "xcc_general_include.h"

@interface PlugInViewController : NSViewController

@property (assign) IBOutlet NSView* contentView;
@property (assign) IBOutlet NSSplitView* workflowDesignerView;
@property (assign) IBOutlet NSScrollView* designerView;
@property (assign) IBOutlet NSSplitView* leftSideBar;
@property (assign) IBOutlet NSSplitView* rightSideBar;
@property (assign) IBOutlet NSToolbarItem* leftSideBarIcon;
@property (assign) IBOutlet NSToolbarItem* rightSideBarIcon;
@property (assign) IBOutlet NSToolbarItem* toolsIcon;
@property (assign) IBOutlet NSToolbarItem* helpIcon;
@property (assign) IBOutlet NSToolbarItem* statusIcon;
@property (assign) IBOutlet NSToolbarItem* userIcon;
@property (assign) IBOutlet NSToolbarItem* pagesIcon;
@property (assign) IBOutlet NSToolbarItem* designerIcon;
@property (assign) IBOutlet NSToolbarItem* jobsIcon;
@property (assign) IBOutlet NSToolbarItem* resultsIcon;
@property (assign) IBOutlet NSButton* connectButton;
@property (assign) IBOutlet NSButton* settingsButton;
@property (assign) IBOutlet NSButton* pagesButton;
@property (assign) IBOutlet NSButton* runsButton;
@property (assign) IBOutlet NSScrollView* jobScrollView;
@property (assign) IBOutlet NSView* jobsView;
@property (assign) IBOutlet NSArray* jobsViewArray;
@property (assign) IBOutlet NSScrollView* leftScrollView;
@property (assign) IBOutlet NSView* pagesView;
@property (assign) IBOutlet NSArray* pagesViewArray;
@property (assign) IBOutlet NSView* runsView;
@property (assign) IBOutlet NSArray* runsViewArray;
@property (assign) IBOutlet NSScrollView* rightUpperScrollView;
@property (assign) IBOutlet NSView* rightUpperView;
@property (assign) IBOutlet NSTableView* settingsView;
@property (assign) IBOutlet NSView* jobA;
@property (assign) IBOutlet NSView* jobB;
@property (assign) IBOutlet NSView* jobC;
@property (assign) IBOutlet NSView* jobD;
@property (assign) IBOutlet NSView* jobE;
@property (assign) IBOutlet NSView* jobF;
@property (assign) IBOutlet NSView* jobG;
@property (assign) IBOutlet NSView* jobH;
@property (assign) IBOutlet NSView* jobI;
@property (assign) IBOutlet NSImageView* imageA;
@property (assign) IBOutlet NSImageView* imageB;
@property (assign) IBOutlet NSImageView* imageC;
@property (assign) IBOutlet NSImageView* imageD;
@property (assign) IBOutlet NSImageView* imageE;
@property (assign) IBOutlet NSImageView* imageF;
@property (assign) IBOutlet NSImageView* imageG;
@property (assign) IBOutlet NSImageView* imageH;
@property (assign) IBOutlet NSImageView* imageI;
@property (assign) IBOutlet NSImageView* imageA2;
@property (assign) IBOutlet NSImageView* imageB2;
@property (assign) IBOutlet NSImageView* imageC2;
@property (assign) IBOutlet NSImageView* imageD2;
@property (assign) IBOutlet NSImageView* imageE2;
@property (assign) IBOutlet NSImageView* imageF2;
@property (assign) IBOutlet NSImageView* imageG2;
@property (assign) IBOutlet NSImageView* imageH2;
@property (assign) IBOutlet NSImageView* imageI2;
@property (assign) IBOutlet NSView* pageA;
@property (assign) IBOutlet NSView* pageB;
@property (assign) IBOutlet NSView* pageC;
@property (assign) IBOutlet NSView* pageD;
@property (assign) IBOutlet NSView* pageE;
@property (assign) IBOutlet NSView* pageF;
@property (assign) IBOutlet NSView* pageG;
@property (assign) IBOutlet NSView* pageH;
@property (assign) IBOutlet NSView* pageI;
@property (assign) IBOutlet NSImageView* pageImageA;
@property (assign) IBOutlet NSImageView* pageImageB;
@property (assign) IBOutlet NSImageView* pageImageC;
@property (assign) IBOutlet NSImageView* pageImageD;
@property (assign) IBOutlet NSImageView* pageImageE;
@property (assign) IBOutlet NSImageView* pageImageF;
@property (assign) IBOutlet NSImageView* pageImageG;
@property (assign) IBOutlet NSImageView* pageImageH;
@property (assign) IBOutlet NSImageView* pageImageI;
@property (assign) IBOutlet NSPanel* attributesPanel;
@property (assign) IBOutlet NSTableHeaderView* attributesTableHeader;
@property (assign) IBOutlet NSOutlineView* attributesOutlineView;
@property (assign) IBOutlet NSScrollView* attributesScrollView;
@property (assign) IBOutlet NSTableView* jobsTableView;
@property (assign) IBOutlet NSArray* _tableContent;
@property (assign) IBOutlet NSOutlineView* _outlineView;
@property (assign) IBOutlet NSTableView* pagesTableView;
@property (assign) IBOutlet NSArrayController* pagesArrayController;

@end

@interface CPArray (MoveIndexes)
@end
