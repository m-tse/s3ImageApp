//
//  photoDetailViewController.m
//  S3Uploader
//
//  Created by Matthew on 3/16/13.
//  Copyright (c) 2013 dukecs. All rights reserved.
//

#import "photoDetailViewController.h"

@interface photoDetailViewController ()
@property (weak) IBOutlet UIImageView *imageView;

@end

@implementation photoDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.image=self.passedImage;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
