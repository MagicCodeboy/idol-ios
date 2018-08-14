//
//  NTESChatroomConfig.m
//  NIM
//
//  Created by chris on 15/12/14.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import "NTESChatroomConfig.h"
#import "NTESChatroomMessageDataProvider.h"
#import "UIImage+NIMKit.h"
@interface NTESChatroomConfig()

@property (nonatomic,strong) NTESChatroomMessageDataProvider *provider;

@end

@implementation NTESChatroomConfig

- (instancetype)initWithChatroom:(NSString *)roomId{
    self = [super init];
    if (self) {
        self.provider = [[NTESChatroomMessageDataProvider alloc] initWithChatroom:roomId];
    }
    return self;
}

- (id<NIMKitMessageProvider>)messageDataProvider{
    return self.provider;
}


- (NSArray<NSNumber *> *)inputBarItemTypes{
    return @[@(NIMInputBarItemTypeVoice),
               @(NIMInputBarItemTypeTextAndRecord),
               @(NIMInputBarItemTypeEmoticon),
               @(NIMInputBarItemTypeMore)
            ];
}


- (NSArray *)mediaItems
{
    return @[[NIMMediaItem item:@"onTapMediaItemPicture:"
                    normalImage:[UIImage nim_imageInKit:@"bk_media_picture_normal"]
                  selectedImage:[UIImage nim_imageInKit:@"bk_media_picture_nomal_pressed"]
                          title:LocalizedStr(@"Photos")],
             
             [NIMMediaItem item:@"onTapMediaItemShoot:"
                    normalImage:[UIImage nim_imageInKit:@"bk_media_shoot_normal"]
                  selectedImage:[UIImage nim_imageInKit:@"bk_media_shoot_pressed"]
                          title:LocalizedStr(@"Camera")]];
             

}



- (NSArray<NIMInputEmoticonCatalog *> *)charlets{
    return nil;
}

- (BOOL)autoFetchWhenOpenSession
{
    return YES;
}

- (BOOL)shouldHandleReceipt
{
    return NO;
}


@end
