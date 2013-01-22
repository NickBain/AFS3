#AFS3

An Amazon S3 client for use with [AFNetworking](https://github.com/AFNetworking/AFNetworking/). This is a port from [ASI-HTTP-Request](https://github.com/pokeb/asi-http-request) S3 client, and the original BSD license and copyright remain.

##Getting Started
- [Download AFNetworking](https://github.com/AFNetworking/AFNetworking/zipball/master) and add it to your project if you haven't already
- Make sure AFNetworking is setup and working  - Read the ["Getting Started" guide](https://github.com/AFNetworking/AFNetworking/wiki/Getting-Started-with-AFNetworking) if you need help.
- [Download AFS3](https://github.com/NickBain/AFS3/zipball/master) and add the AFS3 folder to your project

## How To...
The first thing we do is set the shared access and secret access keys, another option would be to set these for each individual request.
```objectivec
	NSString *secretAccessKey = @"mySecretKey";
	NSString *accessKey = @"myAccessKey";
	[AFS3Request setSharedSecretAccessKey:secretAccessKey];
	[AFS3Request setSharedAccessKey:accessKey];
``` 
When you get a response from AWS it will be xml - you will need to parse that yourself!

### List Bucket Content
To list the content of a bucket called mybucket123:
```objectivec
	AFS3BucketRequest *s3Client = [AFS3BucketRequest requestWithBucket:@"mybucket123"];

	[s3Client enqueRequest:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", [operation responseString]); //XML response
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed");
    }];
```
You can also set the marker, delimiter, prefix and max keys as per the [S3 API](http://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketGET.html).

For example to list the first 25 files in the bucket folder images (mybucket/images) we would use

```objectivec
	AFS3BucketRequest *s3Client = [AFS3BucketRequest requestWithBucket:@"mybucket123"];
	[s3Client setPrefix:@"images"];
	[s3Client setMaxResultCount:25];
...
```

##Upload Object
Upload a file called example.txt on your desktop to your bucket with the name example_123.txt
```objectivec
	AFS3ObjectRequest *s3Client = [AFS3ObjectRequest PUTRequestForFile:@"/Users/me/Desktop/example.txt" withBucket:@"mybucket123" key:@"/example_123.txt"];
	[s3Client enqueRequest:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", [[operation response] allHeaderFields]); //Response Headers
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed Upload!");
    }];
```
Upload a object from NSData
```objectivec
	NSData *myData = [NSData dataWithContentsOfFile:@"/Users/me/Desktop/example.png"];

	AFS3ObjectRequest *s3Client = [AFS3ObjectRequest PUTRequestForData:myData withBucket:exampleBucket key:@"/example.png"];
	[s3Client enqueRequest:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", [[operation response] allHeaderFields]); //Response Headers
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed Upload!");
    }];
```
##Download Object
Here we download and object and get the NSData returned:

```objectivec
	AFS3ObjectRequest *s3Client = [AFS3ObjectRequest GETRequestForPath:exampleBucket key:@"/example.png"];
	
	[s3Client enqueRequest:^(AFHTTPRequestOperation *operation, id responseObject) {
        	[operation responseData] ; //NSData of file
    	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       		 NSLog(@"Failed");
    	}];
```
###By Nicholas Bain 
Twitter: @nicky_bain
