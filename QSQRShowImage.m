//
//  QSQRShowImage.m
//  QSQRCode
//
//  Created by Eric Doughty-Papassideris on 4/01/10.
//  Copyright 2010 FWA. All rights reserved.
//

#import "QSQRShowImage.h"


/* Function copied from Adam Maxwell
   http://code.google.com/p/mactlmgr/source/browse/trunk/TLMStatusWindow.m?spec=svn569&r=569
*/
static void CenterRectInRect(NSRect *toCenter, NSRect enclosingRect)
{
    CGFloat halfWidth = NSWidth(*toCenter) / 2.0;
    CGFloat halfHeight = NSHeight(*toCenter) / 2.0;
    
    NSPoint centerPoint = NSMakePoint(NSMidX(enclosingRect), NSMidY(enclosingRect));
    centerPoint.x -= halfWidth;
    centerPoint.y -= halfHeight;
    toCenter->origin = centerPoint;
}

@implementation QSQRShowImage
+ (void)showImage:(NSImage *)image {
	NSRect screenRect = [[NSScreen mainScreen] frame];
	NSRect visibleRect = [[NSScreen mainScreen] visibleFrame];
	NSSize size = [image size];
	NSSize maxCodeSize = NSMakeSize(visibleRect.size.width * 0.85, visibleRect.size.height * 0.85);
	if (size.width > maxCodeSize.width) {
		size.height = size.height * (maxCodeSize.width / size.width);
		size.width = maxCodeSize.width;
	}
	if (size.height > maxCodeSize.height) {
		size.width = size.width * (maxCodeSize.height / size.height);
		size.height = maxCodeSize.height;
	}
	NSRect imageRect = NSMakeRect(0, 0, size.width, size.height);
	NSRect frameRect = NSMakeRect(0, 0, size.width, size.height);
	NSImageView *imgView = [[[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, size.width, size.height)] autorelease];
	[imgView setEditable:NO];
	[imgView setImage:image];
	[imgView setImageScaling:NSImageScaleProportionallyUpOrDown];

	CenterRectInRect(&frameRect, visibleRect);
	NSWindow *largeTypeWindow = [[QSQRShowImage alloc] initWithContentRect:imageRect styleMask:NSBorderlessWindowMask | NSNonactivatingPanelMask backing:NSBackingStoreBuffered defer:NO];
	[largeTypeWindow setIgnoresMouseEvents:YES];
	[largeTypeWindow setFrame:frameRect display:YES];
	[largeTypeWindow setBackgroundColor: [NSColor clearColor]];
	[largeTypeWindow setOpaque:YES];
	[largeTypeWindow setLevel:NSFloatingWindowLevel];
	[largeTypeWindow setHidesOnDeactivate:NO];
	[largeTypeWindow setContentView:imgView];
	[largeTypeWindow makeKeyAndOrderFront:nil];
	[largeTypeWindow setInitialFirstResponder:imgView];
	[[largeTypeWindow contentView] display];
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
	if (self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag]) {
		[self setReleasedWhenClosed:YES];
	}
	return self;
}

- (IBAction)copy:(id)sender {
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	[pb declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
	[pb setString:[(NSTextField *)[self initialFirstResponder] stringValue] forType:NSStringPboardType];
}

- (BOOL)canBecomeKeyWindow {return YES;}

- (void)keyDown:(NSEvent *)theEvent {
	[self setAlphaValue:0 fadeTime:0.333];
	[self close];
}

- (void)resignKeyWindow {
	[super resignKeyWindow];
	if ([self isVisible]) {
		[self close];
	}
}
@end
