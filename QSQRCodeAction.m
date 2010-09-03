//
//  QSQRCodeAction.m
//  QSQRCode
//
//  Created by Eric Doughty-Papassideris on 3/01/10.
//  Copyright FWA 2010. All rights reserved.
//

#import "QSQRCodeAction.h"
#import "QSQRCodeRenderer.h"
#import "QSQRObjectQualifier.h"
#import "QSQRShowImage.h"

@implementation QSQRCodeAction

+ (void) showError {
	NSAlert *alert = [NSAlert
					  alertWithMessageText:@"Error encoding QR Code"
							 defaultButton:@"Ok"
						   alternateButton:nil
							   otherButton:nil
				 informativeTextWithFormat:@"Unable to convert data to QR Code, data is empty or too large."];
	[alert runModal];
}

- (NSString *)getTextForObject:(QSObject *)dObject {
	return [[QSQRObjectQualifier qualifierWithDefaultConverters] qualify:dObject];
}

- (QSObject *)showCodeForObject:(QSObject *)dObject{
	NSImage *image = QRRenderCodeFor([self getTextForObject:dObject]);
	if (image)
		[QSQRShowImage showImage:image];
	else
		[QSQRCodeAction showError];
	return nil;
}

- (QSObject *)copyCodeForObject:(QSObject *)dObject{
	if (!QRCopyCodeFor([self getTextForObject:dObject]))
		[QSQRCodeAction showError];
	return nil;
}
@end
