//
//  Map.m
//  ProceduralLevelGeneration
//
//  Created by Jesus Magana on 7/4/14.
//  Copyright (c) 2014 Kim Pedersen. All rights reserved.
//

#import "Map.h"

@implementation Map

+ (instancetype) mapWithGridSize:(CGSize)gridSize
{
    return [[self alloc] initWithGridSize:gridSize];
}

- (instancetype) initWithGridSize:(CGSize)gridSize
{
    if (( self = [super init] ))
    {
        self.gridSize = gridSize;
        _spawnPoint = CGPointZero;
        _exitPoint = CGPointZero;
    }
    return self;
}

@end
