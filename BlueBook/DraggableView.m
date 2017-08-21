//
//  DraggableView.m
//
//  Created by Scott Lucien on 9/14/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "DraggableView.h"

@implementation DraggableView

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image name:(NSString *)name
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        CGRect imageFrame = CGRectMake(7, 14, 60, 60);
        CGRect labelFrame = CGRectMake(0, 75, 75, 15);
        
        UIImageView *background = [[UIImageView alloc] initWithFrame:imageFrame];
        [background setImage:[UIImage imageNamed:@"circle-bg-small"]];
        [background setBackgroundColor:[UIColor clearColor]];
        [self addSubview:background];
        
        _faceImage = [[UIImageView alloc] initWithFrame:imageFrame];
        [_faceImage setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_faceImage];
        
        _nameLabel = [[UILabel alloc] initWithFrame:labelFrame];
        [_nameLabel setBackgroundColor:[UIColor clearColor]];
        [_nameLabel setTextAlignment:NSTextAlignmentCenter];
        [_nameLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [self addSubview:_nameLabel];
        
        [_faceImage setImage:image];
        [_faceImage setAlpha:0.5];
        [_nameLabel setText:name];
    }
    return self;
}

@end
