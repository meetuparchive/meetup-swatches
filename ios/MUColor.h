//
//  MUColor.h
//  MeetupApp
//
//  Generated by Meetup Design on 01/22/2015.
//  Copyright (c) 2015 Meetup, Inc. All rights reserved.
//

@import UIKit;
@interface MUColor : NSObject

#pragma mark - Base color palette

+ (UIColor *)white;
+ (UIColor *)darkGray;
+ (UIColor *)mediumGray;
+ (UIColor *)lightGray;
+ (UIColor *)red;
+ (UIColor *)green;
+ (UIColor *)blue;
+ (UIColor *)lightBlue;
+ (UIColor *)purple;
+ (UIColor *)brown;
+ (UIColor *)yellow;


#pragma mark - Text colors

+ (UIColor *)textPrimary;
+ (UIColor *)textSecondary;
+ (UIColor *)textTertiary;
+ (UIColor *)textPrimaryInverted;
+ (UIColor *)textSecondaryInverted;
+ (UIColor *)textTertiaryInverted;


#pragma mark - UI Colors

+ (UIColor *)accent;
+ (UIColor *)link;
+ (UIColor *)border;
+ (UIColor *)borderInverted;
+ (UIColor *)overlayPressed;
+ (UIColor *)modalShade;
+ (UIColor *)shade;
+ (UIColor *)shadeInverted;
+ (UIColor *)textProtection;


#pragma mark - Background colors

+ (UIColor *)contentBG;
+ (UIColor *)contentBGInverted;
+ (UIColor *)collectionBGDark;
+ (UIColor *)collectionBGLight;


#pragma mark - EXTERNAL

+ (UIColor *)facebook;
+ (UIColor *)twitter;
+ (UIColor *)linkedin;
+ (UIColor *)tumblr;
+ (UIColor *)flickr;
+ (UIColor *)foursquare;
+ (UIColor *)googleplus;
+ (UIColor *)instagram;
+ (UIColor *)reddit;
+ (UIColor *)wepay;


@end
