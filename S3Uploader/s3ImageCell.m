//
//  s3ImageCell.m
//  S3Uploader
//
//  Created by Matthew on 3/6/13.
//  Copyright (c) 2013 dukecs. All rights reserved.
//

#import "s3ImageCell.h"
#import <QuartzCore/QuartzCore.h>
@interface s3ImageCell ()

@property (nonatomic, strong, readwrite) UIImageView *imageView;

@end
@implementation s3ImageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
//
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 3.0f;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 3.0f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        self.layer.shadowOpacity = 0.5f;
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        
        [self.contentView addSubview:self.imageView];
    }
    
    
    
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)prepareForReuse
{
    [super prepareForReuse];
    self.imageView.image=nil;
    
}
@end
