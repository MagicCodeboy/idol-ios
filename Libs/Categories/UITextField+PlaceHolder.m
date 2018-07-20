

//
//  UITextField+PlaceHolder.m
//  jinshanStrmear
//
//  Created by lalala on 2017/6/14.
//  Copyright © 2017年 王森. All rights reserved.
//

#import "UITextField+PlaceHolder.h"
#import "VerticallyAlignedLabel.h"

static const char *phTextView = "placeHolderTextView";

@implementation UITextField (PlaceHolder)
- (UITextField *)placeHolderTextView {
    return objc_getAssociatedObject(self, phTextView);
}
- (void)setPlaceHolderTextView:(UILabel *)placeHolderTextView {
    objc_setAssociatedObject(self, phTextView, placeHolderTextView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)addPlaceHolder:(NSString *)placeHolder {
    if (![self placeHolderTextView]) {
        VerticallyAlignedLabel *label = [[VerticallyAlignedLabel alloc] initWithFrame:self.bounds];
        label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        label.font = self.font;
        label.textAlignment = NSTextAlignmentLeft;
        label.verticalAlignment = VerticalAlignmentTop;
        label.backgroundColor = [UIColor clearColor];
        label.textColor =UIColorFromRGB(0xCCCCCC);
        label.userInteractionEnabled = NO;
        label.text = placeHolder;
        [self addSubview:label];
        [self setPlaceHolderTextView:label];
    }
}
# pragma mark -
# pragma mark - UITextViewDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.placeHolderTextView.hidden = YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text && [textField.text isEqualToString:@""]) {
        self.placeHolderTextView.hidden = NO;
    }
}

@end
