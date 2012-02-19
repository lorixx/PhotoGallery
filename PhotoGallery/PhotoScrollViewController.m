//
//  PhotoScrollViewController.m
//  PhotoGallery
//
//  Created by Zhisheng Huang on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoScrollViewController.h"
#import "FlickrFetcher.h"
#import "SingletonNetworkSpinner.h"


@interface PhotoScrollViewController() <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) NSURL *photoURL;

@end



@implementation PhotoScrollViewController


@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize photo = _photo;
@synthesize photoURL = _photoURL;
@synthesize navBar = _navBar;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;  //this is due to conforming to a protocol


/* Here is how we set up toobar item for split view in potrait mode */
-(void) setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (_splitViewBarButtonItem != splitViewBarButtonItem) {
        [self.navBar.topItem setLeftBarButtonItem:splitViewBarButtonItem animated:NO];
        
    }
}


-(void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
}

-(void)setImageView:(UIImageView *)imageView
{
    _imageView = imageView;
}

-(NSURL *)photoURL
{
    if (!_photoURL) {
        _photoURL = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatOriginal];
        
    }
    return _photoURL;
}


- (void) saveToDatabase
{
    NSUserDefaults *defaultDataBase = [NSUserDefaults standardUserDefaults];
    NSMutableArray*recentPhotos = [[defaultDataBase objectForKey:RECENT_PHOTOS] mutableCopy];
    
    if (!recentPhotos) {
        recentPhotos =  [[NSMutableArray alloc]initWithObjects:self.photo, nil];
    } else {
        for (id photo in recentPhotos) {
            if([photo objectForKey:FLICKR_PHOTO_ID] == [self.photo objectForKey:FLICKR_PHOTO_ID]){
                [recentPhotos removeObject:photo];
                break;  
            }
        }
        
        [recentPhotos insertObject:self.photo atIndex:0];
    }
    [defaultDataBase setObject:recentPhotos forKey:RECENT_PHOTOS];
    if(![defaultDataBase synchronize]) NSLog(@"Error when save data to NSDefault..."); 
}


#pragma mark - View lifecycle

#define TEN_MEGABYTES 10*1024*1024
-(void)viewWillAppear:(BOOL)animated
{
 
    self.scrollView.delegate = self;  
    UIActivityIndicatorView * spinner = [SingletonNetworkSpinner sharedNetworkWaitSpinner];
    spinner.center = self.view.center;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    [self saveToDatabase];  //save this photo to NSUserDefault
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("Image downloader", NULL);
    dispatch_async(downloadQueue, ^{
        /* Check if file exist, then dont need to get file from remote, otherwise get file from remote then save it to cache */
        NSString *photoId = [self.photo objectForKey:FLICKR_PHOTO_ID];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSArray *array = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
        NSURL *cacheDirectory = [array objectAtIndex:0]; 
        NSMutableString *filePath = [[NSMutableString alloc]initWithString:[cacheDirectory path]];
        [filePath appendString:@"/"];
        [filePath appendString:photoId];
        [filePath appendString:@".jpg"];
        NSData *photoData;
        if([fileManager fileExistsAtPath:filePath]){
            photoData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
            
        } else{
            photoData = [NSData dataWithContentsOfURL:self.photoURL];
            //save to cache, if over limit, delete the oldest created one
            NSInteger newPhotoSize = [photoData length];
            NSInteger currentSize =  [self calculateSizeForAllFiles:[fileManager contentsOfDirectoryAtPath:[cacheDirectory path] error:nil] onDirectoryPath:[cacheDirectory path]];
            NSArray *allFiles = [fileManager contentsOfDirectoryAtPath:[cacheDirectory path] error:nil];
            
            while (currentSize + newPhotoSize > TEN_MEGABYTES) {  /* Make sure the cache uses no more than 10 MB*/
                allFiles = [fileManager contentsOfDirectoryAtPath:[cacheDirectory path] error:nil]; //refresh the whole array
                NSString *firstFilePath = [allFiles objectAtIndex:0];
                NSMutableString *firstFileFullPath = [[NSMutableString alloc]initWithString:[cacheDirectory path]];
                [firstFileFullPath appendString:@"/"];
                [firstFileFullPath appendString:firstFilePath];
                [fileManager removeItemAtPath:firstFileFullPath error:nil];
                currentSize = [self calculateSizeForAllFiles:[fileManager contentsOfDirectoryAtPath:[cacheDirectory path] error:nil] onDirectoryPath:[cacheDirectory path]];;
            }
            
            //add file to cache
            [photoData writeToFile:filePath atomically:YES];
        }  
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (!photoData) {
                [spinner stopAnimating];
                UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 125.0f, 30.0f)];
                aLabel.center = self.view.center;
                aLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
                [self.view addSubview:aLabel];
                aLabel.text = @"No Data";
                aLabel.textAlignment = UITextAlignmentCenter;
                [aLabel autoresizesSubviews];
            } else{
                self.imageView.image = [UIImage imageWithData:photoData];
                self.scrollView.contentSize = self.imageView.image.size;
                self.imageView.frame = CGRectMake(0,0, self.imageView.image.size.width, self.imageView.image.size.height);
                [spinner stopAnimating]; 
            }
        });
    });
    dispatch_release(downloadQueue);
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}



- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setScrollView:nil];
    self.photoURL = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




#pragma mark - Sort files in directory based on modified date

-(NSInteger) calculateSizeForAllFiles:(NSArray *)files onDirectoryPath: (NSString *)directoryPath
{
    NSInteger totalSize = 0;
    NSMutableString *fullFilePath = [[NSMutableString alloc]initWithString:@""];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    for ( NSString *filePath in files) {
        [fullFilePath appendString:directoryPath];
        [fullFilePath appendString:@"/"];
        [fullFilePath appendString:filePath];
        totalSize +=[[fileManager contentsAtPath:fullFilePath]length];
        [fullFilePath setString: @""];
    }
        return totalSize;  
}




@end
