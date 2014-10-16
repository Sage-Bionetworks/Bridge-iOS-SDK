//
//  NSData+SBBAdditions.m
//  BridgeSDK
//
//  Created by Erin Mounts on 10/10/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "NSData+SBBAdditions.h"
#import "zlib.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (SBBAdditions)

#pragma mark - GZIP

- (NSData *)gzipDeflate
{
  if (self.length == 0) return self;
  
  z_stream strm;
  
  strm.zalloc = Z_NULL;
  strm.zfree = Z_NULL;
  strm.opaque = Z_NULL;
  strm.total_out = 0;
  strm.next_in=(Bytef *)[self bytes];
  strm.avail_in = (unsigned int)self.length;
  
  if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) {
    return nil;
  }
  
  NSMutableData *compressed = [NSMutableData dataWithLength:16384];
  
  do {
    if (strm.total_out >= [compressed length])
      [compressed increaseLengthBy: 16384];
    
    strm.next_out = [compressed mutableBytes] + strm.total_out;
    strm.avail_out = (unsigned int)([compressed length] - strm.total_out);
    
    deflate(&strm, Z_FINISH);
    
  } while (strm.avail_out == 0);
  
  deflateEnd(&strm);
  
  [compressed setLength: strm.total_out];
  return [NSData dataWithData:compressed];
}

#pragma mark - MD5

- (NSString*)contentMD5
{
  unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
  
  // compute the MD5 hash of the data into the buffer
  CC_MD5(self.bytes, (unsigned int)self.length, md5Buffer);
  
  // Convert unsigned char buffer to NSData
  NSData *md5Data = [NSData dataWithBytes:md5Buffer length:CC_MD5_DIGEST_LENGTH];
  
  // Base64 encode it
  NSString *contentMD5 = [md5Data base64EncodedStringWithOptions:0];
  
  return contentMD5;
}

@end
