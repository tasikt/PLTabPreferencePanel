//
//  PLTabPreferenceControl.m
//  PLTabPreferencePanel
//
//  Created by xhan on 3/23/11.
//  Copyright 2011 Baidu.com. All rights reserved.
//


#import "PLTabPreferenceControl.h"


@interface PLTabPreferenceControl(Private)
- (void)switchPanel:(id)sender;
@end

@implementation PLTabPreferenceControl
@synthesize delegate;
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    NSLog(@"window loaded");
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    //this method only will be called if window is loaded by it's nib file
}


- (void)awakeFromNib{
//    NSLog(@"awaked");
    
    NSWindow* theWin = [self window];
    [theWin setShowsToolbarButton:NO];
    [theWin setShowsResizeIndicator:NO];
    
    
    
    toolbar = [[NSToolbar alloc] initWithIdentifier:NSStringFromClass([self class])];
    [toolbar setShowsBaselineSeparator:NO];
    [toolbar setAllowsUserCustomization:NO];
    [toolbar setDelegate:self];
    [[self window] setToolbar:toolbar];
    
//    [toolbar validateVisibleItems];
    
    [self selectPanelAtIndex:0];
}

/////////////////////////////////////////////
#pragma TabPreference methods
- (void)switchPanel:(id)sender
{
    NSView *viewToShow = [delegate panelViewForPreferencePanelAt:(int)[sender tag]];
	NSWindow* theWin = [self window];
    
	if (viewToShow && ([theWin contentView] != viewToShow)) {
		
		[toolbar setSelectedItemIdentifier:[sender itemIdentifier]];
		
		NSRect newFrame = [theWin frameRectForContentRect:[viewToShow bounds]];
		NSRect oldFrame = [theWin frame];
		
		newFrame.origin = oldFrame.origin;
		newFrame.origin.y -= (newFrame.size.height - oldFrame.size.height);
		
		[theWin setContentView:viewToShow];
		[theWin setFrame:newFrame display:YES animate:YES];
        
		[theWin setTitle:[sender label]];
		
	}
}

- (void)selectPanelAtIndex:(int)index
{
   NSToolbarItem* item = [[toolbar items] objectAtIndex:index];
    if (item) {
        [self switchPanel:item];
    }
}

/////////////////////////////////////////////
#pragma toolbar delegates
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    if (prefIdentifyAry) {
        return prefIdentifyAry;
    }
    if (self.delegate) {
        int count = [self.delegate countOfPreferencePanels];
        NSMutableArray* array = [NSMutableArray arrayWithCapacity:count];
        for (int i = 0; i< count; i++) {
            NSString* identify;
            if ([delegate respondsToSelector:@selector(identifyForPreferencePanelAt:)]) {
                identify = [delegate identifyForPreferencePanelAt:i];
            }else{
                identify = [NSString stringWithFormat:@"%d",i];
            }
            [array addObject:identify];
        }
        [prefIdentifyAry release];
        prefIdentifyAry = [[NSArray alloc] initWithArray:array];
        return prefIdentifyAry;
    }
    return nil;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)atoolbar
{
	return [self toolbarAllowedItemIdentifiers:toolbar];
}
- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)atoolbar
{
	return [self toolbarAllowedItemIdentifiers:toolbar];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{

    NSUInteger index = [prefIdentifyAry indexOfObject:itemIdentifier];
    if (index == NSNotFound) {
        return nil;
    }
    NSToolbarItem *item = nil;
    
    item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    [item setLabel:[delegate titleForPreferencePanelAt:(int)index]];
    [item setImage:[delegate imageForPreferencePanelAt:(int)index]];
    [item setTag:index];
		
	[item setTarget:self];
	[item setAction:@selector(switchPanel:)];
	[item setAutovalidates:NO];
    
	return [item autorelease];
}


@end
