//
//  AFS3BucketRequest.h
//  Class for commincating with AWS for Bucket Operations
//
//  Copyright (c) 2012 Nicholas Bain. All rights reserved.
//
//  Ported from ASI-HTTP-Request Created by Ben Copsey, Original Copyright Notice:
//  Copyright 2009 All-Seeing Interactive. All rights reserved.

#import "AFS3Request.h"

@class AFS3Bucket;

@interface AFS3BucketRequest : AFS3Request{
    
	// Name of the bucket to talk to
	NSString *bucket;
    
	// A parameter passed to S3 in the query string to tell it to return specialised information
	// Consult the S3 REST API documentation for more info
	NSString *subResource;
    
	// Options for filtering GET requests
	// See http://docs.amazonwebservices.com/AmazonS3/latest/API/RESTBucketGET.html
	NSString *prefix;
	NSString *marker;
	int maxResultCount;
	NSString *delimiter;
   
}


// Fetch a bucket
+ (id)requestWithBucket:(NSString *)bucket;

// Create a bucket request, passing a parameter in the query string
// You'll need to parse the response XML yourself
+ (id)requestWithBucket:(NSString *)bucket subResource:(NSString *)subResource;

// Use for creating new buckets
+ (id)PUTRequestWithBucket:(NSString *)bucket;

// Use for deleting buckets - they must be empty for this to succeed
+ (id)DELETERequestWithBucket:(NSString *)bucket;

@property (retain, nonatomic) NSString *bucket;
@property (retain, nonatomic) NSString *subResource;
@property (retain, nonatomic) NSString *prefix;
@property (retain, nonatomic) NSString *marker;
@property (assign, nonatomic) int maxResultCount;
@property (retain, nonatomic) NSString *delimiter;


@end
