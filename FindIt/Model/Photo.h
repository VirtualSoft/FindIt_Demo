//
//  Photo.h
//  FindIt
//
//  Created by Satish Kumar on 12/06/16.
//  Copyright © 2016 VS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataHandler.h"

@interface Photo : NSObject<DataRequester>
@property(strong) NSString* photoId;
@property(strong) NSString* url;
@property(assign) int state;

-(id)initWithId:(NSString*) anId andUrl:(NSString*) anUrl;
@end
	