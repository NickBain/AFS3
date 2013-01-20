//
//  AFS3ObjectRequest.m
//
//  Copyright (c) 2012 Nicholas Bain. All rights reserved.
//
//  Ported from ASI-HTTP-Request Created by Ben Copsey, Original Copyright Notice:
//  Copyright 2009 All-Seeing Interactive. All rights reserved.

#import "AFS3ObjectRequest.h"
#import "AFXMLRequestOperation.h"

NSString *const AFS3StorageClassStandard = @"STANDARD";
NSString *const AFS3StorageClassReducedRedundancy = @"REDUCED_REDUNDANCY";


@interface AFS3ObjectRequest ()
@property (retain) NSString *dataPath;

@end

@implementation AFS3ObjectRequest

- (id)initWithBaseURL:(NSURL *)newURL
{
	self = [super initWithBaseURL:newURL];
    
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFXMLRequestOperation class]];
    
	return self;
}

+ (id)requestWithBucket:(NSString *)theBucket key:(NSString *)theKey
{
    NSURL *bucketURL = [NSURL URLWithString:[NSString stringWithFormat:S3BucketBaseURL,theBucket]];
	AFS3ObjectRequest *newRequest = [[self alloc] initWithBaseURL:bucketURL];
	[newRequest setBucket:theBucket];
	[newRequest setKey:theKey];
	return newRequest;
}

+ (id)requestWithBucket:(NSString *)theBucket key:(NSString *)theKey subResource:(NSString *)theSubResource
{
    NSURL *bucketURL = [NSURL URLWithString:[NSString stringWithFormat:S3BucketBaseURL,theBucket]];
	AFS3ObjectRequest *newRequest = [[self alloc] initWithBaseURL:bucketURL];
	[newRequest setSubResource:theSubResource];
	[newRequest setBucket:theBucket];
	[newRequest setKey:theKey];
 
	return newRequest;
}


+ (id)PUTRequestForFile:(NSString *)filePath withBucket:(NSString *)bucket key:(NSString *)key
{
	AFS3ObjectRequest *newRequest = [self requestWithBucket:bucket key:key];
	[newRequest setDataPath:filePath];
	[newRequest setRequestMethod:@"PUT"];
	return newRequest;
}

+ (id)PUTRequestForData:(NSData *)data withBucket:(NSString *)bucket key:(NSString *)key{
    AFS3ObjectRequest *newRequest = [self requestWithBucket:bucket key:key];
	[newRequest setData:data];
	[newRequest setRequestMethod:@"PUT"];
	return newRequest;

}

+ (id)DELETERequestWithBucket:(NSString *)bucket key:(NSString *)key{
    AFS3ObjectRequest *newRequest = [self requestWithBucket:bucket key:key];
	[newRequest setRequestMethod:@"DELETE"];
    return newRequest;

}

+ (id)HEADRequestWithBucket:(NSString *)bucket key:(NSString *)key
{
	AFS3ObjectRequest *newRequest = [self requestWithBucket:bucket key:key];
	[newRequest setRequestMethod:@"HEAD"];
	return newRequest;
}

+ (id)COPYRequestFromBucket:(NSString *)sourceBucket key:(NSString *)sourceKey toBucket:(NSString *)bucket key:(NSString *)key{
    
    AFS3ObjectRequest *newRequest = [self requestWithBucket:bucket key:key];
	[newRequest setRequestMethod:@"PUT"];
	[newRequest setSourceBucket:sourceBucket];
	[newRequest setSourceKey:sourceKey];
    return newRequest;
    
}

+ (id)GETRequestForPath:(NSString *)bucket key:(NSString *)key{
    AFS3ObjectRequest *newRequest = [self requestWithBucket:bucket key:key];
	[newRequest setRequestMethod:@"GET"];
	return newRequest;
    
}
- (void)buildURL
{
	NSString *url;
	if ([self subResource]) {
		url = [NSString stringWithFormat:@"%@://%@.%@/?%@",[self requestScheme],[self bucket],[[self class] S3Host],[self subResource]];
	} else {
		url = [NSString stringWithFormat:@"%@://%@.%@%@",[self requestScheme],[self bucket],[[self class] S3Host], [self key] ];
	}
	
	[self setURL:[NSURL URLWithString:url]];
    
}

- (NSString *)canonicalizedResource
{
	if ([[self subResource] length] > 0) {
		return [NSString stringWithFormat:@"/%@%@?%@",[self bucket],[self key], [self subResource]];
	}
	return [NSString stringWithFormat:@"/%@%@",[self bucket],[self key]];
}

- (NSMutableDictionary *)S3Headers
{
	NSMutableDictionary *headers = [super S3Headers];
	if ([self sourceKey]) {
		NSString *path = [self sourceKey];
		[headers setObject:[[self sourceBucket] stringByAppendingString:path] forKey:@"x-amz-copy-source"];
	}
	if ([self storageClass]) {
		[headers setObject:[self storageClass] forKey:@"x-amz-storage-class"];
	}
	return headers;
}

- (NSString *)stringToSignForHeaders:(NSString *)canonicalizedAmzHeaders resource:(NSString *)canonicalizedResource
{
    

	if ([[self requestMethod] isEqualToString:@"PUT"] && ![self sourceKey]) {

        return [NSString stringWithFormat:@"%@\n\n\n%@\n%@%@",[self requestMethod],[self dateString],canonicalizedAmzHeaders,canonicalizedResource];

		return [NSString stringWithFormat:@"PUT\n\n%@\n%@\n%@%@",[self mimeType],dateString,canonicalizedAmzHeaders,canonicalizedResource];
	}
    
	return [super stringToSignForHeaders:canonicalizedAmzHeaders resource:canonicalizedResource];
}


-(void) enqueRequest:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{

    
    [self setDefaultHeader:@"Key" value:[self key]];
    
    NSData * data;
    if([self dataPath] != nil){
        data = [NSData dataWithContentsOfFile:[self dataPath]];
    }else{
        data = [self data];
    }
    
    if(mimeType != nil)
        [self setDefaultHeader:@"Content-type" value:mimeType];
    [self setData:data];
    [super enqueRequest:success failure:failure];

    
}


@synthesize bucket;
@synthesize key;
@synthesize sourceBucket;
@synthesize sourceKey;
@synthesize mimeType;
@synthesize subResource;
@synthesize storageClass;
@synthesize dataPath;


@end
