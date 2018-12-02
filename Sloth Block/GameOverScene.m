//
//  GameOverScene.m
//  Sloth Block
//
//  Created by Ryan Temple on 2/3/14.
//  Copyright (c) 2014 Ryan Temple. All rights reserved.
//

#import "GameOverScene.h"
#import "SlothMyScene.h"
#import "StartScene.h"
#import "SoundManager.h"

@implementation GameOverScene
{
    FMMParallaxNode *_skyBackground;
    FMMParallaxNode *_trainTracks;
    FMMParallaxNode *_parallax1;
    FMMParallaxNode *_parallax;
    
}


-(id)initWithSize:(CGSize)size andScore:(int)score andHighScore:(int)highscore{
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        if(score>highscore) highscore = score;
        
        [SoundManager sharedManager].allowsBackgroundMusic = YES;
        [[SoundManager sharedManager] prepareToPlay];
        
        
        //Parallax backgrounds
        NSArray *parallaxBackgroundNames = @[@"Sky-05.png", @"Sky-04.png", @"Sky-01.png", @"Sky-02.png", @"Sky-03.png"];
        CGSize planetSizes = CGSizeMake(1000, 320);
        _skyBackground = [[FMMParallaxNode alloc] initWithBackgrounds:parallaxBackgroundNames
                                                                 size:planetSizes
                                                 pointsPerSecondSpeed:25];
        _skyBackground.position = CGPointMake(0, 250);
        [self addChild:_skyBackground];
        
        
        NSArray *parallaxBackground2Names = @[ @"Farbackground1-03.png", @"Farbackground1-01.png", @"Farbackground1-02.png", @"Farbackground1-04.png"];
        CGSize planet1Sizes = CGSizeMake(1000, 276);
        
        _parallax1 = [[FMMParallaxNode alloc] initWithBackgrounds:parallaxBackground2Names
                                                             size:planet1Sizes
                                             pointsPerSecondSpeed:50];
        _parallax1.position = CGPointMake(0, 175);
        //[_parralax1 randomizeNodesPositions];
        [self addChild:_parallax1];
        
        //Add the particles in
        [self addChild:[self loadEmitterNode:@"MyParticle"]];
        
        NSArray *parallaxNigga = @[ @"Midbackground-03.png",@"Midbackground-01.png", @"Midbackground-02.png", @"Midbackground-04.png", @"Midbackground-05.png", @"Midbackground-06.png"];
        CGSize planetsSIZE = CGSizeMake(1000, 320);
        
        _parallax = [[FMMParallaxNode alloc] initWithBackgrounds:parallaxNigga
                                                            size:planetsSIZE
                                            pointsPerSecondSpeed:90];
        _parallax.position = CGPointMake(0, 0);
        //[_parralax1 randomizeNodesPositions];
        [self addChild:_parallax];
        
        //6
        NSArray *traintracks = @[@"TrainTracks.png", @"TrainTracks.png"];
        CGSize planet2Sizes = CGSizeMake(320, 34);
        _trainTracks = [[FMMParallaxNode alloc] initWithBackgrounds:traintracks
                                                               size:planet2Sizes
                                               pointsPerSecondSpeed:170];
        _trainTracks.position = CGPointMake(0, 25);
        [self addChild:_trainTracks];
        
        SKSpriteNode *gameOverTemplate = [SKSpriteNode spriteNodeWithImageNamed:@"GameOver.png"];
        gameOverTemplate.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+90);
        gameOverTemplate.size = CGSizeMake(280, 250);
        [self addChild:gameOverTemplate];
        
        scoreLabel = [[SKLabelNode alloc]init];
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+98);
        scoreLabel.fontName = @"SF Archery Black";
        scoreLabel.fontSize = 24;
        scoreLabel.fontColor = [UIColor whiteColor];
        [scoreLabel setText:[NSString stringWithFormat:@"Berries caught: %i", score]];
        [self addChild:scoreLabel];
        
        highScoreLabel = [[SKLabelNode alloc]init];
        highScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+35);
        highScoreLabel.fontName = @"SF Archery Black";
        highScoreLabel.fontSize = 24;
        highScoreLabel.fontColor = [UIColor whiteColor];
        [highScoreLabel setText:[NSString stringWithFormat:@"High Score: %i", highscore]];
        [self addChild:highScoreLabel];
        
        playAgain = [SKSpriteNode spriteNodeWithImageNamed:@"Play.png"];
        playAgain.position = CGPointMake(CGRectGetMidX(self.frame)-70, CGRectGetMidY(self.frame)-53);
        playAgain.size = CGSizeMake(80, 48);
        [self addChild:playAgain];
        
        tweet = [SKSpriteNode spriteNodeWithImageNamed:@"Twitter.png"];
        tweet.position = CGPointMake(CGRectGetMidX(self.frame)+65, CGRectGetMidY(self.frame)-53);
        tweet.size = CGSizeMake(80, 48);
        [self addChild:tweet];
        
    }
    return self;
}

//Loads in the particle emitter file.
- (SKEmitterNode *)loadEmitterNode:(NSString *)emitterFileName
{
    NSString *emitterPath = [[NSBundle mainBundle] pathForResource:emitterFileName ofType:@"sks"];
    SKEmitterNode *emitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    
    //do some view specific tweaks
    emitterNode.particlePosition = CGPointMake(self.size.width/2.0, self.size.height/2.0);
    emitterNode.particlePositionRange = CGVectorMake(self.size.width+100, self.size.height);
    
    return emitterNode;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   // SKNode *menuNode = [self childNodeWithName:@"menuNode"];
    
    
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:self];
        NSLog(@"** TOUCH LOCATION ** \nx: %f / y: %f", location.x, location.y);
        
        if([playAgain containsPoint:location])
        {
            [[SoundManager sharedManager] playSound:@"button-10.mp3" looping:NO];

            SKTransition *transition = [SKTransition fadeWithColor:[UIColor whiteColor] duration:1.0];
            SKScene *newGame = [[StartScene alloc]initWithSize:self.size];
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
