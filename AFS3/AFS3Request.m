//
//  AFS3Request.m
//
//  Copyright (c) 2012 Nicholas Bain. All rights reserved.
//
//  Ported from ASI-HTTP-Request Created by Ben Copsey, Original Copyright Notice:
//  Copyright 2009 All-Seeing Interactive. All rights reserved.

#import "AFS3Request.h"
#import "AFXMLRequestOperation.h"
#import "S3Security.h"


@implementation AFS3Request

@synthesize url;
@synthesize dateString;
@synthesize accessKey;
@synthesize secretAccessKey;
@synthesize accessPolicy;
@synthesize requestScheme;
@synthesize requestMethod;
@synthesize data;
- (id)initWithBaseURL:(NSURL *)newURL
{
    
    self = [super initWithBaseURL:newURL];
    if (!self) {
        return nil;
    }
    [self setRequestMethod:@"GET"];
    [self setRequestScheme:@"https"];
    [self registerHTTPOperationClass:[AFXMLRequestOperation class]];
    
    return self;
    
}

- (void)setDate:(NSDate *)date
{
	[self setDateString:[[AFS3Request S3RequestDateFormatter] stringFromDate:date]];
}

- (void)setURL:(NSURL *)newURL
{
	url = newURL;
}

- (NSMutableDictionary *)S3Headers
{
	NSMutableDictionary *headers = [NSMutableDictionary dictionary];
	if ([self accessPolicy]) {
		[headers setObject:[self accessPolicy] forKey:@"x-amz-acl"];
	}
	return headers;
}



#pragma mark Shared access keys

+ (NSString *)sharedAccessKey
{
	return sharedAccessKey;
}

+ (void)setSharedAccessKey:(NSString *)newAccessKey
{
	sharedAccessKey = newAccessKey;
}

+ (NSString *)sharedSecretAccessKey
{
	return sharedSecretAccessKey;
}

+ (void)setSharedSecretAccessKey:(NSString *)newAccessKey
{
	sharedSecretAccessKey = newAccessKey;
}


+ (NSDateFormatter*)S3ResponseDateFormatter
{
	// We store our date formatter in the calling thread's dictionary
	// NSDateFormatter is not thread-safe, this approach ensures each formatter is only used on a single thread
	// This formatter can be reused 1000 times in parsing a single response, so it would be expensive to keep creating new date formatters
	NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
	NSDateFormatter *dateFormatter = [threadDict objectForKey:@"AFS3ResponseDateFormatter"];
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
		[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
		[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.000Z'"];
		[threadDict setObject:dateFormatter forKey:@"AFS3ResponseDateFormatter"];
	}
	return dateFormatter;
}

+ (NSDateFormatter*)S3RequestDateFormatter
{
	NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
	NSDateFormatter *dateFormatter = [threadDict objectForKey:@"AFS3RequestHeaderDateFormatter"];
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		// Prevent problems with dates generated by other locales (tip from: http://rel.me/t/date/)
		[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
		[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
		[dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss Z"];
		[threadDict setObject:dateFormatter forKey:@"AFS3RequestHeaderDateFormatter"];
	}
	return dateFormatter;
    
}

+ (NSString *)S3Host
{
	return @"s3.amazonaws.com";
}

- (void)buildURL
{
}

- (NSDictionary *)buildParams
{
    return nil;
}

- (NSString *)canonicalizedResource
{
	return @"/";
}


- (NSString *)stringToSignForHeaders:(NSString *)canonicalizedAmzHeaders resource:(NSString *)canonicalizedResource
{
	return [NSString stringWithFormat:@"%@\n\n\n%@\n%@%@",[self requestMethod],[self dateString],canonicalizedAmzHeaders,canonicalizedResource];
}

- (void)buildRequestHeaders
{
     
	if (![self url]) {
		[self buildURL];
        [self buildParams];
	}
    
    
    
	// If an access key / secret access key haven't been set for this request, let's use the shared keys
	if (![self accessKey]) {
		[self setAccessKey:[AFS3Request sharedAccessKey]];
	}
	if (![self secretAccessKey]) {
		[self setSecretAccessKey:[AFS3Request sharedSecretAccessKey]];
	}
	// If a date string hasn't been set, we'll create one from the current time
	if (![self dateString]) {
		[self setDate:[NSDate date]];
	}
    [self setDefaultHeader:@"Date" value:[self dateString]];

    
	// Ensure our formatted string doesn't use '(null)' for the empty path
	NSString *canonicalizedResource = [self canonicalizedResource];
    
	// Add a header for the access policy if one was set, otherwise we won't add one (and S3 will default to private)
	NSMutableDictionary *amzHeaders = [self S3Headers];
	NSString *canonicalizedAmzHeaders = @"";
	for (NSString *header in [amzHeaders keysSortedByValueUsingSelector:@selector(compare:)]) {
		canonicalizedAmzHeaders = [NSString stringWithFormat:@"%@%@:%@\n",canonicalizedAmzHeaders,[header lowercaseString],[amzHeaders objectForKey:header]];
        [self setDefaultHeader:header value:[amzHeaders objectForKey:header]];
	}
    
	// Jump through hoops while eating hot food
	NSString *stringToSign = [self stringToSignForHeaders:canonicalizedAmzHeaders resource:canonicalizedResource];
	NSString *signature = [S3Security base64forData:[S3Security HMACSHA1withKey:[self secretAccessKey] forString:stringToSign]];
	NSString *authorizationString = [NSString stringWithFormat:@"AWS %@:%@",[self accessKey],signature];
    [self setDefaultHeader:@"Authorization" value:authorizationString];
    
}

-(void) enqueRequest:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
       
    [self buildRequestHeaders];
    NSMutableURLRequest *request = [self requestWithMethod:[self requestMethod] path:[[self url] path] parameters:[self buildParams]];
    
    [request setHTTPBody:data];

    
    AFHTTPRequestOperation *requestOperation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    
    [self enqueueHTTPRequestOperation:requestOperation];
    
    
}

@end
