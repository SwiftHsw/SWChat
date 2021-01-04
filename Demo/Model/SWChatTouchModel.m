//
//  SWChatTouchModel.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/16.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWChatTouchModel.h"
#import "SWChatWebViewController.h"

@implementation SWChatTouchModel

-(NSString *)textContent:(EMMessage *)message
{
    EMMessageBody *msgBody = message.body;
    if (msgBody.type == EMMessageBodyTypeText) {
        EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
        return textBody.text;
    }
    return @"";
}
-(SWChatTouchModel *)EMMToChatModel:(EMMessage *)message timeArr:(NSMutableArray *)timeArr{
     SWChatTouchModel *model = [SWChatTouchModel new];
    //模拟数据
//    model.pid = message.pid;
  //    NSDictionary *info = @{@"data":@{@"content":message.content},@"type":message.type,@"state":@"1"};
      
    NSDictionary *info = [SWChatManage JsonToDict:[self textContent:message]];

     if (!info) {
         model.cellWidth = 0;
         model.cellHeight = 0;
         return model;
     }
    NSDictionary *data = [info valueForKey:@"data"];
    model.content = [data valueForKey:@"content"];
    if (!model.content) {
          model.content = @"未知内容";
      }
    model.EMMessage = message;
    model.showTime = [SWChatManage longLongToStr:message.timestamp dateFormat:@"HH:mm"];
       model.oldTime = [SWChatManage longLongToStr:message.timestamp dateFormat:longTimeformatss];
       NSString *toDay = [SWChatManage getUTCFormateDate:model.oldTime];
       if ([toDay isEqualToString:@"昨天"]) {
           model.showTime = [NSString stringWithFormat:@"昨天 %@",model.showTime];
       }else if ([toDay isEqualToString:@"其他时间"]){
           model.showTime = [SWChatManage longLongToStr:message.timestamp dateFormat:longTimeformatmm];
           model.showTime = [[model.showTime componentsSeparatedByString:@"年"] lastObject];
       }
    if ([timeArr containsObject:model.showTime]) {
        model.showTime = @"0000";
        [timeArr addObject:@"0000"];
        _showTime = @"0000";
    }else{
        _showTime= model.showTime;
        [timeArr addObject:model.showTime];
    }
    model.timeArr = timeArr;
    model.fromUser =  message.from;
     model.type = [info valueForKey:@"type"];
    
     NSDictionary *sendUser = [info valueForKey:@"sendUser"];
      model.sendUserInfo = sendUser;
  
      model.messType = @"单聊信息";
     
    model.isSuccess = [data valueForKey:@"state"];
   model.toUser = message.to;
    model.messageId = message.messageId;
    model.pid = [info valueForKey:@"id"];
    if (!model.pid) {
        model.pid =[info valueForKey:@"pid"];
    }
    model.fileName = [info valueForKey:@"id"];
    if (!model.fileName) {
        model.fileName =[info valueForKey:@"pid"];
    }
    if ([model.type isEqualToString:@"img"]) {
        model.isGIF = false;
               model.cellHeight = [[data valueForKey:@"height"] floatValue];
               model.cellWidth = [[data valueForKey:@"width"] floatValue]+10;
               if (model.cellWidth<50) {
                   model.cellWidth=60;
               }
               model.filePath = [data valueForKey:@"filePath"];
               if (model.cellHeight<100) {
                   model.cellHeight = 100;
               }else if (model.cellHeight>140){
                   model.cellHeight = 140;
               }
               if (model.cellWidth>140) {
                   model.cellWidth = 140;
               }
        
    }
    if ([model.type isEqualToString:@"location"]) {
         model.messageInfo = data;
//        if (message.messageInfo == nil) {
//            model.messageInfo = [SWChatManage JsonToDict:message.messageInfoString];
//        }else
//        model.messageInfo =  message.messageInfo;
    }
    if ([model.type isEqualToString:@"envelope"]) {
//           model.messageInfoString = message.messageInfoString;
        model.content =[info valueForKey:@"data"];
               model.redBagInfo = info;
       }
    
     model = [model configLayoutForModel:model];
    
    
    if ([model.isSuccess isEqualToString:@"upload"]) {
           if ([model.type isEqualToString:@"img"] || [model.type isEqualToString:@"video"] || [model.type isEqualToString:@"voiceAud"]) {
            //逻辑：是否上传成功，如果成功不做操作，失败的话，设置
//               model.isSuccess = @"failure"; 
       }
    }
    
    return model;
    
}
#pragma mark - 设置 计算Cell 高度

-(void)setTextLayout:(YYTextLayout *)textLayout{
    //0000 是没有显示时间的情况下 不加 时间高度
    _textLayout = textLayout;
    if ([_type isEqualToString:@"text"])
       {
           CGFloat rowHeight = 0;
           if (_textLayout) {
               rowHeight = _textLayout.textBoundingSize.height;
               if (rowHeight>19 && [_showTime isEqualToString:@"0000"]) {
                   rowHeight = rowHeight+25;
               }
           }
           _cellHeight = rowHeight+30;
           if (![_showTime isEqualToString:@"0000"]) {
               _cellHeight = _cellHeight+4;
           }
       } else if ([_type isEqual:@"location"]) {
           
            _cellHeight = [_showTime isEqualToString:@"0000"] ? 185:  160;
           
       } else if ([_type isEqual:@"envelope"])  {
           
           _cellHeight = [_showTime isEqualToString:@"0000"] ? 115:  90;
           
       }  else if ([_type isEqual:@"system"])
        {
               CGSize size = [SWChatManage sizeWithText:_content font:[UIFont systemFontOfSize:14] maxSize:CGSizeMake(SCREEN_WIDTH-30, 9999)];
                        _cellHeight = size.height+30+26;
                        if (![_showTime isEqualToString:@"0000"]) {
                            _cellHeight = _cellHeight -5;
                        }
                        _cellWidth = size.width+10;
        }
    
    if ([_showTime isEqualToString:@"0000"])
    {
        _cellHeight = _cellHeight-30;
    }else{
        //计算时间文本的宽度
        CGSize size = [SWChatManage sizeWithText:_showTime font:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(SCREEN_WIDTH-30, 9999)];
        _timeWidth = floor(size.width)+10;
    }
         //计算最终的高度
   _cellFinalHeight =  [self setupFinalHeight];
    
}
- (CGFloat)setupFinalHeight{
    
    float showName = 0;
       BOOL _isShowMemberName = NO;//是否显示群昵称
         if (![_fromUser isEqualToString:[SWChatManage getUserName]] && _isShowMemberName) {
             showName = 20;
         }
         if ([_type isEqualToString:@"system"]) {
             //系统消息
             return _cellHeight;
         }
         if ([_type isEqualToString:@"location"] || [_type isEqualToString:@"envelope"] || [_type isEqualToString:@"text"]  ) {
             //地图 ｜｜ 红包 || 文本
             if ([_type isEqualToString:@"text"] && _cellHeight<49) {
                 return 54+showName; //文本只有一行的情况下
             }
              return [_showTime isEqualToString:@"0000"]?_cellHeight+5+showName:_cellHeight+35+showName;
         }else if ([_type isEqualToString:@"img"]){
             //图片
              return [_showTime isEqualToString:@"0000"]?_cellHeight+showName+15:_cellHeight+30+showName+15;
         }
         return 44+showName;
    
}
-(SWChatTouchModel *)configLayoutForModel:(SWChatTouchModel *)model
{
    YYTextLayout *textLayout = nil;
    if ([model.type isEqualToString:@"text"]) {
        // 创建 AttributedString （生成emoji格式，超链接等）
        NSMutableAttributedString *text = [self attributedStringWithText:model.content
                                                              emojiMapper:[SWChatManage emjonDict]
                                                                  handler:nil];
        textLayout = [YYTextLayout layoutWithContainerSize:CGSizeMake(SCREEN_WIDTH-140, 5000)
                                                      text:text];
    }
    // 赋值排版并且计算高度
    model.textLayout = textLayout;
    return model;
}
- (NSMutableAttributedString *)attributedStringWithText:(NSString *)text emojiMapper:(NSMutableDictionary *)emojiMapper handler:(void(^)(BOOL isTap, int strType, NSString *targetString))handler
{
     
    // emoji

        //转成可变属性字符串
        NSMutableAttributedString * mAttributedString = [[NSMutableAttributedString alloc]init];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:4];//调整行间距
        [paragraphStyle setParagraphSpacing:4];//调整行间距
          NSDictionary *attri;
        if ([self.fromUser isEqualToString: [SWChatManage getUserName]]) {
            attri = [NSDictionary dictionaryWithObjects:@[[UIFont systemFontOfSize:16],[UIColor whiteColor],paragraphStyle] forKeys:@[NSFontAttributeName,NSForegroundColorAttributeName,NSParagraphStyleAttributeName]];
        }else{
            attri = [NSDictionary dictionaryWithObjects:@[[UIFont systemFontOfSize:16],[UIColor blackColor],paragraphStyle] forKeys:@[NSFontAttributeName,NSForegroundColorAttributeName,NSParagraphStyleAttributeName]];
        }
        [mAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:text attributes:attri]];
        //创建匹配正则表达式的类型描述模板
        NSString * pattern = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        //创建匹配对象
        NSError * error;
        NSRegularExpression * regularExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        //判断
        if (!regularExpression)//如果匹配规则对象为nil
        {
            NSLog(@"正则创建失败！");
            NSLog(@"error = %@",[error localizedDescription]);
            return nil;
        }
        else
        {
            NSArray * resultArray = [regularExpression matchesInString:mAttributedString.string options:NSMatchingReportCompletion range:NSMakeRange(0, mAttributedString.string.length)];
            //开始遍历 逆序遍历
            for (NSInteger i = resultArray.count - 1; i >= 0; i --)
            {
                //获取检查结果，里面有range
                NSTextCheckingResult * result = resultArray[i];
                //根据range获取字符串
                NSString * rangeString = [mAttributedString.string substringWithRange:result.range];
                NSString *imageName =  rangeString;
                if (imageName)
                {
                    //获取图片
                    YYImage * image = emojiMapper[imageName];//这是个自定义的方法
                    if (image != nil)
                    {
                        image.preloadAllAnimatedImageFrames = YES;
                        YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:image];
                        NSMutableAttributedString *attachText = [NSMutableAttributedString attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.bounds.size alignToFont:[UIFont systemFontOfSize:16] alignment:YYTextVerticalAlignmentCenter];
                        //开始替换
                        [mAttributedString replaceCharactersInRange:result.range withAttributedString:attachText];
                    }
                }
            }
        }

        // 高亮 点击
        NSMutableArray *highlightRanges = [NSMutableArray array];
        [highlightRanges addObjectsFromArray:[self tagResultsWithAttributeString:mAttributedString]];
        [highlightRanges addObjectsFromArray:[self emailResultsWithAttributeString:mAttributedString]];
        [highlightRanges addObjectsFromArray:[self urlResultsWithAttributeString:mAttributedString]];
        [highlightRanges addObjectsFromArray:[self phoneResultsWithAttributeString:mAttributedString]];

        for (NSDictionary *rangeDict in highlightRanges) {
            if (![rangeDict isKindOfClass:[NSDictionary class]]) continue;
            // 获取高亮文本类型
            NSNumber *typeNum = [rangeDict allKeys][0];
            NSValue *rangeValue = [rangeDict objectForKey:typeNum];
            NSRange range = [rangeValue rangeValue];
            [mAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor colorWithHexString:@"#3b779a"].CGColor range:range];

            // 1. 创建一个"高亮"属性，当用户点击了高亮区域的文本时，"高亮"属性会替换掉原本的属性
            YYTextBorder *highlightBorder = [YYTextBorder borderWithFillColor:[UIColor colorWithWhite:0.2 alpha:0.2f] cornerRadius:3];

            YYTextHighlight *highlight = [YYTextHighlight new];
            [highlight setColor:[UIColor colorWithHexString:@"#3b779a"]];
            [highlight setBackgroundBorder:highlightBorder];
            [highlight setTapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
                // 点击回调
                NSString * rangeString = [text.string substringWithRange:range];
                [self richTextTouchAction:[typeNum intValue] value:rangeString];

            }];
            
            [highlight setLongPressAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
                // 长按回调
                NSString * rangeString = [text.string substringWithRange:range];
                [self richTextLongTouchAction:[typeNum intValue] value:rangeString];
            }];
             
            // 2. 把"高亮"属性设置到某个文本范围
            [mAttributedString setTextHighlight:highlight range:range];
        }
    //    [mAttributedString setlong]
        return mAttributedString;
    
}

// 获取tag的range
- (NSArray *)tagResultsWithAttributeString:(NSMutableAttributedString *)attString
{
    NSMutableArray *regularResults = [NSMutableArray array];
    NSMutableString * attStr = attString.mutableString;
    NSError *error = nil;//@"[\\$#@]\\{[a-zA-Z0-9_:\\u3400-\\u9FFF]{1,20}\\}|\\[[a-zA-Z0-9_\\u3400-\\u9FFF]+\\]";
    //[a-zA-Z0-9_:\\u3400-\\u9FFF]{1,20}
    NSString *regulaStr = @"<tag type='[a-zA-Z0-9_]*' value='((?!<\\/tag>).)*'>((?!<\\/tag>).)*</tag>";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (error == nil)
    {
        NSArray *arrayOfAllMatches = [regex matchesInString:attStr
                                                    options:0
                                                      range:NSMakeRange(0, [attStr length])];
        NSInteger forIndex = 0;
        NSInteger startIndex = -1;

        for (NSTextCheckingResult *match in arrayOfAllMatches){
            NSRange matchRange = match.range;

            if(startIndex == -1){
                startIndex = matchRange.location;
            }else{
                startIndex = matchRange.location-forIndex;
            }

            NSString* substringForMatch = [attStr substringWithRange:NSMakeRange(startIndex, matchRange.length)];

            NSString * contentStr = nil;
            NSString * replaceStr = nil;

            NSArray * contentArr = [substringForMatch componentsSeparatedByString:@"'>"];
            if(contentArr.count != 2){
                continue;
            }
            NSArray * contentArr0 = [contentArr[0] componentsSeparatedByString:@"'"];

            NSString * t_str = contentArr[1];

            NSString * tagType = contentArr0[1];//[contentArr[0] componentsSeparatedByString:@"'"][1];

            contentStr = contentArr0[3];

            NSString * tagName = nil;

            //这里的tagName写死了，写别的不知道为什么会给标签图片和文本之间留空格...
            if([tagType isEqualToString:@"image"]){
                tagName = @"[linkp]";
            }else if ([tagType isEqualToString:@"video"]){
                tagName = @"[linkv]";
            }else if ([tagType isEqualToString:@"link"]){
                tagName = @"[linka]";
            }else{
                continue;
            }
            replaceStr = [NSString stringWithFormat:@"%@%@",tagName,[t_str substringWithRange:NSMakeRange(0, t_str.length-6)]];

            [attString replaceCharactersInRange:NSMakeRange(startIndex, matchRange.length) withString:replaceStr];

            NSRange range = NSMakeRange(startIndex, replaceStr.length);

//            [attString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)KATUrlColor.CGColor range:range];
//            [attString addAttribute:@"keyAttribute" value:[NSString stringWithFormat:@"T%@{%@}",contentStr,[NSValue valueWithRange:range]] range:range];
            // 高亮文本类型为4
            [regularResults addObject:@{@4 : [NSValue valueWithRange:range]}];

            forIndex += substringForMatch.length-replaceStr.length;

            //            NSLog(@"attString: %@",attString.string);

        }

    }
    return regularResults;
}
// 获取email的range
- (NSArray *)emailResultsWithAttributeString:(NSMutableAttributedString *)attString
{
    NSMutableArray *regularResults = [NSMutableArray array];

    NSMutableString * attStr = attString.mutableString;
    NSError *error = nil;;
    NSString *regulaStr = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];

    if (error == nil)
    {
        NSArray *arrayOfAllMatches = [regex matchesInString:attStr
                                                    options:0
                                                      range:NSMakeRange(0, [attStr length])];

        for (NSTextCheckingResult *match in arrayOfAllMatches){
            NSRange matchRange = match.range;
            NSValue * valueRange = [NSValue valueWithRange:matchRange];

//            NSString* substringForMatch = [attStr substringWithRange:matchRange];

//            [attString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)KATUrlColor.CGColor range:matchRange];
//
//            [attString addAttribute:@"keyAttribute" value:[NSString stringWithFormat:@"E%@{%@}",substringForMatch,valueRange] range:matchRange];
//            if(styleModel.emailUnderLine){
//                [attString addAttribute:(NSString *)kCTUnderlineStyleAttributeName value:(id)[NSNumber numberWithInt:kCTUnderlineStyleSingle] range:matchRange];
//            }
            // 高亮文本类型为3
            [regularResults addObject:@{@3 : valueRange}];
        }
    }

    return regularResults;
}

// 获取url的range
- (NSArray *)urlResultsWithAttributeString:(NSMutableAttributedString *)attString
{
    NSMutableArray *regularResults = [NSMutableArray array];

    NSMutableString * attStr = attString.mutableString;
    NSError *error = nil;
    NSString *regulaStr = [NSString stringWithFormat:@"<a href='(((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%@^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%@^&*+?:_/=<>]*)?))'>((?!<\\/a>).)*<\\/a>|(((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%@^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%@^&*+?:_/=<>]*)?))",@"%",@"%",@"%",@"%"];//(<a href='%@'>[^<>]*</at>)
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSInteger forIndex = 0;
    NSInteger startIndex = -1;
    //    NSLog(@"o__str:  %@",attString.string);
    if (error == nil)
    {
        NSArray *arrayOfAllMatches = [regex matchesInString:attStr
                                                    options:0
                                                      range:NSMakeRange(0, [attStr length])];

        for (NSTextCheckingResult *match in arrayOfAllMatches){
            NSRange matchRange = match.range;

            if(startIndex == -1){
                startIndex = matchRange.location;
            }else{
                startIndex = matchRange.location-forIndex;
            }

            NSString* substringForMatch = [attStr substringWithRange:NSMakeRange(startIndex, matchRange.length)];
 
            NSString * contentStr = nil;
            NSString * replaceStr = nil;

            if([substringForMatch hasPrefix:@"<a"]){

                NSArray * contentArr = [substringForMatch componentsSeparatedByString:@"'>"];
                contentStr = [contentArr[0] componentsSeparatedByString:@"'"][1];

                NSString * t_str = contentArr[1];

                NSString * url_pre = @"[linka]";

                replaceStr = [NSString stringWithFormat:@"%@%@",url_pre,[t_str substringWithRange:NSMakeRange(0, t_str.length-4)]];

                [attString replaceCharactersInRange:NSMakeRange(startIndex, matchRange.length) withString:replaceStr];

                NSRange range = NSMakeRange(startIndex, replaceStr.length);
 

                [regularResults addObject:[NSValue valueWithRange:range]];

                forIndex += substringForMatch.length-replaceStr.length;
            }else{

                replaceStr = [NSString stringWithFormat:@"%@",substringForMatch];

                [attString replaceCharactersInRange:NSMakeRange(startIndex, matchRange.length) withString:replaceStr];

                NSRange range = NSMakeRange(startIndex, replaceStr.length);
 
                // 高亮文本类型为1
                [regularResults addObject:@{@1 : [NSValue valueWithRange:range]}];

                //                forIndex -= 4;
                forIndex += substringForMatch.length-replaceStr.length;
            }
        }
    }

    return regularResults;
}

// 获取手机号的range
- (NSArray *)phoneResultsWithAttributeString:(NSMutableAttributedString *)attString
{
    NSMutableArray *regularResults = [NSMutableArray array];

    NSMutableString * attStr = attString.mutableString;
    NSError *error = nil;
 
    NSString *regulaStr=@"^(0[0-9]{2})\\d{8}$|^(0[0-9]{3}(\\d{7,8}))$|(1[34578][0-9]{9})";
 
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (error == nil)
    {
        NSArray *arrayOfAllMatches = [regex matchesInString:attStr
                                                    options:0
                                                      range:NSMakeRange(0, [attStr length])];

        for (NSTextCheckingResult *match in arrayOfAllMatches){

            NSRange matchRange = match.range;
 
            // 高亮文本类型为2
            [regularResults addObject:@{@2 : [NSValue valueWithRange:matchRange]}];
 
        }
    }

    return regularResults;
}

-(void)richTextTouchAction:(NSInteger)type value:(NSString *)value
{
    switch (type) {
        case 1:
        {
            //网址
            SWChatWebViewController *vc = [SWChatWebViewController new];
            vc.url_string = value;
            [[UIView getCurrentVC].navigationController pushViewController:vc animated:YES];
            
        }

            break;
        case 2:
        {
            //电话
            [NSObject callPhoneNumber:value];
 
        }
            break;
        default:
            break;
    }
}
-(void)richTextLongTouchAction:(NSInteger)type value:(NSString *)value
{
    SWLog(@"richTextLongTouchAction");
    
}
@end
