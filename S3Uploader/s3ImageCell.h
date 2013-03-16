//
//  s3ImageCell.h
//  S3Uploader
//
//  Created by Matthew on 3/6/13.
//  Copyright (c) 2013 dukecs. All rights reserved.
//

#import <UIKit/UIKit.h>
static NSString * const PhotoCellIdentifier = @"simpleCellID";

@interface s3ImageCell : UICollectionViewCell
@property (nonatomic, strong, readonly) IBOutlet UIImageView *imageView;

@end
