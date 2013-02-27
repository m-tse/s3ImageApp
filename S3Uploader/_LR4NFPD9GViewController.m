//
//  _LR4NFPD9GViewController.m
//  S3Uploader
//
//  Created by Matthew on 2/10/13.
//  Copyright (c) 2013 dukecs. All rights reserved.
//

#import "_LR4NFPD9GViewController.h"
#import <AWSiOSSDK/S3/AmazonS3Client.h>

@interface _LR4NFPD9GViewController ()

@end

@implementation _LR4NFPD9GViewController
NSString *MY_ACCESS_KEY_ID = @"AKIAJXYLMJM5JBOWN7NA";
NSString *MY_SECRET_KEY = @"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";
AmazonS3Client *s3;
NSMutableArray *listOfItems;
NSData *imageData;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    
    AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:MY_ACCESS_KEY_ID withSecretKey:MY_SECRET_KEY];
    NSArray *listOfBuckets = s3.listBuckets;
    S3Bucket *myBucket;
    for(S3Bucket *bucket in listOfBuckets){
        if([[bucket name]isEqual:@"s3uploaderbucket"]){
            myBucket=bucket;
        }
    }
    
    listOfItems = [[NSMutableArray alloc] init];
    NSArray * objectList = [s3 listObjectsInBucket:myBucket.name];
    for(S3ObjectSummary* object in objectList){
        [listOfItems addObject:object.description];
    }

    

    
    
        
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pickAnImage:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    [self presentModalViewController:imagePicker animated:YES];



}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //show an alert window to input the image name
    UIImage *myImage = [info objectForKey: @"UIImagePickerControllerOriginalImage"];
    imageData = [NSData dataWithData:UIImageJPEGRepresentation(myImage, 1.0)];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Name Your Image" message:@"" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];


    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"Entered: %@",[[alertView textFieldAtIndex:0] text]);
    s3 = [[AmazonS3Client alloc] initWithAccessKey:MY_ACCESS_KEY_ID withSecretKey:MY_SECRET_KEY];
    
    //If the bucket does not exist, then create it.
    NSArray *listOfBuckets = s3.listBuckets;
    S3Bucket *myBucket;
    for(S3Bucket *bucket in listOfBuckets){
        if([[bucket name]isEqual:@"s3uploaderbucket"]){
            myBucket=bucket;
        }
    }
    // create the bucket if it does not yet exist
    if(myBucket==nil){
        [s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"s3uploaderbucket"]];
    }
    
        NSString* keyName = [[alertView textFieldAtIndex:0] text];
    S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:keyName inBucket:@"s3uploaderbucket"];
    por.contentType = @"image/jpeg";
    por.data = imageData;
    [s3 putObject:por];
    NSLog(@"just uploaded an image");
    
    
    
    listOfItems = [[NSMutableArray alloc] init];
    NSArray * objectList = [s3 listObjectsInBucket:myBucket.name];
    for(S3ObjectSummary* object in objectList){
        [listOfItems addObject:object.description];
    }
    NSLog(@"just reloaded data");
    [self.tableViewThing reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [listOfItems count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [listOfItems objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:MY_ACCESS_KEY_ID withSecretKey:MY_SECRET_KEY];
    S3ResponseHeaderOverrides *override = [[S3ResponseHeaderOverrides alloc] init];
    override.contentType = @"image/jpeg";
    
    S3GetPreSignedURLRequest *gpsur = [[S3GetPreSignedURLRequest alloc] init];
    gpsur.key     = [listOfItems objectAtIndex:indexPath.row];
    NSLog(@"gpsurkey: %@", [listOfItems objectAtIndex:indexPath.row]);
    gpsur.bucket  = @"s3uploaderbucket";
    gpsur.expires = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval) 3600];  // Added an hour's worth of seconds to the current time.
    gpsur.responseHeaderOverrides = override;
    NSURL *url = [s3 getPreSignedURL:gpsur];
    NSLog(@"urlpath = %@", url.path);

    [[UIApplication sharedApplication] openURL:url];
    
    
    
}
@end
