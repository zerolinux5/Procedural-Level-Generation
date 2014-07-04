//
//  FloorMaker.m
//  ProceduralLevelGeneration
//
//  Created by Jesus Magana on 7/4/14.
//  Copyright (c) 2014 Kim Pedersen. All rights reserved.
//

#import "FloorMaker.h"

@implementation FloorMaker

- (instancetype) initWithCurrentPosition:(CGPoint)currentPosition andDirection:(NSUInteger)direction
{
    if (( self = [super init] ))
    {
        self.currentPosition = currentPosition;
        self.direction = direction;
    }
    return self;
}

@end
