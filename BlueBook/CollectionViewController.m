//
//  CollectionViewController.m
//
//  Created by Scott Lucien on 9/10/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "CollectionViewController.h"
#import "HelpViewController.h"
#import "BasePeoplePickerNavigationController.h"
#import "ContactNotFoundViewController.h"
#import "CustomCollectionView.h"
#import "FaceCollectionViewLayout.h"
#import "FaceCell.h"
#import "SwipeView.h"
#import "DraggableView.h"
#import "CoreDataManager.h"
#import "AppDelegate.h"
#import "UIBarButtonItem+ButtonItems.h"
#import "UIAlertView+AlertViews.h"

#define GUTTER_WIDTH 20
#define RESIGN_TIME 300 // 5 minutes

@interface CollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate, HelpViewControllerDelegate, UIGestureRecognizerDelegate>

// IBOutlets
@property (weak, nonatomic) IBOutlet CustomCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet SwipeView *swipeView;

// Properties
@property (nonatomic) BOOL isLaunch;
@property (nonatomic) BOOL isEditingMode;
@property (strong, nonatomic) UIView *editToolbar;
@property (strong, nonatomic) FaceCell *fromCell;
@property (strong, nonatomic) DraggableView *draggableCell;
@property (nonatomic) CGPoint touchStartingPoint;
@property (nonatomic) CGPoint cellStartingPoint;
@property (nonatomic) BOOL draggableCellHasMoved;
@property (nonatomic) BOOL shouldPromptToRemove;
@property (strong, nonatomic) NSIndexPath *movingIndexPath;
@property (strong, nonatomic) NSIndexPath *deleteIndexPath;

@end

#pragma mark -

@implementation CollectionViewController {
    BOOL shouldMoveToLastPlace;
    BOOL inTheGutter;
    CGFloat pageWidth;
    CGFloat leftGutter;
    CGFloat rightGutter;
    CGRect collectionViewOverlapBounds;
    BOOL midScroll;
}

static NSString *CellIdentifier = @"FaceCell";

- (id)init
{
    NSString *nibName = @"CollectionViewController";
    self = [super initWithNibName:nibName bundle:nil];
    return self;
}

#pragma mark - View Life Cycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[CoreDataManager sharedManager] clearTheImagesDictionary];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.view setExclusiveTouch:YES];
    [self.view setMultipleTouchEnabled:NO];
    [self setIsLaunch:YES];
    
    // set up the navigation buttons
    [self setUpNavigationBarButtons];
    
    // set up the collection view
    FaceCollectionViewLayout *layout = [[FaceCollectionViewLayout alloc] init];
    [_collectionView setCollectionViewLayout:layout];
    [_collectionView registerNib:[UINib nibWithNibName:@"FaceCell" bundle:nil] forCellWithReuseIdentifier:CellIdentifier];
    [_collectionView setAllowsMultipleSelection:NO];
    [_collectionView setAlpha:0.0];
    
    // set up the data manager and load the core data
    __weak typeof(self) weakSelf = self;
    [[CoreDataManager sharedManager] reloadCoreDataWithCompletion:^{
        [weakSelf.collectionView reloadData];
    }];
    
    // set up the page control
    [_pageControl setCurrentPageIndicatorTintColor:self.navigationController.navigationBar.tintColor];
    [_pageControl addTarget:self action:@selector(pageControlChanged:) forControlEvents:UIControlEventValueChanged];
    NSInteger numberOfPages = [[CoreDataManager sharedManager] numberOfPages];
    if (numberOfPages < 1) {
        numberOfPages = 1;
    }
    [_pageControl setNumberOfPages:numberOfPages];
    [_pageControl setCurrentPage:0];
    [_pageControl setAlpha:0.0];
    
    // set up the swipe gesture
    UIScreenEdgePanGestureRecognizer *edgeSwipe = [[UIScreenEdgePanGestureRecognizer alloc] init];
    [edgeSwipe addTarget:self action:@selector(handleSwipeGesture:)];
    [edgeSwipe setEdges:UIRectEdgeRight];
    [edgeSwipe setMaximumNumberOfTouches:1];
    [edgeSwipe setMinimumNumberOfTouches:1];
    [_swipeView addGestureRecognizer:edgeSwipe];
    
    // register for app notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    // set up additional properties
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    pageWidth = [[UIScreen mainScreen] bounds].size.width;
    leftGutter = GUTTER_WIDTH;
    rightGutter = pageWidth - GUTTER_WIDTH;
    collectionViewOverlapBounds = CGRectMake(GUTTER_WIDTH, 64, pageWidth - (GUTTER_WIDTH * 2), height - 108);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_isLaunch) {
        [self setIsLaunch:NO];
        [self updateNavigationBar:NO animated:YES];
        [UIView animateWithDuration:0.25 animations:^{
            [_collectionView setAlpha:1.0];
            [_pageControl setAlpha:1.0];
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (_isEditingMode) {
        [self stopEditingModeAnimated:NO];
    }
    [self clearAndResetScreen];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setup Methods

- (void)setUpNavigationBarButtons
{
    // set up the navigation bar
    [self setTitle:NSLocalizedString(@"Contacts", nil)];
    BasePeoplePickerNavigationController *nav = (BasePeoplePickerNavigationController *)self.navigationController;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem listButtonWithTarget:nav action:@selector(showContactsList:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem addButtonWithTarget:nav action:@selector(addNewShortcut:)];
    
    // set up the editing mode buttons
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    _editToolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 64)];
    UILabel *editLabel = [UIBarButtonItem editModeLabel];
    UIButton *editDoneButton = [UIBarButtonItem editModeDoneButtonWithTarget:self action:@selector(doneButtonPressed:)];
    UIButton *editHelpButton = [UIBarButtonItem editModeHelpButtonWithTarget:self action:@selector(helpButtonPressed:)];
    [_editToolbar addSubview:editLabel];
    [_editToolbar addSubview:editDoneButton];
    [_editToolbar addSubview:editHelpButton];
    [self.view addSubview:_editToolbar];
    [self hideEditButtonsAnimated:NO];
    [self setIsEditingMode:NO];
}

#pragma mark - Actions

- (void)handleSwipeGesture:(UIScreenEdgePanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        BasePeoplePickerNavigationController *nav = (BasePeoplePickerNavigationController *)self.navigationController;
        [nav showContactsList:nil];
    }
}

- (void)helpButtonPressed:(id)sender
{
    HelpViewController *helpViewController = [[HelpViewController alloc] initWithDelegate:self];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:helpViewController];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)doneButtonPressed:(id)sender
{
    [self stopEditingModeAnimated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [[CoreDataManager sharedManager] numberOfPages];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[CoreDataManager sharedManager] numberOfItemsOnPage:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FaceCell *cell = (FaceCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // update the cell from data
    Person *person = [[CoreDataManager sharedManager] personObjectAtIndexPath:indexPath];
    [cell setPerson:person];
    
    // set the image
    [cell.faceImage setImage:[[CoreDataManager sharedManager] imageForPerson:person]];
    
    // set the name label
    [cell.nameLabel setText:[self trimName:person.displayName]];
    
    // set up the long press gesture recognizer
    if (!cell.longfellowDeeds) {
        [cell setUpLongPressWithTarget:self action:@selector(handleLongPressOrDrag:)];
    }
    
    // set editing mode if applicable
    [cell setEditingMode:_isEditingMode];
    
    // hide the cell when dragging
    if (!_isEditingMode) {
        [cell showEverything];
    } else {
        if ([indexPath isEqual:_movingIndexPath]) {
            [cell hideEverything];
        } else {
            [cell showEverything];
        }
    }
    
    return cell;
}

- (NSString *)trimName:(NSString *)name
{
    NSString *trimmedName = name;
    if (name.length > 11) {
        trimmedName = [NSString stringWithFormat:@"%@...", [name substringToIndex:8]];
    }
    return trimmedName;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isEditingMode) {
        FaceCell *cell = (FaceCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        BasePeoplePickerNavigationController *nav = (BasePeoplePickerNavigationController *)self.navigationController;
        NSInteger personID = [cell.person.personID integerValue];
        ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(nav.addressBook, (int32_t)personID);
        if (personRef) {
            [nav pushPersonViewControllerWithPerson:personRef];
        } else {
            
            // contact not found!
            ContactNotFoundViewController *notFound = [[ContactNotFoundViewController alloc] initWithNib];
            [nav pushViewController:notFound animated:YES];
        }
    } else {
        
        // editing mode... prompt to delete shortcut
        [self promptToRemoveShortcutAtIndexPath:indexPath];
    }
}

#pragma mark - Page Control

- (void)pageControlChanged:(id)sender
{
    UIPageControl *pageControl = sender;
    CGPoint scrollTo = CGPointMake(CGRectGetWidth(_collectionView.frame) * pageControl.currentPage, 0);
    midScroll = YES;
    [_collectionView setContentOffset:scrollTo animated:YES];
}

- (void)scrollPageControlToPage:(NSInteger)page
{
    CGPoint scrollTo = CGPointMake(CGRectGetWidth(_collectionView.frame) * page, 0);
    midScroll = YES;
    [_collectionView setContentOffset:scrollTo animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_pageControl setCurrentPage:(_collectionView.contentOffset.x / CGRectGetWidth(_collectionView.frame))];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    midScroll = NO;
}

#pragma mark - Long Press/Drag Gesture

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return (((NSInteger)_collectionView.contentOffset.x % (NSInteger)pageWidth) == 0);
}

- (void)handleLongPressOrDrag:(UILongPressGestureRecognizer *)recognizer
{
    if (!_fromCell) {
        _fromCell = (FaceCell *)recognizer.view;
        NSIndexPath *indexPath = [_collectionView indexPathForCell:_fromCell];
        [self setMovingIndexPath:indexPath];
    }
    
    /* TOUCH STARTED */
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [self.view setUserInteractionEnabled:NO];
        [self.navigationController.navigationBar setUserInteractionEnabled:NO];
        [self getReadyToDrag];
        
        [_fromCell stopShaking];
        if (!_isEditingMode) {
            [self startEditingModeAnimated:YES];
            [self setShouldPromptToRemove:NO];
        }
        
        // add the draggable view
        CGRect frame = [_fromCell convertRect:_fromCell.bounds toView:self.view];
        UIImage *image = _fromCell.faceImage.image;
        NSString *name = _fromCell.nameLabel.text;
        _draggableCell = [[DraggableView alloc] initWithFrame:frame image:image name:name];
        [self.view addSubview:_draggableCell];
        [_fromCell hideEverything];
        
        // set the properties
        [self setTouchStartingPoint:[recognizer locationInView:self.view]];
        [self setCellStartingPoint:_draggableCell.center];
        [self setDraggableCellHasMoved:NO];
    }
    
    /* TOUCH MOVED */
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        [self setDraggableCellHasMoved:YES];
        [self moveCellRelativeToPoint:[recognizer locationInView:self.view]];
    }
    
    /* TOUCH ENDED */
    else if ((recognizer.state == UIGestureRecognizerStateCancelled) ||
             (recognizer.state == UIGestureRecognizerStateFailed) ||
             (recognizer.state == UIGestureRecognizerStateEnded))
    {
        // prompt to delete shortcut if applicable
        if ((!_draggableCellHasMoved) && (_shouldPromptToRemove)) {
            [self promptToRemoveShortcutAtIndexPath:_movingIndexPath];
        }
        
        // calculate the ending frame
        FaceCell *cell = (FaceCell *)[_collectionView cellForItemAtIndexPath:_movingIndexPath];
        CGRect endingFrame = [self getFrameForRow:_movingIndexPath.row];
        
        // animate to the appropriate spot
        [UIView animateWithDuration:0.375 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:1 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [_draggableCell.faceImage setAlpha:1.0];
            [_draggableCell setFrame:endingFrame];
        } completion:^(BOOL finished){
            [self setShouldPromptToRemove:YES];
            for (FaceCell *cell in [_collectionView visibleCells]) {
                [cell showEverything];
            }
            [cell showEverything];
            [cell.faceImage setAlpha:1.0];
            [self removeDraggableViews];
            if (_isEditingMode) {
                [cell startShaking];
            }
            [self setFromCell:nil];
            [self setDraggableCell:nil];
            [self setMovingIndexPath:nil];
            [self.view setUserInteractionEnabled:YES];
            [self.navigationController.navigationBar setUserInteractionEnabled:YES];
        }];
    }
}

- (CGRect)getFrameForRow:(NSInteger)row
{
    FaceCollectionViewLayout *layout = (FaceCollectionViewLayout *)_collectionView.collectionViewLayout;
    CGSize cell = layout.itemSize;
    NSInteger xM = (row % layout.numberOfColumns);
    NSInteger yM = (row / layout.numberOfColumns);

    CGFloat x = (cell.width * xM) + 10;
    CGFloat y = (cell.height * yM) + 64;
    return CGRectMake(x, y, cell.width, cell.height);
}

- (void)getReadyToDrag
{
    // add a new section to the data and collection view
    if (!_isEditingMode) {
        [self addSectionToCollectionView];
    } else if (_pageControl.currentPage == (_pageControl.numberOfPages - 1)) {
        [self addSectionToCollectionView];
    }
    
    // increment the page control
    [_pageControl setNumberOfPages:_collectionView.numberOfSections];
    shouldMoveToLastPlace = YES;
    midScroll = NO;
}

- (void)addSectionToCollectionView
{
    CoreDataManager *dataManager = [CoreDataManager sharedManager];
    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:dataManager.coreDataObjects.count];
    [dataManager.coreDataObjects addObject:[[NSMutableArray alloc] init]];
    [UIView performWithoutAnimation:^{
        [_collectionView insertSections:sections];
    }];
}

- (void)moveCellRelativeToPoint:(CGPoint)newPoint
{
    // move the cell
    CGPoint center = _cellStartingPoint;
    center.x += newPoint.x - _touchStartingPoint.x;
    center.y += newPoint.y - _touchStartingPoint.y;
    _draggableCell.center = center;
    
    // only continue if the collection view is not scrolling
    if (!midScroll) {
        [self checkForOverlappingCellsOnThisPage];
        [self checkToScroll];
    }
}

- (void)checkForOverlappingCellsOnThisPage
{
    CGPoint center = _draggableCell.center;
    if (CGRectContainsPoint(collectionViewOverlapBounds, center)) {
        
        BOOL overlap = NO;
        
        // loop through each visible cell
        for (FaceCell *cell in _collectionView.visibleCells) {
            
            // check if the center point is inside the cell frame
            CGRect cellFrame = [_collectionView convertRect:cell.frame toView:self.view];
            if (CGRectContainsPoint(cellFrame, center)) {
                overlap =  YES;
                
                // get the index path to move to
                NSIndexPath *toIndexPath = [_collectionView indexPathForCell:cell];
                
                if (![toIndexPath isEqual:_movingIndexPath]) {
                    
                    // update the moving index path to reflect the change
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_movingIndexPath.row inSection:_movingIndexPath.section];
                    [self setMovingIndexPath:toIndexPath];
                    
                    // move the cells in memory first, then in the collection view
                    __weak typeof(self) weakSelf = self;
                    [[CoreDataManager sharedManager] movePersonOnSamePageFromIndexPath:indexPath toIndexPath:toIndexPath completion:^{
                        shouldMoveToLastPlace = YES;
                        [weakSelf.collectionView moveItemAtIndexPath:indexPath toIndexPath:toIndexPath];
                    }];
                    
                    break;
                }
            }
        }
        
        // move the cell to the end of the current page
        if (!overlap) {
            if (shouldMoveToLastPlace) {
                
                // get the indexPath for the last spot on this page
                NSInteger section = _movingIndexPath.section;
                NSInteger lastSpot = ([_collectionView numberOfItemsInSection:section] - 1);
                NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:lastSpot inSection:section];
                
                // update the moving index path to reflect the change
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_movingIndexPath.row inSection:_movingIndexPath.section];
                [self setMovingIndexPath:toIndexPath];
                
                // move the cells in memory, then in the collection view
                __weak typeof(self) weakSelf = self;
                [[CoreDataManager sharedManager] movePersonOnSamePageFromIndexPath:indexPath toIndexPath:toIndexPath completion:^{
                    [weakSelf.collectionView moveItemAtIndexPath:indexPath toIndexPath:toIndexPath];
                }];

                shouldMoveToLastPlace = NO;
            }
        }
    }
}

- (void)checkToScroll
{
    CGFloat x = _draggableCell.center.x;
    
    // scroll to the previous page
    if (x < leftGutter) {
        if (inTheGutter) {
            return;
        } else {
            inTheGutter = YES;
        }
        [self scrollToPreviousPage];
    }
    
    // scroll to the next page
    else if (x > rightGutter) {
        if (inTheGutter) {
            return;
        } else {
            inTheGutter =YES;
        }
        [self scrollToNextPage];
    }
    
    // reset the flag
    else {
        inTheGutter = NO;
    }
}

- (void)scrollToPreviousPage
{
    if (_pageControl.currentPage == 0) {
        return;
    }
    
    // move the cell to the previous page
    midScroll = YES;
    [self moveCellToThePreviousPageWithCompletion:^{
        
        // decrement the page control and scroll to the previous page
        shouldMoveToLastPlace =  YES;
        [_pageControl setCurrentPage:(_pageControl.currentPage - 1)];
        CGFloat newOffset = _collectionView.contentOffset.x - pageWidth;
        midScroll = YES;
        [_collectionView setContentOffset:CGPointMake(newOffset, 0) animated:YES];
    }];
}

- (void)scrollToNextPage
{
    if (_pageControl.currentPage == (_pageControl.numberOfPages - 1)) {
        return;
    }
    
    // move the cell to the next page
    midScroll = YES;
    [self moveCellToTheNextPageWithCompletion:^{
        
        // increment the page control and scroll to the next page
        shouldMoveToLastPlace = YES;
        [_pageControl setCurrentPage:(_pageControl.currentPage + 1)];
        CGFloat newOffset = _collectionView.contentOffset.x + pageWidth;
        midScroll = YES;
        [_collectionView setContentOffset:CGPointMake(newOffset, 0) animated:YES];
    }];
}

- (void)moveCellToTheNextPageWithCompletion:(void(^)(void))completion
{
    // save the original index path
    NSIndexPath *originalIndexPath = [NSIndexPath indexPathForRow:_movingIndexPath.row inSection:_movingIndexPath.section];
    
    // find the index for the next page
    NSInteger nextPage = (originalIndexPath.section + 1);
    
    // get the data source for the next page
    CoreDataManager *dataManager = [CoreDataManager sharedManager];
    NSMutableArray *nextSection = [dataManager.coreDataObjects objectAtIndex:nextPage];
    NSInteger max = [dataManager getMaxPerPage];
        
    // if the new page is full, push the object in its last spot to the next page
    if (!(nextSection.count < max)) {
        NSIndexPath *lastSpot = [NSIndexPath indexPathForRow:(nextSection.count - 1) inSection:nextPage];
        [self pushCellAtIndexPath:lastSpot toFirstSpotOnPage:(nextPage + 1)];
    }
    
    // get the index for the first empty spot on the next page
    NSInteger newRow = nextSection.count;
    NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:newRow inSection:nextPage];
    
    // update the moving index path
    [self setMovingIndexPath:toIndexPath];
    
    // mutate the data arrays
    NSMutableArray *oldSection = [dataManager.coreDataObjects objectAtIndex:originalIndexPath.section];
    Person *person = (Person *)[oldSection objectAtIndex:originalIndexPath.row];
    [oldSection removeObject:person];
    [nextSection insertObject:person atIndex:newRow];
    
    // update the person properties
    person.pageNumber = [NSNumber numberWithInteger:nextPage];
    person.pageRow = [NSNumber numberWithInteger:newRow];
    
    // move item in the collection view
    [_collectionView performBatchUpdates:^{
        [_collectionView moveItemAtIndexPath:originalIndexPath toIndexPath:toIndexPath];
    } completion:^(BOOL finished) {
        
        // completion handler
        if (completion) {
            completion();
        }
    }];
}

- (void)pushCellAtIndexPath:(NSIndexPath *)fromIndexPath toFirstSpotOnPage:(NSInteger)newPage
{
    // get the data source for the new page
    CoreDataManager *dataManager = [CoreDataManager sharedManager];
    NSMutableArray *newSection = [dataManager.coreDataObjects objectAtIndex:newPage];
    NSInteger max = [dataManager getMaxPerPage];
    
    // if the new page is full, push the object in the last spot to the next page
    if (!(newSection.count < max)) {
        NSIndexPath *lastSpot = [NSIndexPath indexPathForRow:(newSection.count - 1) inSection:newPage];
        [self pushCellAtIndexPath:lastSpot toFirstSpotOnPage:(newPage + 1)];
    }

    // get the index for the first spot
    NSInteger newRow = 0;
    
    // mutate the data arrays
    NSMutableArray *oldSection = [dataManager.coreDataObjects objectAtIndex:fromIndexPath.section];
    Person *person = (Person *)[oldSection objectAtIndex:fromIndexPath.row];
    [oldSection removeObject:person];
    [newSection insertObject:person atIndex:newRow];
    
    // update the person properties
    person.pageNumber = [NSNumber numberWithInteger:newPage];
    person.pageRow = [NSNumber numberWithInteger:newRow];
    
    // move item in the collection view
    NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:newRow inSection:newPage];
    [UIView performWithoutAnimation:^{
        [_collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
    }];
}

- (void)moveCellToThePreviousPageWithCompletion:(void(^)(void))completion
{
    // save the original index path
    NSIndexPath *originalIndexPath = [NSIndexPath indexPathForRow:_movingIndexPath.row inSection:_movingIndexPath.section];
    
    // find the index for the previous page
    NSInteger previousPage = (originalIndexPath.section - 1);

    // get the data sources for the current and previous pages
    CoreDataManager *dataManager = [CoreDataManager sharedManager];
    NSMutableArray *previousSection = [dataManager.coreDataObjects objectAtIndex:previousPage];
    NSMutableArray *oldSection = [dataManager.coreDataObjects objectAtIndex:originalIndexPath.section];
    NSInteger max = [dataManager getMaxPerPage];
    
    void (^updates)();
    
    // if the new page is full, push the object in its last spot to the next page
    if (!(previousSection.count < max)) {
        
        // get the index to move to
        NSInteger newRow = (previousSection.count - 1);
        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:originalIndexPath.section];
        NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:newRow inSection:previousPage];
        
        // update the moving index path
        [self setMovingIndexPath:toIndexPath];
        
        // mutate the data arrays
        Person *person = (Person *)[oldSection objectAtIndex:originalIndexPath.row];
        Person *lastPerson = (Person *)[previousSection objectAtIndex:newRow];
        [oldSection removeObject:person];
        [previousSection removeObject:lastPerson];
        [oldSection insertObject:lastPerson atIndex:0];
        [previousSection insertObject:person atIndex:newRow];
        
        // update the person properties
        person.pageNumber = [NSNumber numberWithInteger:previousPage];
        person.pageRow = [NSNumber numberWithInteger:newRow];
        
        // save the updates to be completed later
        updates = ^{
            [_collectionView moveItemAtIndexPath:toIndexPath toIndexPath:firstIndexPath];
            [_collectionView moveItemAtIndexPath:originalIndexPath toIndexPath:toIndexPath];
        };
    }
    else {
        
        // get the index for the last spot on previous page
        NSInteger newRow = previousSection.count;
        NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:newRow inSection:previousPage];
        
        // update the moving index path
        [self setMovingIndexPath:toIndexPath];
        
        // mutate the data arrays
        Person *person = (Person *)[oldSection objectAtIndex:originalIndexPath.row];
        [oldSection removeObject:person];
        [previousSection insertObject:person atIndex:newRow];
        
        // update the person properties
        person.pageNumber = [NSNumber numberWithInteger:previousPage];
        person.pageRow = [NSNumber numberWithInteger:newRow];
        
        // save the updates to be completed later
        updates = ^{
            [_collectionView moveItemAtIndexPath:originalIndexPath toIndexPath:toIndexPath];
        };
    }
    
    // perform the collectionView updates
    [_collectionView performBatchUpdates:^{
        updates();
    } completion:^(BOOL finished) {
        
        // completion handler
        if (completion) {
            completion();
        }
    }];
}

- (void)clearAndResetScreen
{
    if (_isEditingMode) {
        [self stopEditingModeAnimated:NO];
    }
    inTheGutter = NO;
    [self setFromCell:nil];
    [self setDraggableCell:nil];
    [self setDraggableCellHasMoved:NO];
    [self setMovingIndexPath:nil];
    [self setDeleteIndexPath:nil];
}

- (void)removeDraggableViews
{
    for (UIView *view in [self.view subviews]) {
        if ([view isKindOfClass:[DraggableView class]]) {
            [view removeFromSuperview];
        }
    }
}

#pragma mark - Editing Mode

- (void)setEditingMode:(BOOL)mode animated:(BOOL)animated
{
    [self setIsEditingMode:mode];
    [_swipeView setUserInteractionEnabled:!mode];
    [self updateNavigationBar:mode animated:animated];
    for (FaceCell *cell in [_collectionView visibleCells]) {
        [cell setEditingMode:mode];
    }
}

- (void)startEditingModeAnimated:(BOOL)animated
{
    [self setEditingMode:YES animated:animated];
}

- (void)stopEditingModeAnimated:(BOOL)animated
{
    [self setEditingMode:NO animated:animated];
    [self removeDraggableViews];
    
    // delete any empty data arrays
    CoreDataManager *dataManager = [CoreDataManager sharedManager];
    for (NSInteger i = 0; i < dataManager.coreDataObjects.count; i++) {
        NSMutableArray *array = [dataManager.coreDataObjects objectAtIndex:i];
        if (array.count < 1) {
            [dataManager.coreDataObjects removeObject:array];
        }
    }
    
    // reload the tableView
    [_collectionView reloadData];
    
    // reload the page control
    NSInteger numberOfPages = [dataManager numberOfPages];
    if (numberOfPages < 1) {
        numberOfPages = 1;
    }
    [_pageControl setNumberOfPages:numberOfPages];
    
    // update object index paths in the background
    dispatch_queue_t updateQueue = dispatch_queue_create("updateQueue", NULL);
    dispatch_async(updateQueue, ^{
        [[CoreDataManager sharedManager] saveObjectIndexPaths];
    });
}

- (void)updateNavigationBar:(BOOL)editing animated:(BOOL)animated
{
    if (editing) {
        [self.navigationController setNavigationBarHidden:YES animated:animated];
        [self showEditButtonsAnimated:animated];
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
        [self hideEditButtonsAnimated:animated];
    }
}

- (void)hideEditButtonsAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [_editToolbar setAlpha:0];
        } completion:^(BOOL finished) {
            [_editToolbar setHidden:YES];
        }];
    } else {
        [_editToolbar setAlpha:0];
        [_editToolbar setHidden:YES];
    }
}

- (void)showEditButtonsAnimated:(BOOL)animated
{
    [_editToolbar setHidden:NO];
    if (animated) {
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^{
            [_editToolbar setAlpha:1.0];
        } completion:nil];
    } else {
        [_editToolbar setAlpha:1.0];
    }
}

- (void)promptToRemoveShortcutAtIndexPath:(NSIndexPath *)indexPath
{
    [self setDeleteIndexPath:indexPath];
    FaceCell *cell = (FaceCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    UIActionSheet *actions = [UIAlertView removeCellPromptWithDelegate:self name:cell.person.displayName];
    [actions showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // delete the object and then the cell
    if (buttonIndex == 0) {
        BOOL lastCellRemaining = (([_collectionView numberOfSections] == 1) &&
                                  ([_collectionView numberOfItemsInSection:0] == 1));
        if (lastCellRemaining) {
            [self stopEditingModeAnimated:YES];
        }
        FaceCell *cell = (FaceCell *)[_collectionView cellForItemAtIndexPath:_deleteIndexPath];
        __weak typeof(self) weakSelf = self;
        [[CoreDataManager sharedManager] deletePersonObject:cell.person atIndexPath:_deleteIndexPath completion:^{
            [cell setPerson:nil];
            [weakSelf.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:weakSelf.deleteIndexPath]];
        }];
    }
    
    // edit the shortcut
    else if (buttonIndex == 1) {
        BasePeoplePickerNavigationController *nav = (BasePeoplePickerNavigationController *)self.navigationController;
        FaceCell *cell = (FaceCell *)[_collectionView cellForItemAtIndexPath:_deleteIndexPath];
        NSInteger personID = [cell.person.personID integerValue];
        ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(nav.addressBook, (int32_t)personID);
        
        // show the options view controller in editing mode
        OptionsViewController *options = [[OptionsViewController alloc] initWithEditingModeAndDelegate:self];
        [options.navigationItem setTitle:cell.person.displayName];
        [options setPersonObject:cell.person];
        [options setSelectedPerson:personRef];
        if (cell.person.displayImage) {
            [options setCurrentImage:cell.faceImage.image];
        }
        
        UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:options];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - OptionsViewController Delegate

- (void)optionsViewController:(OptionsViewController *)controller didFinishWithInfo:(NSDictionary *)info scrollTo:(NSInteger)page
{
    CoreDataManager *dataManager = [CoreDataManager sharedManager];
    
    if (info) {
        [dataManager addImage:info[@"img"] forID:info[@"uid"]];
    }
    
    [dataManager loadTheImagesInBackground];
    [_collectionView reloadData];
    [_pageControl setNumberOfPages:[dataManager numberOfPages]];
    [self dismissViewControllerAnimated:YES completion:^{
        CGFloat width = _collectionView.frame.size.width;
        midScroll = YES;
        [_collectionView setContentOffset:CGPointMake(page * width, 0) animated:YES];
        [_pageControl setCurrentPage:page];
    }];
}

- (void)optionsViewController:(OptionsViewController *)controller didEndEditingWithInfo:(NSDictionary *)info
{
    CoreDataManager *dataManager = [CoreDataManager sharedManager];
    
    if (info[@"img"]) {
        [dataManager addImage:info[@"img"] forID:info[@"uid"]];
    } else {
        [dataManager removeImageForId:info[@"uid"]];
    }
    
    [dataManager loadTheImagesInBackground];
    [_collectionView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)optionsViewControllerDidCancel:(OptionsViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - HelpViewController Delegate

- (void)helpViewControllerDidDeleteAllContacts:(HelpViewController *)controller
{
    __weak typeof(self) weakSelf = self;
    [[CoreDataManager sharedManager] deleteAllPersonObjectsWithCompletion:^{
        [weakSelf.collectionView reloadData];
        [weakSelf.pageControl setNumberOfPages:1];
        [weakSelf.collectionView setContentOffset:CGPointMake(0, 0) animated:NO];
        [weakSelf.pageControl setCurrentPage:0];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)helpViewControllerDidDismiss:(HelpViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - App Notificiations

- (void)willResignActive
{
    [self clearAndResetScreen];
}

- (void)willEnterForeground
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (abs([delegate.resignTime timeIntervalSinceNow]) > RESIGN_TIME) {
        [self dismissViewControllerAnimated:NO completion:nil];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

@end
