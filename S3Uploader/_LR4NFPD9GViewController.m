//
//  _LR4NFPD9GViewController.m
//  S3Uploader
//
//  Created by Matthew on 2/10/13.
//  Copyright (c) 2013 dukecs. All rights reserved.
//

#import "_LR4NFPD9GViewController.h"
#import <AWSiOSSDK/S3/AmazonS3Client.h>
#import "s3ImageCell.h"


@interface _LR4NFPD9GViewController ()

@end

@implementation _LR4NFPD9GViewController
NSString *MY_ACCESS_KEY_ID = @"AKIAJXYLMJM5JBOWN7NA";
NSString *MY_SECRET_KEY = @"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";
AmazonS3Client *s3;
NSMutableArray *listOfItems;
NSData *imageData;
NSData *compressedImageData;
S3Bucket *myBucket;
S3Bucket *compressedBucket;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.25f alpha:1.0f]; //set background color to grey
    [self.collectionView registerClass:[s3ImageCell class] forCellWithReuseIdentifier:@"simpleCellID"];
    AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:MY_ACCESS_KEY_ID withSecretKey:MY_SECRET_KEY];
    NSArray *listOfBuckets = s3.listBuckets;
    
    
    //If the bucket does not exist, then create it.

    for(S3Bucket *bucket in listOfBuckets){
        if([[bucket name]isEqual:@"delpictures"]){
            myBucket=bucket;
        }
    }
    // create the bucket if it does not yet exist
    if(myBucket==nil){
        [s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"delpictures"]];
    }
    
    
    //check for and if needed create the compressedBucket
    
    for(S3Bucket *bucket in listOfBuckets){
        if([[bucket name]isEqual:@"delpicturescompressed"]){
            compressedBucket=bucket;
        }
    }
    // create the bucket if it does not yet exist
    if(compressedBucket==nil){
        [s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"delpicturescompressed"]];
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
    compressedImageData = [NSData dataWithData:UIImageJPEGRepresentation(myImage, 0.05)];


    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Name Your Image" message:@"" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];


    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    NSLog(@"Entered: %@",[[alertView textFieldAtIndex:0] text]);
    s3 = [[AmazonS3Client alloc] initWithAccessKey:MY_ACCESS_KEY_ID withSecretKey:MY_SECRET_KEY];
    

    
    
    
    //upload the original image
        NSString* keyName = [[alertView textFieldAtIndex:0] text];
    S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:keyName inBucket:@"delpictures"];
    por.contentType = @"image/jpeg";
    por.data = imageData;
    [s3 putObject:por];

    //upload the compressed image
    NSString* compressedKeyName = [keyName stringByAppendingString:@"_compressed"];
    S3PutObjectRequest *porCompressed = [[S3PutObjectRequest alloc] initWithKey:compressedKeyName inBucket:@"delpicturescompressed"];
    porCompressed.contentType = @"image/jpeg";
    porCompressed.data = compressedImageData;
    [s3 putObject:porCompressed];
    
    
    
    //reload data
    listOfItems = [[NSMutableArray alloc] init];
    NSArray * objectList = [s3 listObjectsInBucket:myBucket.name];
    for(S3ObjectSummary* object in objectList){
        [listOfItems addObject:object.description];
    }
    [self.tableViewThing reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [listOfItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    s3 = [[AmazonS3Client alloc] initWithAccessKey:MY_ACCESS_KEY_ID withSecretKey:MY_SECRET_KEY];
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    NSString* imageName = [listOfItems objectAtIndex:indexPath.row];
    NSString* compressedImageName = [imageName stringByAppendingString:@"_compressed"];
    
    
    S3GetObjectRequest* gor = [[S3GetObjectRequest alloc] initWithKey:compressedImageName withBucket:@"delpicturescompressed"];
    S3GetObjectResponse* gore = [s3 getObject:gor];
    gore.contentType=@"image/jpeg";
    
    UIImage *compressedThumbnail = [[UIImage alloc] initWithData:gore.body];
    cell.imageView.image=compressedThumbnail;
    cell.textLabel.text = imageName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    s3 = [[AmazonS3Client alloc] initWithAccessKey:MY_ACCESS_KEY_ID withSecretKey:MY_SECRET_KEY];
    S3ResponseHeaderOverrides *override = [[S3ResponseHeaderOverrides alloc] init];
    override.contentType = @"image/jpeg";
    
    S3GetPreSignedURLRequest *gpsur = [[S3GetPreSignedURLRequest alloc] init];
    gpsur.key     = [listOfItems objectAtIndex:indexPath.row];
    NSLog(@"gpsurkey: %@", [listOfItems objectAtIndex:indexPath.row]);
    gpsur.bucket  = @"delpictures";
    gpsur.expires = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval) 3600];  // Added an hour's worth of seconds to the current time.
    gpsur.responseHeaderOverrides = override;
    NSURL *url = [s3 getPreSignedURL:gpsur];
    NSLog(@"urlpath = %@", url.path);

    [[UIApplication sharedApplication] openURL:url];
    
    
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    // _data is a class member variable that contains one array per section.
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {

    return [listOfItems count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {


    static NSString* MyCellID = @"simpleCellID";
    NSString* imageName = [listOfItems objectAtIndex:indexPath.row];
    NSString* compressedImageName = [imageName stringByAppendingString:@"_compressed"];
    
    
    S3GetObjectRequest* gor = [[S3GetObjectRequest alloc] initWithKey:compressedImageName withBucket:@"delpicturescompressed"];
    S3GetObjectResponse* gore = [s3 getObject:gor];
    gore.contentType=@"image/jpeg";
    
    UIImage *compressedThumbnail = [[UIImage alloc] initWithData:gore.body];
    
    s3ImageCell* newCell = [collectionView dequeueReusableCellWithReuseIdentifier:MyCellID
                                                                           forIndexPath:indexPath];

//    newCell.backgroundColor = [UIColor whiteColor];
    newCell.imageView.image = nil;
    newCell.imageView.image = compressedThumbnail;
    return newCell;
}

@end
