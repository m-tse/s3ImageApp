//
//  photoDetailViewController.h
//  S3Uploader
//
//  Created by Matthew on 3/16/13.
//  Copyright (c) 2013 dukecs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface photoDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *detailImageView;
@property (weak, nonatomic) UIImage *passedImage;

@end
