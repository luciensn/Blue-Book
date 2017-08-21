//
//  FaceCollectionViewLayout.m
//
//  Created by Scott Lucien on 6/2/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "FaceCollectionViewLayout.h"

static NSString *const FaceLayoutCellKind = @"FaceCell";

@interface FaceCollectionViewLayout ()

// Properties
@property (nonatomic, strong) NSDictionary *layoutInfo;
@property (nonatomic) CGFloat pageWidth;

@end

#pragma mark -

@implementation FaceCollectionViewLayout

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    [self setPageWidth:[[UIScreen mainScreen] bounds].size.width];
    self.itemInsets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
    self.itemSize = CGSizeMake(75.0, 93.0);
    self.interItemSpacingX = 0.0f;
    self.interItemSpacingY = 0.0f;
    self.numberOfColumns = 4;
}

#pragma mark - Prepare Layout

- (void)prepareLayout
{
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath = nil;
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < itemCount; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes =
                [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            itemAttributes.frame = [self frameForFaceCellAtIndexPath:indexPath];
            
            cellLayoutInfo[indexPath] = itemAttributes;
        }
    }
    
    newLayoutInfo[FaceLayoutCellKind] = cellLayoutInfo;
    
    self.layoutInfo = newLayoutInfo;
}

#pragma mark - Layout Factory

- (CGRect)frameForFaceCellAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat startingX = (indexPath.section * _pageWidth) + 10;
    NSInteger column = indexPath.row % self.numberOfColumns;
    NSInteger row = indexPath.row / self.numberOfColumns;
    CGFloat originX = floor(startingX + (self.itemSize.width + self.interItemSpacingX) * column);
    CGFloat originY = floor((self.itemSize.height + self.interItemSpacingY) * row);
    
    return CGRectMake(originX, originY, self.itemSize.width, self.itemSize.height);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier,
                                                         NSDictionary *elementsInfo,
                                                         BOOL *stop) {
        [elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath,
                                                          UICollectionViewLayoutAttributes *attributes,
                                                          BOOL *innerStop) {
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [allAttributes addObject:attributes];
            }
        }];
    }];
    
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.layoutInfo[FaceLayoutCellKind][indexPath];
}

- (CGSize)collectionViewContentSize
{
    return CGSizeMake((_pageWidth * self.collectionView.numberOfSections), self.collectionView.bounds.size.height);
}

@end
