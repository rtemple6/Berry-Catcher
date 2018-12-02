//
//  StartScene.h
//  Sloth Block
//
//  Created by Ryan Temple on 2/2/14.
//  Copyright (c) 2014 Ryan Temple. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface StartScene : SKScene {
    SKSpriteNode *playAgain;
    SKSpriteNode *tweet;
    CIFilter *blur;
}

-(id)initWithSize:(CGSize)size;

@end
