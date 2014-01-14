//
//  ADDetailView.m
//  AgileMD
//
//  Created by Zack Liston on 1/13/14.
//  Copyright (c) 2014 Agile Diagnosis. All rights reserved.
//

#import "ADFullScreenDetailView.h"
#import <QuartzCore/QuartzCore.h>

#define ANIMATION_TIME 0.3f

@interface ADFullScreenDetailView ()

@property (nonatomic, weak) UIWindow *window;
@property (nonatomic, strong) UIView *rootView;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIView *buttonView;

@property (nonatomic, strong) UIButton *previousButton;
@property (nonatomic, strong) UIButton *nextButton;

@property (nonatomic, strong) CALayer *titleBorderLayer;
@property (nonatomic, strong) CALayer *textBorderLayer;

@property (nonatomic, strong) NSString *currentTitle;
@property (nonatomic, strong) NSString *currentText;

@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, assign) BOOL isActive;
@end

@implementation ADFullScreenDetailView

#pragma mark Sythesize
@synthesize window = _window;
@synthesize rootView = _rootView;
@synthesize mainView = _mainView;
@synthesize titleView = _titleView;
@synthesize titleLabel = _titleLabel;
@synthesize textLabel = _textLabel;
@synthesize buttonView = _buttonView;

@synthesize previousButton = _previousButton;
@synthesize nextButton = _nextButton;

@synthesize info = _info;
@synthesize currentTitle = _currentTitle;
@synthesize currentText = _currentText;

@synthesize selectedIndex = _selectedIndex;

static ADFullScreenDetailView *sharedDetailView;

#pragma mark Getters and Setters

+ (ADFullScreenDetailView *)sharedInstance
{
    if (!sharedDetailView) {
        sharedDetailView = [[ADFullScreenDetailView alloc] init];
    }
    return sharedDetailView;
}

- (NSString *)currentTitle
{
    if (!_currentTitle) {
        _currentTitle = @"";
    }
    return _currentTitle;
}

- (NSString *)currentText
{
    if (!_currentText) {
        _currentText = @"";
    }
    return _currentText;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    if (_selectedIndex != selectedIndex || selectedIndex == 0) {
        _selectedIndex = selectedIndex;
        
        if ([self.info count] > 0 && _selectedIndex < [self.info count]) {
            id object = [self.info objectAtIndex:_selectedIndex];
            if ([object isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dictionary = (NSDictionary *)object;
                if ([dictionary objectForKey:@"title"]) {
                    self.currentTitle = [dictionary objectForKey:@"title"];
                }
                if ([dictionary objectForKey:@"text"]) {
                    self.currentText = [dictionary objectForKey:@"text"];
                }
            }
        }
        self.previousButton.enabled = (_selectedIndex > 0) ? YES : NO;
        self.nextButton.enabled = (_selectedIndex < self.info.count-1) ? YES : NO;
    }
}

#pragma mark Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.isActive = NO;
        self.window = [[UIApplication sharedApplication] keyWindow];
        [self setupRootView];
    }
    return self;
}

#pragma mark Setup
- (void)setupRootView
{
    self.rootView = [[UIView alloc] initWithFrame:self.window.bounds];
    self.rootView.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimmedViewTapped:)];
    [self.rootView addGestureRecognizer:tap];
    
    [self setupMainView];
}

- (void)setupMainView
{
    CGFloat height = [self titleLabelHeight]+[self textLabelHeight]+44.0;
    self.mainView = [[UIView alloc] initWithFrame:CGRectMake(0.0, -height, self.window.frame.size.width, height)];
    self.mainView.backgroundColor = [UIColor colorC50];
    
    [self setupTitleView];
    [self setupTextView];
    [self setupButtonView];
    [self.rootView addSubview:self.mainView];
}

- (void)setupTitleView
{
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.mainView.bounds.size.width, [self titleLabelHeight])];
    self.titleView.backgroundColor = [UIColor clearColor];
    
    if (!self.titleBorderLayer) {
        self.titleBorderLayer = [CALayer layer];
    }
    self.titleBorderLayer.frame = CGRectMake(0.0f, self.titleView.bounds.size.height-1.0, self.titleView.bounds.size.width, 0.5f);
    self.titleBorderLayer.backgroundColor = [UIColor colorC40].CGColor;
    [self.titleView.layer addSublayer:self.titleBorderLayer];

    
    CGRect titleFrame = CGRectInset(self.titleView.bounds, 10.0, 10.0);
    titleFrame.size.width -= 55.0;
    
    self.titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    self.titleLabel.textColor = [UIColor colorC43];
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.text = self.currentTitle;
    
    CGRect buttonFrame = CGRectMake(self.titleView.frame.size.width-50.0, self.titleView.frame.size.height/2.0-20.0, 40.0, 40.0);
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    closeButton.frame = buttonFrame;
    closeButton.tag = 9;
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton setTintColor:[UIColor colorC30]];
    
    [self.titleView addSubview:self.titleLabel];
    [self.titleView addSubview:closeButton];
    [self.mainView addSubview:self.titleView];
}

- (void)setupTextView
{
    CGRect textFrame = CGRectMake(10.0, [self titleLabelHeight], self.window.bounds.size.width-20.0, [self textLabelHeight]);
    
    self.textLabel = [[UILabel alloc] initWithFrame:textFrame];
    self.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    self.textLabel.textColor = [UIColor colorC43];
    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.textLabel.numberOfLines = 0;
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.text = self.currentText;
    
    if (!self.textBorderLayer) {
        self.textBorderLayer = [CALayer layer];
    }
    self.textBorderLayer.frame = CGRectMake(0.0f, self.textLabel.bounds.size.height-1.0, self.window.bounds.size.width, 0.5f);
    self.textBorderLayer.backgroundColor = [UIColor colorC40].CGColor;
    [self.textLabel.layer addSublayer:self.textBorderLayer];
    
    [self.mainView addSubview:self.textLabel];
}

- (void)setupButtonView
{
    CGRect buttonViewFrame = CGRectMake(0.0, [self titleLabelHeight]+[self textLabelHeight], self.window.bounds.size.width, 44.0);
    
    self.buttonView = [[UIView alloc] initWithFrame:buttonViewFrame];
    self.buttonView.backgroundColor = [UIColor clearColor];
    
    self.previousButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.previousButton setTitle:@"Previous" forState:UIControlStateNormal];
    [self.previousButton setTitleColor:[UIColor colorC21] forState:UIControlStateNormal];
    [self.previousButton setTitleColor:[UIColor colorC40] forState:UIControlStateDisabled];
    CGRect backButtonFrame = CGRectMake(5.0, 5.0, 75.0, 34.0);
    self.previousButton.frame = backButtonFrame;
    [self.previousButton addTarget:self action:@selector(previousButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttonView addSubview:self.previousButton];
    
    self.nextButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor colorC21] forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor colorC40] forState:UIControlStateDisabled];
    CGRect nextButtonFrame = CGRectMake(self.buttonView.bounds.size.width-45.0, 5.0, 40.0, 34.0);
    self.nextButton.frame = nextButtonFrame;
    [self.nextButton addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttonView addSubview:self.nextButton];
    
    [self.mainView addSubview:self.buttonView];
}

- (void)showIndex:(NSUInteger)index
{
    self.selectedIndex = index;
    [self layoutViews];
    
    if (!self.isActive) {
        self.isActive = YES;
        [self.window addSubview:self.rootView];
        CGRect mainViewFrame = self.mainView.frame;
        mainViewFrame.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height;
        
        [UIView animateWithDuration:ANIMATION_TIME animations:^{
            self.rootView.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
            self.mainView.frame = mainViewFrame;
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)remove
{
    self.isActive = NO;
    
    CGRect mainViewFrame = self.mainView.frame;
    mainViewFrame.origin.y = -mainViewFrame.size.height;
    
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        self.rootView.backgroundColor = [UIColor clearColor];
        self.mainView.frame = mainViewFrame;
    } completion:^(BOOL finished) {
        [self.rootView removeFromSuperview];
    }];
}

#pragma mark Helpers

- (CGFloat)titleLabelHeight
{
    CGSize maxSize = CGSizeMake(self.window.bounds.size.width-75.0, MAXFLOAT);
    CGSize labelSize = [self.currentTitle sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16.0] constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
    
    return MAX(44.0, labelSize.height+20.0);
}

- (CGFloat)textLabelHeight
{
    CGSize maxSize = CGSizeMake(self.window.bounds.size.width-20.0, MAXFLOAT);
    CGSize labelSize = [self.currentText sizeWithFont:[UIFont fontWithName:@"Helvetica" size:15.0] constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
    return labelSize.height + 20.0;
}

- (void)layoutViews
{
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        self.titleLabel.text = self.currentTitle;
        self.textLabel.text = self.currentText;
        
        
        CGFloat height = [self titleLabelHeight]+[self textLabelHeight]+44.0;
        
        if (self.isActive) {
            self.mainView.frame = CGRectMake(0.0, [UIApplication sharedApplication].statusBarFrame.size.height, self.window.frame.size.width, height);
        } else {
            self.mainView.frame = CGRectMake(0.0, -height, self.window.frame.size.width, height);
        }
        
        self.titleView.frame = CGRectMake(0.0, 0.0, self.mainView.bounds.size.width, [self titleLabelHeight]);
        
        CGRect titleFrame = CGRectInset(self.titleView.bounds, 10.0, 10.0);
        titleFrame.size.width -= 55.0;
        self.titleLabel.frame = titleFrame;
        
        for (UIView *subView in self.titleView.subviews) {
            if (subView.tag == 9) {
                subView.frame = CGRectMake(self.titleView.frame.size.width-50.0, self.titleView.frame.size.height/2.0-20.0, 40.0, 40.0);
            }
        }
        
        self.titleBorderLayer.frame = CGRectMake(0.0f, self.titleView.bounds.size.height-1.0, self.titleView.bounds.size.width, 0.5f);
        
        self.textLabel.frame = CGRectMake(10.0, [self titleLabelHeight], self.window.bounds.size.width-20.0, [self textLabelHeight]);
        self.textBorderLayer.frame = CGRectMake(0.0f, self.textLabel.bounds.size.height-1.0, self.window.bounds.size.width, 0.5f);
        
        self.buttonView.frame = CGRectMake(0.0, [self titleLabelHeight]+[self textLabelHeight], self.window.bounds.size.width, 44.0);
    }];
}

#pragma mark Button Responders

- (void)closeButtonClicked:(UIButton *)button
{
    [self remove];
}

- (void)previousButtonClicked:(UIButton *)button
{
    self.selectedIndex--;
    [self layoutViews];
}

- (void)nextButtonClicked:(UIButton *)button
{
    self.selectedIndex++;
    [self layoutViews];
}

- (void)dimmedViewTapped:(UITapGestureRecognizer *)tap
{
    [self remove];
}

@end
