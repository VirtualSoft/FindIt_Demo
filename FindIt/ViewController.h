//
//  ViewController.h
//  FindIt
//
//  Created by Satish Kumar on 10/06/16.
//  Copyright © 2016 VS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataHandler.h"


@interface ViewController : UIViewController<DataRequester>

@property(strong) DataHandler* dataProvider;
-(void) reloadData:(NSArray*) arr;
-(UIImage*) imageForUrl:(NSString*) url;
@end

