//
//  NTESSessionUtil.m
//  NIMDemo
//
//  Created by ght on 15-1-27.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESSessionUtil.h"
//#import "NTESLoginManager.h"
//#import "NTESSnapchatAttachment.h"
//#import "NTESJanKenPonAttachment.h"
//#import "NTESChartletAttachment.h"
//#import "UIImage+NTES.h"
#import "NIMKit.h"
//#import "NTESSnapchatAttachment.h"
//#import "NTESWhiteboardAttachment.h"
#import "NIMKitInfoFetchOption.h"
//#import "NTESSubscribeManager.h"
#import "NIMExtensionHelper.h"
//#import "NTESSubscribeDefine.h"
#import "NSDictionary+NTESJson.h"
//#import "NTESDevice.h"

double OnedayTimeIntervalValue = 24*60*60;  //一天的秒数

static NSString *const NTESRecentSessionAtMark = @"NTESRecentSessionAtMark";

@implementation NTESSessionUtil

+ (CGSize)getImageSizeWithImageOriginSize:(CGSize)originSize
                                  minSize:(CGSize)imageMinSize
                                  maxSize:(CGSize)imageMaxSiz
{
    CGSize size;
    NSInteger imageWidth = originSize.width ,imageHeight = originSize.height;
    NSInteger imageMinWidth = imageMinSize.width, imageMinHeight = imageMinSize.height;
    NSInteger imageMaxWidth = imageMaxSiz.width, imageMaxHeight = imageMaxSiz.height;
    if (imageWidth > imageHeight) //宽图
    {
        size.height = imageMinHeight;  //高度取最小高度
        size.width = imageWidth * imageMinHeight / imageHeight;
        if (size.width > imageMaxWidth)
        {
            size.width = imageMaxWidth;
        }
    }
    else if(imageWidth < imageHeight)//高图
    {
        size.width = imageMinWidth;
        size.height = imageHeight *imageMinWidth / imageWidth;
        if (size.height > imageMaxHeight)
        {
            size.height = imageMaxHeight;
        }
    }
    else//方图
    {
        if (imageWidth > imageMaxWidth)
        {
            size.width = imageMaxWidth;
            size.height = imageMaxHeight;
        }
        else if(imageWidth > imageMinWidth)
        {
            size.width = imageWidth;
            size.height = imageHeight;
        }
        else
        {
            size.width = imageMinWidth;
            size.height = imageMinHeight;
        }
    }
    return size;
}

                                                 
+(BOOL)isTheSameDay:(NSTimeInterval)currentTime compareTime:(NSDateComponents*)older
{
    NSCalendarUnit currentComponents = (NSCalendarUnit)(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour | NSCalendarUnitMinute);
    NSDateComponents *current = [[NSCalendar currentCalendar] components:currentComponents fromDate:[NSDate dateWithTimeIntervalSinceNow:currentTime]];
    
    return current.year == older.year && current.month == older.month && current.day == older.day;
}

+(NSString*)weekdayStr:(NSInteger)dayOfWeek
{
    static NSDictionary *daysOfWeekDict = nil;
    daysOfWeekDict = @{@(1):@"星期日",
                       @(2):@"星期一",
                       @(3):@"星期二",
                       @(4):@"星期三",
                       @(5):@"星期四",
                       @(6):@"星期五",
                       @(7):@"星期六",};
    return [daysOfWeekDict objectForKey:@(dayOfWeek)];
}


+(NSDateComponents*)stringFromTimeInterval:(NSTimeInterval)messageTime components:(NSCalendarUnit)components
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:components fromDate:[NSDate dateWithTimeIntervalSince1970:messageTime]];
    return dateComponents;
}


+ (NSString *)showNick:(NSString*)uid inSession:(NIMSession*)session{
    
    NSString *nickname = nil;
    if (session.sessionType == NIMSessionTypeTeam)
    {
        NIMTeamMember *member = [[NIMSDK sharedSDK].teamManager teamMember:uid inTeam:session.sessionId];
        nickname = member.nickname;
    }
    if (!nickname.length) {
        NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:uid option:nil];
        nickname = info.showName;
    }
    return nickname;
}
+ (NSString *)onlineState:(NSString *)userId detail:(BOOL)detail
{
    NSString *state = @"";
    if ([[NIMSDK sharedSDK].loginManager.currentAccount isEqualToString:userId])
    {
        //没有开启订阅服务或是自己  不显示在线状态
        return state;
    }
    if ([[NIMSDK sharedSDK].robotManager isValidRobot:userId]) {
        return @"在线";
    }
    return @"在线";

    
}

+(NSString*)showTime:(NSTimeInterval) msglastTime showDetail:(BOOL)showDetail
{
    //今天的时间
    NSDate * nowDate = [NSDate date];
    NSDate * msgDate = [NSDate dateWithTimeIntervalSince1970:msglastTime];
    NSString *result = nil;
    NSCalendarUnit components = (NSCalendarUnit)(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitHour | NSCalendarUnitMinute);
    NSDateComponents *nowDateComponents = [[NSCalendar currentCalendar] components:components fromDate:nowDate];
    NSDateComponents *msgDateComponents = [[NSCalendar currentCalendar] components:components fromDate:msgDate];

    NSInteger hour = msgDateComponents.hour;
    
    result = [NTESSessionUtil getPeriodOfTime:hour withMinute:msgDateComponents.minute];
    if (hour > 12)
    {
        hour = hour - 12;
    }
    if(nowDateComponents.day == msgDateComponents.day) //同一天,显示时间
    {
        result = [[NSString alloc] initWithFormat:@"%@ %zd:%02d",result,hour,(int)msgDateComponents.minute];
    }
    else if(nowDateComponents.day == (msgDateComponents.day+1))//昨天
    {
        result = showDetail?  [[NSString alloc] initWithFormat:@"昨天%@ %zd:%02d",result,hour,(int)msgDateComponents.minute] : @"昨天";
    }
    else if(nowDateComponents.day == (msgDateComponents.day+2)) //前天
    {
        result = showDetail? [[NSString alloc] initWithFormat:@"前天%@ %zd:%02d",result,hour,(int)msgDateComponents.minute] : @"前天";
    }
    else if([nowDate timeIntervalSinceDate:msgDate] < 7 * OnedayTimeIntervalValue)//一周内
    {
        NSString *weekDay = [NTESSessionUtil weekdayStr:msgDateComponents.weekday];
        result = showDetail? [weekDay stringByAppendingFormat:@"%@ %zd:%02d",result,hour,(int)msgDateComponents.minute] : weekDay;
    }
    else//显示日期
    {
        NSString *day = [NSString stringWithFormat:@"%zd-%zd-%zd", msgDateComponents.year, msgDateComponents.month, msgDateComponents.day];
        result = showDetail? [day stringByAppendingFormat:@"%@ %zd:%02d",result,hour,(int)msgDateComponents.minute]:day;
    }
    return result;
}

+ (NSString *)getPeriodOfTime:(NSInteger)time withMinute:(NSInteger)minute
{
    NSInteger totalMin = time *60 + minute;
    NSString *showPeriodOfTime = @"";
    if (totalMin > 0 && totalMin <= 5 * 60)
    {
        showPeriodOfTime = @"凌晨";
    }
    else if (totalMin > 5 * 60 && totalMin < 12 * 60)
    {
        showPeriodOfTime = @"上午";
    }
    else if (totalMin >= 12 * 60 && totalMin <= 18 * 60)
    {
        showPeriodOfTime = @"下午";
    }
    else if ((totalMin > 18 * 60 && totalMin <= (23 * 60 + 59)) || totalMin == 0)
    {
        showPeriodOfTime = @"晚上";
    }
    return showPeriodOfTime;
}


+ (void)sessionWithInputURL:(NSURL*)inputURL
                  outputURL:(NSURL*)outputURL
               blockHandler:(void (^)(AVAssetExportSession*))handler
{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset
                                                                     presetName:AVAssetExportPresetMediumQuality];
    session.outputURL = outputURL;
    session.outputFileType = AVFileTypeMPEG4;   // 支持安卓某些机器的视频播放
    session.shouldOptimizeForNetworkUse = YES;
    [session exportAsynchronouslyWithCompletionHandler:^(void)
     {
         handler(session);
     }];
}


+ (NSDictionary *)dictByJsonData:(NSData *)data
{
    NSDictionary *dict = nil;
    if ([data isKindOfClass:[NSData class]])
    {
        NSError *error = nil;
        dict = [NSJSONSerialization JSONObjectWithData:data
                                               options:0
                                                 error:&error];
        if (error) {
        }
    }
    return [dict isKindOfClass:[NSDictionary class]] ? dict : nil;
}


+ (NSDictionary *)dictByJsonString:(NSString *)jsonString
{
    if (!jsonString.length) {
        return nil;
    }
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    return [NTESSessionUtil dictByJsonData:data];
}


+ (NSString *)tipOnMessageRevoked:(NIMRevokeMessageNotification *)notificaton
{
    NSString *fromUid = nil;
    NIMSession *session = nil;
    NSString *tip = @"";
    BOOL isFromMe = NO;
    if([notificaton isKindOfClass:[NIMRevokeMessageNotification class]])
    {
        fromUid = [notificaton fromUserId];
        session = [notificaton session];
        isFromMe = [fromUid isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]];

    }
    else if(!notificaton)
    {
        isFromMe = YES;
    }
    else
    {
        assert(0);
    }
    if (isFromMe)
    {
        tip = @"你";
    }
    else{
        switch (session.sessionType) {
            case NIMSessionTypeP2P:
                tip = @"对方";
                break;
            case NIMSessionTypeTeam:{
                NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:session.sessionId];
                NIMTeamMember *member = [[NIMSDK sharedSDK].teamManager teamMember:fromUid inTeam:session.sessionId];
                if ([fromUid isEqualToString:team.owner])
                {
                    tip = @"群主";
                }
                else if(member.type == NIMTeamMemberTypeManager)
                {
                    tip = @"管理员";
                }
                NIMKitInfoFetchOption *option = [[NIMKitInfoFetchOption alloc] init];
                option.session = session;
                NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:fromUid option:option];
                tip = [tip stringByAppendingString:info.showName];
            }
                break;
            default:
                break;
        }
    }
    return [NSString stringWithFormat:@"%@撤回了一条消息",tip];
}




+ (BOOL)canRevokeMessageByRole:(NIMMessage *)message
{
    BOOL isFromMe  = [message.from isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]];
    BOOL isToMe        = [message.session.sessionId isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]];
    BOOL isTeamManager = NO;
    if (message.session.sessionType == NIMSessionTypeTeam)
    {
        NIMTeamMember *member = [[NIMSDK sharedSDK].teamManager teamMember:[NIMSDK sharedSDK].loginManager.currentAccount inTeam:message.session.sessionId];
        isTeamManager = member.type == NIMTeamMemberTypeOwner || member.type == NIMTeamMemberTypeManager;
    }
    
    BOOL isRobotMessage = NO;
    id<NIMMessageObject> messageObject = message.messageObject;
    if ([messageObject isKindOfClass:[NIMRobotObject class]]) {
        NIMRobotObject *robotObject = (NIMRobotObject *)messageObject;
        isRobotMessage = robotObject.isFromRobot;
    }
    //我发出去的消息并且不是发给我的电脑的消息并且不是机器人的消息，可以撤回
    //群消息里如果我是管理员可以撤回以上所有消息
    return (isFromMe && !isToMe && !isRobotMessage) || isTeamManager;
}


+ (void)addRecentSessionAtMark:(NIMSession *)session
{
    NIMRecentSession *recent = [[NIMSDK sharedSDK].conversationManager recentSessionBySession:session];
    if (recent)
    {
        NSDictionary *localExt = recent.localExt?:@{};
        NSMutableDictionary *dict = [localExt mutableCopy];
        [dict setObject:@(YES) forKey:NTESRecentSessionAtMark];
        [[NIMSDK sharedSDK].conversationManager updateRecentLocalExt:dict recentSession:recent];
    }


}

+ (void)removeRecentSessionAtMark:(NIMSession *)session
{
    NIMRecentSession *recent = [[NIMSDK sharedSDK].conversationManager recentSessionBySession:session];
    if (recent) {
        NSMutableDictionary *localExt = [recent.localExt mutableCopy];
        [localExt removeObjectForKey:NTESRecentSessionAtMark];
        [[NIMSDK sharedSDK].conversationManager updateRecentLocalExt:localExt recentSession:recent];
    }
}

+ (BOOL)recentSessionIsAtMark:(NIMRecentSession *)recent
{
    NSDictionary *localExt = recent.localExt;
    return [localExt[NTESRecentSessionAtMark] boolValue] == YES;
}





+ (NIMLoginClientType)resolveShowClientType:(NSArray *)senderClientTypes
{
    NSArray *clients = @[@(NIMLoginClientTypePC),@(NIMLoginClientTypemacOS),@(NIMLoginClientTypeiOS),@(NIMLoginClientTypeAOS),@(NIMLoginClientTypeWeb),@(NIMLoginClientTypeWP)]; //显示优先级
    for (NSNumber *type in clients) {
        NIMLoginClientType client = type.integerValue;
        if ([senderClientTypes containsObject:@(client)]) {
            return client;
        }
    }
    return NIMLoginClientTypeUnknown;
}

+ (NSString *)resolveOnlineClientName:(NIMLoginClientType )client
{
    NSDictionary *formats  = @{
                              @(NIMLoginClientTypePC) : @"PC",
                              @(NIMLoginClientTypemacOS) : @"Mac",
                              @(NIMLoginClientTypeiOS): @"iOS",
                              @(NIMLoginClientTypeAOS): @"Android",
                              @(NIMLoginClientTypeWeb): @"Web",
                              @(NIMLoginClientTypeWP) : @"WP"
                             };

    NSString *format = [formats objectForKey:@(client)];
    return format? format : @"";
}



+ (NSString *)formatAutoLoginMessage:(NSError *)error
{
    NSString *message = [NSString stringWithFormat:@"自动登录失败 %@",error];
    NSString *domain = error.domain;
    NSInteger code = error.code;
    if ([domain isEqualToString:NIMLocalErrorDomain])
    {
        if (code == NIMLocalErrorCodeAutoLoginRetryLimit)
        {
            message = @"自动登录错误次数超限，请检查网络后重试";
        }
    }
    else if([domain isEqualToString:NIMRemoteErrorDomain])
    {
        if (code == NIMRemoteErrorCodeInvalidPass)
        {
            message = @"密码错误";
        }
        else if(code == NIMRemoteErrorCodeExist)
        {
            message = @"当前已经其他设备登录，请使用手动模式登录";
        }
    }
    return message;
}
+ (AVMutableVideoComposition *) getVideoComposition:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    CGSize videoSize = videoTrack.naturalSize;
    BOOL isPortrait_ = [NTESSessionUtil isVideoPortrait:asset];
    if(isPortrait_) {
        videoSize = CGSizeMake(videoSize.height, videoSize.width);
    }
    composition.naturalSize     = videoSize;
    videoComposition.renderSize = videoSize;
    
    videoComposition.frameDuration = CMTimeMakeWithSeconds( 1 / videoTrack.nominalFrameRate, 600);
    AVMutableCompositionTrack *compositionVideoTrack;
    compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    AVMutableVideoCompositionLayerInstruction *layerInst;
    layerInst = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    [layerInst setTransform:videoTrack.preferredTransform atTime:kCMTimeZero];
    AVMutableVideoCompositionInstruction *inst = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    inst.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    inst.layerInstructions = [NSArray arrayWithObject:layerInst];
    videoComposition.instructions = [NSArray arrayWithObject:inst];
    return videoComposition;
}
+(BOOL) isVideoPortrait:(AVAsset *)asset
{
    BOOL isPortrait = NO;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks    count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        
        CGAffineTransform t = videoTrack.preferredTransform;
        // Portrait
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0)
        {
            isPortrait = YES;
        }
        // PortraitUpsideDown
        if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0)  {
            
            isPortrait = YES;
        }
        // LandscapeRight
        if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0)
        {
            isPortrait = NO;
        }
        // LandscapeLeft
        if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0)
        {
            isPortrait = NO;
        }
    }
    return isPortrait;
}
@end
