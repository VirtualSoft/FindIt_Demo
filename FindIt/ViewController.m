//
//  ViewController.m
//  FindIt
//
//  Created by Satish Kumar on 10/06/16.
//  Copyright © 2016 VS. All rights reserved.
//
#include <stdlib.h>
#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "ImageCell.h"
#import "RequestManager.h"
#import "Photo.h"
#import "Constants.h"

@interface ViewController ()
    @property (nonatomic, strong) IBOutlet UICollectionView *gridView;
    @property (nonatomic, strong) IBOutlet UIImageView *imgCurrent;
@property (nonatomic, assign) IBOutlet UILabel* lblTimer,*lblCountCorrect,*lblTotalAttempts;
    @property (nonatomic, strong) NSArray* arrData;
@property (nonatomic, strong) NSTimer* viewTimer;
    @property (nonatomic, strong) NSMutableArray* arrFound;
    @property (nonatomic, strong) Photo* currentPhoto;
    @property (assign) BOOL isGameModeOn;
    @property (assign) NSInteger tapCount;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataProvider = [DataHandler provider];
    self.arrFound = [NSMutableArray array];
    self.dataProvider.requester = self;
    self.isGameModeOn = NO;_tapCount=0;
    self.lblCountCorrect.text = [NSString stringWithFormat:@"%d",(int)self.arrFound.count];
    self.lblTotalAttempts.text = [NSString stringWithFormat:@"%d",0];
    [self.gridView registerClass:[ImageCell class] forCellWithReuseIdentifier:@"ImageCell"];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(103, 103)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self.imgCurrent.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [self.imgCurrent.layer setBorderWidth:1.0f];
    [self.gridView setCollectionViewLayout:flowLayout];
    __block ViewController* parent = self;
    [[RequestManager manager] loadData:^(NSArray *arr){
        [parent reloadData:arr];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //NSMutableArray *sectionArray = [self.dataArray objectAtIndex:section];
    return 3;//[sectionArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
   
    
    static NSString *cellIdentifier = @"ImageCell";
    
    ImageCell *cell = (ImageCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if(cell == nil){
        cell = (ImageCell*)[[[NSBundle mainBundle] loadNibNamed:@"ImageCell" owner:self options:nil] objectAtIndex:0];
    }
    
    NSArray* arrData = self.arrData;//[[DataManager manager] arrPhotos];
    NSInteger index = (indexPath.section*3)+(indexPath.row%3);
    
    Photo* aPhoto = [arrData objectAtIndex:index];
    [self updateCell:cell withPhoto:aPhoto];
   
    return cell;
    
}

-(void)updateCell:(ImageCell*) cell withPhoto:(Photo*) photo{
    [cell.contentView.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [cell.contentView.layer setBorderWidth:1.0f];
    [cell setPhoto:photo];
    [cell.btnFlip addTarget:self action:@selector(imageTapped:) forControlEvents:UIControlEventTouchUpInside];
    if(_isGameModeOn)
        return;
    NSData* data = [self.dataProvider imageForUrl:photo.url];
    if(data){
        cell.imgView.image = [UIImage imageWithData:data];
        [cell.photo setState:1];
        [cell setState:1];
    }else{
        [cell setState:2];
    }
}

-(void)selectNextPhoto{
    int index = arc4random_uniform(IMAGE_COUNT);
    Photo* aPhoto = (Photo*)[_arrData objectAtIndex:index];
    while (aPhoto.state == 3) {
        index = arc4random_uniform(IMAGE_COUNT);
        aPhoto = (Photo*)[_arrData objectAtIndex:index];
    }
    self.currentPhoto = aPhoto;
    NSData* data = [self.dataProvider imageForUrl:self.currentPhoto.url];
    if(data){
        self.imgCurrent.image = [UIImage imageWithData:data];
    }
    
}

-(void)flipAllImages{
    NSInteger len = [_arrData count];
    UIImage* img = [UIImage imageNamed:@"bg1.png"];
    for (int i = 0 ; i < len; i++) {
         Photo* aPhoto = [_arrData objectAtIndex:i];
        aPhoto.state = 1;
    }
    
    for(int section = 0; section < 3 ; section++){
        for (int col = 0; col < 3 ; col++) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:col inSection:section];
            ImageCell* cell = (ImageCell*)[self.gridView cellForItemAtIndexPath:indexPath];
            
            [UIView transitionWithView:cell.imgView
                              duration:0.4
                               options:UIViewAnimationOptionTransitionFlipFromRight
                            animations:^{
                                //  Set the new image
                                //  Since its done in animation block, the change will be animated
                                cell.imgView.image = img;
                            } completion:^(BOOL finished) {
                                //  Do whatever when the animation is finished
                            }];
        }
    }
}

-(void)imageTapped:(id) sender{
    if(!self.isGameModeOn)
        return;
    _tapCount++;
    self.lblTotalAttempts.text = [NSString stringWithFormat:@"%d",(int)_tapCount];
    long tag = (long)[((UIButton*)sender) tag];
    NSLog(@"Btn Tapped %ld",tag);
    ImageCell* cell = (ImageCell *) [sender superview].superview;
    
    //NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    NSInteger len = [_arrData count];
    for (int i = 0 ; i < len; i++) {
        Photo* aPhoto = [_arrData objectAtIndex:i];
        
        if(aPhoto.photoId == tag && aPhoto.state !=3){
            UIImage* img = nil;
            int state = aPhoto.state;
            if(state == 2){
                aPhoto.state = 1;
                img = [UIImage imageNamed:@"bg1.png"];
            }else if(state == 1){
                aPhoto.state = 2;
                img = [UIImage imageWithData:[[DataHandler provider] imageForUrl:aPhoto.url]];
            }
            
            [UIView transitionWithView:cell.imgView
                              duration:0.4
                 options:UIViewAnimationOptionTransitionFlipFromRight
              animations:^{
                  //  Set the new image
                  //  Since its done in animation block, the change will be animated
                  cell.imgView.image = [UIImage imageWithData:[[DataHandler provider] imageForUrl:aPhoto.url]];;
                  
              } completion:^(BOOL finished) {
                  if(_currentPhoto.photoId != aPhoto.photoId){
                      UIImage* img = [UIImage imageNamed:@"bg1.png"];
                      cell.state = 2;
                      [UIView transitionWithView:cell.imgView
                                        duration:0.4
                               options:UIViewAnimationOptionTransitionFlipFromLeft
                            animations:^{
                                //  Set the new image
                                //  Since its done in animation block, the change will be animated
                                cell.imgView.image = img;
                            } completion:^(BOOL finished) {
                                //  Do whatever when the animation is finished
                            }];
                  }else{
                      cell.state = 3;
                      if ([_arrFound indexOfObject:aPhoto] > 0) {
                          [self.arrFound addObject:_currentPhoto];
                          self.lblCountCorrect.text = [NSString stringWithFormat:@"%d",(int)self.arrFound.count];
                          if([self.arrFound count] == IMAGE_COUNT){
                              [self gameOver];
                          }else{
                              [self selectNextPhoto];
                          }
                      }
                      
                      
                  }
              }];
            break;
        }else if(aPhoto.photoId == tag && aPhoto.state ==3 ){
            UIImage* img = [UIImage imageWithData:[[DataHandler provider] imageForUrl:aPhoto.url]];
            cell.imgView.image = img;
        }
    }
}

-(UIImage*) imageForUrl:(NSString*) url{
    NSData* data = [self.dataProvider imageForUrl:url];
    if(data){
        return [UIImage imageWithData:data];
    }
    return nil;
}

-(void) reloadData:(NSArray*) arr{
    NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:arr];
    NSInteger len = [tempArr count];
    for (NSUInteger i = 0; i < len; ++i) {
        NSInteger nElements = len - i;
        NSInteger n = (arc4random() % nElements) + i;
        [tempArr exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    self.arrData = tempArr;//[[DataManager manager] arrPhotos];
    [self.gridView reloadData];
}

int count = 0;
-(void)notifyDataLoaded{
    ++count;
    NSLog(@"COUNT %d",count);
    if(count == 9){
        [self prepareGame];
    }
    if(self.currentPhoto != nil){
        NSData* data = [self.dataProvider imageForUrl:self.currentPhoto.url];
        if(data){
            self.imgCurrent.image = [UIImage imageWithData:data];
        }
    }
    [self.gridView reloadData];
}
-(void)notifyDataError{
    
}

int viewTime = 10;
-(void)onTick:(NSTimer *)timer {
    if(viewTime > 0){
        viewTime--;
    }
    if(viewTime == 0){
        _lblTimer.text = @"NA";
        [self flipAllImages];
        [self selectNextPhoto];
        self.isGameModeOn = YES;
        self.isGameModeOn = YES;
        [self.viewTimer invalidate];
        self.viewTimer = nil;
    }else{
        _lblTimer.text = [NSString stringWithFormat:@"%d",viewTime];
    }
}

-(void)prepareGame{
    self.viewTimer = [[NSTimer alloc] initWithFireDate: [NSDate date]
                                          interval: 1
                                            target: self
                                          selector:@selector(onTick:)
                                          userInfo:nil repeats:YES];
    
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:self.viewTimer forMode: NSDefaultRunLoopMode];
}

-(void)gameOver{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Game Over"
                                  message:@"Thanks for Playing, Play again?"
                                  preferredStyle:UIAlertControllerStyleAlert];
     __block ViewController* parent = self;
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes, please"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    [parent restartGame];
                                }];
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"No, thanks"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   self.isGameModeOn = NO;
                                   
                               }];
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(IBAction)btnTapped:(id)sender{
    if(!self.isGameModeOn){
        [self restartGame];
    }
}

-(void)restartGame{
    _tapCount=0;
    
    self.arrFound=[NSMutableArray array];
    self.arrData = [NSMutableArray array];
    self.currentPhoto = nil;
    self.isGameModeOn = NO;count = 0;
    self.dataProvider.requester = self;
    self.imgCurrent.image = [UIImage imageNamed:@"bg1.png"];
    __block ViewController* parent = self;viewTime = 10;
    _lblTimer.text = [NSString stringWithFormat:@"%d",viewTime];
    self.lblCountCorrect.text = [NSString stringWithFormat:@"%d",(int)self.arrFound.count];
    self.lblTotalAttempts.text = [NSString stringWithFormat:@"%d",0];
    [[RequestManager manager] loadData:^(NSArray *arr){
        [parent reloadData:arr];
    }];

}

@end
