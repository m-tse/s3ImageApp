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
#import "photoDetailViewController.h"

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
    [self.collectionView reloadData];
}




- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    s3 = [[AmazonS3Client alloc] initWithAccessKey:MY_ACCESS_KEY_ID withSecretKey:MY_SECRET_KEY];
    
    
    NSString* imageName = [listOfItems objectAtIndex:indexPath.row];
    
    
    S3GetObjectRequest* gor = [[S3GetObjectRequest alloc] initWithKey:imageName withBucket:@"delpictures"];
    S3GetObjectResponse* gore = [s3 getObject:gor];
    gore.contentType=@"image/jpeg";
    
    [self performSegueWithIdentifier:@"ShowPhoto"
                              sender:imageName];
    [self.collectionView
     deselectItemAtIndexPath:indexPath animated:YES];
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowPhoto"]) {
        photoDetailViewController *flickrPhotoViewController = segue.destinationViewController;
        flickrPhotoViewController.imageName = sender;
    }
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
    s3 = [[AmazonS3Client alloc] initWithAccessKey:MY_ACCESS_KEY_ID withSecretKey:MY_SECRET_KEY];


    static NSString* MyCellID = @"simpleCellID";
    NSString* imageName = [listOfItems objectAtIndex:indexPath.row];
    NSString* compressedImageName = [imageName stringByAppendingString:@"_compressed"];
    
    
    S3GetObjectRequest* gor = [[S3GetObjectRequest alloc] initWithKey:compressedImageName withBucket:@"delpicturescompressed"];
    S3GetObjectResponse* gore = [s3 getObject:gor];
    gore.contentType=@"image/jpeg";
    
    UIImage *compressedThumbnail = [[UIImage alloc] initWithData:gore.body];
    
    s3ImageCell* newCell = [collectionView dequeueReusableCellWithReuseIdentifier:MyCellID
                                                                           forIndexPath:indexPath];

    newCell.imageView.image = compressedThumbnail;
    return newCell;
}



@end
