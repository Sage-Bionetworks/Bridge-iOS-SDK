//
//  NSData+SBBAdditions.m
//  BridgeSDK
//
//  Created by Erin Mounts on 10/10/14.
//
//	Copyright (c) 2014, Sage Bionetworks
//	All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without
//	modification, are permitted provided that the following conditions are met:
//	    * Redistributions of source code must retain the above copyright
//	      notice, this list of conditions and the following disclaimer.
//	    * Redistributions in binary form must reproduce the above copyright
//	      notice, this list of conditions and the following disclaimer in the
//	      documentation and/or other materials provided with the distribution.
//	    * Neither the name of Sage Bionetworks nor the names of BridgeSDk's
//		  contributors may be used to endorse or promote products derived from
//		  this software without specific prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//	DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
//	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
