//
//  SlothMyScene.m
//  Sloth Block
//
//  Created by Ryan Temple on 2/2/14.
//  Copyright (c) 2014 Ryan Temple. All rights reserved.
//

#import "SlothMyScene.h"
#import "FMMParallaxNode.h"
#import "SlothViewController.h"
#import "GameOverScene.h"
#import "Round2.h"
#import "SoundManager.h"

static const uint32_t slothCategory     =  0x1 << 0;
static const uint32_t berrieCategory   =  0x1 << 1;

@interface SlothMyScene() <SKPhysicsContactDelegate>
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) int berriesKilled;
//@property (nonatomic) int berriesSpawned;
@property (nonatomic) int highScore;
@property (nonatomic) int playerLives;
@property (getter = isPaused) BOOL paused;
@end

@implementation SlothMyScene {
    FMMParallaxNode *_skyBackground;
    FMMParallaxNode *_trainTracks;
    FMMParallaxNode *_parallax1;
    FMMParallaxNode *_parallax;
}

@synthesize hidden = isHidden;


-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        //Set the init variables.
        [SoundManager sharedManager].allowsBackgroundMusic = YES;
        [[SoundManager sharedManager] prepareToPlay];
        
        //[[SoundManager sharedManager] playMusic:@"KenRaps.mp3" looping:YES];
        
        isDamaged = NO;
        _berriesKilled = 0;
        _playerLives = 3;
        isHidden = YES;
        
        _highScore = [[[NSUserDefaults standardUserDefaults] objectForKey:@"High Score"] doubleValue];

        if (_highScore){
            if (_highScore < _berriesKilled){
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_berriesKilled] forKey:@"High Score"];
            }
        }
        else{
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_berriesKilled] forKey:@"High Score"];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        

        
        [self.scene.view setPaused:NO];
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
#pragma mark PARALLAX BACKGROUNDS
        
        //Parallax backgrounds
        NSArray *parallaxBackgroundNames = @[@"Sky-05.png", @"Sky-04.png", @"Sky-01.png", @"Sky-02.png", @"Sky-03.png"];
        CGSize planetSizes = CGSizeMake(1000, 320);
        _skyBackground = [[FMMParallaxNode alloc] initWithBackgrounds:parallaxBackgroundNames
                                                                 size:planetSizes
                                                 pointsPerSecondSpeed:75];
        _skyBackground.position = CGPointMake(0, 250);
        [self addChild:_skyBackground];
        
        
        NSArray *parallaxBackground2Names = @[ @"Farbackground1-03.png", @"Farbackground1-01.png", @"Farbackground1-02.png", @"Farbackground1-04.png"];
        CGSize planet1Sizes = CGSizeMake(1000, 276);
        
        _parallax1 = [[FMMParallaxNode alloc] initWithBackgrounds:parallaxBackground2Names
                                                             size:planet1Sizes
                                             pointsPerSecondSpeed:80];
        _parallax1.position = CGPointMake(0, 175);
        //[_parralax1 randomizeNodesPositions];
        [self addChild:_parallax1];
        
         //Add the particles in
        //[self addChild:[self loadEmitterNode:@"MyParticle"]];
        
        NSArray *parallaxNigga = @[ @"Midbackground-03.png",@"Midbackground-01.png", @"Midbackground-02.png", @"Midbackground-04.png", @"Midbackground-05.png", @"Midbackground-06.png"];
        CGSize planetsSIZE = CGSizeMake(1000, 320);
        
        _parallax = [[FMMParallaxNode alloc] initWithBackgrounds:parallaxNigga
                                                            size:planetsSIZE
                                            pointsPerSecondSpeed:500];
        _parallax.position = CGPointMake(0, 0);
        //[_parralax1 randomizeNodesPositions];
        [self addChild:_parallax];
        
        //6
        NSArray *traintracks = @[@"TrainTracks.png", @"TrainTracks.png"];
        CGSize trainTrackCGSize = CGSizeMake(320, 34);
        _trainTracks = [[FMMParallaxNode alloc] initWithBackgrounds:traintracks
                                                               size:trainTrackCGSize
                                               pointsPerSecondSpeed:1170];
        _trainTracks.position = CGPointMake(0, 25);
        [self addChild:_trainTracks];
        
        [self addChild:[self createSloth]];
        [self setUpSlothActions];
        
        instructions = [[SKLabelNode alloc]init];
        instructions.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+50);
        instructions.fontName = @"SF Archery Black";
        instructions.fontColor = [UIColor blackColor];
        instructions.text = @"Catch all the berries!";
        instructions.fontSize = 22;
        [self addChild:instructions];
        [instructions runAction:[SKAction fadeAlphaTo:0.0 duration:3.0] completion:^{
            [instructions removeFromParent];
        }];

        //Update the score
        scoreLabel = [[SKLabelNode alloc]init];
        scoreLabel.position = CGPointMake(150, 170);
        scoreLabel.fontName = @"SF Archery Black";
        scoreLabel.fontColor = [UIColor blackColor];
        scoreLabel.text = @"";
        scoreLabel.fontSize = 20;
        scoreLabel.name = @"scorelabel";
        [self addChild:scoreLabel];
        
        //update the lives
        amountOfLives = [[SKLabelNode alloc]init];
        amountOfLives.position = CGPointMake(150, 155);
        amountOfLives.fontName = @"SF Archery Black";
        amountOfLives.fontColor = [UIColor blackColor];
        amountOfLives.text = @"";
        amountOfLives.fontSize = 15;
        
        [self addChild:amountOfLives];
        
        //[self addChild:[self createPauseButton]];
        }
    return self;
}
#pragma mark VIBRATE
- (void)vibrate {
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}

#pragma mark PARTICLE
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


#pragma mark CREATE SLOTH
//Creates a sprite sloth object
-(SKSpriteNode*) createSloth{
    
    SKSpriteNode *sloth = [SKSpriteNode spriteNodeWithImageNamed:@"Sloths-01.png"];
    sloth.size = CGSizeMake(83, 121);
    sloth.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-193 );
    sloth.name = @"sloth";
    sloth.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sloth.size];
    sloth.physicsBody.dynamic = YES;
    sloth.physicsBody.categoryBitMask    = slothCategory;
    sloth.physicsBody.contactTestBitMask = berrieCategory;
    sloth.physicsBody.collisionBitMask   = 0;
    sloth.physicsBody.usesPreciseCollisionDetection = NO;
    
    return sloth;
}

#pragma mark SPAWN BERRIES

- (void)addBerry {
    
    berry = [SKSpriteNode spriteNodeWithImageNamed:@"Blue Berry"];
    berry.size = CGSizeMake(30, 40);
    berry.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:berry.size]; // 1
    berry.physicsBody.dynamic = YES; // 2
    berry.physicsBody.categoryBitMask = berrieCategory; // 3
    berry.physicsBody.contactTestBitMask = slothCategory; // 4
    berry.physicsBody.collisionBitMask = 0; // 5
    berry.name = @"berry";
    
    // Determine where to spawn the monster along the X axis
    int minX = berry.size.height / 2;
    int maxX = self.frame.size.width - berry.size.width / 2;
    int rangeY = maxX - minX;
    int actualX = (arc4random() % rangeY) + minX;

    
    // Create the monster slightly off-screen along the top edge,
    // and along a random position along the Y axis as calculated above
    berry.position = CGPointMake(actualX, self.frame.size.height + berry.size.height*2);
    
    [self addChild:berry];
    
    //Determine the rotation angle that the berries are spawned at
    int rotate = (arc4random() % 35);
    
    
    // Create the actions
    //For each individual berry
    SKAction * actionMove = [SKAction moveTo:CGPointMake(actualX, -berry.size.height/2) duration:[self determineSpeed]];
    SKAction * gameWon = [SKAction runBlock:^{
        if (_berriesKilled == -1) {
            [[SoundManager sharedManager] stopMusic];
            SKTransition *fade = [SKTransition fadeWithDuration:1.0];
            SKScene *nextRound = [[Round2 alloc]initWithSize:self.size andScore:_berriesKilled andLives:_playerLives+2 andHighScore:_highScore];
            [self.view presentScene:nextRound transition:fade];}}];
    
    SKAction * rotateBerry = [SKAction rotateByAngle:rotate duration:2];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    SKAction * loseAction = [SKAction runBlock:^{
        [self vibrate];
        [berry removeFromParent];
        [self subtractLives];
        
        if (_playerLives == 0)
        {
            //INSIDE THIS BLOCK OF CODE YOU DETERMINE WETHER THE NEW SCORE IS HIGHER THAN THE HIGH SCORE AND SET THE NEW HIGH SCORE TO THE CURRENT SCORE.
            if (_highScore){
                if (_highScore < _berriesKilled){
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_berriesKilled] forKey:@"High Score"];
                }
            }
            else{
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_highScore] forKey:@"High Score"];
            }
            
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[SoundManager sharedManager] stopMusic];
            
            SKTransition *reveal = [SKTransition fadeWithDuration:1.0];
            SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size andScore:_berriesKilled andHighScore:_highScore];
            [self.view presentScene:gameOverScene transition: reveal];}
    }];
    
    SKAction * berrie = [SKAction runBlock:^{
                                            [berry runAction:rotateBerry];
                                            [berry runAction:actionMove];
                                            }];
    
    [berry runAction:[SKAction sequence:@[berrie, gameWon, actionMove, loseAction, actionMoveDone]]];

        
}

-(double)determineSpeed{
    
    if (_berriesKilled <= 100) {
        return .85;
    } else if (_berriesKilled > 100 && _berriesKilled <= 250)
    {
        return .8;
    }else if (_berriesKilled > 250 &&_berriesKilled <= 500){
        return .9;
    }
    return .75;
}

-(double)determineAmountOfBerries{
    
    
    if (_berriesKilled <= 10) {
        return .9;
    } else if (_berriesKilled > 10 && _berriesKilled <= 25){
        return .6;
    } else if (_berriesKilled > 25 && _berriesKilled <= 39){
        return .5;
    } else if (_berriesKilled > 39 && _berriesKilled <= 50){
        return .45;
    }else if (_berriesKilled > 50 && _berriesKilled <= 75){
        return .4;
    } else if (_berriesKilled > 75 && _berriesKilled <= 100){
        return .3;
    } else if (_berriesKilled > 100 && _berriesKilled <=250){
        return .25;
    } else if (_berriesKilled > 250 && _berriesKilled <= 500){
        return .2;
    } else if (_berriesKilled > 500 && _berriesKilled <= 1000){
        return .14;
    } return .1;
}


#pragma mark SLOTH COLLISIONS
- (void)character:(SKSpriteNode *)sloth didCollideWithMonster:(SKSpriteNode*)berrie {
    
    isDamaged = YES;
    
    [sloth runAction:slothJumpAnimation];
    
    [self addPoint];
    [berrie removeFromParent];
    //[burstNode removeFromParent];
}

#pragma mark POINTS
//Call whenever you want to add a point
- (void)addPoint
{
    _berriesKilled++;
    [scoreLabel setText:[NSString stringWithFormat:@"%i", _berriesKilled]];
}


//Call whenever you want to subtract a point
-(void)subtractLives{
    _playerLives--;
    [amountOfLives setText:[NSString stringWithFormat:@"Lives: %i", _playerLives]];
}

#pragma mark SKSPHYSICS CONTACT
- (void)didBeginContact:(SKPhysicsContact *)contact {
    // 1
    //SKSpriteNode *sloth = (SKSpriteNode*)[self childNodeWithName:@"sloth"];

    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    // 2
    if ((firstBody.categoryBitMask & slothCategory) != 0 &&
        (secondBody.categoryBitMask & berrieCategory) != 0)
    {
        [self character:(SKSpriteNode *) firstBody.node didCollideWithMonster:(SKSpriteNode *) secondBody.node];
        
    }
}

#pragma mark MOVE SLOTH

//Move the sloth
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    SKSpriteNode *sloth = (SKSpriteNode*)[self childNodeWithName:@"sloth"];
    UITouch *myTouch = [touches anyObject];
    
    startPoint = [myTouch locationInNode:self];
    CGPoint lastPosition = [myTouch previousLocationInNode:self];
    CGPoint translation = CGPointMake(startPoint.x - lastPosition.x, startPoint.y - lastPosition.y);
    
    sloth.position = CGPointMake(lastPosition.x +translation.x, sloth.position.y);
    scoreLabel.position = CGPointMake(lastPosition.x + translation.x, scoreLabel.position.y);
    amountOfLives.position = CGPointMake(lastPosition.x + translation.x, amountOfLives.position.y);

}

#pragma mark SLOTH

-(void) setUpSlothActions {
    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"character"];
    
    SKTexture *slothMove1 = [atlas textureNamed:@"Sloths-01.png"];
    SKTexture *slothMove = [atlas textureNamed:@"Sloths-02.png"];
    SKTexture *slothMove2 = [atlas textureNamed:@"Sloths-03.png"];
    SKTexture *slothMove3 = [atlas textureNamed:@"Sloths-04.png"];
    
    NSArray *slothAtlas = @[ slothMove, slothMove2, slothMove3, slothMove2, slothMove, slothMove1];
    
    SKAction *slothAtlasAnimation = [SKAction animateWithTextures:slothAtlas timePerFrame:0.02];
    
    slothJumpAnimation = [SKAction sequence:@[slothAtlasAnimation]  ];
    
}

#pragma mark UPDATE TIME
-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered*/
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    SKAction *wait = [SKAction waitForDuration:2];
    [self runAction:wait completion:^
    { [self updateWithTimeSinceLastUpdate:timeSinceLast]; }];
    
    //Update background (parallax) position
    [_trainTracks update:currentTime];
    [_parallax1 update:currentTime];
    [_parallax update:currentTime];
    [_skyBackground update:currentTime];
    
}


- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;

    if (self.lastSpawnTimeInterval > [self determineAmountOfBerries]) {
    self.lastSpawnTimeInterval = 0;    [self addBerry];
    
    }
}
@end
