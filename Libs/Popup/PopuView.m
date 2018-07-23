//
//  PopuView.m
//  FastReadApp
//
//  Created by wsmbp on 2018/4/10.
//  Copyright © 2018年 LSH. All rights reserved.
//

#import "PopuView.h"
#import "KLCPopup.h"
static KLCPopup *_popup;

@implementation PopuView
+(void)showView:(UIView *)view controller:(UIViewController *)controller
{
    KLCPopupLayout layout = KLCPopupLayoutMake((KLCPopupHorizontalLayout)KLCPopupHorizontalLayoutCenter,
                                               (KLCPopupVerticalLayout)KLCPopupVerticalLayoutBottom);
    _popup = [KLCPopup popupWithContentView:view
                                             showType:KLCPopupShowTypeBounceInFromBottom
                                          dismissType:KLCPopupDismissTypeBounceOutToBottom
                                             maskType:KLCPopupMaskTypeDimmed
                             dismissOnBackgroundTouch:NO
                                dismissOnContentTouch:NO];
    
    
    [_popup showWithLayout:layout duration:0.0];
   
}

+(void)dismiss{
    [_popup dismiss:YES];

}

@end
