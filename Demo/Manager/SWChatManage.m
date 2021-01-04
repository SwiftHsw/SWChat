//
//  SWChatManage.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/16.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWChatManage.h"
#import "SWFriendSortManager.h"

 NSString * const longTimeformatss = @"yyyy年MM月dd日 HH:mm:ss";

 NSString * const longTimeformatmm = @"yyyy年MM月dd日 HH:mm";

NSInteger const maxVideoDuration = 60;

static NSMutableDictionary *emjonDict;
static NSMutableDictionary *expressionDict;
static UIImage *leftImage;
static UIImage *rightImage;
static UIImage *soundLeftImage;
static UIImage *soundRightImage;
static SDImageCache *touchPicCache; //图片缓存文件
static NSMutableArray *progressLabelArr;//存储百分比lable
static NSMutableDictionary *progressDict; //存储key 的lable
static NSMutableDictionary *friendArr; //好友列表
static NSString *touchUser;//临时存储当前聊天对象id
static SWChatMessageViewController *messageController;


@implementation SWChatManage

CREATE_SHARED_MANAGER(SWChatManage)



+(SDImageCache *)getTouchCache
{
    return touchPicCache;
}
+(void)initTouchCache{
    touchPicCache = [[SDImageCache alloc] initWithNamespace:@"picCache"];
}

+(void)setLabelArr:(NSMutableArray *)labelArr
{
    progressLabelArr = labelArr;
}
+(void)removeLaberWithPid:(NSString *)pid
{
    for (int i = 0; i<progressLabelArr.count; i++) {
        SWLabel *label = progressLabelArr[i];
        if ([label.labelID isEqualToString:pid]) {
            [progressLabelArr removeObject:label];
        }
    }
}
+(void)setProgressForKey:(NSString *)pid press:(NSString *)progress
{
    if (!progressDict) {
        progressDict = [[NSMutableDictionary alloc] init];
    }
    [progressDict setObject:progress forKey:pid];
}
+(NSString *)getProgressForKey:(NSString *)pid
{
    return [progressDict valueForKey:pid];
}

+(NSMutableArray *)uploadLabeArr
{
    return progressLabelArr;
}

+ (NSString *)getUserName{
    return [kUserDefaults objectForKey:@"userName"];
}
+ (void)setUserName:(NSString *)getUserName{
    [kUserDefaults setObject:getUserName forKey:@"userName"];
}
+(NSMutableDictionary *)expression
{
    if (!expressionDict) {
        [SWChatManage initExpression];
        return expressionDict;
    }
    return expressionDict;
}

+(void)initExpression
{
    NSMutableArray *plistPathArr = [NSMutableArray array];
    NSMutableArray *collectDataArr = [NSMutableArray array];
//    //匹配是否已经下载表情包
//    NSArray * modelArr = [[ATFMDBTool shareDatabase] at_lookupTable:@"downloadList" dicOrModel:[ATDownLoadEmModel new] whereFormat:nil];
//    for (ATDownLoadEmModel *model in modelArr) {
//
//        NSString * FilePath = ATEmtionPath;
//        NSString * plistFilePath = [NSString stringWithFormat:@"%@/%@/%@.plist",FilePath,model.emEnName,model.emEnName];
//
//        if ([ATGeneralFuncUtil isHaveFile:plistFilePath]) {
//            [plistPathArr addObject:plistFilePath];
//            [collectDataArr addObject:model.emEnName];
//        }else{
//            NSString *sql = [NSString stringWithFormat:@"where downloadUrl = '%@'",model.downloadUrl];
//            [[ATFMDBTool shareDatabase] at_deleteTable:@"downloadList" whereFormat:sql];
//        }
//    }
 
    NSString *path = [[NSBundle mainBundle] pathForResource:@"expression" ofType:@"plist"];
    [plistPathArr insertObject:path atIndex:0];
    [collectDataArr insertObject:@"expression" atIndex:0];
 
    NSMutableDictionary *allExDict =[[NSMutableDictionary alloc] init];
    NSInteger totalCount = 0;
    for (int i = 0; i<collectDataArr.count; i++) {
        NSString *plistName = collectDataArr[i];
 
        NSDictionary *smileDict = [[NSDictionary alloc] initWithContentsOfFile:plistPathArr[i]];
        NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|
        NSWidthInsensitiveSearch|NSForcedOrderingSearch;
        NSComparator sort = ^(NSString *obj1,NSString *obj2){
            NSRange range = NSMakeRange(0,obj1.length);
            return [obj1 compare:obj2 options:comparisonOptions range:range];
        };
        NSArray *imageArr = [smileDict.allValues sortedArrayUsingComparator:sort].copy;
        [allExDict setObject:imageArr forKey:[NSString stringWithFormat:@"%@_image",plistName]];
        NSMutableArray * arr =[NSMutableArray arrayWithCapacity:0];
        for (NSString * valuse in imageArr) {
            for (NSString * key in smileDict.allKeys) {
                if ([valuse isEqualToString:[smileDict objectForKey:key]]) {
                    [arr addObject:key];
                }
            }
        }
        [allExDict setObject:arr.copy forKey:[NSString stringWithFormat:@"%@_title",plistName]];
 
        NSInteger page = 0;
        //NSUInteger
        if ([plistName isEqualToString:@"expression"]) {
            page = imageArr.count%31 == 0? imageArr.count/31 : imageArr.count/31+1;
        }else
        {
            page = imageArr.count%8 == 0? imageArr.count/8 : imageArr.count/8+1;
        }
        [allExDict setObject:[NSString stringWithFormat:@"%zd",page] forKey:[NSString stringWithFormat:@"%@_page",plistName]];
        totalCount = totalCount+page;
    }
    [allExDict setObject:[NSString stringWithFormat:@"%zd",totalCount] forKey:@"totalPage"];
    expressionDict = allExDict;
        
}


+(NSMutableDictionary *)emjonDict
{
    if (!emjonDict) {
        emjonDict = [[NSMutableDictionary alloc] initWithDictionary:[SWChatManage getTouchEmjonDict]];
    }
    return emjonDict;
}
+(NSMutableDictionary *)getTouchEmjonDict
{
    NSMutableDictionary *_emjonDict = [NSMutableDictionary new];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"expression" ofType:@"plist"];
    NSDictionary *smileDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    [smileDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        UIImage *immm = [UIImage imageNamed:obj];
        NSData *imageData = UIImagePNGRepresentation(immm);
        YYImage *image = [YYImage imageWithData:imageData scale:2];
        image.preloadAllAnimatedImageFrames = YES;
        [_emjonDict setObject:image forKey:key];
    }];
    return _emjonDict;
}

+(void)setTouchUser:(NSString *)user
{
    touchUser = user;
}
+(NSString *)GetTouchUser
{
    return touchUser;
}

+(void)setFriendArr:(NSMutableDictionary *)arr
{
    friendArr = [[NSMutableDictionary alloc] initWithDictionary:arr];
}
+(NSMutableDictionary *)getFriendArr
{
    return friendArr;
}
+(void)updateFriendArr
{
    NSArray *oldArr = [[ATFMDBTool shareDatabase] at_lookupTable:@"friendList" dicOrModel:[SWFriendInfoModel new] whereFormat:nil];
    if (oldArr.count <=0) {//已经没有好友了
        [SWChatManage setFriendArr:[NSMutableDictionary dictionary]];
        return;
    }
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i = 0; i<oldArr.count; i++) {
        SWFriendInfoModel *info = oldArr[i];
        if ([info.remark isEqualToString:@"-"]) {
            //没有备注默认显示昵称
            info.remark = info.nickName;
        }
        [arr addObject:info];
    }
    dispatch_async(dispatch_queue_create(0, 0), ^{
        
        NSMutableArray *index = [SWFriendSortManager IndexWithArray:arr Key:@"remark"];
        NSMutableArray *letter = [SWFriendSortManager sortObjectArray:arr Key:@"remark"];
        if ([[index firstObject] isEqualToString:@"#"] && index.count>1) {
            NSString *first = [index firstObject];
            NSMutableArray *firstArr = [letter firstObject];
            [index removeObject:first];
            [letter removeObject:firstArr];
            [index addObject:first];
            [letter addObject:firstArr];
        }
        
        SWFriendInfoModel *model = [SWFriendInfoModel new];
        model.isSystem = true;
        model.nickName = [NSString stringWithFormat:@"%zd位好友",arr.count];
        model.remark = [NSString stringWithFormat:@"%zd位好友",arr.count];
        NSMutableArray *addArrr = [letter lastObject];
        [letter removeLastObject];
        [addArrr addObject:model];
        [letter addObject:addArrr];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
            [info setObject:letter forKey:@"letter"];
            [info setObject:index forKey:@"index"];
            [SWChatManage setFriendArr:info];
        });
    });
}

+ (void)setMessageController:(SWChatMessageViewController *)controller{
    messageController = controller;
}
+ (SWChatMessageViewController *)messageControll{
    return  messageController;
}


+ (BOOL) isEmpty:(NSString *) str {
    if (!str) {
        return
        true;
        
    } else {
        NSCharacterSet *set = [NSCharacterSet
                               whitespaceAndNewlineCharacterSet];
        NSString *trimedString = [str
                                  stringByTrimmingCharactersInSet:set];
        if ([trimedString length] == 0) {
            return true;
            
        } else {
            return false;
            
        } 
    }
    
}
+(CGRect)getFrameSizeForImage:(UIImage *)image
{
    if (!image) {
        return CGRectMake(0, 0, 0, 0);
    }
    CGRect rect = CGRectMake(55, 40, 140, 140);
    float hfactor = image.size.width / rect.size.width;
    float vfactor = image.size.height / rect.size.height;
    
    float factor = fmax(hfactor, vfactor);
    
    
    float newWidth = image.size.width / factor;
    float newHeight = image.size.height / factor;
    
    
    float leftOffset = (rect.size.width - newWidth) / 2;
    float topOffset = (rect.size.height - newHeight) / 2;
    if (newHeight<45) {
        newHeight = 45;
    }
    return CGRectMake(leftOffset, topOffset, newWidth, newHeight);
}
+(NSMutableDictionary *)sendInfoWithSing:(SWFriendInfoModel *)infoModel
{
//    if (!infoModel) {
//        NSLog(@"单聊对方数据未空，不能发送");
//        return nil;
//    }
//    ATUser *user = [ATUserHelper shareInstance].user; //模拟用户数据
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    //发送者登录号
    [info setObject:[SWChatManage getUserName] forKey:@"loginName"];
    //发送者昵称
    [info setObject:[SWChatManage getUserName] forKey:@"remarkName"];
    //发送者头像
//    if (user.head_img && user.head_img.length!=0) {
        [info setObject:@"https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=1194131577,2954769920&fm=26&gp=0.jpg" forKey:@"headUrl"];
//    }else
//        [info setObject:@"" forKey:@"headUrl"];
    if (infoModel.remark) {
        [info setObject:infoModel.remark forKey:@"singleReceiveRemark"];
    }else if (infoModel.nickName){
        [info setObject:infoModel.nickName forKey:@"singleReceiveRemark"];
    }else{
        [info setObject:[SWChatManage getUserName] forKey:@"singleReceiveRemark"];
    }
    
    if (infoModel.headPic) {
        [info setObject:infoModel.headPic forKey:@"singleReceiveHeadPic"];
    }else
        [info setObject:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1605847688143&di=b2f4c8357bd6cc61a317f1230c668628&imgtype=0&src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fitem%2F201711%2F13%2F20171113192541_CxtUj.thumb.400_0.jpeg" forKey:@"singleReceiveHeadPic"];
    
    
    return info;
}

+(id)JsonToDict:(NSString *)result
{
    if (result == nil)
    {
        return nil;
    }else
    {
        NSData *data= [result dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (error)
        {
            NSLog(@"%@",error);
        }
        return jsonObject;
    }
}
+(NSString *)toJSOStr:(id)theData
{
    NSError *error = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:theData options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:json
                                                 encoding:NSUTF8StringEncoding];
    return jsonString;
}

+(NSString *)longLongToStr:(long long)timeDate dateFormat:(NSString *)dateFormat
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    NSDate *conm = [NSDate dateWithTimeIntervalSince1970:timeDate/1000];
    fmt.dateFormat = dateFormat;
    NSString *time = [fmt stringFromDate:conm];
    return time;
}
+(NSString *)getUTCFormateDate:(NSString *)timeStr
{
    NSString *dateContent;
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today= [[NSDate alloc] init];
    NSDate *yearsterDay = [[NSDate alloc] initWithTimeIntervalSinceNow:-secondsPerDay];
    NSDate *qianToday  = [[NSDate alloc] initWithTimeIntervalSinceNow:-2*secondsPerDay];
    //假设这是你要比较的date：NSDate
    NSDate *yourDate = [NSDate dateWithString:timeStr format:longTimeformatss];
    //日历
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:yourDate];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:yearsterDay];
    NSDateComponents* comp3 = [calendar components:unitFlags fromDate:qianToday];
    NSDateComponents* comp4 = [calendar components:unitFlags fromDate:today];
    if (comp1.year == comp2.year && comp1.month == comp2.month && comp1.day == comp2.day)
    {
        dateContent = @"昨天";
    }else if (comp1.year == comp4.year && comp1.month == comp4.month && comp1.day == comp4.day)
    {
        dateContent = @"今天";
    }else{
        //返回0说明该日期不是今天、昨天、前天
        dateContent = @"其他时间";
    }
    return dateContent;
    
}
+(BOOL)withdrawWithOldTime:(NSString *)oldTime
{
    NSDateFormatter *date = [[NSDateFormatter alloc]init];
    
    [date setDateFormat:longTimeformatss];
    
    NSDate *startD =[NSDate date];
    
    NSDate *endD = [date dateFromString:oldTime];
    unsigned int unitFlags = NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *d = [calendar components:unitFlags fromDate:endD toDate:startD options:0];
    if ((long)[d hour]>0) {
        return NO;
    }else if ((long)[d minute]>2){
        return NO;
    }else if ((long)[d day]>0){
        return NO;
    }
    return YES;
}

+ (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize
{
    if (font == NULL)
    {
        return CGSizeMake(0, 0);
    }else
    {
        if (text.length>0) {
            NSDictionary *attrs = @{NSFontAttributeName : font};
            CGSize sizr = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrs context:nil].size;
            return sizr;
        }else
            return CGSizeMake(0, 0);
        
    }
}


+(UIImage *)touchleftImage{
    if (leftImage) {
        return leftImage;
    }else{
        UIImage *bubble = [[UIImage alloc] init];
        bubble = [UIImage imageNamed:@"chat_bg_other"];
        leftImage = [bubble resizableImageWithCapInsets:UIEdgeInsetsMake(28, 20, 15, 28) resizingMode:UIImageResizingModeStretch];
        return leftImage;
    }
}
+(UIImage *)touchRightImage{
    if (rightImage) {
        return rightImage;
    }else{
        UIImage *bubble = [[UIImage alloc] init];
        bubble = [UIImage imageNamed:@"chat_bg_others_self"];
        rightImage = [bubble resizableImageWithCapInsets:UIEdgeInsetsMake(28, 20, 15, 28) resizingMode:UIImageResizingModeStretch];
        return rightImage;
    }
}
+(UIImage *)soundleftImage{
    if (soundLeftImage) {
        return soundLeftImage;
    }else{
        UIImage *bubble = [[UIImage alloc] init];
        bubble = [UIImage imageNamed:@"chat_bg_others"];
        soundLeftImage = [bubble resizableImageWithCapInsets:UIEdgeInsetsMake(28, 20, 15, 28) resizingMode:UIImageResizingModeStretch];
        return soundLeftImage;
    }
}
+(UIImage *)soundRightImage{
    if (soundRightImage) {
        return soundRightImage;
    }else{
        UIImage *bubble = [[UIImage alloc] init];
        bubble = [UIImage imageNamed:@"chat_bg_others_self"];
        soundRightImage = [bubble resizableImageWithCapInsets:UIEdgeInsetsMake(28, 20, 15, 28) resizingMode:UIImageResizingModeStretch];
        return soundRightImage;
    }
}

-(CGSize)imagePhotoSize:(NSString *)videoFristFramesWidth  videoFristFramesHeight:(NSString *)videoFristFramesHeight{
    CGSize size;
    CGFloat  imageSWidth = [videoFristFramesWidth doubleValue];
    CGFloat imageSHeight = [ videoFristFramesHeight doubleValue];
    if (imageSWidth == 0 && imageSHeight == 0) {
        size = CGSizeMake(0, 0);
    }else{
        size = [SWKit getSingleSize:CGSizeMake(imageSWidth, imageSHeight) max:230];
    }
    return size;
}
+ (CALayer *)lineWithLength:(CGFloat)length atPoint:(CGPoint)point {
    CALayer *line = [CALayer layer];
    line.backgroundColor = UIColorRGB(221, 221, 221).CGColor;
    
    line.frame = CGRectMake(point.x, point.y, length, 1/[UIScreen mainScreen].scale);
    
    return line;
}

+(void)updateMessageCount:(NSInteger)count
{
    UIViewController *nowController = [SWKit getCurrentVC];
    if (nowController.tabBarController.tabBar.items.count>2) {
        UITabBarController *tabbar = nowController.tabBarController;
        UITabBarItem *messageItem = [tabbar.tabBar.items objectAtIndex:0];
        if (count <= 0)
        {
            messageItem.badgeValue = nil;
        }else
        {
            if (count>99)
            {
                messageItem.badgeValue = @"99+";
            }else
                messageItem.badgeValue = [NSString stringWithFormat:@"%ld",count];
        } 
        //首页更新page
        [UIApplication sharedApplication].applicationIconBadgeNumber=count;
    }
}



-(void)sendMessageToUser:(NSString *)toUser
   messageType:(NSString *)messtype
      chatType:(NSInteger)chatType
      userInfo:(NSDictionary *)info
       content:(NSDictionary *)content
     messageID:(NSString *) messageID
      isInsert:(BOOL)isInsert
isConversation:(BOOL)isConversation
        isJoin:(BOOL)isJoin
successBlock:(void (^)(SWChatTouchModel *model))block{
    
     
    //操作IM发送逻辑
    SWChatTouchModel *model = [[SWChatTouchModel alloc]init];
   
    model.showTime = [NSDate getNowTimeTimestamp3]; 
    NSArray *arr = @[[SWChatManage getUserName],@"2222"];
    int index =  arc4random()%arr.count;
     //模拟消息发送方
    model.fromUser = arr[index];
    
    
    //文本
       model.content = [content valueForKey:@"content"];
       model.type = messtype;
       
       //图片
       if ([messtype isEqualToString:@"img"]) {
           model.pid = [content valueForKey:@"fileName"];
           model.imageHeight = [[content valueForKey:@"height"] floatValue];
           model.imageWight = [[content valueForKey:@"width"] floatValue];
           model.isSuccess = @"upload";
//          model.fromUser = [SWChatManage getUserName];
       }
       //位置
       if ([messtype isEqualToString:@"location"]) {
             model.pid = [content valueForKey:@"fileName"];
           model.messageInfo = @{@"addressTitle":content[@"addressTitle"],@"addressDet":content[@"addressTitle"]};
//           model.fromUser = [SWChatManage getUserName];
       }
       //红包
       if ([messtype isEqualToString:@"envelope"]) {
           model.messageInfoString = @"0";
           model.pid = [SWKit getRandomString];
       }
        self.getBlock(model);
     
         block(model);
}
@end
