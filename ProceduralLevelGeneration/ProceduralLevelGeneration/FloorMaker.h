//
//  FloorMaker.h
//  ProceduralLevelGeneration
//
//  Created by Jesus Magana on 7/4/14.
//  Copyright (c) 2014 Kim Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FloorMaker : NSObject

@property (nonatomic) CGPoint currentPosition;
@property (nonatomic) NSUInteger direction;

- (instancetype) initWithCurrentPosition:(CGPoint)currentPosition andDirection:(NSUInteger)direction;

@end
