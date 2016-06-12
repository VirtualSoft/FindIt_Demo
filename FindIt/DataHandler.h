//
//  DataHandler.h
//  FindIt
//
///  Created by Satish Kumar on 12/06/16.
//  Copyright © 2016 VS. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol DataRequester <NSObject>
@optional
-(void)notifyDataLoaded;
-(void)notifyDataError;
@end
@interface DataHandler : NSObject {
@private
    NSOperationQueue* commonQueue;
	NSMutableDictionary* requestKeys;
	NSDictionary* currentRequestKeys;
	NSString* primaryUrl;
	NSString* secondaryUrl;
	id<DataRequester> requester;
	NSString* documentDirectory;
}

@property(nonatomic,readonly) NSString* documentDirectory;
@property(nonatomic,strong) id<DataRequester> requester;
@property(nonatomic,strong) NSString* primaryUrl;
@property(nonatomic,strong) NSString* secondaryUrl;
@property(nonatomic,strong) NSOperationQueue* commonQueue;
@property(nonatomic,strong) NSDictionary* currentRequestKeys;
@property(nonatomic,strong) NSMutableDictionary* requestKeys;

+(DataHandler *)provider;
-(id)initWithImageRequester:(id) aRequester;
-(NSData*)imageForUrl:(NSString*) aUrl;
-(BOOL)deleateCache;
-(NSURL*)pathForResource:(NSString*) aUrl;
-(NSString*)downloadPathForResource:(NSString*) aFile;
-(void)removeCachedResourceAtPath:(NSString*) aPath;
-(void)addRequestToQueue:(NSString*) aUrl;
@end
