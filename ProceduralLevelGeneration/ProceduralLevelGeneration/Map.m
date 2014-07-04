//
//  Map.m
//  ProceduralLevelGeneration
//
//  Created by Jesus Magana on 7/4/14.
//  Copyright (c) 2014 Kim Pedersen. All rights reserved.
//

#import "Map.h"
#import "MapTiles.h"
#import "MyScene.h"
#import "FloorMaker.h"

@interface Map ()
@property (nonatomic) MapTiles *tiles;
@property (nonatomic) SKTextureAtlas *tileAtlas;
@property (nonatomic) CGFloat tileSize;
@property (nonatomic) NSMutableArray *floorMakers;
@end

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
        self.tileAtlas = [SKTextureAtlas atlasNamed:@"tiles"];
        
        NSArray *textureNames = [self.tileAtlas textureNames];
        SKTexture *tileTexture = [self.tileAtlas textureNamed:(NSString *)[textureNames firstObject]];
        self.tileSize = tileTexture.size.width;
    }
    return self;
}

- (void) generateTileGrid
{
    CGPoint startPoint = CGPointMake(self.tiles.gridSize.width / 2, self.tiles.gridSize.height / 2);
    // 1
    [self.tiles setTileType:MapTileTypeFloor at:startPoint];
    //NSUInteger currentFloorCount = 1;
    // 2
    //FloorMaker* floorMaker = [[FloorMaker alloc] initWithCurrentPosition:startPoint andDirection:0];
    
    __block NSUInteger currentFloorCount = 1;
    self.floorMakers = [NSMutableArray array];
    [self.floorMakers addObject:[[FloorMaker alloc] initWithCurrentPosition:startPoint andDirection:0]];
    
    while ( currentFloorCount < self.maxFloorCount )
    {
        [self.floorMakers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FloorMaker *floorMaker = (FloorMaker *)obj;
        // 3
        floorMaker.direction = [self randomNumberBetweenMin:1 andMax:4];
        CGPoint newPosition;
        // 4
        switch ( floorMaker.direction )
        {
            case 1: // Up
                newPosition = CGPointMake(floorMaker.currentPosition.x, floorMaker.currentPosition.y - 1);
                break;
            case 2: // Down
                newPosition = CGPointMake(floorMaker.currentPosition.x, floorMaker.currentPosition.y + 1);
                break;
            case 3: // Left
                newPosition = CGPointMake(floorMaker.currentPosition.x - 1, floorMaker.currentPosition.y);
                break;
            case 4: // Right
                newPosition = CGPointMake(floorMaker.currentPosition.x + 1, floorMaker.currentPosition.y);
                break;
        }
        //5
        if([self.tiles isValidTileCoordinateAt:newPosition] &&
           ![self.tiles isEdgeTileAt:newPosition] &&
           [self.tiles tileTypeAt:newPosition] == MapTileTypeNone)
        {
            floorMaker.currentPosition = newPosition;
            [self.tiles setTileType:MapTileTypeFloor at:floorMaker.currentPosition];
            currentFloorCount++;
            _exitPoint = [self convertMapCoordinateToWorldCoordinate:floorMaker.currentPosition];
        }
        }];
    }
    // 6
    // 7
    NSLog(@"%@", [self.tiles description]);
    _spawnPoint = [self convertMapCoordinateToWorldCoordinate:startPoint];
}

- (void) generate
{
    self.tiles = [[MapTiles alloc] initWithGridSize:self.gridSize];
    [self generateTileGrid];
    [self generateWalls];
    [self generateTiles];
    [self generateCollisionWalls];
}

- (NSInteger) randomNumberBetweenMin:(NSInteger)min andMax:(NSInteger)max
{
    return min + arc4random() % (max - min);
}

- (void) generateTiles
{
    // 1
    for ( NSInteger y = 0; y < self.tiles.gridSize.height; y++ )
    {
        for ( NSInteger x = 0; x < self.tiles.gridSize.width; x++ )
        {
            // 2
            CGPoint tileCoordinate = CGPointMake(x, y);
            // 3
            MapTileType tileType = [self.tiles tileTypeAt:tileCoordinate];
            // 4
            if ( tileType != MapTileTypeNone )
            {
                // 5
                SKTexture *tileTexture = [self.tileAtlas textureNamed:[NSString stringWithFormat:@"%li", tileType]];
                SKSpriteNode *tile = [SKSpriteNode spriteNodeWithTexture:tileTexture];
                // 6
                tile.position = [self convertMapCoordinateToWorldCoordinate:CGPointMake(tileCoordinate.x, tileCoordinate.y)];
                // 7
                [self addChild:tile];
            }
        }
    }
}

- (CGPoint) convertMapCoordinateToWorldCoordinate:(CGPoint)mapCoordinate
{
    return CGPointMake(mapCoordinate.x * self.tileSize,  (self.tiles.gridSize.height - mapCoordinate.y) * self.tileSize);
}

- (void) generateWalls
{
    // 1
    for ( NSInteger y = 0; y < self.tiles.gridSize.height; y++ )
    {
        for ( NSInteger x = 0; x < self.tiles.gridSize.width; x++ )
        {
            CGPoint tileCoordinate = CGPointMake(x, y);
            
            // 2
            if ( [self.tiles tileTypeAt:tileCoordinate] == MapTileTypeFloor )
            {
                for ( NSInteger neighbourY = -1; neighbourY < 2; neighbourY++ )
                {
                    for ( NSInteger neighbourX = -1; neighbourX < 2; neighbourX++ )
                    {
                        if ( !(neighbourX == 0 && neighbourY == 0) )
                        {
                            CGPoint coordinate = CGPointMake(x + neighbourX, y + neighbourY);
                            
                            // 3
                            if ( [self.tiles tileTypeAt:coordinate] == MapTileTypeNone )
                            {
                                [self.tiles setTileType:MapTileTypeWall at:coordinate];
                            }
                        }
                    }
                }
            }
        }
    }
}

- (void) addCollisionWallAtPosition:(CGPoint)position withSize:(CGSize)size
{
    SKNode *wall = [SKNode node];
    
    wall.position = CGPointMake(position.x + size.width * 0.5f - 0.5f * self.tileSize,
                                position.y - size.height * 0.5f + 0.5f * self.tileSize);
    wall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
    wall.physicsBody.dynamic = NO;
    wall.physicsBody.categoryBitMask = CollisionTypeWall;
    wall.physicsBody.contactTestBitMask = 0;
    wall.physicsBody.collisionBitMask = CollisionTypePlayer;
    
    [self addChild:wall];
}

- (void) generateCollisionWalls
{
    for ( NSInteger y = 0; y < self.tiles.gridSize.height; y++ )
    {
        CGFloat startPointForWall = 0;
        CGFloat wallLength = 0;
        for ( NSInteger x = 0; x <= self.tiles.gridSize.width; x++ )
        {
            CGPoint tileCoordinate = CGPointMake(x, y);
            // 1
            if ( [self.tiles tileTypeAt:tileCoordinate] == MapTileTypeWall )
            {
                if ( startPointForWall == 0 && wallLength == 0 )
                {
                    startPointForWall = x;
                }
                wallLength += 1;
            }
            // 2
            else if ( wallLength > 0 )
            {
                CGPoint wallOrigin = CGPointMake(startPointForWall, y);
                CGSize wallSize = CGSizeMake(wallLength * self.tileSize, self.tileSize);
                [self addCollisionWallAtPosition:[self convertMapCoordinateToWorldCoordinate:wallOrigin]
                                        withSize:wallSize];
                startPointForWall = 0;
                wallLength = 0;
            }
        }
    }
}

@end
