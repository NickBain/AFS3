//
//  S3Security.h
//  Securit Helper methods
//
//  Copyright (c) 2012 Nicholas Bain. All rights reserved.
//
//  Ported from ASI-HTTP-Request Created by Ben Copsey, Original Copyright Notice:
//  Copyright 2009 All-Seeing Interactive. All rights reserved.

#import <Foundation/Foundation.h>

@interface S3Security : NSObject

+ (NSString *)base64forData:(NSData *)theData;
+ (NSData *)HMACSHA1withKey:(NSString *)key forString:(NSString *)string;
@end
