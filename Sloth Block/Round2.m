//
//  Round2.m
//  Sloth Block
//
//  Created by Ryan Temple on 2/8/14.
//  Copyright (c) 2014 Ryan Temple. All rights reserved.
//

#import "Round2.h"
#import "SlothMyScene.h"
#import "GameOverScene.h"
#import "FMMParallaxNode.h"
#import "SoundManager.h"


static const uint32_t slothCategory     =  0x1 << 0;
static const uint32_t berrieCategory   =  0x1 << 1;

@interface Round2() <SKPhysicsContactDelegate>
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) int berriesSpawned;
@property (nonatomic) int berriesKilled;
@property (nonatomic) int playerLives;
@end


@implementation Round2 {
    FMMParallaxNode *_skyBackground;
    FMMParallaxNode *_trainTracks;
    FMMParallaxNode *_parallax1;
    FMMParallaxNode *_parallax;
    
}

-(id)initWithSize:(CGSize)size andScore:(int)score andLives:(int)lives andHighScore:(int)highScore{
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        [SoundManager sharedManager].allowsBackgroundMusic = YES;
        [[SoundManager sharedManager] prepareToPlay];
        
        [[SoundManager sharedManager] playMusic:@"KenRaps.mp3" looping:YES];
        
        isDamaged = NO;
        _berriesKilled = score;
        _playerLives = lives;
        
        NSLog(@"SKScene:initWithSize %f x %f",size.width,size.height);
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
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
        _parallax1.position = CGPointMake(0, 185);
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
        
        [self addChild:[self createSloth]];
        [self setUpSlothActions];
        
        scoreLabel = [[SKLabelNode alloc]init];
        scoreLabel.position = CGPointMake(150, 170);
        scoreLabel.fontName = @"SF Archery Black";
        scoreLabel.fontColor = [UIColor blackColor];
        scoreLabel.text = @"";//[NSString stringWithFormat:@"%i", _berriesKilled];
        scoreLabel.fontSize = 20;
        [self addChild:scoreLabel];
        
        livesLabel = [[SKLabelNode alloc]init];
        livesLabel.position = CGPointMake(150, 155);
        livesLabel.fontName = @"SF Archery Black";
        livesLabel.fontColor = [UIColor blackColor];
        livesLabel.text = @"";//[NSString stringWithFormat:@"Lives: %i", _playerLives];
        livesLabel.fontSize = 15;
        [self addChild:livesLabel];
    }
    return self;
}
#pragma mark VIBRATE
- (void)vibrate {
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
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

//Creates a sprite sloth object
-(SKSpriteNode*) createSloth{
    
    SKSpriteNode *sloth = [SKSpriteNode spriteNodeWithImageNamed:@"Sloths-01.png"];
    sloth.size = CGSizeMake(83, 121);
    sloth.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-193 );
    sloth.name = @"sloth";
    //Creates a physics body for the sprite. In this case, the body is defined as a rectangle of the same size of the sprite, because that’s a decent approximation for the monster.
    sloth.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sloth.size];
    
    //Sets the sprite to be dynamic. This means that the physics engine will not control the movement of the monster – you will through the code you’ve already written (using move actions).
    sloth.physicsBody.dynamic = YES;
    
    //Sets the category bit mask to be the monsterCategory you defined earlier.
    sloth.physicsBody.categoryBitMask    = slothCategory;
    
    
    //The contactTestBitMask indicates what categories of objects this object should notify the contact listener when they intersect. You choose projectiles here.
    sloth.physicsBody.contactTestBitMask = berrieCategory;
    
    //The collisionBitMask indicates what categories of objects this object that the physics engine handle contact responses to (i.e. bounce off of). You don’t want the monster and projectile to bounce off each other – it’s OK for them to go right through each other in this game – so you set this to 0.
    sloth.physicsBody.collisionBitMask   = 0;
    sloth.physicsBody.usesPreciseCollisionDetection = NO;
    
    
    return sloth;
}

- (void)addBerry {
    
    int highScore = [[[NSUserDefaults standardUserDefaults] objectForKey:@"High Score"] doubleValue];

    //Create red berry
     SKSpriteNode * red = [SKSpriteNode spriteNodeWithImageNamed:@"Red Berry@2x"];
     red.size = CGSizeMake(30, 40);
     red.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:red.size]; // 1
     red.physicsBody.dynamic = YES; // 2
     red.physicsBody.categoryBitMask = berrieCategory; // 3
     red.physicsBody.contactTestBitMask = slothCategory; // 4
     red.physicsBody.collisionBitMask = 0; // 5
    
    
    // Determine where to spawn the monster along the Y axis
    int minX = red.size.height / 2;
    int maxX = self.frame.size.width - red.size.width / 2;
    int rangeY = maxX - minX;
    int actualX = (arc4random() % rangeY) + minX;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    red.position = CGPointMake(actualX, self.frame.size.height + red.size.height*2);
    [self addChild:red];
    
    //Determine the rotation angle that the berries are spawned at
    int rotate = (arc4random() % 35);
    
    
    // Create the actions
    //For each individual berry
    SKAction * actionMove = [SKAction moveTo:CGPointMake(actualX, -red.size.width/2) duration:[self determineSpeed]];
    SKAction * gameWon = [SKAction runBlock:^{
        if (_berriesKilled == 2000) {
            SKTransition *fade = [SKTransition fadeWithDuration:1.0];
            SKScene *nextRound = [[Round2 alloc]initWithSize:self.size andScore:_berriesKilled andLives:_playerLives andHighScore:highScore];
            [self.view presentScene:nextRound transition:fade];
        }
    }];
    SKAction * rotateBerry = [SKAction rotateByAngle:rotate duration:2];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    SKAction * loseAction = [SKAction runBlock:^{
        [self subtractLives];
        [self vibrate];
        NSLog(@"Lost a life");
        if (_playerLives == 0){
            if (highScore){
                if (highScore < _berriesKilled){
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_berriesKilled] forKey:@"High Score"];
                }
            }
            else{
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_berriesKilled] forKey:@"High Score"];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
            SKTransition *reveal = [SKTransition fadeWithDuration:1.0];
            SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size andScore:_berriesKilled andHighScore:highScore];
            [self.view presentScene:gameOverScene transition: reveal];
        }
    }];
    SKAction *berrie = [SKAction runBlock:^{
        [red runAction:rotateBerry];
        [red runAction:actionMove];
    }];
    
#pragma mark Assign Color Berries
  
    [red runAction:[SKAction sequence:@[berrie,gameWon, actionMove,  loseAction, actionMoveDone]]];
    
    
}

-(double)determineSpeed{
    
    if (_berriesKilled <= 300) {
        return .8;
    } else if (_berriesKilled > 350 && _berriesKilled <= 500)
    {
        return .7;
    }else if (_berriesKilled > 500 &&_berriesKilled <= 1000){
        return .6;
    } else if (_berriesKilled > 1000 && _berriesKilled <= 2000){
        return .5;
    }
    return .75;
}


-(double)determineAmountOfBerries{
    
    if (_berriesKilled <= 300) {
        return .9;
    } else if (_berriesKilled > 300 && _berriesKilled <= 350){
        return .85;
    } else if (_berriesKilled > 350 && _berriesKilled <= 400){
        return .8;
    } else if (_berriesKilled > 400 && _berriesKilled <= 600){
        return .75;
    }else if (_berriesKilled > 600 && _berriesKilled <= 800){
        return .65;
    } else if (_berriesKilled > 800 && _berriesKilled <= 1000){
        return .6;
    } else if (_berriesKilled > 1000 && _berriesKilled <=1250){
        return .55;
    } else if (_berriesKilled > 1250 && _berriesKilled <= 1500){
        return .5;
    } else if (_berriesKilled > 1500 && _berriesKilled <= 2000){
        return .4;
    }
    return 1;
}


- (void)character:(SKSpriteNode *)sloth didCollideWithMonster:(SKSpriteNode *)berry {
    
    isDamaged = YES;
    
    //[self runAction:[SKAction playSoundFileNamed:@"Smack.mp3" waitForCompletion:NO]];
    [sloth runAction:slothJumpAnimation];
    //berriesKilled++;
    [self addPoint];
    [berry removeFromParent];
    
}


//Call whenever you want to add a point
- (void)addPoint
{
    _berriesKilled++; //I think: score++; will also work.
    [scoreLabel setText:[NSString stringWithFormat:@"%i", _berriesKilled]];
}



//Call whenever you want to subtract a point
-(void)subtractLives{
    _playerLives--;
    [livesLabel setText:[NSString stringWithFormat:@"Lives: %i", _playerLives]];
}




- (void)didBeginContact:(SKPhysicsContact *)contact {
    // 1
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




//Move the sloth
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    SKSpriteNode *sloth = (SKSpriteNode*)[self childNodeWithName:@"sloth"];
    UITouch *myTouch = [touches anyObject];
    
    startPoint = [myTouch locationInNode:self];
    CGPoint lastPosition = [myTouch previousLocationInNode:self];
    CGPoint translation = CGPointMake(startPoint.x - lastPosition.x, startPoint.y - lastPosition.y);
    
    sloth.position = CGPointMake(lastPosition.x +translation.x, sloth.position.y);
    
}


-(void) setUpSlothActions {
    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"character"];
    
    SKTexture *slothMove1 = [atlas textureNamed:@"Sloths-01.png"];
    SKTexture *slothMove = [atlas textureNamed:@"Sloths-02.png"];
    SKTexture *slothMove2 = [atlas textureNamed:@"Sloths-03.png"];
    SKTexture *slothMove3 = [atlas textureNamed:@"Sloths-04.png"];
    
    NSArray *slothAtlas = @[ slothMove, slothMove2, slothMove3, slothMove2, slothMove, slothMove1];
    
    SKAction *slothAtlasAnimation = [SKAction animateWithTextures:slothAtlas timePerFrame:0.02];
    //SKAction *wait = [SKAction waitForDuration:0.4];
    
    slothJumpAnimation = [SKAction sequence:@[slothAtlasAnimation]  ];
    
}




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
        self.lastSpawnTimeInterval = 0;
        [self addBerry];
    }
}

@end
