//
//  AFS3BucketRequest.m
//
//  Copyright (c) 2012 Nicholas Bain. All rights reserved.
//
//  Ported from ASI-HTTP-Request Created by Ben Copsey, Original Copyright Notice:
//  Copyright 2009 All-Seeing Interactive. All rights reserved.

#import "AFS3BucketRequest.h"
#import "AFXMLRequestOperation.h"

//Private
@interface AFS3BucketRequest ()

@end


@implementation AFS3BucketRequest


- (id)initWithBaseURL:(NSURL *)newURL
{
	self = [super initWithBaseURL:newURL];

    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFXMLRequestOperation class]];
        
	return self;
}

+ (id)requestWithBucket:(NSString *)theBucket
{
    NSURL *bucketURL = [NSURL URLWithString:[NSString stringWithFormat:S3BucketBaseURL,theBucket]];
	AFS3BucketRequest *request = [[self alloc] initWithBaseURL:bucketURL];
	[request setBucket:theBucket];
	return request;
}

+ (id)requestWithBucket:(NSString *)theBucket subResource:(NSString *)theSubResource
{
    NSURL *bucketURL = [NSURL URLWithString:[NSString stringWithFormat:S3BucketBaseURL,theBucket]];

	AFS3BucketRequest *request = [[self alloc] initWithURL:bucketURL];
	[request setBucket:theBucket];
	[request setSubResource:theSubResource];
	return request;
}

+ (id)PUTRequestWithBucket:(NSString *)theBucket
{
	AFS3BucketRequest *request = [self requestWithBucket:theBucket];
	[request setRequestMethod:@"PUT"];
	return request;
}


+ (id)DELETERequestWithBucket:(NSString *)theBucket
{
	AFS3BucketRequest *request = [self requestWithBucket:theBucket];
	[request setRequestMethod:@"DELETE"];
	return request;
}

- (NSString *)canonicalizedResource
{
	if ([self subResource]) {
		return [NSString stringWithFormat:@"/%@/?%@",[self bucket],[self subResource]];
	}
	return [NSString stringWithFormat:@"/%@/",[self bucket]];
}

-(NSDictionary *) buildParams{
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    NSMutableArray *objectArray = [[NSMutableArray alloc] init];
	if ([self prefix]) {
        [keys addObject:@"prefix"];
		[objectArray addObject:[NSString stringWithFormat:@"%@",[[self prefix] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	}
	if ([self marker]) {
        [keys addObject:@"marker"];
		[objectArray addObject:[NSString stringWithFormat:@"%@",[[self marker] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	}
	if ([self delimiter]) {
        [keys addObject:@"delimiter"];
		[objectArray addObject:[NSString stringWithFormat:@"%@",[[self delimiter] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	}
	if ([self maxResultCount] > 0) {
        [keys addObject:@"max-keys"];
		[objectArray addObject:[NSString stringWithFormat:@"%i",[self maxResultCount]]];
	}
    
   return [NSDictionary dictionaryWithObjects:objectArray forKeys:keys];
    
}
- (void)buildURL
{
	NSString *baseURL;
	if ([self subResource]) {
		baseURL = [NSString stringWithFormat:@"%@://%@.%@/?%@",[self requestScheme],[self bucket],[[self class] S3Host],[self subResource]];
	} else {
		baseURL = [NSString stringWithFormat:@"%@://%@.%@",[self requestScheme],[self bucket],[[self class] S3Host]];
	}
	
	
	[self setURL:[NSURL URLWithString:baseURL]];
        
}

-(void) enqueRequest:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [self buildURL];
    [super enqueRequest:success failure:failure];
    
}

@synthesize bucket;
@synthesize subResource;
@synthesize prefix;
@synthesize marker;
@synthesize maxResultCount;
@synthesize delimiter;


@end
