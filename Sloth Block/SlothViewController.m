//
//  SlothViewController.m
//  Sloth Block
//
//  Created by Ryan Temple on 2/2/14.
//  Copyright (c) 2014 Ryan Temple. All rights reserved.
//

#import "SlothViewController.h"
#import "SlothMyScene.h"
#import "StartScene.h"

//IMPORTANT: THIS WILL MAKE YOUR APP RUN AT EITHER AN IPHONE 5 RESOLUTION OR A IPHONE 4 RESOLUTION. SEE THE VIEWDIDLOAD METHOD AND MAKE SURE THAT YOU ARE EDITING THE CORRECT PHONE SIZE.

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@implementation SlothViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if (IS_WIDESCREEN) {
        
        //4 inch screen
        //score.text = @"4 inch screen";
        
        SKView *skView = (SKView *)self.view;
        if (!skView.scene) {
            skView.showsFPS = YES;
            skView.showsNodeCount = YES;
            
            // Create and configure the scene.
            SKScene *title = [StartScene sceneWithSize:skView.bounds.size];
            title.scaleMode = SKSceneScaleModeAspectFill;
            
            // Present the scene.
            [skView presentScene:title];
        }
        
        
    }else {
        
        //3.5 inch screen
       // score.text = @"3.5 inch screen";
    }
    
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    // Configure the view.
    // Configure the view after it has been sized for the correct orientation.
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
