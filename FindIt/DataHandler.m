//
//  DataHandler.m
//  FindIt
//
//  Created by Satish Kumar on 12/06/16.
//  Copyright © 2016 VS. All rights reserved.reserved.
//

#import "DataHandler.h"
#import "AFHTTPRequestOperation.h"
#import "Constants.h"

#define MAX_REQUEST_IN_QUEUE 20
#define DUMMY @"DUMMY"

@interface DataHandler()
-(BOOL)isFolderPresent;
-(void)checkConfiguration;
-(NSString*)fileName:(NSString*) aFile;
-(void)removeKeyFromQueue:(NSString*)aRequest;
@end
@implementation DataHandler
@synthesize documentDirectory,requester,commonQueue,requestKeys,currentRequestKeys,primaryUrl,secondaryUrl;

static DataHandler *provider = nil;
+(DataHandler *)provider{
    // singleton being initialized.
    if (provider != nil){
        return provider;
    }
    // Allocates once with Grand Central Dispatch (GCD) routine.
    // It's thread safe.
    static dispatch_once_t safer;
    dispatch_once(&safer, ^(void){
        provider = [[DataHandler alloc] init];
        provider.primaryUrl = nil;
        provider.requester = nil;
        provider.secondaryUrl = nil;
        provider.requestKeys = [NSMutableDictionary dictionary];
        NSOperationQueue* aQueue = [[NSOperationQueue alloc] init];
        [aQueue setMaxConcurrentOperationCount:5];
        [provider setCommonQueue:aQueue];
        provider.requestKeys = [NSMutableDictionary dictionary];
        provider.currentRequestKeys = nil;
        [provider performSelector:@selector(checkConfiguration)];
        
    });
    return provider;
}
-(id)initWithImageRequester:(id<DataRequester>) aRequester{
	self = [super init];
	if (self) {
		self.primaryUrl = nil;
        self.requester = aRequester;
		self.secondaryUrl = nil;
		self.requestKeys = [NSMutableDictionary dictionary];
		NSOperationQueue* aQueue = [[NSOperationQueue alloc] init];
		[aQueue setMaxConcurrentOperationCount:5];
		[self setCommonQueue:aQueue];
        self.requestKeys = [NSMutableDictionary dictionary];
		self.currentRequestKeys = nil;
		[self performSelector:@selector(checkConfiguration)];
	}
	return self;
}



-(void)checkConfiguration{
	NSString *path;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	path = [[paths objectAtIndex:0] stringByAppendingPathComponent:APPLICATION_NAME];
	NSError *error;
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])	//Does directory already exist?
	{
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }else{
		if (![[NSFileManager defaultManager] createDirectoryAtPath:path
									   withIntermediateDirectories:NO
														attributes:nil
															 error:&error])
		{
			NSLog(@"Create directory error: %@", error);
		}
	}
	
	documentDirectory = [[NSString alloc] initWithString:path];
}

-(BOOL)isFolderPresent{
    
    BOOL isOk;
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentDirectory isDirectory:&isOk])	//Does directory already exist?
    {
        [self performSelector:@selector(checkConfiguration)];
    }
    return isOk;
}

-(BOOL)deleateCache{
	return [[NSFileManager defaultManager] removeItemAtPath:documentDirectory error:nil];
}



-(NSString*)fileName:(NSString*) aFile{
	return [documentDirectory stringByAppendingPathComponent:aFile];
}



-(NSData*)imageForUrl:(NSString*) aUrl{
	NSData* imgData = nil;
    if (aUrl) {
        NSArray* ar = [aUrl componentsSeparatedByString:@"/"];
        if (ar && [ar count] > 0) {
            NSString* p = [self fileName:[ar lastObject]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:p]){
                imgData =  [NSData dataWithContentsOfFile:p]; 
            }
        }
        
        if (imgData == nil) {
            if ([requestKeys objectForKey:aUrl] == nil) {
                [requestKeys setObject:DUMMY forKey:aUrl];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                {
                    [self addRequestToQueue:aUrl];
                });
			}
            
            
		} 
    }
	return imgData;
}

-(void)addRequestToQueue:(NSString*) aUrl{
    NSString* str = aUrl;
    NSString* urlpath  = [NSString stringWithFormat:@"%@",[str stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
    NSLog(@"URL:%@",urlpath);
    NSString* path = nil;
    NSArray* ar = [str componentsSeparatedByString:@"/"];
    if (ar && [ar count] > 0) {
        path = [self fileName:[ar lastObject]];
    }
    NSURL* url = [NSURL URLWithString:urlpath];
    if(url == nil || path == nil)
        return;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded file to %@", path);
        [self removeKeyFromQueue:str];
        [self isFolderPresent];
        [requester notifyDataLoaded];
        //NSLog(@"Success: Current Request in Queue : %d: Request Count %d",[commonQueue operationCount],[requestKeys count]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self removeKeyFromQueue:str];
        //NSLog(@"Error: Current Request in Queue : %d : Request Count %d",[commonQueue operationCount],[requestKeys count]);
        [self isFolderPresent];
        
    }];
    [commonQueue addOperation:operation];
    
    //NSLog(@"Resource added to Queue: %@",aUrl);
}

-(void)removeKeyFromQueue:(NSString*)aRequest{
    dispatch_async(dispatch_get_main_queue(), ^{
        [requestKeys removeObjectForKey:aRequest];
        return;
    });
}
-(NSURL*)pathForResource:(NSString*) aFile{
	NSLog(@"Resource Path: %@",aFile);
	NSURL* anUrl = nil;
    if (aFile) {
		NSArray* ar = [aFile componentsSeparatedByString:@"/"];
        if (ar && [ar count] > 0) {
            NSString* p = [self fileName:[ar lastObject]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:p])
        {
            anUrl = [NSURL fileURLWithPath:p];
        }else{
			if ([requestKeys objectForKey:aFile] == nil) {
                [requestKeys setObject:DUMMY forKey:aFile];
				[self addRequestToQueue:aFile];
			}
		}
	}

    }
		
	return anUrl;
}

-(NSString*)downloadPathForResource:(NSString*) aFile{
	return [self fileName:aFile];
}

-(void)removeCachedResourceAtPath:(NSString*) aPath{
    if (aPath) {
        [[NSFileManager defaultManager] removeItemAtPath:aPath error:nil];
    }
}

@end
