//
//  StartScene.m
//  Sloth Block
//
//  Created by Ryan Temple on 2/2/14.
//  Copyright (c) 2014 Ryan Temple. All rights reserved.
//

#import "StartScene.h"
#import "FMMParallaxNode.h"
#import "SlothMyScene.h"
#import "SoundManager.h"
#import "StartScene.h"
#import "Instructions.h"

@implementation StartScene{
    FMMParallaxNode *_skyBackground;
    FMMParallaxNode *_trainTracks;
    FMMParallaxNode *_parallax1;
    FMMParallaxNode *_parallax;
    
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        [SoundManager sharedManager].allowsBackgroundMusic = YES;
        [[SoundManager sharedManager] prepareToPlay];
        
        SKEffectNode *blurEffect = [[SKEffectNode alloc]init];
        blurEffect.shouldEnableEffects = true;
        blurEffect.filter = [self blurFilter];
        blurEffect.position = self.view.center;
        blurEffect.blendMode = SKBlendModeAdd;
        //[blurEffect addChild: self.scene];
        [self addChild:blurEffect];
        
        //Parallax backgrounds
        NSArray *parallaxBackgroundNames = @[@"Sky-05.png", @"Sky-04.png", @"Sky-01.png", @"Sky-02.png", @"Sky-03.png"];
        CGSize planetSizes = CGSizeMake(1000, 320);
        _skyBackground = [[FMMParallaxNode alloc] initWithBackgrounds:parallaxBackgroundNames
                                                                 size:planetSizes
                                                 pointsPerSecondSpeed:5];
        _skyBackground.position = CGPointMake(0, 250);
        [self addChild:_skyBackground];
        
        
        NSArray *parallaxBackground2Names = @[ @"Farbackground1-03.png", @"Farbackground1-01.png"];
        CGSize planet1Sizes = CGSizeMake(1000, 276);
        
        _parallax1 = [[FMMParallaxNode alloc] initWithBackgrounds:parallaxBackground2Names
                                                             size:planet1Sizes
                                             pointsPerSecondSpeed:20];
        _parallax1.position = CGPointMake(0, 185);
        //[_parralax1 randomizeNodesPositions];
        [self addChild:_parallax1];
        
        //Add the particles in
        
        NSArray *parallaxNigga = @[ @"Midbackground-03.png",@"Midbackground-01.png"];
        CGSize planetsSIZE = CGSizeMake(1000, 320);
        
        _parallax = [[FMMParallaxNode alloc] initWithBackgrounds:parallaxNigga
                                                            size:planetsSIZE
                                            pointsPerSecondSpeed:40];
        _parallax.position = CGPointMake(0, 0);
        //[_parralax1 randomizeNodesPositions];
        [self addChild:_parallax];
        
        //6
        NSArray *traintracks = @[@"TrainTracks.png", @"TrainTracks.png"];
        CGSize planet2Sizes = CGSizeMake(320, 34);
        _trainTracks = [[FMMParallaxNode alloc] initWithBackgrounds:traintracks
                                                               size:planet2Sizes
                                               pointsPerSecondSpeed:70];
        _trainTracks.position = CGPointMake(0, 25);
        [self addChild:_trainTracks];
        
        SKSpriteNode *slothToss = [SKSpriteNode spriteNodeWithImageNamed:@"SlothToss-01.png"];
        slothToss.size = CGSizeMake(320, 600);
        slothToss.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame)+330);
        [self addChild:slothToss];
        
        playAgain = [SKSpriteNode spriteNodeWithImageNamed:@"Play.png"];
        playAgain.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        playAgain.size = CGSizeMake(80, 48);
        [self addChild:playAgain];
        
        
        //SKAction *animateSlothTossTitle = [SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+240)  duration:.2];

        //[slothToss runAction:animateSlothTossTitle];
    }
    return self;
}
-(CIFilter*)blurFilter{
    CIFilter *filter = [CIFilter filterWithName:@"CIBoxBlur"]; // 3
    [filter setDefaults];
    [filter setValue:[NSNumber numberWithFloat:20] forKey:@"inputRadius"];
    return filter;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:self];
        
        if([playAgain containsPoint:location])
        {
            [[SoundManager sharedManager] playSound:@"button-10.mp3" looping:NO];

            SKTransition *transition = [SKTransition fadeWithColor:[UIColor whiteColor] duration:1.0];
            SKScene *newGame = [[Instructions alloc]initWithSize:self.size];
            [self.view presentScene:newGame transition:transition];
        }
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered*/
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    
    //Update background (parallax) position
    [_trainTracks update:currentTime];
    [_parallax1 update:currentTime];
    [_parallax update:currentTime];
    [_skyBackground update:currentTime];
    
    
}

@end
