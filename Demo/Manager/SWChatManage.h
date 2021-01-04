//
//  SWChatManage.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/16.
//  Copyright © 2020 sw. All rights reserved.
// 静态、工具类、

#import <Foundation/Foundation.h>
 
NS_ASSUME_NONNULL_BEGIN

//长时间格式 精确到秒
extern NSString * const longTimeformatss;
//长时间格式 精确到分
extern NSString * const longTimeformatmm;
//视频最大长度
extern NSInteger const maxVideoDuration;


@class SWChatTouchModel;


typedef void (^getIMMessageDataBlock)(SWChatTouchModel *model);

@interface SWChatManage : NSObject
 
+ (instancetype)sharedManager;

#pragma mark 写入当前上传图片对应的cell
+(void)setLabelArr:(NSMutableArray *)labelArr;
+(NSMutableArray *)uploadLabeArr;
//上传失败移除lable
+(void)removeLaberWithPid:(NSString *)pid;
 +(void)setProgressForKey:(NSString *)pid press:(NSString *)progress;
 +(NSString *)getProgressForKey:(NSString *)pid;
//获取登陆的IM用户
+ (NSString *)getUserName;
+(void)setUserName:(NSString *)getUserName;
//环信返回好友 写入本地
+(void)setFriendArr:(NSMutableDictionary *)arr;
+(NSMutableDictionary *)getFriendArr;
+(void)updateFriendArr;
//临时存储聊天对象
+(void)setTouchUser:(NSString *)user;
+(NSString *)GetTouchUser;

#pragma mark 获取发送的图片缓存
+(void)initTouchCache;
+(SDImageCache *)getTouchCache;

#pragma mark - 获取回话消息界面
+(SWChatMessageViewController *)messageControll;
+(void)setMessageController:(SWChatMessageViewController *)controller;

//匹配富文本表情
+(NSMutableDictionary *)emjonDict;
//是否空字符
+ (BOOL) isEmpty:(NSString *) str;
//获取所有表情包
+(NSMutableDictionary *)expression;

//模拟获取用户基本数据
+(NSMutableDictionary *)sendInfoWithSing:(SWFriendInfoModel *)infoModel;

//转换json
+(id)JsonToDict:(NSString *)result;

+(NSString *)toJSOStr:(id)theData;

//转换时间
+(NSString *)longLongToStr:(long long)timeDate dateFormat:(NSString *)dateFormat;
+(NSString *)getUTCFormateDate:(NSString *)timeStr;
//是否在撤回时间之内
+(BOOL)withdrawWithOldTime:(NSString *)oldTime;

//计算文本长度
+ (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize;

//获取图片拉伸
+(UIImage *)touchleftImage;
+(UIImage *)touchRightImage;
+(UIImage *)soundleftImage;
+(UIImage *)soundRightImage;

//获取图片比例rect
+(CGRect)getFrameSizeForImage:(UIImage *)image;

//图片比例缩放
-(CGSize)imagePhotoSize:(NSString *)videoFristFramesWidth  videoFristFramesHeight:(NSString *)videoFristFramesHeight;

//绘制
+ (CALayer *)lineWithLength:(CGFloat)length atPoint:(CGPoint)point;

 
//缓存未读的数据
+(void)updateMessageCount:(NSInteger)count;
#pragma mark - 模拟第三方IM发送消息
/*
发送消息
@param toUser 接收方的ID
@param messtype 聊天类型
@param chatType 会话类型 1单聊 2群聊
@param info 接收方的信息
@param content 会话内容
@param messageID 会话ID
 @param successBlock 成功回调
**/
-(void)sendMessageToUser:(NSString *)toUser
             messageType:(NSString *)messtype
                chatType:(NSInteger)chatType
                userInfo:(NSDictionary *)info
                 content:(NSDictionary *)content
               messageID:(NSString *)messageID
                isInsert:(BOOL)isInsert
          isConversation:(BOOL)isConversation
                  isJoin:(BOOL)isJoin
          successBlock:(void (^)(SWChatTouchModel *model))block;

//消息回调
@property (nonatomic,copy) getIMMessageDataBlock getBlock;



@end

NS_ASSUME_NONNULL_END
