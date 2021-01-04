//
//  SWChatLocationViewController.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/18.
//  Copyright © 2020 sw. All rights reserved.
// 位置

#import <SWKit/SWKit.h>
#import  <AMapSearchKit/AMapSearchKit.h>

NS_ASSUME_NONNULL_BEGIN

/*
  @param latitude  纬度
  @param longitude 经度
  @param address   位置的名字
  @param image     返回的图片
 */
typedef  void (^GetLoactionBlock)(double latitude,double longitude, NSString *address,NSString *title,NSData *image);
 

@interface SWChatLocationViewController : SWSuperViewContoller


@property (nonatomic,copy) GetLoactionBlock getLoactionBlock;

- (void)didRowWithModelSelected:(AMapPOI *)poiModel;

 
@end

NS_ASSUME_NONNULL_END
