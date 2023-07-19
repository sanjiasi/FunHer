//
//  NSDate+Format.m
//  FunHer
//
//  Created by GLA on 2023/7/19.
//

#import "NSDate+Format.h"

@implementation NSDate (Format)

+ (NSString *)timeFormatString:(NSString *)format withDate:(NSDate *)date {
    NSDateFormatter *dateformatter = [self defaultFormatter];
    [dateformatter setDateFormat:format];
    NSString *locationString = [dateformatter stringFromDate:date];
    locationString = [NSString stringWithFormat:@"%@",locationString];
    return locationString;
}

+ (NSDate *)timeDate:(NSString *)date withFormat:(NSString *)format {
    NSDateFormatter *dateformatter = [self defaultFormatter];
    [dateformatter setDateFormat:format];
    NSDate *locationDate = [dateformatter dateFromString:date];
    return locationDate;
}

+ (NSDateFormatter *)defaultFormatter {
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    return dateformatter;
}

#pragma mark -- stamp formatter
+ (NSString *)timeStampWithDate:(NSDate *)date {
    NSString *stampStr = [NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970] * 1000];
    return stampStr;
}

+ (NSDate *)dateStampWithTime:(NSString *)timeStr {
    NSTimeInterval intervalTime = [timeStr doubleValue] / 1000.0;
    NSDate *stampDate = [NSDate dateWithTimeIntervalSince1970:intervalTime];
    return stampDate;
}

#pragma mark -- timeString
+ (NSString *)timeDefaultFormatterWithDate:(NSTimeInterval)interval {
    NSDate *creatDate = [NSDate dateWithTimeIntervalSince1970:interval/1000];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:creatDate];
    
    return strDate;
}

+ (NSString *)timeFormatYMMDD:(NSDate *)date {
    NSString *locationString = [self timeFormatString:@"yyyy.MM.dd" withDate:date];
    return locationString;
}

+ (NSString *)timeFormatMDYHM:(NSDate *)date {
    NSString *locationString = [self timeFormatString:@"MM dd, yyyy, HH:mm" withDate:date];
    return locationString;
}

+ (NSString *)timeFormatMDYHMS:(NSDate *)date {
    NSString *locationString = [self timeFormatString:@"MM dd, yyyy, HH:mm:ss" withDate:date];
    return locationString;
}

+ (NSString *)timeFormatLocalMDYHM:(NSDate *)date {
    NSString *locationString = [self timeFormatString:@"MMM dd,yyyy HH:mm" withDate:date];
    return locationString;
}

+ (NSString *)timeFormatYMDHMS:(NSDate *)date {
    NSString *locationString = [self timeFormatString:@"yyyy-MM-dd HH:mm:ss" withDate:date];
    return locationString;
}

+ (NSString *)timeFormatYDM:(NSDate *)date {
    NSString *locationString = [self timeFormatString:@"yyyy年M月d日" withDate:date];
    return locationString;
}
+ (NSString *)timeFormatYM:(NSDate *)date {
    NSString *locationString = [self timeFormatString:@"yyyy年M月" withDate:date];
    return locationString;
}

+ (NSString *)timeFormatMD:(NSDate *)date {
    NSString *locationString = [self timeFormatString:@"M月d日" withDate:date];
    return locationString;
}

+ (NSString *)timeFormatHMS:(NSDate *)date {
    NSString *locationString = [self timeFormatString:@"HH:mm:ss" withDate:date];
    return locationString;
}

+ (NSString *)timeFormatHM:(NSDate *)date {//24小时制
    NSString *locationString = [self timeFormatString:@"HH:mm" withDate:date];
    return locationString;
}

+ (NSString *)timeFormatAHM:(NSDate *)date {//12小时制
    NSDateFormatter *dateFormatter = [self defaultFormatter];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *locationString = [dateFormatter stringFromDate:date];
    return locationString;
}

+ (NSString *)timeFormatMY:(NSDate *)date {
    NSString *locationString = [self timeFormatString:@"MM/yyyy" withDate:date];
    return locationString;
}

#pragma mark -- 获取日
+ (NSInteger)timeDayForDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:date];
    NSInteger day = [dateComponent day];
    return day;
}

#pragma mark -- 获取月份
+ (NSInteger)timeMonthForDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:date];
    NSInteger month = [dateComponent month];
    return month;
}

#pragma mark -- 获取年份
+ (NSInteger)timeYearForDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:date];
    NSInteger year = [dateComponent year];
    return year;
}

#pragma mark --  Time
+ (NSDate *)dateForAHM:(NSString *)timeStr {//12小时制
    NSDateFormatter *dateFormatter = [self defaultFormatter];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSDate *date = [dateFormatter dateFromString:timeStr];
    return date;
}

+ (NSDate *)dateForYMDHMS:(NSString *)timeStr {
    NSDate *date = [self timeDate:timeStr withFormat:@"yyyy-MM-dd HH:mm:ss"];
    return date;
}

///< 获取当前时间的: 前一周(day:-7)丶前一个月(month:-30)丶前一年(year:-1)的时间戳
+ (NSTimeInterval)ddpGetExpectTimestamp:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day {
    ///< 当前时间
    NSDate *currentdata = [NSDate date];
    ///< NSCalendar -- 日历类，它提供了大部分的日期计算接口，并且允许您在NSDate和NSDateComponents之间转换
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *datecomps = [[NSDateComponents alloc] init];
    [datecomps setYear:year?:0];
    [datecomps setMonth:month?:0];
    [datecomps setDay:day?:0];
    ///< dateByAddingComponents: 在参数date基础上，增加一个NSDateComponents类型的时间增量
    NSDate *calculatedate = [calendar dateByAddingComponents:datecomps toDate:currentdata options:0];
    return [calculatedate timeIntervalSince1970];
}

+ (NSInteger)componentDaysWithTargetDate:(NSDate *)date {
    NSDate *endDate = [NSDate date];
    //利用NSCalendar比较日期的差异
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitDay;//只比较天数差异
    //比较的结果是NSDateComponents类对象
    NSDateComponents *delta = [calendar components:unit fromDate:date toDate:endDate options:0];
    return delta.day;
}

@end
