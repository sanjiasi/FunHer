//
//  ZXRoundedButton.h
//  TORoundedButtonExample
//
//  Created by victor on 2019/8/31.
//  Copyright © 2019 Tim Oliver. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZXRoundedButton : UIButton

/** The text that is displayed in center of the button (Default is "Button") */
@property (nonatomic, copy) IBInspectable NSString *text;

/** The attributed string used in the label of this button. See `UILabel.attributedText` documentation for full details (Default is nil) */
@property (nonatomic, copy, nullable) NSAttributedString *attributedText;

/** The radius of the corners of this button (Default is 12.0f) */
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;

/** The color of the text in this button (Default is white) */
@property (nonatomic, strong) IBInspectable UIColor *textColor;

/** When tapped, the level of transparency that the text label animates to. (Defaults to off with 1.0f) */
@property (nonatomic, assign) IBInspectable CGFloat tappedTextAlpha;

/** The font of the text in the button (Default is size UIFontTextStyleBody with bold) */
@property (nonatomic, strong) UIFont *textFont;

/** Because IB cannot handle fonts, this can alternatively be used to set the font size. (Default is off with 0.0) */
@property (nonatomic, assign) IBInspectable CGFloat textPointSize;

/** Taking the default button background color apply a brightness offset for the tapped color (Default is -0.1f. Set 0.0 for off) */
@property (nonatomic, assign) IBInspectable CGFloat tappedTintColorBrightnessOffset;

/** If desired, explicity set the background color of the button when tapped (Default is nil). */
@property (nonatomic, strong, nullable) IBInspectable UIColor *tappedTintColor;

/** When tapped, the scale by which the button shrinks during the animation (Default is 0.97f) */
@property (nonatomic, assign) IBInspectable CGFloat tappedButtonScale;

/** The duration of the tapping cross-fade animation (Default is 0.4f) */
@property (nonatomic, assign) CGFloat tapAnimationDuration;

/** Given the current size of the text label, the smallest horizontal width in which this button can scale. */
@property (nonatomic, readonly) CGFloat minimumWidth;

/** A callback handler triggered each time the button is tapped. */
@property (nonatomic, copy) void (^tappedHandler)(void);

/** Create a new instance with the supplied button text. The size will be 288 points wide, and 50 tall. */
- (instancetype)initWithText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
