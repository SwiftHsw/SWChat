//
//  SWChatLocationViewController.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/18.
//  Copyright © 2020 sw. All rights reserved.
// 位置选择界面

#import "SWChatLocationViewController.h"
#import <MAMapKit/MAMapKit.h>

#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "SWSearchBar.h"
#import "SWLocationTableViewCell.h"
#import <CoreLocation/CoreLocation.h>
#import "SWSearchViewController.h"
#import "SWLocationSearchResultController.h"

 
CGFloat CGPointDistanceBetween(CGPoint point1, CGPoint point2) {
    CGFloat dtx = point1.x - point2.x;
    CGFloat dty = point1.y - point2.y;
    CGFloat distance = sqrt(dtx * dtx + dty * dty);
    return distance;
}



typedef NS_ENUM(NSInteger, LLAroundSearchTableStyle) {
    kLLAroundSearchTableStyleBeginSearch,  //开始附件POI搜索
    kLLAroundSearchTableStyleReGeocodeComplete, //逆地理解析完成
    kLLAroundSearchTableStylePOIPageSearchComplete,   //POI完成一页搜索
    kLLAroundSearchTableStylePOIAllPageSearchComplete, //POI搜索全部结束
};

@interface SWChatLocationViewController ()
<
MAMapViewDelegate,
AMapSearchDelegate,
UITableViewDelegate,
UITableViewDataSource,
UISearchBarDelegate,
CLLocationManagerDelegate
>
{
    UIView *blankView;
        NSInteger curPage;
  NSInteger curSelectedTableRow;
     CGFloat origionMapViewMinY;
    UIImageView *accessoryView;
    BOOL isBigStyle;
    UIView *footerView;
    UIView *headerView;
    UIActivityIndicatorView *footerIndicator;
     UIActivityIndicatorView *reGeocodeIndicator;
        BOOL needRefreshNearbyPOI;
    NSString *reGeocodeString;
     CLLocation *lastRegionCLLocation;
      BOOL hasInitRegion;
     SWLocationSearchResultController *resultController;
    CLLocationCoordinate2D _currentPt;//经纬度
  
}
@property (nonatomic) CLLocationManager *locationManager;


@property (nonatomic) LLAroundSearchTableStyle reGeocodeStyle;
@property (nonatomic) LLAroundSearchTableStyle POISearchStyle;

@property (nonatomic) NSMutableArray<AMapPOI *> *allMapPOIs;

@property (nonatomic) UIImageView *pinchView;

@property (nonatomic) UIButton *locationBtn;

@property (nonatomic) SWSearchBar *searchBar;

@property (nonatomic,strong) MAMapView *mapView; //地图
  
 
@property (nonatomic,strong) AMapSearchAPI *searchAPI; //搜索API
 @property (nonatomic) AMapReGeocode *curCenterReGeocode;
 @property (nonatomic) AMapSearchAPI *search;
 @property (nonatomic) AMapPOIAroundSearchRequest *request;
 @property (nonatomic) AMapReGeocodeSearchRequest *regeo;

@end

@implementation SWChatLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.view.backgroundColor = UIColor.whiteColor;
  
    [self initNavBar];
       _allMapPOIs = [NSMutableArray array];
    
    blankView = [[UIView alloc] init];
       
    //搜索框
    _searchBar = [SWSearchBar defaultSearchBar];
     _searchBar.delegate = self;
     _searchBar.placeholder = @"搜索地点";
    [self.view addSubview:_searchBar];
     
    //地图
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0,50, ScreenWidth, 250)];
     _mapView.delegate = self;
     _mapView.mapType = MAMapTypeStandard;
     _mapView.language = MAMapLanguageZhCN;
     
     _mapView.zoomEnabled = YES;
     _mapView.minZoomLevel = 16;
 
     _mapView.scrollEnabled = YES;
     _mapView.showsCompass = NO;
     _mapView.showsScale = YES;
    _mapView.showsUserLocation = YES;
    
     [self.view addSubview:_mapView];
     
    
     origionMapViewMinY = CGRectGetMaxY(_searchBar.frame);
       CGRect frame = SCREEN_FRAME;
       accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AlbumCheckmark"]];
       frame.size.height = floor(SCREEN_HEIGHT * TABLE_VIEW_HEIGHT_MIN_FACTOR);
       frame.origin.y = SCREEN_HEIGHT - frame.size.height - NavBarHeight;
    //tableView
       self.tableView .frame = CGRectMake(0,frame.origin.y , SCREEN_WIDTH, frame.size.height);
        self.tableView.backgroundColor = UIColor.whiteColor;
        self.tableView.separatorColor = UIColor.lightGrayColor;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.rowHeight = 51;
       [self.view addSubview: self.tableView];
    
      isBigStyle = NO;
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.tableView.rowHeight)];
    headerView.backgroundColor = self.tableView.backgroundColor;
    reGeocodeIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    reGeocodeIndicator.center = CGPointMake(SCREEN_WIDTH/2, 25);
    reGeocodeIndicator.hidden = YES;
    [headerView addSubview:reGeocodeIndicator];
    CALayer *line = [SWChatManage lineWithLength:SCREEN_WIDTH atPoint:CGPointZero];
    line.backgroundColor = self.tableView.separatorColor.CGColor;
    [headerView.layer addSublayer:line];
    
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.tableView.rowHeight)];
    footerView.backgroundColor = self.tableView.backgroundColor;
    footerIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    footerIndicator.center = CGPointMake(SCREEN_WIDTH/2, 25);
    footerIndicator.hidden = YES;
    [footerView addSubview:footerIndicator];
    line = [SWChatManage lineWithLength:SCREEN_WIDTH atPoint:CGPointZero];
    line.backgroundColor = self.tableView.separatorColor.CGColor;
    [footerView.layer addSublayer:line];
    
    self.tableView.tableFooterView = footerView;
    
    _mapView.logoCenter = CGPointMake(SCREEN_WIDTH - 3 - _mapView.logoSize.width/2, CGRectGetHeight(self.mapView.frame) - 3 - _mapView.logoSize.height/2);
      _mapView.scaleOrigin = CGPointMake(12, CGRectGetHeight(_mapView.frame) - 25);
    
    frame = SCREEN_FRAME;
      frame.origin.y = CGRectGetMaxY(_searchBar.frame);
      frame.size.height = SCREEN_HEIGHT - CGRectGetMaxY(_searchBar.frame) - CGRectGetHeight(self.tableView.frame);
      self.mapView.frame = frame;
      
      _mapView.logoCenter = CGPointMake(SCREEN_WIDTH - 3 - _mapView.logoSize.width/2, CGRectGetHeight(self.mapView.frame) - 3 - _mapView.logoSize.height/2);
      _mapView.scaleOrigin = CGPointMake(12, CGRectGetHeight(_mapView.frame) - 25);

    
    
    _locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
     [_locationBtn setBackgroundImage:[UIImage imageNamed:@"location_my"] forState:UIControlStateNormal];
     [_locationBtn setBackgroundImage:[UIImage imageNamed:@"location_my_HL"] forState:UIControlStateHighlighted];
     frame = CGRectMake(0, 0, 50, 50);
     frame.origin.x = SCREEN_WIDTH - 8 - 50;
     frame.origin.y = self.tableView.y - 18 - 50;
     _locationBtn.frame = frame;
     [self.view addSubview:_locationBtn];
     [_locationBtn addTarget:self action:@selector(backToUserLocation:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _pinchView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"located_pin"]];
    _pinchView.frame = CGRectMake(0, 0, 18, 38);
    _pinchView.layer.anchorPoint = CGPointMake(0.5, 0.96);
    _pinchView.center = _mapView.center;
    [self.view addSubview:_pinchView];
    
     _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    [self checkAuthorization];
    
}

#pragma mark - 权限管理

- (void)checkAuthorization {
    if (![CLLocationManager locationServicesEnabled]) {
        [self promptNoAuthorizationAlert];
    }else {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        switch (status) {
            case kCLAuthorizationStatusDenied:
            case kCLAuthorizationStatusRestricted:
                [self promptNoAuthorizationAlert];
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                [self startUpdatingLocation];
                break;
            case kCLAuthorizationStatusNotDetermined:
                [_locationManager requestWhenInUseAuthorization];
                break;
        }
    }
    
}
- (void)locationManager:(CLLocationManager *)locationManager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            [self promptNoAuthorizationAlert];
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self startUpdatingLocation];
            break;
        case kCLAuthorizationStatusNotDetermined:
            [locationManager requestWhenInUseAuthorization];
            break;
    }
}
- (void)promptNoAuthorizationAlert {
    
    [SWAlertViewController showInController:self title:LOCATION_AUTHORIZATION_DENIED_TEXT message:@"" cancelButton:@"" other:@"好的" completionHandler:^(SWAlertButtonStyle buttonStyle) {
        [self dismiss];
    }];
}
- (void)startUpdatingLocation {
    _mapView.distanceFilter = 10;
      _mapView.desiredAccuracy = kCLLocationAccuracyBest;
      _mapView.userTrackingMode = MAUserTrackingModeFollow;
      
    _request = [[AMapPOIAroundSearchRequest alloc] init];
    _request.types =  allPOISearchTypes;
    _request.sortrule = 1;
    _request.requireExtension = YES;
    _request.requireSubPOIs = NO;
    _request.radius = 5000;
    _request.page = 1;
    _request.offset = 20;
    
    _regeo = [[AMapReGeocodeSearchRequest alloc] init];
    _regeo.radius = 3000;
    _regeo.requireExtension = NO;
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;

}
- (void)backToUserLocation:(UIButton *)button {
    needRefreshNearbyPOI = YES;
    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate  animated:YES];
}

#pragma mark - 初始化
- (void)initNavBar {
    

    self.title = @"位置";
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
    [btn setTitle:@"发送" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [btn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(sendLocation) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;

    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
    [backBtn setTitle:@"取消" forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backsssss) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * leftBarBtn = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    UIBarButtonItem * spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = -10;
    self.navigationItem.leftBarButtonItems = @[spaceItem,leftBarBtn];
 
    
}

- (void)amapLocationManager:(AMapLocationManager *)manager doRequireLocationAuth:(CLLocationManager *)locationManager{
      [locationManager requestAlwaysAuthorization];
}
 
- (void)backsssss{
    [self willDismissSelf];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//即将销毁，在这里做些清理工作
- (void)willDismissSelf {
    self.mapView.userTrackingMode = MAUserTrackingModeNone;
     self.mapView.showsUserLocation = NO;
     self.mapView.delegate = nil;
     self.search.delegate = nil;
      [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)sendLocation
{
    if (self.allMapPOIs.count > 0) {
          //位置截图需要一段时间，要么弹一个ActivityIndicator，待截图完毕后退出然后发送
               //要么立马退出，待截图完成后更新地图cell，然后发送
            NSString *address;
              NSString *name;
            AMapPOI *model = self.allMapPOIs[curSelectedTableRow];
            
            if (!_curCenterReGeocode) {
                address = LOCATION_UNKNOWE_ADDRESS;
                name = LOCATION_UNKNOWE_NAME;
            }else{
                
            MAMapPoint point1 = MAMapPointForCoordinate(self.mapView.centerCoordinate);
            CLLocationCoordinate2D coordinate2D = CLLocationCoordinate2DMake(_regeo.location.latitude, _regeo.location.longitude);
            MAMapPoint point2 = MAMapPointForCoordinate(coordinate2D);
            CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
            
            if (distance > 100) {
                address = LOCATION_UNKNOWE_ADDRESS;
                name = LOCATION_UNKNOWE_NAME;
            }else{
                  address = model.address;
                  name = model.name;
            }
            }
            
            __weak typeof(self) weakSelf = self;
          NSData * imageData = [self darwMapImageData];
         !self.getLoactionBlock?:weakSelf.getLoactionBlock(model.location.latitude,model.location.longitude,model.address,model.name,imageData);
  
        [self backsssss];
        
    }
}

#pragma maek --screenshots
-(NSData *)darwMapImageData{
 
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
//        CGRect rect = CGRectMake(0, 0, _mapView.bounds.size.width,_mapView.bounds.size.height * 1.2);
//        imaegsss =  [_mapView takeSnapshotInRect:rect];
//    }else{
//        imaegsss =  [_mapView takeSnapshotInRect:_mapView.bounds];
//    }
//   [_mapView takeSnapshotInRect:_mapView.bounds withCompletionBlock:^(UIImage *resultImage, CGRect rect) {
//
//    }];
//    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, UIScreen.mainScreen.scale);
//
//    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    UIImage *Img = [self snapshotToImage:self.mapView.size];
     
    NSData * imageData =UIImagePNGRepresentation(Img);
    return imageData;
 
}
- (nullable UIImage *)snapshotToImage:(CGSize)size {
//    self.mapView.myLocationEnabled = NO;  -(map_center.y - size.height)
//    CGPoint map_center = self.mapView.center;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    [self.mapView drawViewHierarchyInRect:CGRectMake(0,0, self.mapView.bounds.size.width, self.mapView.bounds.size.height) afterScreenUpdates:YES];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return snapshotImage;
}

- (void)takeCenterSnapshotFromMapView:(MAMapView *)mapView withCompletionBlock:(void (^)(UIImage *resultImage, CGRect rect))block {
    CGSize size = mapView.bounds.size;
    CGPoint centerPoint = CGPointMake(size.width/2, size.height/2);
    CGRect rect = CGRectMake(centerPoint.x - SNAPSHOT_SPAN_WIDTH/2, centerPoint.y - SNAPSHOT_SPAN_HEIGHT/2, SNAPSHOT_SPAN_WIDTH, SNAPSHOT_SPAN_HEIGHT);
    [mapView takeSnapshotInRect:rect withCompletionBlock:^(UIImage *resultImage, CGRect rect) {
        
    }];
}

#pragma mark - tableView
 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allMapPOIs.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID1 = @"ID1";
    static NSString *ID2 = @"ID2";
    
    BOOL isHeadRow = indexPath.row == 0;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:isHeadRow? ID1 : ID2];
    if (!cell) {
        if (indexPath.row == 0) {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID1];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.textLabel.textColor = UIColor.blackColor;
        }else {
            cell = [[SWLocationTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID2];
        }
    }
    
    cell.accessoryView = (indexPath.row == curSelectedTableRow) ? accessoryView : nil;
    if (isHeadRow) {
        cell.textLabel.text =  @"[位置]";
        if (reGeocodeString.length == 0)
            cell.accessoryView = nil;
    }else {
        AMapPOI *model = self.allMapPOIs[indexPath.row - 1];
        ((SWLocationTableViewCell *)cell).poiModel = model;
        cell.textLabel.text = model.name;
        cell.detailTextLabel.text = [self getAddressFromAMapPOI:model];
    }

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.textLabel.text.length == 0)
        return;
    
    if (indexPath.row == 0) {
        [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
    }else {
        SWLocationTableViewCell *locationCell = (SWLocationTableViewCell *)cell;
        AMapGeoPoint *point = locationCell.poiModel.location;
        CLLocationCoordinate2D coordinate2D = CLLocationCoordinate2DMake(point.latitude, point.longitude);
        [self.mapView setCenterCoordinate:coordinate2D animated:YES];
    }
    
    UITableViewCell *selectcell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:curSelectedTableRow inSection:0]];
    if (selectcell) {
        selectcell.accessoryView = nil;
    }
    
    cell.accessoryView = accessoryView;
    curSelectedTableRow = indexPath.row;
    //
    if (self.allMapPOIs.count>0) {
        AMapPOI *model = self.allMapPOIs[curSelectedTableRow];
             _currentPt =    CLLocationCoordinate2DMake(model.location.latitude,model.location.longitude);
    }
    
}

- (NSString *)getAddressFromAMapPOI:(AMapPOI *)poi {
    NSString *address;
    if ([poi.city isEqualToString:poi.province]) {
        address = [NSString stringWithFormat:@"%@%@", poi.city, poi.address];
    }else {
        address = [NSString stringWithFormat:@"%@%@%@", poi.province, poi.city, poi.address];
    }
    
    return address;
}

#pragma mark - 搜索

//搜索发生错误时调用
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    NSLog(@"%s: searchRequest = %@, errInfo= %@", __func__, [request class], error);
    
    reGeocodeIndicator.hidden = YES;
    [reGeocodeIndicator stopAnimating];
    
    footerIndicator.hidden = YES;
    [footerIndicator stopAnimating];
    
}

//搜索成功回调
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response {
    curPage = request.page;

    //搜索全部结束
    if (response.pois.count < request.offset) {
        [self.allMapPOIs addObjectsFromArray:response.pois];
        [self setSearchTableStyle:kLLAroundSearchTableStylePOIAllPageSearchComplete];
    }else {
        [self.allMapPOIs addObjectsFromArray:response.pois];
        [self setSearchTableStyle:kLLAroundSearchTableStylePOIPageSearchComplete];
    }

}

//实现逆地理编码的回调函数
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    _curCenterReGeocode = response.regeocode;
    self.searchTableStyle = kLLAroundSearchTableStyleReGeocodeComplete;
}
 
//UITableView上拉刷新时，获取更多数据
- (void)fetchMorePOIData {
    if (curPage == _request.page) {
        _request.page = _request.page + 1;
        [self.search AMapPOIAroundSearch:_request];
    }
    
}

//获取地图中心附近的POI
- (void)fetchPOIAroundCenterCoordinate {
    [self changeFrameToBeBigger:NO];
    self.searchTableStyle = kLLAroundSearchTableStyleBeginSearch;
    
    CLLocationCoordinate2D coordinate2D = self.mapView.centerCoordinate;
    AMapGeoPoint *point = [AMapGeoPoint locationWithLatitude:coordinate2D.latitude     longitude:coordinate2D.longitude];
   
    curPage = 1;
    _request.location = point;
    _request.page = curPage;
    
    _regeo.location = point;
    
    [self.search cancelAllRequests];
    
    [self.search AMapReGoecodeSearch:_regeo];
    [self.search AMapPOIAroundSearch:_request];
}
- (void)changeFrameToBeBigger:(BOOL)bigger {
    if (isBigStyle == bigger)return;
    isBigStyle = bigger;
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.25
                          delay:(bigger? 0 : 0.1)
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame= self.tableView.frame;
                         frame.size.height = floor(SCREEN_HEIGHT *
                                                   (bigger ? TABLE_VIEW_HEIGHT_MAX_FACTOR : TABLE_VIEW_HEIGHT_MIN_FACTOR));
                         frame.origin.y = SCREEN_HEIGHT - frame.size.height - NavBarHeight;
                         self.tableView.frame = frame;
                         
                         frame = self.mapView.frame;
                         CGFloat barY = CGRectGetMaxY(self.searchBar.frame);
                         CGFloat height = SCREEN_HEIGHT - CGRectGetHeight(self.tableView.frame) - barY;
                         CGFloat heightDelt = (CGRectGetHeight(frame) - height)/2;
                         frame.origin.y = barY - heightDelt-self.searchBar.height -2;
                         self.mapView.frame = frame;
                         
                         frame = self.locationBtn.frame;
                         frame.origin.y = CGRectGetMinY(self.tableView.frame) - 18 - 50;
                         self.locationBtn.frame = frame;
                         
                         _pinchView.center = _mapView.center;
                         
                         _mapView.logoCenter = CGPointMake(SCREEN_WIDTH - 3 - _mapView.logoSize.width/2, CGRectGetHeight(self.mapView.frame) - 3 - _mapView.logoSize.height/2 - heightDelt);

                         _mapView.scaleOrigin = CGPointMake(12, CGRectGetHeight(_mapView.frame) - heightDelt - 25);
                         
                     }
                     completion:^(BOOL finished) {
                         self.view.userInteractionEnabled = YES;
                     }];
    
}

#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    NSLog(@"regionDidChange animated:%@", animated? @"YES":@"NO");
    
    CLLocationCoordinate2D coordinate2D = [self.mapView convertPoint:self.mapView.center toCoordinateFromView:self.mapView];
 
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate2D.latitude longitude:coordinate2D.longitude];
    if (!lastRegionCLLocation) {
        lastRegionCLLocation = self.mapView.userLocation.location;
    }
    CLLocationDistance distance = [lastRegionCLLocation distanceFromLocation:location];
    
    if (distance >= MOVE_DISTANCE_RESPONCE_THREASHOLD) {
        lastRegionCLLocation = location;
        if (!animated || needRefreshNearbyPOI) {
            needRefreshNearbyPOI = NO;
            [self fetchPOIAroundCenterCoordinate];
        }
        

        CGFloat _y = self.pinchView.bottom;
        [UIView animateKeyframesWithDuration:0.75 delay:0
                                     options:UIViewKeyframeAnimationOptionCalculationModeCubicPaced |
                                             UIViewKeyframeAnimationOptionOverrideInheritedDuration |
                                             UIViewKeyframeAnimationOptionBeginFromCurrentState
                                  animations:^{
                                      [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
                                          self.pinchView.bottom = _y;
                                      }];
                                      [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
                                          self.pinchView.bottom = _y - 12;
                                      }];
                                      [UIView addKeyframeWithRelativeStartTime:1 relativeDuration:0 animations:^{
                                          self.pinchView.bottom = _y;
                                      }];
                                  }
                                  completion:nil];
        
    }

    CGPoint point = [self.mapView convertCoordinate:mapView.userLocation.location.coordinate toPointToView:self.view];
    CGFloat _d = CGPointDistanceBetween(point, self.mapView.center);
    [self setLocationButtonStyle:_d <= 6];

}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    if (!updatingLocation)return;
    
    if (!hasInitRegion) {
        hasInitRegion = YES;
        CLLocationDistance span = SCREEN_WIDTH * MAP_VIEW_SPAN_METER_PER_POINT;
 
        MACoordinateRegion theRegion = MACoordinateRegionMakeWithDistance(userLocation.location.coordinate, span, span);
        [_mapView setRegion:theRegion];
        
    }
    
    //水平精度偏差大于500米，则不采取这个数据
    if (userLocation.location.horizontalAccuracy < 0 || userLocation.location.horizontalAccuracy > 500)
        return;
}
- (void)setLocationButtonStyle:(BOOL)isLocationMe {
    NSString *backgroundImageString =  isLocationMe ? @"location_my_current": @"location_my";
    [_locationBtn setBackgroundImage:[UIImage imageNamed:backgroundImageString] forState:UIControlStateNormal];
}
- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

#pragma mark - 辅助

- (void)setSearchTableStyle:(LLAroundSearchTableStyle)searchTableStyle {
    switch (searchTableStyle) {
        case kLLAroundSearchTableStyleBeginSearch: {
            [self.allMapPOIs removeAllObjects];
            [self.tableView setContentOffset:CGPointZero animated:NO];
            [self.tableView addSubview:headerView];
            reGeocodeIndicator.hidden = NO;
            [reGeocodeIndicator startAnimating];
            self.tableView.tableFooterView = blankView;
            curSelectedTableRow = 0;
            _curCenterReGeocode = nil;
            reGeocodeString = nil;
            
            _reGeocodeStyle = searchTableStyle;
            _POISearchStyle = searchTableStyle;
            break;
        }
        case kLLAroundSearchTableStyleReGeocodeComplete: {
            _reGeocodeStyle = searchTableStyle;
            reGeocodeString = _curCenterReGeocode.formattedAddress;
            if (reGeocodeString.length == 0) {
                reGeocodeString = @"位置";
            }
            [headerView removeFromSuperview];
            [reGeocodeIndicator stopAnimating];
            
            if (_POISearchStyle == kLLAroundSearchTableStyleBeginSearch) {
                self.tableView.tableFooterView = footerView;
                footerIndicator.hidden = NO;
                [footerIndicator startAnimating];
            }
            
            break;
        }
        case kLLAroundSearchTableStylePOIPageSearchComplete:{
            _POISearchStyle = searchTableStyle;
            if (self.tableView.tableFooterView != footerView) {
                self.tableView.tableFooterView = footerView;
            }
            footerIndicator.hidden = YES;
            [footerIndicator stopAnimating];
            
            break;
        }
        case kLLAroundSearchTableStylePOIAllPageSearchComplete: {
            _POISearchStyle = searchTableStyle;
            if (self.tableView.tableFooterView == footerView) {
                self.tableView.tableFooterView = blankView;
                [footerIndicator stopAnimating];
            }
            break;
        }
            
        default:
            break;
    }
    
    [self.tableView reloadData];
}
#pragma mark - 滚动tableView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.tableView)return;
    
    if (!isBigStyle && scrollView.contentOffset.y > 10) {
        [self changeFrameToBeBigger:YES];
    }else if (isBigStyle && scrollView.contentOffset.y < -10) {
        [self changeFrameToBeBigger:NO];
    }
    //开始加载新的数据
    if ((_POISearchStyle == kLLAroundSearchTableStylePOIPageSearchComplete) && (!footerIndicator.isAnimating) && (footerIndicator.hidden) && (self.tableView.tableFooterView == footerView) && (scrollView.contentOffset.y + scrollView.frame.size.height + 2 >= scrollView.contentSize.height)) {
        footerIndicator.hidden = NO;
        [footerIndicator startAnimating];
        [self fetchMorePOIData];
    }
}

#pragma mark - 地图UISerachBar 代理

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
 SWSearchViewController *vc = [SWSearchViewController sharedInstance];
 vc.delegate = self;
 if (!resultController) {
     resultController = [[SWLocationSearchResultController alloc] init];
     resultController.gaodeViewController = self;
 }
 vc.searchResultController = resultController;
 resultController.searchViewController = vc;
 [vc showInViewController:self fromSearchBar:self.searchBar];
 
    
    return NO;
}
 

- (void)adjustPositionForSearch {
//    CGFloat _y = CGRectGetMinY(self.view.frame);
//
//    [UIView animateWithDuration:0.25 animations:^{
//        if (_y < 0) {
//            self.view.top = 0;
//        }else {
//            self.view.top =  NavBarHeight - self->origionMapViewMinY;
//        }
//
//    }];

}

- (void)willDismissSearchController:(SWSearchViewController *)searchController {
//    [self adjustPositionForSearch];
  
    [UIView animateWithDuration:.2 animations:^{
        self.view.transform = CGAffineTransformIdentity ;
            
    }];
}

- (void)willPresentSearchController:(SWSearchViewController *)searchController {
//    [self adjustPositionForSearch];
    [UIView animateWithDuration:.2 animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, -60);
    }];
}

- (void)didRowWithModelSelected:(AMapPOI *)poiModel {
    AMapGeoPoint *point = poiModel.location;
    CLLocationCoordinate2D coordinate2D = CLLocationCoordinate2DMake(point.latitude, point.longitude);
    needRefreshNearbyPOI = YES;
    [self.mapView setCenterCoordinate:coordinate2D animated:YES];
    [[SWSearchViewController sharedInstance] dismissSearchController];
}
@end
