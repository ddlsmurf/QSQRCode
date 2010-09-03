//
//  QSQRObjectQualifier.m
//  QSQRCode
//
//  Created by Eric Doughty-Papassideris on 3/01/10.
//  Copyright 2010. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import "QSQRObjectQualifier.h"

#define AB_BirthDayHeader @"BDAY;value=date:"

@implementation QSQRObjectQualifier

@synthesize converters;

-(NSString *)convertPhone:(QSObject *)obj {
	return [NSString stringWithFormat:@"tel:%@", [obj stringValue]];
}

NSString *fixABBirthDateFormatForAndroidZXing(NSString *vCard) {
	NSRange header = [vCard rangeOfString:AB_BirthDayHeader];
	NSUInteger len = [vCard length];
	while (header.location != NSNotFound) {
		NSUInteger end = header.location + header.length;
		if (end < len - 1) {
			NSRange replaceOver = NSMakeRange(end, len - end - 1);
			NSRange fieldEnd = [vCard rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSLiteralSearch range:replaceOver];
			if (fieldEnd.location != NSNotFound) {
				replaceOver.length = fieldEnd.location - replaceOver.location;
			}
			vCard = [vCard stringByReplacingOccurrencesOfString:@"-" withString:@"" options:NSLiteralSearch range:replaceOver];
			len = [vCard length];
		}
		if (end < len - 2) {
			header.location = end;
			header.length = len - end - 1;
			header = [vCard rangeOfString:AB_BirthDayHeader options:NSLiteralSearch range:header];
		} else {
			header.location = NSNotFound;
		}
	}
	return vCard;
};

-(NSString *)convertVCard:(QSObject *)obj {
	ABPerson *person = (ABPerson *)[[ABAddressBook sharedAddressBook] recordForUniqueId:[[obj arrayForType:@"ABPeopleUIDsPboardType"]lastObject]];
	NSData *vCard = [person vCardRepresentation];
	NSString *vCardText = [[[NSString alloc] initWithData:vCard encoding:NSUTF8StringEncoding] autorelease];
	
	return fixABBirthDateFormatForAndroidZXing(vCardText);
}

+(NSDictionary *)defaultConverters {
	return [[NSDictionary alloc] initWithObjectsAndKeys:
							NSStringFromSelector(@selector(convertPhone:)), @"qs.contact.phone",
							NSStringFromSelector(@selector(convertVCard:)), @"ABPeopleUIDsPboardType",
							nil
	 ];
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.converters = [QSQRObjectQualifier defaultConverters];
	}
	return self;
}

- (void) dealloc
{
	self.converters = nil;
	[super dealloc];
}

+(QSQRObjectQualifier *)qualifierWithDefaultConverters {
	return [[[QSQRObjectQualifier alloc] init] autorelease];
}

-(NSString *)qualify:(QSObject *)obj {
	NSString *pType = [obj primaryType];
	id item = [self.converters objectForKey:pType];
	if (!item) return [obj stringValue];
	SEL method = NSSelectorFromString((NSString*)item);
	return (NSString *)[self performSelector:method withObject:obj];
}
@end
