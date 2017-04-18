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
@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, strong) FMDatabaseQueue *queue;
@end

@implementation ZFQFileManager

#pragma mark - Public
- (void)createTableIfNotExist
{
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:[self dbPath]];
    
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

- (ZFQDBPromise *)executeUpdate:(NSString *)sql
{
    ZFQDBPromise *promise = [ZFQDBPromise promiseWithAdapterBlock:^(ZFQDBPromiseAdapter *adapter) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.queue inDatabase:^(FMDatabase *db) {
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
            [self.queue inDatabase:^(FMDatabase *db) {
                NSError *error;
                id result = [db executeQuery:sql values:values error:&error];
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        adapter.reject(error);
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
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
//    return [self executeQuery:@"SELECT name,path FROM wifi_files WHERE file_id=?" values:@[@(fileId)]];
    
    ZFQDBPromise *promise = [ZFQDBPromise promiseWithAdapterBlock:^(ZFQDBPromiseAdapter *adapter) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            adapter.resolve(nil);
        });
        
    }];
    
    return promise;
}

#pragma mark - Getter Setter
- (FMDatabase *)database
{
    if (!_database) {
        _database = [self createDadabase];
    }
    return _database;
}

- (FMDatabaseQueue *)queue
{
    if (!_queue) {
        _queue = [FMDatabaseQueue databaseQueueWithPath:[self dbPath]];
    }
    return _queue;
}

#pragma mark - Private
- (NSString *)dbPath
{
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath   = [docsPath stringByAppendingPathComponent:@"wifi_files.db"];
    return dbPath;
}

- (FMDatabase *)createDadabase
{
    FMDatabase *db     = [FMDatabase databaseWithPath:[self dbPath]];
    return db;
}

@end
