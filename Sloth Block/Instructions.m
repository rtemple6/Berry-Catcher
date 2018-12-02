//
//  Instructions.m
//  Sloth Block
//
//  Created by Ryan Temple on 5/20/14.
//  Copyright (c) 2014 Ryan Temple. All rights reserved.
//

#import "Instructions.h"
#import "SlothMyScene.h"

@implementation Instructions

- (id)initWithSize:(CGSize)size
{
     if (self = [super initWithSize:size]){
         
         SKSpriteNode *backgroundNode = [[SKSpriteNode alloc]initWithColor:[UIColor whiteColor] size:size];
        
        SKLabelNode * instructions = [[SKLabelNode alloc]init];
        instructions.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+50);
        instructions.fontName = @"SF Archery Black";
        instructions.fontColor = [UIColor whiteColor];
        instructions.text = @"Catch all the berries!";
        instructions.fontSize = 22;
        [self addChild:instructions];
    
         playAgain = [SKSpriteNode spriteNodeWithImageNamed:@"Play.png"];
         playAgain.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-93);
         playAgain.size = CGSizeMake(80, 48);
         [self addChild:playAgain];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:self];
        
        if([playAgain containsPoint:location])
        {
            //[[SoundManager sharedManager] playSound:@"button-10.mp3" looping:NO];
            
            SKTransition *transition = [SKTransition fadeWithColor:[UIColor whiteColor] duration:0];
            SKScene *newGame = [[SlothMyScene alloc]initWithSize:self.size];
            [self.view presentScene:newGame transition:transition];
        }
    }
}
@end
