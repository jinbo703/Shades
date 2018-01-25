//
//  RKCommon.m
//  Shades
//
//  Created by John Nik on 11/17/17.
//  Copyright © 2017 johnik703. All rights reserved.
//s

#import "RKCommon.h"

@implementation RKCommon

+(BOOL)checkInternetConnection
{
    Reachability *myNetwork = [Reachability reachabilityWithHostname:@"google.com"];
    NetworkStatus myStatus = [myNetwork currentReachabilityStatus];
    
    switch (myStatus) {
        case NotReachable:
            NSLog(@"There's no internet connection at all. Display error message now.");
            return false;
            break;
        case ReachableViaWWAN:
            NSLog(@"We have a 3G connection");
            return true;
            break;
            
        case ReachableViaWiFi:
            NSLog(@"We have WiFi.");
            return true;
            break;
        default:
            return false;
            break;
    }
}

+(NSString *)displayTodayDate
{
    NSDate *today = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM-dd-yyyy"];
    NSString *formattedDate = [df stringFromDate:today];
    NSString *todayDate = [NSString stringWithFormat:@"%@",formattedDate];
    return todayDate;
}

+(NSString *)getSyncDateInString
{
    NSDate *today = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM-dd-yyyy"];
    NSString *formattedDate = [df stringFromDate:today];
    NSString *todayDate = [NSString stringWithFormat:@"%@",formattedDate];
    return todayDate;
}

+(NSString *)stringFromTheDate:(NSDate*)date
{
    NSDate *today = date;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM-dd-yyyy"];
    NSString *formattedDate = [df stringFromDate:today];
    NSString *todayDate = [NSString stringWithFormat:@"%@",formattedDate];
    return todayDate;
}

@end
