//
//  Photo.m
//  FindIt
//
//  Created by Satish Kumar on 12/06/16.
//  Copyright © 2016 VS. All rights reserved.
//

#import "Photo.h"

@implementation Photo
-(id)initWithId:(NSString*) anId andUrl:(NSString*) anUrl{
    self = [super init];
    if (self) {
        self.photoId = anId;
        self.url = anUrl;
    }
    return self;
}

-(void)notifyDataLoaded{
    self.state = 1;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageLoaded" object:self];
}
-(void)notifyDataError{
    self.state = 0;
}

@end
