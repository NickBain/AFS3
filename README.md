#AFS3

An Amazon S3 client for use with AFNetworking. This is a port from [ASI-HTTP-Request](https://github.com/pokeb/asi-http-request) S3 client, and the original BSD license and copyright remain.

##Getting Started
- [Download AFNetworking](https://github.com/AFNetworking/AFNetworking/zipball/master) and add it to your project if you haven't already
- Make sure AFNetworking is setup and working  - Read the ["Getting Started" guide](https://github.com/AFNetworking/AFNetworking/wiki/Getting-Started-with-AFNetworking) if you need help.
You will need to add AFNetworking library to your project if you haven't already then add AFS3 classes.
- [Download AFS3](https://github.com/NickBain/AFS3/zipball/master) and add the AFS3 folder to your project

## How To...
The first thing we do is set the shared access and secret access keys, another option would be to set these for each individual request.

	NSString *secretAccessKey = @"mySecretKey";
	NSString *accessKey = @"myAccessKey";
	[AFS3Request setSharedSecretAccessKey:secretAccessKey];
	[AFS3Request setSharedAccessKey:accessKey];
 
When you get a response from AWS it will be xml - you will need to parse that yourself!

### List Bucket Content
To list the content of a bucket called mybucket123:

	AFS3BucketRequest *s3Client = [AFS3BucketRequest requestWithBucket:@"mybucket123"];

	[s3Client enqueRequest:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", [operation responseString]); //XML response
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed");
    }];
    
##Upload File
Upload a file called example.txt on your desktop to your bucket with the name example_123.txt

	AFS3ObjectRequest *s3Client = [AFS3ObjectRequest PUTRequestForFile:@"/Users/me/Desktop/example.txt" withBucket:@"mybucket123" key:@"/example_123.txt"];
	[s3Client enqueRequest:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", [[operation response] allHeaderFields]);//Response Headers
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed Upload!");
    }];


...More examples soon