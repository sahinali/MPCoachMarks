//
//  MPCoachMarks.m
//  Example
//
//  Created by marcelo.perretta@gmail.com on 7/8/15.
//  Copyright (c) 2015 MAWAPE. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MPCoachMarks.h"

static const CGFloat kAnimationDuration = 0.3f;
static const CGFloat kCutoutRadius = 5.0f;
static const CGFloat kMaxLblWidth = 230.0f;
static const CGFloat kLblSpacing = 0.0f;
static const CGFloat kLabelMargin = 5.0f;
static const CGFloat kMaskAlpha = 0.75f;
static const BOOL kEnableContinueLabel = YES;
static const BOOL kEnableSkipButton = YES;


@implementation MPCoachMarks {
    CAShapeLayer *mask;
    NSUInteger markIndex;
    UIView *currentView;
}

#pragma mark - Properties

@synthesize delegate;
@synthesize coachMarks;
@synthesize lblCaption;
@synthesize lblContinue;
@synthesize btnSkipCoach;
@synthesize maskColor = _maskColor;
@synthesize animationDuration;
@synthesize cutoutRadius;
@synthesize maxLblWidth;
@synthesize lblSpacing;
@synthesize enableContinueLabel;
@synthesize enableSkipButton;
@synthesize arrowImage;
@synthesize continueLocation;

#pragma mark - Methods

- (id)initWithFrame:(CGRect)frame coachMarks:(NSArray *)marks {
    self = [super initWithFrame:frame];
    if (self) {
        // Save the coach marks
        self.coachMarks = marks;
        
        // Setup
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Setup
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Setup
        [self setup];
    }
    return self;
}

- (void)setup {
    // Default
    self.animationDuration = kAnimationDuration;
    self.cutoutRadius = kCutoutRadius;
    self.maxLblWidth = kMaxLblWidth;
    self.lblSpacing = kLblSpacing;
    self.enableContinueLabel = kEnableContinueLabel;
    self.enableSkipButton = kEnableSkipButton;
    
    
    // Shape layer mask
    mask = [CAShapeLayer layer];
    [mask setFillRule:kCAFillRuleEvenOdd];
    [mask setFillColor:[[UIColor colorWithHue:0.0f saturation:0.0f brightness:0.0f alpha:kMaskAlpha] CGColor]];
    [self.layer addSublayer:mask];
    
    
    
    
    // Captions
    self.lblCaption = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {self.maxLblWidth, 0.0f}}];
    self.lblCaption.backgroundColor = [UIColor clearColor];
    self.lblCaption.textColor = [UIColor whiteColor];
    self.lblCaption.font = [UIFont systemFontOfSize:20.0f];
    self.lblCaption.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblCaption.numberOfLines = 0;
    self.lblCaption.textAlignment = NSTextAlignmentCenter;
    self.lblCaption.alpha = 0.0f;
    [self addSubview:self.lblCaption];
    
    //Location Position
    self.continueLocation = LOCATION_TOP;
    
    // Hide until unvoked
    self.hidden = YES;
}

#pragma mark - Cutout modify

- (void)setCutoutToRect:(CGRect)rect withShape:(MaskShape)shape{
    // Define shape
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *cutoutPath;
    
    if (shape == SHAPE_CIRCLE)
        cutoutPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    else if (shape == SHAPE_SQUARE)
        cutoutPath = [UIBezierPath bezierPathWithRect:rect];
    else
        cutoutPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cutoutRadius];
    
    
    [maskPath appendPath:cutoutPath];
    
    // Set the new path
    mask.path = maskPath.CGPath;
}

- (void)animateCutoutToRect:(CGRect)rect withShape:(MaskShape)shape{
    // Define shape
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *cutoutPath;
    
    if (shape == SHAPE_CIRCLE)
        cutoutPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    else if (shape == SHAPE_SQUARE)
        cutoutPath = [UIBezierPath bezierPathWithRect:rect];
    else
        cutoutPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cutoutRadius];
    
    
    [maskPath appendPath:cutoutPath];
    
    // Animate it
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
    anim.delegate = self;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim.duration = self.animationDuration;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    anim.fromValue = (__bridge id)(mask.path);
    anim.toValue = (__bridge id)(maskPath.CGPath);
    [mask addAnimation:anim forKey:@"path"];
    mask.path = maskPath.CGPath;
}

#pragma mark - Mask color

- (void)setMaskColor:(UIColor *)maskColor {
    _maskColor = maskColor;
    [mask setFillColor:[maskColor CGColor]];
}

#pragma mark - Touch handler

- (void)userDidTap:(UITapGestureRecognizer *)recognizer {
    // Go to the next coach mark
    [self goToCoachMarkIndexed:(markIndex+1)];
}

#pragma mark - Navigation

- (void)start {
    // Fade in self
    self.alpha = 0.0f;
    self.hidden = NO;
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         self.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         // Go to the first coach mark
                         [self goToCoachMarkIndexed:0];
                     }];
}

- (void)skipCoach {
    [self goToCoachMarkIndexed:self.coachMarks.count];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    //    [self.delegate coachMarksViewDidClicked:self atIndex:markIndex];
    
    if ([self.delegate respondsToSelector:@selector(coachMarksViewDidClicked:atIndex:)]) {
        [self.delegate coachMarksViewDidClicked:self atIndex:markIndex];
    }
    
    //    [self cleanup];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    
    
    if ([self.delegate respondsToSelector:@selector(coachMarksViewLongPressDetected:atIndex:longPress:)]) {
        [self.delegate coachMarksViewLongPressDetected:self atIndex:markIndex longPress:recognizer];
    }
    
}

- (UIImage*)fetchImage:(NSString*)name {
    // Check for iOS 8
    if ([UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        return [UIImage imageNamed:name];
    }
}

- (void)goToCoachMarkIndexed:(NSUInteger)index {
    // Out of bounds
    if (index >= self.coachMarks.count) {
        [self cleanup];
        return;
    }
    
    // Current index
    markIndex = index;
    
    // Coach mark definition
    NSDictionary *markDef = [self.coachMarks objectAtIndex:index];
    NSString *markCaption = [markDef objectForKey:@"caption"];
    CGRect markRect = [[markDef objectForKey:@"rect"] CGRectValue];
    
    MaskShape shape = DEFAULT;
    if([[markDef allKeys] containsObject:@"shape"])
        shape = [[markDef objectForKey:@"shape"] integerValue];
    
    
    //Label Position
    LabelAligment labelAlignment = [[markDef objectForKey:@"alignment"] integerValue];
    LabelPosition labelPosition = [[markDef objectForKey:@"position"] integerValue];
    if([markDef objectForKey:@"cutoutRadius"]) {
        self.cutoutRadius = [[markDef objectForKey:@"cutoutRadius"] floatValue];
    } else {
        self.cutoutRadius = kCutoutRadius;
    }
    
    if ([self.delegate respondsToSelector:@selector(coachMarksViewDidClicked:atIndex:)]) {
        [currentView removeFromSuperview];
        currentView = [[UIView alloc] initWithFrame:markRect];
        currentView.backgroundColor = [UIColor clearColor];
        
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTap:)];
        
        BOOL tabEnabled = NO;
        if( [markDef objectForKey:@"didTabEnabled"])
            tabEnabled = [[markDef objectForKey:@"didTabEnabled"] boolValue];
        if (tabEnabled) {
            // Capture touches
            
            [self addGestureRecognizer:tapGestureRecognizer];
        }
        else {
            
            for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
                [self removeGestureRecognizer:recognizer];
            }
        }
        
        
        // LongPress
        
        BOOL checkLongPress = NO;
        if( [markDef objectForKey:@"checkLongPress"])
            checkLongPress = [[markDef objectForKey:@"checkLongPress"] boolValue];
        
        
        if (checkLongPress) {
            
            UILongPressGestureRecognizer *longPressDetected = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
            
            //            longPressDetected.delegate = self;
            [currentView addGestureRecognizer:longPressDetected];
            
        }
        else
            
        {
            UITapGestureRecognizer *singleFingerTap =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(handleSingleTap:)];
            [currentView addGestureRecognizer:singleFingerTap];
            
        }
        
        //LongPress
        
        
        [self addSubview:currentView];
    }
    
    
    
    [self.arrowImage removeFromSuperview];
    BOOL showArrow = NO;
    if( [markDef objectForKey:@"showArrow"])
        showArrow = [[markDef objectForKey:@"showArrow"] boolValue];
    
    
    // Calculate the caption position and size
    self.lblCaption.alpha = 0.0f;
    self.lblCaption.frame = (CGRect){{0.0f, 0.0f}, {self.maxLblWidth, 0.0f}};
    self.lblCaption.text = markCaption;
    [self.lblCaption sizeToFit];
    CGFloat y;
    CGFloat x;
    
    
    //Label Aligment and Position
    switch (labelAlignment) {
        case LABEL_ALIGNMENT_RIGHT:
            x = floorf(self.bounds.size.width - self.lblCaption.frame.size.width - kLabelMargin);
            break;
            
        case LABEL_ALIGNMENT_LEFT:
            x = kLabelMargin;
            break;
            
        case LABEL_ALIGNMENT_RIGHT1:
            x = markRect.origin.x;
            break;
            
        default:
            x = floorf((self.bounds.size.width - self.lblCaption.frame.size.width) / 2.0f);
            break;
    }
    
    switch (labelPosition) {
            
        case LABEL_POSITION_CENTER:
        {
            y = markRect.origin.y + markRect.size.height/2 - kLabelMargin;
            //            x = self.bounds.size.width - self.lblCaption.frame.size.width - kLabelMargin - markRect.size.width;
            if(showArrow) {
                self.arrowImage = [[UIImageView alloc] initWithImage:[self fetchImage:@"arrow-top"]];
                CGRect imageViewFrame = self.arrowImage.frame;
                imageViewFrame.origin.x = x;
                imageViewFrame.origin.y = y;
                self.arrowImage.frame = imageViewFrame;
                y -= (self.arrowImage.frame.size.height + kLabelMargin);
                [self addSubview:self.arrowImage];
            }
        }
            break;
            
        case LABEL_POSITION_TOP:
        {
            y = markRect.origin.y - self.lblCaption.frame.size.height - kLabelMargin;
            //            x = self.bounds.size.width - self.lblCaption.frame.size.width - kLabelMargin - markRect.size.width;
            if(showArrow) {
                self.arrowImage = [[UIImageView alloc] initWithImage:[self fetchImage:@"arrow-down"]];
                CGRect imageViewFrame = self.arrowImage.frame;
                imageViewFrame.origin.x = x;
                imageViewFrame.origin.y = y;
                self.arrowImage.frame = imageViewFrame;
                y -= (self.arrowImage.frame.size.height + kLabelMargin);
                [self addSubview:self.arrowImage];
            }
        }
            break;
        case LABEL_POSITION_LEFT:
        {
            y = markRect.origin.y + markRect.size.height/2 - self.lblCaption.frame.size.height/2;
            x = self.bounds.size.width - self.lblCaption.frame.size.width - kLabelMargin - markRect.size.width;
            if(showArrow) {
                self.arrowImage = [[UIImageView alloc] initWithImage:[self fetchImage:@"arrow-right"]];
                CGRect imageViewFrame = self.arrowImage.frame;
                imageViewFrame.origin.x = self.bounds.size.width - self.arrowImage.frame.size.width - kLabelMargin - markRect.size.width;
                imageViewFrame.origin.y = y + self.lblCaption.frame.size.height/2 - imageViewFrame.size.height/2;
                self.arrowImage.frame = imageViewFrame;
                x -= (self.arrowImage.frame.size.width + kLabelMargin);
                [self addSubview:self.arrowImage];
            }
        }
            break;
        case LABEL_POSITION_RIGHT:
        {
            y = markRect.origin.y + markRect.size.height/2 - self.lblCaption.frame.size.height/2;
            x = markRect.origin.x + markRect.size.width + kLabelMargin;
            if(showArrow) {
                
            }
        }
            break;
            //        case LABEL_POSITION_RIGHT_BOTTOM:
            //        {
            //            y = markRect.origin.y + markRect.size.height + self.lblSpacing;
            //
            //
            //            CGFloat bottomY = y + self.lblCaption.frame.size.height + self.lblSpacing;
            //            if (bottomY > self.bounds.size.height) {
            //                y = markRect.origin.y - self.lblSpacing - self.lblCaption.frame.size.height;
            //            }
            //            x = markRect.origin.x + markRect.size.width + kLabelMargin;
            //            if(showArrow) {
            //                self.arrowImage = [[UIImageView alloc] initWithImage:[self fetchImage:@"arrow-top"]];
            //                CGRect imageViewFrame = self.arrowImage.frame;
            //                imageViewFrame.origin.x = x - markRect.size.width/2 - imageViewFrame.size.width/2;
            //                imageViewFrame.origin.y = y - kLabelMargin; //self.lblCaption.frame.size.height/2
            //                y += imageViewFrame.size.height/2;
            //                self.arrowImage.frame = imageViewFrame;
            //                [self addSubview:self.arrowImage];
            //            }
            //
            //        }
            //            break;
        default: {
            y = markRect.origin.y + markRect.size.height + self.lblSpacing;
            CGFloat bottomY = y + self.lblCaption.frame.size.height + self.lblSpacing;
            if (bottomY > self.bounds.size.height) {
                y = markRect.origin.y - self.lblSpacing - self.lblCaption.frame.size.height;
            }
            if(showArrow) {
                self.arrowImage = [[UIImageView alloc] initWithImage:[self fetchImage:@"arrow-top"]];
                CGRect imageViewFrame = self.arrowImage.frame;
                imageViewFrame.origin.x = x;
                imageViewFrame.origin.y = y;
                self.arrowImage.frame = imageViewFrame;
                y += (self.arrowImage.frame.size.height + kLabelMargin);
                [self addSubview:self.arrowImage];
            }
        }
            break;
    }
    
    // Animate the caption label
    self.lblCaption.frame = (CGRect){{x, y}, self.lblCaption.frame.size};
    
    [UIView animateWithDuration:0.3f animations:^{
        self.lblCaption.alpha = 1.0f;
    }];
    
    // Delegate (coachMarksView:willNavigateTo:atIndex:)
    if ([self.delegate respondsToSelector:@selector(coachMarksView:willNavigateToIndex:)]) {
        [self.delegate coachMarksView:self willNavigateToIndex:markIndex];
    }
    
    // If first mark, set the cutout to the center of first mark
    if (markIndex == 0) {
        CGPoint center = CGPointMake(floorf(markRect.origin.x + (markRect.size.width / 2.0f)), floorf(markRect.origin.y + (markRect.size.height / 2.0f)));
        CGRect centerZero = (CGRect){center, CGSizeZero};
        [self setCutoutToRect:centerZero withShape:shape];
    }
    
    // Animate the cutout
    [self animateCutoutToRect:markRect withShape:shape];
    
    CGFloat lblContinueWidth = self.enableSkipButton ? (50.0/100.0) * self.bounds.size.width : self.bounds.size.width;
    CGFloat btnSkipWidth = self.bounds.size.width - lblContinueWidth;
    
    if( [markDef objectForKey:@"enableContinueLabel"])
        self.enableContinueLabel = [[markDef objectForKey:@"enableContinueLabel"] boolValue];
    
    if( [markDef objectForKey:@"enableSkipButton"])
        self.enableSkipButton  = [[markDef objectForKey:@"enableSkipButton"] boolValue];
    
    // Show continue lbl if first mark
    if (self.enableContinueLabel) {
        if (markIndex == 0) {
            lblContinue = [[UILabel alloc] initWithFrame:(CGRect){{0, [self yOriginForContinueLabel]}, {lblContinueWidth, 30.0f}}];
            lblContinue.font = [UIFont boldSystemFontOfSize:13.0f];
            lblContinue.textAlignment = NSTextAlignmentCenter;
            lblContinue.text = @"Tap to continue";
            lblContinue.alpha = 0.0f;
            lblContinue.backgroundColor = [UIColor whiteColor];
            [self addSubview:lblContinue];
            [UIView animateWithDuration:0.3f delay:1.0f options:0 animations:^{
                lblContinue.alpha = 1.0f;
            } completion:nil];
        } else if (markIndex > 0 && lblContinue != nil) {
            // Otherwise, remove the lbl
            [lblContinue removeFromSuperview];
            lblContinue = nil;
        }
    }
    
    if (self.enableSkipButton) {
        btnSkipCoach = [[UIButton alloc] initWithFrame:(CGRect){{lblContinueWidth, [self yOriginForContinueLabel]}, {btnSkipWidth, 30.0f}}];
        [btnSkipCoach addTarget:self action:@selector(skipCoach) forControlEvents:UIControlEventTouchUpInside];
        [btnSkipCoach setTitle:@"Skip" forState:UIControlStateNormal];
        btnSkipCoach.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        btnSkipCoach.alpha = 0.0f;
        btnSkipCoach.tintColor = [UIColor whiteColor];
        [self addSubview:btnSkipCoach];
        [UIView animateWithDuration:0.3f delay:1.0f options:0 animations:^{
            btnSkipCoach.alpha = 1.0f;
        } completion:nil];
    }
}

- (CGFloat)yOriginForContinueLabel {
    switch (self.continueLocation) {
        case LOCATION_TOP:
            return 20.0f;
        case LOCATION_CENTER:
            return self.bounds.size.height / 2 - 15.0f;
        default:
            return self.bounds.size.height - 30.0f;
    }
}

#pragma mark - Cleanup

- (void)cleanup {
    // Delegate (coachMarksViewWillCleanup:)
    if ([self.delegate respondsToSelector:@selector(coachMarksViewWillCleanup:)]) {
        [self.delegate coachMarksViewWillCleanup:self];
    }
    
    // Fade out self
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         self.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         // Remove self
                         [self removeFromSuperview];
                         
                         // Delegate (coachMarksViewDidCleanup:)
                         if ([self.delegate respondsToSelector:@selector(coachMarksViewDidCleanup:)]) {
                             [self.delegate coachMarksViewDidCleanup:self];
                         }
                     }];
}

#pragma mark - Animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    // Delegate (coachMarksView:didNavigateTo:atIndex:)
    if ([self.delegate respondsToSelector:@selector(coachMarksView:didNavigateToIndex:)]) {
        [self.delegate coachMarksView:self didNavigateToIndex:markIndex];
    }
}


- (void) continueNextStepSet:(Boolean)typeVal
{
    self.continueNextStep =typeVal;
}

- (Boolean) continueNextStepGet
{
    return self.continueNextStep;
}

- (void) coachMarksSet:(NSArray*) newCoachMarks
{
    self.coachMarks = newCoachMarks;
}



@end

