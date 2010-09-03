//
//  QSQRCodeRenderer.m
//  QSQRCode
//
//  Created by Eric Doughty-Papassideris on 3/01/10.
//  Copyright 2010 FWA. All rights reserved.
//

#import "QSQRCodeRenderer.h"
#include "qrencode.h"

#define QRCode_Margin 4
#define QRCode_CellSize 8
#define QRCode_MaxData 7090

QRcode *getCode(NSString *text) {
	QRcode *code;
	const char *intext = [text cStringUsingEncoding:NSUTF8StringEncoding];
	if (strlen(intext) > QRCode_MaxData)
		return nil;
	code = QRcode_encodeString8bit(intext, 0, QR_ECLEVEL_L);
	return code;
}

NSBitmapImageRep *getBitmap(QRcode *code) {
	NSBitmapImageRep *bmrep = [[NSBitmapImageRep alloc] autorelease];
	int size = (code->width + QRCode_Margin * 2) * QRCode_CellSize;
	bmrep = [bmrep initWithBitmapDataPlanes:nil
			pixelsWide:size
			pixelsHigh:size
			bitsPerSample:1
			samplesPerPixel:1
			hasAlpha:NO
			isPlanar:NO
			colorSpaceName:NSCalibratedBlackColorSpace
			bytesPerRow:0
			bitsPerPixel:1];
	unsigned char *pixels = [bmrep bitmapData];
	int bpr = [bmrep bytesPerRow];
	unsigned int x, y;
	for (y = 0; y < size; y++) {
		unsigned char *row = pixels + (y * bpr);
		for (x = 0; x < size; x++) {
			unsigned char *pixel = row + x / 8;
			unsigned int pixelMask = 1u << (7 - x % 8);
			int codeValue;
			
			int codeX = x / QRCode_CellSize - QRCode_Margin;
			int codeY = y / QRCode_CellSize - QRCode_Margin;
			
			if (codeY < 0 || codeY >= code->width ||
				codeX < 0 || codeX >= code->width) {
				codeValue = 0; // Margin area - White
			} else {
				codeValue = code->data[code->width * codeY + codeX] & 1;
			}
			if (codeValue) {
				*pixel = *pixel | pixelMask;
			} else {
				*pixel = *pixel & ~pixelMask;
			}
		}
	}
	return bmrep;
}

NSImage *getImage(NSBitmapImageRep *bmp) {
	NSImage *result = [[NSImage alloc] initWithSize:[bmp size]];
	[result addRepresentation:bmp];
	return result;
}

void copyBMP(NSBitmapImageRep *bmp) {
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	[pb declareTypes:[NSArray arrayWithObjects:NSTIFFPboardType, nil] owner:nil];
	[pb setData:[bmp TIFFRepresentation] forType:NSTIFFPboardType];
}


BOOL QRCopyCodeFor(NSString *text) {
	QRcode *code = getCode(text);
	if (!code)
		return NO;
	copyBMP(getBitmap(code));
	return YES;
}
NSImage *QRRenderCodeFor(NSString *text) {
	QRcode *code = getCode(text);
	if (!code)
		return nil;
	return getImage(getBitmap(code));
}
