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
//  GTLDriveChangeList.m
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
//   GTLDriveChangeList (0 custom class methods, 4 custom properties)

#import "GTLDriveChangeList.h"

#import "GTLDriveChange.h"

// ----------------------------------------------------------------------------
//
//   GTLDriveChangeList
//

@implementation GTLDriveChangeList
@dynamic changes, kind, newStartPageToken, nextPageToken;

+ (NSDictionary *)arrayPropertyToClassMap {
  NSDictionary *map = @{
    @"changes" : [GTLDriveChange class]
  };
  return map;
}

+ (void)load {
  [self registerObjectClassForKind:@"drive#changeList"];
}

@end
