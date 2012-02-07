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
@property (strong, nonatomic) NSDictionary *photo;
@property (strong, nonatomic) NSURL *photoURL;
@end



@implementation PhotoScrollViewController


@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize photo = _photo;
@synthesize photoURL = _photoURL;

-(id)initWithPhoto: (NSDictionary*)photo
{
    self = [super init];
    
    //self = [self.storyboard instantiateInitialViewController];
    if (self) {
        self.photo = photo;  
    }
    return self;
}

-(NSURL *)photoURL
{
    if (!_photoURL) {
        _photoURL = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatOriginal];
        
    }
    return _photoURL;
}


-(UIImageView*) imageView
{
    if (!_imageView) {
        _imageView =[[UIImageView alloc]init];

    }
    return _imageView;
}

-(UIScrollView *)scrollView 
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    }
    return _scrollView;

}


//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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

-(void)viewWillAppear:(BOOL)animated
{
 
    self.scrollView.delegate = self;  
    UIActivityIndicatorView * spinner = [SingletonNetworkSpinner sharedNetworkWaitSpinner];
    spinner.center = self.view.center;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    [self saveToDatabase];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("Image downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSData *photoData = [NSData dataWithContentsOfURL:self.photoURL];
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
                
                //Manually add subView to the UIViewController, and then add scrollView
                [self.view addSubview:self.scrollView];
                [self.scrollView addSubview:self.imageView];
                
                //set zoom size
                self.scrollView.minimumZoomScale = 0.1;
                self.scrollView.maximumZoomScale = 5.0;
                
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

        return YES;

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


@end
