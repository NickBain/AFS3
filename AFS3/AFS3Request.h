//
//  AFS3Request.h
//  Class for accessing Amazon S3 rest API unsing AFNetworking
//
//  Copyright (c) 2012 Nicholas Bain. All rights reserved.
//
//  Ported from ASI-HTTP-Request Created by Ben Copsey, Original Copyright Notice:
//  Copyright 2009 All-Seeing Interactive. All rights reserved.

#import "AFHTTPClient.h"

static NSString *sharedAccessKey = nil;
static NSString *sharedSecretAccessKey = nil;
static NSString *const S3BaseURLString = @"https://s3.amazonaws.com";
static NSString * const S3BucketBaseURL = @"https://%@.s3.amazonaws.com";

@interface AFS3Request : AFHTTPClient <NSCopying, NSXMLParserDelegate> {
    
    // Your S3 access key. Set it on the request, or set it globally using [AFS3 setSharedAccessKey:]
	NSString *accessKey;
    
	// Your S3 secret access key. Set it on the request, or set it globally using [AFS3 setSharedSecretAccessKey:]
	NSString *secretAccessKey;
    
	// The string that will be used in the HTTP date header. Generally you'll want to ignore this and let the class add the current date for you, but the accessor is used by the tests
	NSString *dateString;
    
	// The access policy to use when PUTting a file (e.g. public-read, private) see http://docs.aws.amazon.com/AmazonS3/latest/dev/ACLOverview.html#CannedACL
	NSString *accessPolicy;
    

}

@property (retain) NSURL *url;
@property (retain) NSString *dateString;
@property (retain) NSString *accessKey;
@property (retain) NSString *secretAccessKey;
@property (retain) NSString *accessPolicy;
@property (retain) NSString *requestScheme;
@property (retain) NSString *requestMethod;
@property (retain) NSData *data;


//Methods

// Uses the supplied date to create a Date header string
- (void)setDate:(NSDate *)date;

//We store the full URL path
- (void)setURL:(NSURL *)newURL;

//We build the parameters for AF Request object
-(NSDictionary *)buildParams;

// Will return a dictionary of the 'amz-' headers that wil be sent to S3
// Override in subclasses to add new ones
- (NSMutableDictionary *)S3Headers;

// Returns the string that will used to create a signature for this request
// Is overridden in AFS3ObjectRequest
- (NSString *)stringToSignForHeaders:(NSString *)canonicalizedAmzHeaders resource:(NSString *)canonicalizedResource;

- (void)buildRequestHeaders;
#pragma mark shared access keys

// Get and set the global access key, this will be used for all requests the access key hasn't been set for
+ (NSString *)sharedAccessKey;
+ (void)setSharedAccessKey:(NSString *)newAccessKey;
+ (NSString *)sharedSecretAccessKey;
+ (void)setSharedSecretAccessKey:(NSString *)newAccessKey;


# pragma mark helpers

// Returns a date formatter than can be used to parse a date from S3
+ (NSDateFormatter*)S3ResponseDateFormatter;

// Returns a date formatter than can be used to send a date header to S3
+ (NSDateFormatter*)S3RequestDateFormatter;


// Returns a string for the hostname used for S3 requests. You shouldn't ever need to change this.
+ (NSString *)S3Host;

// This is called automatically before the request starts to build the request URL (if one has not been manually set already)
- (void)buildURL;

//finally enqueue request
-(void) enqueRequest:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end
