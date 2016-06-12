//
//  RequestManager.h
//  FindIt
//
//  Created by Satish Kumar on 11/06/16.
//  Copyright © 2016 VS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestManager : NSObject
@property(nonatomic,strong) NSMutableArray* arrPhotos;
+(RequestManager *)manager;
-(void)loadData:(void(^)(NSArray *))dataLoaded;
-(void)reset;

@end
