//
//  ImageCell
//  FindIt
//
//  Created by Satish Kumar on 10/06/16.
//  Copyright © 2016 VS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

@interface ImageCell : UICollectionViewCell
@property(nonatomic,assign) IBOutlet UIActivityIndicatorView* vSpinner;
@property(nonatomic,assign) IBOutlet UIImageView* imgView;
@property(nonatomic,assign) IBOutlet UIButton* btnFlip;
@property(nonatomic,assign) int state;
@property(nonatomic,strong) Photo* photo;
@end
