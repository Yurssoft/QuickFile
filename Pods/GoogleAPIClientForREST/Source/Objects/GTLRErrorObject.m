/* Copyright (c) 2011 Google Inc.
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

#if !__has_feature(objc_arc)
#error "This file needs to be compiled with ARC enabled."
#endif

#import "GTLRErrorObject.h"
#import "GTLRService.h"

@implementation GTLRErrorObject {
  NSError *_originalFoundationError;
}

// V1 & V2 properties.
@dynamic code;
@dynamic message;

// V1 properties.
@dynamic errors;

// V2 properties.
@dynamic status;
@dynamic details;

// Implemented below.
@dynamic foundationError;

+ (instancetype)objectWithFoundationError:(NSError *)error {
  GTLRErrorObject *object = [self object];
  object->_originalFoundationError = error;
  object.code = @(error.code);
  object.message = error.description;
  return object;
}

+ (NSDictionary *)arrayPropertyToClassMap {
  return @{
    @"errors" : [GTLRErrorObjectErrorItem class],
    @"details" : [GTLRErrorObjectDetail class]
  };
}

- (NSError *)foundationError {
  // If there was an original foundation error, copy its userInfo as the basis for ours.
  NSMutableDictionary *userInfo =
      [NSMutableDictionary dictionaryWithDictionary:_originalFoundationError.userInfo];

  // This structured GTLRErrorObject will be available in the error's userInfo
  // dictionary.
  [userInfo setObject:self forKey:kGTLRStructuredErrorKey];

  NSError *error;
  if (_originalFoundationError) {
    error = [NSError errorWithDomain:_originalFoundationError.domain
                                code:_originalFoundationError.code
                            userInfo:userInfo];
  } else {
    NSString *reasonStr = self.message;
    if (reasonStr) {
      // We always store an error in the userInfo key "error"
      [userInfo setObject:reasonStr forKey:kGTLRServiceErrorStringKey];

      // Store a user-readable "reason" to show up when an error is logged,
      // in parentheses like NSError does it
      NSString *parenthesized = [NSString stringWithFormat:@"(%@)", reasonStr];
      [userInfo setObject:parenthesized
                   forKey:NSLocalizedFailureReasonErrorKey];
    }

    error = [NSError errorWithDomain:kGTLRErrorObjectDomain
                                code:self.code.integerValue
                            userInfo:userInfo];
  }
  return error;
}

+ (GTLRErrorObject *)underlyingObjectForError:(NSError *)foundationError {
  NSDictionary *userInfo = [foundationError userInfo];
  GTLRErrorObject *errorObj = [userInfo objectForKey:kGTLRStructuredErrorKey];
  return errorObj;
}

@end

@implementation GTLRErrorObjectErrorItem
@dynamic domain;
@dynamic reason;
@dynamic message;
@dynamic location;
@end

@implementation GTLRErrorObjectDetail
@dynamic type;
@dynamic detail;

+ (NSDictionary *)propertyToJSONKeyMap {
  return @{ @"type" : @"@type" };
}

@end
