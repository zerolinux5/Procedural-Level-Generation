//
//  Map.h
//  ProceduralLevelGeneration
//
//  Created by Jesus Magana on 7/4/14.
//  Copyright (c) 2014 Kim Pedersen. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Map : SKNode

@property (nonatomic) CGSize gridSize;
@property (nonatomic, readonly) CGPoint spawnPoint;
@property (nonatomic, readonly) CGPoint exitPoint;
@property (nonatomic) NSUInteger maxFloorCount;

+ (instancetype) mapWithGridSize:(CGSize)gridSize;
- (instancetype) initWithGridSize:(CGSize)gridSize;

@end
