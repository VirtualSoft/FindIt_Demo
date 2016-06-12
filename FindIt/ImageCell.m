//
//  ImageCell.m
//  FindIt
//
//  Created by Satish Kumar on 10/06/16.
//  Copyright © 2016 VS. All rights reserved.
//

#import "ImageCell.h"
#import "DataHandler.h"

@implementation ImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"ImageCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
        
    }
    
    return self;
}

-(void)setState:(int) aState {
    _state = aState;
    self.photo.state=_state;
    [self.btnFlip setTag:self.photo.photoId];
    if(_state == 1){
        [self.vSpinner stopAnimating];
    }
    
    
}



@end
