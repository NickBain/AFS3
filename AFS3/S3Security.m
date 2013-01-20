//
//  S3Security.m
//
//  Copyright (c) 2012 Nicholas Bain. All rights reserved.
//
//  Ported from ASI-HTTP-Request Created by Ben Copsey, Original Copyright Notice:
//  Copyright 2009 All-Seeing Interactive. All rights reserved.

#import "S3Security.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation S3Security

+ (NSData *)HMACSHA1withKey:(NSString *)key forString:(NSString *)string
{
	NSData *clearTextData = [string dataUsingEncoding:NSUTF8StringEncoding];
	NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    
	uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
    
	CCHmacContext hmacContext;
	CCHmacInit(&hmacContext, kCCHmacAlgSHA1, keyData.bytes, keyData.length);
	CCHmacUpdate(&hmacContext, clearTextData.bytes, clearTextData.length);
	CCHmacFinal(&hmacContext, digest);
    
	return [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
}

// From: http://www.cocoadev.com/index.pl?BaseSixtyFour

+ (NSString*)base64forData:(NSData*)theData {
    
	const uint8_t* input = (const uint8_t*)[theData bytes];
	NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
	NSInteger i,i2;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
		for (i2=0; i2<3; i2++) {
            value <<= 8;
            if (i+i2 < length) {
                value |= (0xFF & input[i+i2]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

@end
