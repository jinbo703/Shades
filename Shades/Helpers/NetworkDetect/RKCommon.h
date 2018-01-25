//
//  RKCommon.h
//  Shades
//
//  Created by John Nik on 11/17/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface RKCommon : NSObject

+(BOOL)checkInternetConnection;
+(NSString *)displayTodayDate;
+(NSString *)getSyncDateInString;
+(NSString *)stringFromTheDate:(NSDate*)date;

@end
