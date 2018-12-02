//
//  GameOverScene.h
//  Sloth Block
//
//  Created by Ryan Temple on 2/3/14.
//  Copyright (c) 2014 Ryan Temple. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "FMMParallaxNode.h"

@interface GameOverScene : SKScene{
    BOOL isSelected;
    SKLabelNode *scoreLabel;
    SKLabelNode *highScoreLabel;
    SKSpriteNode *playAgain;
    SKSpriteNode *tweet;
}

-(id)initWithSize:(CGSize)size andScore:(int)score andHighScore:(int)highscore;

@end
