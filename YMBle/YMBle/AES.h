//
//  AES.h
//  iOSAES256
//
//  Created by ren zhicheng on 2018/1/10.
//  Copyright © 2018年 renzhicheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AES : NSObject
+(NSData *)AES256ParmEncryptWithKey:(NSString *)key Encrypttext:(NSData *)text;   //加密
+(NSData *)AES256ParmDecryptWithKey:(NSString *)key Decrypttext:(NSData *)text;   //解密
+(NSString *) aes256_encrypt:(NSString *)key Encrypttext:(NSString *)text;
+(NSString *) aes256_decrypt:(NSString *)key Decrypttext:(NSString *)text;
@end
