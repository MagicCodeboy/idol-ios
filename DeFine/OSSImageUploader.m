//
//  OSSImageUploader.m
//  OSSImsgeUpload
//
//  Created by cysu on 5/31/16.
//  Copyright © 2016 cysu. All rights reserved.
//

#import "OSSImageUploader.h"
#import <AliyunOSSiOS/OSSService.h>
#import "YYCache+Cache.h"

@implementation OSSImageUploader
static NSString *const AccessKey = @"your-key";
static NSString *const SecretKey = @"your-secret";
static NSString *const BucketName = @"your-bucket";
static NSString *const AliYunHost = @"http://oss-cn-shenzhen.aliyuncs.com/";
static NSString *kTempFolder = @"temp";


//+ (void)asyncUploadImage:(UIImage *)image complete:(void(^)(NSArray<NSString *> *names,UploadImageState state))complete
//{
//    [self uploadImages:@[image] isAsync:YES complete:complete];
//}
//
//+ (void)syncUploadImage:(UIImage *)image complete:(void(^)(NSArray<NSString *> *names,UploadImageState state))complete
//{
//    [self uploadImages:@[image] isAsync:NO complete:complete];
//}

+ (void)asyncUploadImages:(NSArray<UIImage *> *)models andPicImage:(NSString *)picImageName complete:(void(^)(NSArray<NSString *> *names, UploadImageState state))complete
{
    [self uploadImages:models andPicImage:picImageName isAsync:YES complete:complete];
}

//+ (void)syncUploadImages:(NSArray<UIImage *> *)images complete:(void(^)(NSArray<NSString *> *names, UploadImageState state))complete
//{
//    [self uploadImages:images isAsync:NO complete:complete];
//}

+ (void)uploadImages:(NSArray<UIImage *> *)models andPicImage:(NSString *)picImageName isAsync:(BOOL)isAsync complete:(void(^)(NSArray<NSString *> *names, UploadImageState state))complete
{
    NSString * accessKeyId = (NSString *)[[YYCache shareCache] objectForKey:@"accessKeyId"];
    NSString * accessKeySecret = (NSString *)[[YYCache shareCache] objectForKey:@"accessKeySecret"];
    NSString * securityToken = (NSString *)[[YYCache shareCache] objectForKey:@"securityToken"];
    id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:accessKeyId secretKeyId:accessKeySecret securityToken:securityToken];
    
    OSSClient *client = [[OSSClient alloc] initWithEndpoint:AliYunHost credentialProvider:credential];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = models.count;
    
    NSMutableArray *callBackNames = [NSMutableArray array];
    int i = 0;
    for (UIImage *image in models) {
        if (image) {
            NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                //任务执行
                OSSPutObjectRequest * put = [OSSPutObjectRequest new];
                put.bucketName = BucketName;
//                NSString *imageName = [kTempFolder stringByAppendingPathComponent:[[NSUUID UUID].UUIDString stringByAppendingString:@".jpg"]];
                NSString * imageName = picImageName;
                put.objectKey = imageName;
                [callBackNames addObject:imageName];
                NSData *data = UIImageJPEGRepresentation(image, 1.0);
                put.uploadingData = data;
                
                OSSTask * putTask = [client putObject:put];
                [putTask waitUntilFinished]; // 阻塞直到上传完成
                if (!putTask.error) {
                    NSLog(@"upload object success!");
                } else {
                    NSLog(@"upload object failed, error: %@" , putTask.error);
                }
                if (isAsync) {
                        NSLog(@"upload object finished!");
                        if (complete) {
                            if (!putTask.error) {
                                complete([NSArray arrayWithArray:callBackNames] ,UploadImageSuccess);
                            } else {
                                complete([NSArray arrayWithArray:callBackNames] ,UploadImageFailed);
                            }
                        }
                }
            }];
            if (queue.operations.count != 0) {
                [operation addDependency:queue.operations.lastObject];
            }
            [queue addOperation:operation];
        }
        i++;
    }
    if (!isAsync) {
        [queue waitUntilAllOperationsAreFinished];
        NSLog(@"haha");
        if (complete) {
            if (complete) {
                complete([NSArray arrayWithArray:callBackNames], UploadImageSuccess);
            }
        }
    }
}


@end
