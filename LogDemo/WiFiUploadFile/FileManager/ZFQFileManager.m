//
//  ZFQFileManager.m
//  LogDemo
//
//  Created by _ on 17/4/17.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "ZFQFileManager.h"
#import <FMDB.h>
#import <ZFQLog.h>
#import "ZFQDBPromise.h"
#import "NSString+FileHelp.h"

@interface ZFQFileManager()

@end

@implementation ZFQFileManager

+ (FMDatabaseQueue *)sharedDBQueue
{
    /**
     Since there are may be several ZFQFileManager instances in multithreading, 
     so these instance should be use a shared database queue.
     */
    static FMDatabaseQueue *sharedQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //First create a database if needed.
        NSString *dbPath = [[self class] dbPath];
        [FMDatabase databaseWithPath:dbPath];
        //then create a shared serial queue.
        sharedQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        //finally create table.
        [[self class] createTableIfNotExistOnQueue:sharedQueue];
    });
    return sharedQueue;
}

#pragma mark - Public

- (ZFQDBPromise *)executeUpdate:(NSString *)sql
{
    ZFQDBPromise *promise = [ZFQDBPromise promiseWithAdapterBlock:^(ZFQDBPromiseAdapter *adapter) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            FMDatabaseQueue *queue = [[self class] sharedDBQueue];
            [queue inDatabase:^(FMDatabase *db) {
                if (![db executeUpdate:sql]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        adapter.reject([db lastError]);
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        adapter.resolve(@"1");
                    });
                }
            }];
            
        });

    }];
    
    return promise;
}

- (ZFQDBPromise *)executeQuery:(NSString *)sql values:(NSArray *)values
{
    ZFQDBPromise *promise = [ZFQDBPromise promiseWithAdapterBlock:^(ZFQDBPromiseAdapter *adapter) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            FMDatabaseQueue *queue = [[self class] sharedDBQueue];
            [queue inDatabase:^(FMDatabase *db) {
                NSError *error;
                FMResultSet *result = [db executeQuery:sql values:values error:&error];

                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        adapter.reject(error);
                    });
                } else {
                    NSMutableArray *allValues = [[NSMutableArray alloc] init];
                    while ([result next]) {
                        NSDictionary *tmpDict = [result resultDictionary];
                        [allValues addObject:tmpDict];
                    }
                    [result close];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        adapter.resolve(allValues);
                    });
                }
                
            }];
            
        });
        
    }];
    
    return promise;
}

- (ZFQDBPromise *)addFileWithName:(NSString *)fileName path:(NSString *)path
{
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO wifi_files (path,name) VALUES('%@','%@')",path,fileName];
    return [self executeUpdate:sql];
}

- (ZFQDBPromise *)removeFileWithName:(NSString *)fileName path:(NSString *)path
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM wifi_files WHERE path='%@' AND name ='%@'",path,fileName];
    return [self executeUpdate:sql];
}

- (void)asynExecuteSql:(NSString *)sql value:(NSArray *)values successBlk:(void (^)(id result))successBlk failureBlk:(void (^)(NSError *error))failureBlk
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FMDatabaseQueue *queue = [[self class] sharedDBQueue];
        [queue inDatabase:^(FMDatabase *db) {
            NSError *error;
            FMResultSet *result = [db executeQuery:sql values:values error:&error];
            
            if (error) {
                if (failureBlk) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        failureBlk(error);
                    });
                }
                
            } else {
                NSMutableArray *allValues = [[NSMutableArray alloc] init];
                while ([result next]) {
                    NSDictionary *tmpDict = [result resultDictionary];
                    [allValues addObject:tmpDict];
                }
                [result close];
                
                if (successBlk) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        successBlk(error);
                    });
                }
            }
            
        }];
        
    });
    
}

- (void)removeFileWithFileInfo:(NSDictionary *)dict
{
    if (!dict) return;
    
    NSString *path = dict[@"path"];
    NSString *fileName = dict[@"name"];
    
    NSMutableString *filePath = [[NSMutableString alloc] init];
    if (path.length > 0) {
        [filePath appendFormat:@"/%@/%@",path,fileName];
    } else {
        [filePath appendFormat:@"/%@",fileName];
    }
    NSString *absolutePath = [[NSString documentPath] stringByAppendingPathComponent:filePath];
    [[NSFileManager defaultManager] removeItemAtPath:absolutePath error:nil];
}

- (NSError *)removeAllFileAtPath:(NSString *)path
{
    if (!path) return nil;

    BOOL isDir = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    if (isDir == NO) return nil;
        
    //Clear all file at path.
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    if (error) {
        ZFQLog(@"remove all file error:%@",[error localizedDescription]);
    }
    return error;
}

- (ZFQDBPromise *)removeFileWithFileId:(NSString *)fileId
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM wifi_files WHERE file_id=%@",fileId];
    
    return [self executeUpdate:sql]
    .then(^(id value){
        
    })
    .thenOn(^(id value,ZFQDBPromise *promise){
        //Search file detail info.
        NSString *sql = @"SELECT name,path FROM wifi_files WHERE file_id=?";
        NSArray *values = @[fileId];
        [self asynExecuteSql:sql value:values successBlk:^(id result) {
            promise.adapter.resolve(result);
        } failureBlk:^(NSError *error) {
            promise.adapter.reject(error);
        }];
    })
    .then(^(id value){
        //Delete real file from directory.
        NSArray *result = value;
        if (result.count > 0) {
            [self removeFileWithFileInfo:result[0]];
        }
    })
    .thenOn(^(id value,ZFQDBPromise *promise){
        promise.adapter.resolve(value);
    });
}

- (void)removeFileWithFileIds:(NSArray *)fileIds successBlk:(void (^)(void))successBlk
{
    if (fileIds == nil || fileIds.count == 0) {
        if (successBlk) successBlk();
    }
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (successBlk) {
            successBlk();
        }
    });
    for (NSString *fileId in fileIds) {
        dispatch_group_enter(group);
        [self removeFileWithFileId:fileId].then(^(id value){
            dispatch_group_leave(group);
        })
        .catch(^(NSError *error){
            dispatch_group_leave(group);
        });
    }
}

- (ZFQDBPromise *)removeAllFile
{
    NSString *folderPath = @"wifiFile";
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM wifi_files where path='%@'",folderPath];
    return [self executeUpdate:sql]
    .then(^(id value){
    
    })
    .thenOn(^(id value,ZFQDBPromise *promise){
        NSString *absolutePath = [[NSString documentPath] stringByAppendingPathComponent:folderPath];
        NSError *error = [self removeAllFileAtPath:absolutePath];
        if (error) {
            promise.adapter.reject(error);
        } else {
            promise.adapter.resolve(nil);
        }
    });
}

- (ZFQDBPromise *)searchFileWithFileId:(NSInteger)fileId
{
    return [self executeQuery:@"SELECT name,path FROM wifi_files WHERE file_id=?" values:@[@(fileId)]];
}

- (ZFQDBPromise *)fileListWithPath:(NSString *)folderPath
{
    return [self executeQuery:@"SELECT name,file_id FROM wifi_files WHERE path=?" values:@[folderPath]];
}

#pragma mark - Private
+ (NSString *)dbPath
{
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath   = [docsPath stringByAppendingPathComponent:@"wifi_files.db"];
    return dbPath;
}

+ (void)createTableIfNotExistOnQueue:(FMDatabaseQueue *)queue
{
    //create table
    [queue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"CREATE TABLE IF NOT EXISTS wifi_files ( \
        file_id INTEGER PRIMARY KEY, \
        path TEXT, \
        name TEXT \
        );";
        if (![db executeUpdate:sql]) {
            ZFQLog(@">>create table wifi_files failed ,%@", [db lastError]);
        }
    }];
}

@end
