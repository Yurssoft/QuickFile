/* Copyright (c) 2016 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  GTLDriveComment.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   Drive API (drive/v3)
// Description:
//   Manages files in Drive including uploading, downloading, searching,
//   detecting changes, and updating sharing permissions.
// Documentation:
//   https://developers.google.com/drive/
// Classes:
//   GTLDriveComment (0 custom class methods, 12 custom properties)
//   GTLDriveCommentQuotedFileContent (0 custom class methods, 2 custom properties)

#import "GTLDriveComment.h"

#import "GTLDriveReply.h"
#import "GTLDriveUser.h"

// ----------------------------------------------------------------------------
//
//   GTLDriveComment
//

@implementation GTLDriveComment
@dynamic anchor, author, content, createdTime, deleted, htmlContent, identifier,
         kind, modifiedTime, quotedFileContent, replies, resolved;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map = @{
    @"identifier" : @"id"
  };
  return map;
}

+ (NSDictionary *)arrayPropertyToClassMap {
  NSDictionary *map = @{
    @"replies" : [GTLDriveReply class]
  };
  return map;
}

+ (void)load {
  [self registerObjectClassForKind:@"drive#comment"];
}

@end


// ----------------------------------------------------------------------------
//
//   GTLDriveCommentQuotedFileContent
//

@implementation GTLDriveCommentQuotedFileContent
@dynamic mimeType, value;
@end
