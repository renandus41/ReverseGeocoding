//
//  ReverseGeocoding.h
//
//  Created by cybergarage on 11/1/16.
//  Copyright © 2016 com.41studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworkingMethod.h"

@interface ReverseGeocoding : NSObject
+ (void)getCurrentLocationWithCompletion:(void (^)(NSString *route,NSString *neighborhood,NSString *city,NSString *country, NSString *fullAddress))completion;
@end
