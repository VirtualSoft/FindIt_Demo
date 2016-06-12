//
//  RequestManager.m
//  FindIt
//
//  Created by Satish Kumar on 11/06/16.
//  Copyright © 2016 VS. All rights reserved.
//

#import "RequestManager.h"
#import "Constants.h"
#import "AFNetworking.h"
#import "Photo.h"
@implementation RequestManager

static RequestManager *manager = nil;
+(RequestManager *)manager{
    // singleton being initialized.
    if (manager != nil){
        return manager;
    }
    // Allocates once with Grand Central Dispatch (GCD) routine.
    // It's thread safe.
    static dispatch_once_t safer;
    dispatch_once(&safer, ^(void){
                      manager = [[RequestManager alloc] init];
                  });
    return manager;
}

-(void)loadData:(void(^)(NSArray *))dataLoaded{
    
    NSArray* arrType = @[@"animal",@"actors",@"scenery",@"space",@"planets",@"birds",@"kids",@"mobile"];
    NSString* url = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&tags=%@&per_page=%d&format=json&nojsoncallback=1&page=%d",FLICKR_API_KEY,[arrType objectAtIndex:arc4random_uniform(7)],IMAGE_COUNT,arc4random_uniform(20)];
    NSMutableArray* arrData = [NSMutableArray array];
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response: %@",responseObject );
        
        NSArray *photos = [[responseObject objectForKey:@"photos"] objectForKey:@"photo"];
        
        for (NSDictionary *photo in photos) {
            // 3.a Get title for e/ photo
            NSString *pid = [photo objectForKey:@"id"];
            // 3.b Construct URL for e/ photo.
            NSString *photoUrl = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_s.jpg", [photo objectForKey:@"farm"], [photo objectForKey:@"server"], [photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
            [arrData addObject:[[Photo alloc] initWithId:pid andUrl:photoUrl]];
        }
        if([arrData count] >= 9){
            self.arrPhotos = [NSMutableArray arrayWithArray:[arrData subarrayWithRange: NSMakeRange( 0, 9 )]];
            dataLoaded(self.arrPhotos);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
  
}
-(void)reset{
    self.arrPhotos=nil;
}

@end
