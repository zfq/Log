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

@interface ZFQFileManager()

@end

@implementation ZFQFileManager

+ (FMDatabaseQueue *)sharedDBQueue
{
    /**
     Since there are may be several ZFQFileManager instance in multithreading, 
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
                        [result close];
                    });
                } else {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        adapter.resolve(result);
//                    });
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        adapter.resolve(result);
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

- (ZFQDBPromise *)removeFileWithFileId:(NSInteger)fileId
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM wifi_files WHERE file_id=%li",fileId];
    return [self executeUpdate:sql];
}

- (ZFQDBPromise *)removeAllFile
{
    NSString *sql = @"DELETE FROM wifi_files";
    return [self executeUpdate:sql];
}

- (ZFQDBPromise *)searchFileWithFileId:(NSInteger)fileId
{
    return [self executeQuery:@"SELECT name,path FROM wifi_files WHERE file_id=?" values:@[@(fileId)]];
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
