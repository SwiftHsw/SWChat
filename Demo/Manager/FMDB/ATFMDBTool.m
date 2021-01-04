//
//  ATFMDBTool.m
//  ATDemoProject
//
//  Created by Qiaojun Chen on 2018/7/10.
//  Copyright © 2018年 Shiwen Huang. All rights reserved.
//

#import "ATFMDBTool.h"

#import <objc/runtime.h>
//#import "UtilsMacro.h"
//#import "ATStaticDataTool.h"
//#import "ATFriendPostModel.h"

#define ATDocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define ATSqlitePath [NSString stringWithFormat:@"%@/SWChatUI/%@/data.sqlite",ATDocumentPath,@"chat"]


// 数据库中常见的几种类型
#define SQL_TEXT     @"TEXT" //文本
#define SQL_INTEGER  @"INTEGER" //int long integer ...
#define SQL_REAL     @"REAL" //浮点
#define SQL_BLOB     @"BLOB" //data

@interface ATFMDBTool ()

@property (nonatomic, strong)NSString *dbPath;


@end

@implementation ATFMDBTool

- (FMDatabaseQueue *)dbQueue
{
    if (!_dbQueue) {
        FMDatabaseQueue *fmdb = [FMDatabaseQueue databaseQueueWithPath:_dbPath];
        self.dbQueue = fmdb;
        [_db close];
        self.db = [fmdb valueForKey:@"_db"];
    }else{
        if (![_dbQueue.path isEqualToString:_dbPath]) {
            FMDatabaseQueue *fmdb = [FMDatabaseQueue databaseQueueWithPath:_dbPath];
            self.dbQueue = fmdb;
            [_db close];
            self.db = [fmdb valueForKey:@"_db"];
        }
    }
    return _dbQueue;
}

static ATFMDBTool *atdb = nil;
+ (instancetype)shareDatabase
{
    
    return [ATFMDBTool shareDatabase:nil];
}

+ (instancetype)shareDatabase:(NSString *)dbName
{
    return [ATFMDBTool shareDatabase:dbName path:nil];
}
- (void)openHXDB{
//    NSString *dbPath = [NSString stringWithFormat:@"%@/HyphenateSDK/easemobDB/39485425.db",ATDocumentPath];
    NSString *dbPath = @"";
    FMDatabase *fmdb = [FMDatabase databaseWithPath:dbPath];
    if ([fmdb open]) {
        atdb = ATFMDBTool.new;
        atdb.db = fmdb;
        atdb.dbPath = dbPath;
     }
}

+ (instancetype)shareDatabase:(NSString *)dbName path:(NSString *)dbPath
{
    
    if (!atdb) {//如果db文件不存在。
        NSString *path = ATSqlitePath;
        FMDatabase *fmdb = [FMDatabase databaseWithPath:path];
        if ([fmdb open]) {
            atdb = ATFMDBTool.new;
            atdb.db = fmdb;
            atdb.dbPath = path;
        }
    }else{
        if (![atdb.dbPath isEqualToString:ATSqlitePath]) {//如果之前的db文件路和现在登陆的账号不一致
            FMDatabase *fmdb = [FMDatabase databaseWithPath:ATSqlitePath];
            if ([fmdb open]) {
                atdb = ATFMDBTool.new;
                atdb.db = fmdb;
                atdb.dbPath = ATSqlitePath;
            }
        }
    }
    if (![atdb.db open]) {
        NSLog(@"database can not open !");
        return nil;
    };
    return atdb;
}

- (instancetype)initWithDBName:(NSString *)dbName
{
    return [self initWithDBName:dbName path:nil];
}

- (instancetype)initWithDBName:(NSString *)dbName path:(NSString *)dbPath
{
    FMDatabase *fmdb = [FMDatabase databaseWithPath:ATSqlitePath];
    if ([fmdb open]) {
        self = [self init];
        if (self) {
            self.db = fmdb;
            self.dbPath = ATSqlitePath;
            return self;
        }
    }
    return nil;
}

- (BOOL)at_createTable:(NSString *)tableName dicOrModel:(id)parameters
{
    return [self at_createTable:tableName dicOrModel:parameters excludeName:nil];
}

- (BOOL)at_createTable:(NSString *)tableName dicOrModel:(id)parameters excludeName:(NSArray *)nameArr
{
    
    NSDictionary *dic;
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        dic = parameters;
    } else {
        Class CLS;
        if ([parameters isKindOfClass:[NSString class]]) {
            if (!NSClassFromString(parameters)) {
                CLS = nil;
            } else {
                CLS = NSClassFromString(parameters);
            }
        } else if ([parameters isKindOfClass:[NSObject class]]) {
            CLS = [parameters class];
        } else {
            CLS = parameters;
        }
        dic = [self modelToDictionary:CLS excludePropertyName:nameArr];
    }
    
    NSMutableString *fieldStr = [[NSMutableString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (pkid  INTEGER PRIMARY KEY,", tableName];
    
    int keyCount = 0;
    for (NSString *key in dic) {
        
        keyCount++;
        if ((nameArr && [nameArr containsObject:key]) || [key isEqualToString:@"pkid"]) {
            continue;
        }
        if (keyCount == dic.count) {
            [fieldStr appendFormat:@" %@ %@)", key, dic[key]];
            break;
        }
        
        [fieldStr appendFormat:@" %@ %@,", key, dic[key]];
    }
    
    BOOL creatFlag;
    creatFlag = [_db executeUpdate:fieldStr];
    
    return creatFlag;
}

- (NSString *)createTable:(NSString *)tableName dictionary:(NSDictionary *)dic excludeName:(NSArray *)nameArr
{
    NSMutableString *fieldStr = [[NSMutableString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (pkid  INTEGER PRIMARY KEY,", tableName];
    
    int keyCount = 0;
    for (NSString *key in dic) {
        
        keyCount++;
        if ((nameArr && [nameArr containsObject:key]) || [key isEqualToString:@"pkid"]) {
            continue;
        }
        if (keyCount == dic.count) {
            [fieldStr appendFormat:@" %@ %@)", key, dic[key]];
            break;
        }
        
        [fieldStr appendFormat:@" %@ %@,", key, dic[key]];
    }
    
    return fieldStr;
}

- (NSString *)createTable:(NSString *)tableName model:(Class)cls excludeName:(NSArray *)nameArr
{
    NSMutableString *fieldStr = [[NSMutableString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (pkid INTEGER PRIMARY KEY,", tableName];
    
    NSDictionary *dic = [self modelToDictionary:cls excludePropertyName:nameArr];
    int keyCount = 0;
    for (NSString *key in dic) {
        
        keyCount++;
        
        if ([key isEqualToString:@"pkid"]) {
            continue;
        }
        if (keyCount == dic.count) {
            [fieldStr appendFormat:@" %@ %@)", key, dic[key]];
            break;
        }
        
        [fieldStr appendFormat:@" %@ %@,", key, dic[key]];
    }
    
    return fieldStr;
}

#pragma mark - *************** runtime
- (NSDictionary *)modelToDictionary:(Class)cls excludePropertyName:(NSArray *)nameArr
{
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithCapacity:0];
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList(cls, &outCount);
    for (int i = 0; i < outCount; i++) {
        
        NSString *name = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
        if ([nameArr containsObject:name]) continue;
        
        NSString *type = [NSString stringWithCString:property_getAttributes(properties[i]) encoding:NSUTF8StringEncoding];
        
        id value = [self propertTypeConvert:type];
        if (value) {
            [mDic setObject:value forKey:name];
        }
        
    }
    free(properties);
    
    return mDic;
}

// 获取model的key和value
- (NSDictionary *)getModelPropertyKeyValue:(id)model tableName:(NSString *)tableName clomnArr:(NSArray *)clomnArr
{
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithCapacity:0];
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([model class], &outCount);
    
    for (int i = 0; i < outCount; i++) {
        
        NSString *name = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
        if (![clomnArr containsObject:name]) {
            continue;
        }
        
        id value = [model valueForKey:name];
        if (value) {
            [mDic setObject:value forKey:name];
        }
    }
    free(properties);
    
    return mDic;
}

- (NSString *)propertTypeConvert:(NSString *)typeStr
{
    NSString *resultStr = nil;
    if ([typeStr hasPrefix:@"T@\"NSString\""]) {
        resultStr = SQL_TEXT;
    } else if ([typeStr hasPrefix:@"T@\"NSData\""]) {
        resultStr = SQL_BLOB;
    } else if ([typeStr hasPrefix:@"Ti"]||[typeStr hasPrefix:@"TI"]||[typeStr hasPrefix:@"Ts"]||[typeStr hasPrefix:@"TS"]||[typeStr hasPrefix:@"T@\"NSNumber\""]||[typeStr hasPrefix:@"TB"]||[typeStr hasPrefix:@"Tq"]||[typeStr hasPrefix:@"TQ"]) {
        resultStr = SQL_INTEGER;
    } else if ([typeStr hasPrefix:@"Tf"] || [typeStr hasPrefix:@"Td"]){
        resultStr= SQL_REAL;
    }
    
    return resultStr;
}

// 得到表里的字段名称
- (NSArray *)getColumnArr:(NSString *)tableName db:(FMDatabase *)db
{
    NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:0];
    
    FMResultSet *resultSet = [db getTableSchema:tableName];
    
    while ([resultSet next]) {
        [mArr addObject:[resultSet stringForColumn:@"name"]];
    }
    
    return mArr;
}

#pragma mark - *************** 增删改查
- (BOOL)at_insertTable:(NSString *)tableName dicOrModel:(id)parameters
{
    NSArray *columnArr = [self getColumnArr:tableName db:_db];
    return [self insertTable:tableName dicOrModel:parameters columnArr:columnArr];
}

- (BOOL)insertTable:(NSString *)tableName dicOrModel:(id)parameters columnArr:(NSArray *)columnArr
{
    BOOL flag;
    NSDictionary *dic;
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        dic = parameters;
    }else {
        dic = [self getModelPropertyKeyValue:parameters tableName:tableName clomnArr:columnArr];
    }
    
    NSMutableString *finalStr = [[NSMutableString alloc] initWithFormat:@"INSERT INTO %@ (", tableName];
    NSMutableString *tempStr = [NSMutableString stringWithCapacity:0];
    NSMutableArray *argumentsArr = [NSMutableArray arrayWithCapacity:0];
    
    for (NSString *key in dic) {
        
        if (![columnArr containsObject:key] || [key isEqualToString:@"pkid"]) {
            continue;
        }
        [finalStr appendFormat:@"%@,", key];
        [tempStr appendString:@"?,"];
        
        [argumentsArr addObject:dic[key]];
    }
    
    [finalStr deleteCharactersInRange:NSMakeRange(finalStr.length-1, 1)];
    if (tempStr.length)
        [tempStr deleteCharactersInRange:NSMakeRange(tempStr.length-1, 1)];
    
    [finalStr appendFormat:@") values (%@)", tempStr];
    
    flag = [_db executeUpdate:finalStr withArgumentsInArray:argumentsArr];
    return flag;
}

- (BOOL)at_deleteTable:(NSString *)tableName whereFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *where = format?[[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args]:format;
    va_end(args);
    BOOL flag;
    NSMutableString *finalStr = [[NSMutableString alloc] initWithFormat:@"delete from %@  %@", tableName,where];
    flag = [_db executeUpdate:finalStr];
    
    return flag;
}

- (BOOL)at_updateTable:(NSString *)tableName dicOrModel:(id)parameters whereFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *where = format?[[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args]:format;
    va_end(args);
    BOOL flag;
    NSDictionary *dic;
    NSArray *clomnArr = [self getColumnArr:tableName db:_db];
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        dic = parameters;
    }else {
        dic = [self getModelPropertyKeyValue:parameters tableName:tableName clomnArr:clomnArr];
    }
    
    NSMutableString *finalStr = [[NSMutableString alloc] initWithFormat:@"update %@ set ", tableName];
    NSMutableArray *argumentsArr = [NSMutableArray arrayWithCapacity:0];
    
    for (NSString *key in dic) {
        
        if (![clomnArr containsObject:key] || [key isEqualToString:@"pkid"]) {
            continue;
        }
        [finalStr appendFormat:@"%@ = %@,", key, @"?"];
        [argumentsArr addObject:dic[key]];
    }
    
    [finalStr deleteCharactersInRange:NSMakeRange(finalStr.length-1, 1)];
    if (where.length) [finalStr appendFormat:@" %@", where];
    
    
    flag =  [_db executeUpdate:finalStr withArgumentsInArray:argumentsArr];
    
    return flag;
}

- (NSArray *)at_lookupTable:(NSString *)tableName dicOrModel:(id)parameters whereFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *where = format?[[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args]:format;
    va_end(args);
    NSMutableArray *resultMArr = [NSMutableArray arrayWithCapacity:0];
    NSDictionary *dic;
    NSMutableString *finalStr = [[NSMutableString alloc] initWithFormat:@"select * from %@ %@ Order By pkid Desc", tableName, where?where:@""];
    NSArray *clomnArr = [self getColumnArr:tableName db:_db];
    
    FMResultSet *set = [_db executeQuery:finalStr];
    
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        dic = parameters;
        
        while ([set next]) {
            
            NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithCapacity:0];
            for (NSString *key in dic) {
                
                if ([dic[key] isEqualToString:SQL_TEXT]) {
                    id value = [set stringForColumn:key];
                    if (value)
                        [resultDic setObject:value forKey:key];
                } else if ([dic[key] isEqualToString:SQL_INTEGER]) {
                    [resultDic setObject:@([set longLongIntForColumn:key]) forKey:key];
                } else if ([dic[key] isEqualToString:SQL_REAL]) {
                    [resultDic setObject:[NSNumber numberWithDouble:[set doubleForColumn:key]] forKey:key];
                } else if ([dic[key] isEqualToString:SQL_BLOB]) {
                    id value = [set dataForColumn:key];
                    if (value)
                        [resultDic setObject:value forKey:key];
                }
                
            }
            
            if (resultDic) [resultMArr addObject:resultDic];
        }
        
    }else {
        
        Class CLS;
        if ([parameters isKindOfClass:[NSString class]]) {
            if (!NSClassFromString(parameters)) {
                CLS = nil;
            } else {
                CLS = NSClassFromString(parameters);
            }
        } else if ([parameters isKindOfClass:[NSObject class]]) {
            CLS = [parameters class];
        } else {
            CLS = parameters;
        }
        
        if (CLS) {
            NSString *three = [self getNDay:3];
            NSDictionary *propertyType = [self modelToDictionary:CLS excludePropertyName:nil];
            NSMutableArray *oneArr = [[NSMutableArray alloc] init];
            NSMutableArray *twoArr = [[NSMutableArray alloc] init];
            while ([set next]) {
                
                id model = CLS.new;
                for (NSString *name in clomnArr) {
                    if ([propertyType[name] isEqualToString:SQL_TEXT]) {
                        id value = [set stringForColumn:name];
                        if (value)
                            [model setValue:value forKey:name];
                    } else if ([propertyType[name] isEqualToString:SQL_INTEGER]) {
                        [model setValue:@([set longLongIntForColumn:name]) forKey:name];
                    } else if ([propertyType[name] isEqualToString:SQL_REAL]) {
                        [model setValue:[NSNumber numberWithDouble:[set doubleForColumn:name]] forKey:name];
                    } else if ([propertyType[name] isEqualToString:SQL_BLOB]) {
                        id value = [set dataForColumn:name];
                        if (value)
                            [model setValue:value forKey:name];
                    }
                }
//                if ([tableName isEqualToString:@"friendPost"]) {
//                    ATFriendPostModel *postM = (ATFriendPostModel *)model;
//                    NSString *sql = [NSString stringWithFormat:@"where userId = '%@'",postM.fromUser];
//                    NSArray *arr = [[ATFMDBTool shareDatabase] at_lookupTable:@"friendList" dicOrModel:[ATFriendInfoModel new] whereFormat:sql];
//                    if ([self compareDate:three withDate:[postM.time substringToIndex:10]]) {
//                        [oneArr addObject:model];
//                    }else
//                        [twoArr addObject:model];
//                    if (arr.count==0) {
//                        postM.isFriend = false;
//                    }else
//                        postM.isFriend = true;
//                }else
                    [resultMArr addObject:model];
                
            }
            if ([tableName isEqualToString:@"friendPost"]) {
                if (oneArr.count!=0) {
                    [resultMArr addObject:oneArr];
                }
                if (twoArr.count!=0) {
                    [resultMArr addObject:twoArr];
                }
                
            }
        }
        
    }
    
    return resultMArr;
}

// 直接传一个array插入
- (NSArray *)at_insertTable:(NSString *)tableName dicOrModelArray:(NSArray *)dicOrModelArray
{
    int errorIndex = 0;
    NSMutableArray *resultMArr = [NSMutableArray arrayWithCapacity:0];
    NSArray *columnArr = [self getColumnArr:tableName db:_db];
    for (id parameters in dicOrModelArray) {
        
        BOOL flag = [self insertTable:tableName dicOrModel:parameters columnArr:columnArr];
        if (!flag) {
            [resultMArr addObject:@(errorIndex)];
        }
        errorIndex++;
    }
    
    return resultMArr;
}

- (BOOL)at_deleteTable:(NSString *)tableName
{
    
    NSString *sqlstr = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", tableName];
    if (![_db executeUpdate:sqlstr])
    {
        return NO;
    }
    return YES;
}

- (BOOL)at_deleteAllDataFromTable:(NSString *)tableName
{
    
    NSString *sqlstr = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    if (![_db executeUpdate:sqlstr])
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)at_isExistTable:(NSString *)tableName
{
    
    FMResultSet *set = [_db executeQuery:@"SELECT count(*) as 'count' FROM sqlite_master WHERE type ='table' and name = ?", tableName];
    while ([set next])
    {
        NSInteger count = [set intForColumn:@"count"];
        if (count == 0) {
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)at_columnNameArray:(NSString *)tableName
{
    return [self getColumnArr:tableName db:_db];
}

- (int)at_tableItemCount:(NSString *)tableName
{
    
    NSString *sqlstr = [NSString stringWithFormat:@"SELECT count(*) as 'count' FROM %@", tableName];
    FMResultSet *set = [_db executeQuery:sqlstr];
    while ([set next])
    {
        return [set intForColumn:@"count"];
    }
    return 0;
}
- (int)at_tableItemUnTreatedCount:(NSString *)tableName
{
    NSString *sqlstr = [NSString stringWithFormat:@"SELECT count(PKID) FROM %@ where state = 'untreated'", tableName];
    int count = [_db intForQuery:sqlstr];
    return count;
}
- (void)close
{
    [_db close];
}

- (void)open
{
    [_db open];
}

- (NSInteger)lastInsertPrimaryKeyId:(NSString *)tableName
{
    NSString *sqlstr = [NSString stringWithFormat:@"SELECT * FROM %@ where pkid = (SELECT max(pkid) FROM %@)", tableName, tableName];
    FMResultSet *set = [_db executeQuery:sqlstr];
    while ([set next])
    {
        return [set longLongIntForColumn:@"pkid"];
    }
    return 0;
}

- (BOOL)at_alterTable:(NSString *)tableName dicOrModel:(id)parameters
{
    return [self at_alterTable:tableName dicOrModel:parameters excludeName:nil];
}

- (BOOL)at_alterTable:(NSString *)tableName dicOrModel:(id)parameters excludeName:(NSArray *)nameArr
{
    __block BOOL flag;
    [self at_inTransaction:^(BOOL *rollback) {
        if ([parameters isKindOfClass:[NSDictionary class]]) {
            for (NSString *key in parameters) {
                if ([nameArr containsObject:key]) {
                    continue;
                }
                flag = [_db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@", tableName, key, parameters[key]]];
                if (!flag) {
                    *rollback = YES;
                    return;
                }
            }
            
        } else {
            Class CLS;
            if ([parameters isKindOfClass:[NSString class]]) {
                if (!NSClassFromString(parameters)) {
                    CLS = nil;
                } else {
                    CLS = NSClassFromString(parameters);
                }
            } else if ([parameters isKindOfClass:[NSObject class]]) {
                CLS = [parameters class];
            } else {
                CLS = parameters;
            }
            NSDictionary *modelDic = [self modelToDictionary:CLS excludePropertyName:nameArr];
            NSArray *columnArr = [self getColumnArr:tableName db:_db];
            for (NSString *key in modelDic) {
                if (![columnArr containsObject:key] && ![nameArr containsObject:key]) {
                    flag = [_db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@", tableName, key, modelDic[key]]];
                    if (!flag) {
                        *rollback = YES;
                        return;
                    }
                }
            }
        }
    }];
    return flag;
}

// =============================   线程安全操作    ===============================

- (void)at_inDatabase:(void(^)(void))block
{
    
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        block();
    }];
}

- (void)at_inTransaction:(void(^)(BOOL *rollback))block
{
    
    [[self dbQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        block(rollback);
    }];
    
}
-(NSString *)getNDay:(NSInteger)n
{
    NSDate*snowDate = [NSDate date];
    NSDate* theDate;
    if(n!=0){
        NSTimeInterval  oneDay = 24*60*60*1;  //1天的长度
        theDate = [snowDate initWithTimeIntervalSinceNow: -oneDay*n ];//initWithTimeIntervalSinceNow是从现在往前后推的秒数、
        
    }else{
        theDate = snowDate;
        
    }
    NSDateFormatter *date_formatter = [[NSDateFormatter alloc] init];
    [date_formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *the_date_str = [date_formatter stringFromDate:theDate];
    return the_date_str;
    
}
- (NSInteger)compareDate:(NSString*)aDate withDate:(NSString*)bDate
{
    NSInteger aa;
    NSDateFormatter *dateformater = [[NSDateFormatter alloc] init];
    [dateformater setDateFormat:@"yyyy-MM-dd"];
    NSDate *dta = [[NSDate alloc] init];
    NSDate *dtb = [[NSDate alloc] init];
    
    dta = [dateformater dateFromString:aDate];
    dtb = [dateformater dateFromString:bDate];
    NSComparisonResult result = [dta compare:dtb];
    if (result==NSOrderedSame)
    {//相等
        aa=0;
    }else if (result==NSOrderedAscending)
    {//bDate比aDate大
        aa=1;
    }else {//bDate比aDate小
        aa=-1;
    }
    
    return aa;
}

//-(void)updateGroupInfoWithGroup:(ATChatGroupModel *)model
//{
//    NSString *sql = [NSString stringWithFormat:@"where groupId = '%@'",model.groupId];
//    [self at_updateTable:@"chatGroupList" dicOrModel:model whereFormat:sql];
//}
//-(ATChatGroupModel *)getGroupModelWithGroupId:(NSString *)groupId
//{
//    NSString *where = [NSString stringWithFormat:@"where groupId = '%@'",groupId];
//    NSArray *arr = [[ATFMDBTool shareDatabase] at_lookupTable:@"chatGroupList" dicOrModel:[ATChatGroupModel new] whereFormat:where];
//    return [arr firstObject];
//}
//-(ATGroupServerModel *)getGroupInfoModelWithGroupId:(NSString *)groupId
//{
//    NSString *where = [NSString stringWithFormat:@"where groupId = '%@'",groupId];
//    NSArray *arr = [[ATFMDBTool shareDatabase] at_lookupTable:@"chatGroupInfo" dicOrModel:[ATGroupServerModel new] whereFormat:where];
//    return [arr firstObject];
//}
//-(BOOL)isShowGroupNameWithGroupId:(NSString *)groupId
//{
//    NSString *sql = [NSString stringWithFormat:@"select settingStr from chatGroupInfo where groupId is '%@'",groupId];
//    FMResultSet *set = [_db executeQuery:sql];
//    while ([set next]) {
//        id value = [set stringForColumn:@"settingStr"];
//        if ([value isKindOfClass:[NSString class]]) {
//            NSString *new= (NSString *)value;
//            if ([new containsString:@"SHOW_NICK"]) {
//                return true;
//            }
//        }
//
//        return false;
//    }
//    return false;
//}
//-(void)updateGroupServerModelWithGroup:(ATGroupServerModel *)model
//{
//    NSString *sql = [NSString stringWithFormat:@"where groupId = '%@'",model.groupId];
//    [self at_updateTable:@"chatGroupInfo" dicOrModel:model whereFormat:sql];
//}
//-(void)insertGroupTolist:(ATChatGroupModel *)model
//{
//    [[ATFMDBTool shareDatabase] at_insertTable:@"chatGroupList" dicOrModel:model];
//}
-(SWFriendInfoModel *)isFriendWithName:(NSString *)name
{
    NSString *where = [NSString stringWithFormat:@"where imToken = '%@'",name];
    NSArray *arr = [[ATFMDBTool shareDatabase] at_lookupTable:@"friendList" dicOrModel:[SWFriendInfoModel new] whereFormat:where];
    if (arr.count>0) {
        return [arr firstObject];
    }else
        return nil;
}
//-(void)deleteFriendWithLoginName:(NSString *)name
//{
//    NSString *where = [NSString stringWithFormat:@"where imToken = '%@'",name];
//    [[ATFMDBTool shareDatabase] at_deleteTable:@"friendList" whereFormat:where];
//}
//-(void)updateFriendInfoWithUserId:(ATFriendInfoModel *)model
//{
//    NSString *sql = [NSString stringWithFormat:@"where userId = '%@'",model.userId];
//    [self at_updateTable:@"friendList" dicOrModel:model whereFormat:sql];
//}
//-(void)updateFriendPostStates:(NSString *)states
//{
////    NSString *sql = @"where state = 'untreated'";
//    NSString *sql = [NSString stringWithFormat:@"UPDATE friendPost SET state = '%@' where state = 'untreated';",states];
////    [_db INS]
//     [_db executeUpdate:sql];
////    [self at_updateTable:@"friendList" dicOrModel:model whereFormat:sql];
//}
//
//-(void)updateMessageContentWithMessageModel:(EMMessage *)messageModel type:(NSInteger)type conversation:(EMConversation *)conver value:(NSInteger)value{
//    EMMessageBody *msgBody = messageModel.body;
//    if (msgBody.type == EMMessageBodyTypeText) {
//        EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
//        if (type==1) {//更新红包状态
//            NSString *body = textBody.text;
//            NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithDictionary:[ATGeneralFuncUtil JsonToDict:body]];
//            NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithDictionary:[info valueForKey:@"data"]];
//            [data setObject:@(value) forKey:@"stats"];
//            [info setValue:data forKey:@"data"];
//            EMTextMessageBody *newBody = [[EMTextMessageBody alloc] initWithText:[ATGeneralFuncUtil toJSOStr:info]];
//            messageModel.body = newBody;
//            EMError *error;
//            [conver updateMessageChange:messageModel error:&error];
//
//
//        }
//    }
//}
@end

