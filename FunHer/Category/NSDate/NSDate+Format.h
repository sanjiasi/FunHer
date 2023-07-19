//
//  NSDate+Format.h
//  FunHer
//
//  Created by GLA on 2023/7/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Format)

/// --  date --> str
+ (NSString *)timeFormatString:(NSString *)format withDate:(NSDate *)date;
/// --  str --> date
+ (NSDate *)timeDate:(NSString *)date withFormat:(NSString *)format;

#pragma mark -- timeString
/// -- 时间戳 毫秒级
+ (NSString *)timeStampWithDate:(NSDate *)date;

/// -- 线上时间戳转换date timeStr(毫秒级)
+ (NSDate *)dateStampWithTime:(NSString *)timeStr;

/// -- 默认格式
+ (NSString *)timeDefaultFormatterWithDate:(NSTimeInterval)interval;
/// --  yyyy-MM-dd
+ (NSString *)timeFormatYMMDD:(NSDate *)date;
/// -- MM dd,yyyy HH:mm
+ (NSString *)timeFormatMDYHM:(NSDate *)date;
/// -- MM dd, yyyy, HH:mm:ss
+ (NSString *)timeFormatMDYHMS:(NSDate *)date;
/// -- MMM dd,yyyy HH:mm
+ (NSString *)timeFormatLocalMDYHM:(NSDate *)date;
/// -- yyyy-MM-dd HH:mm:ss
+ (NSString *)timeFormatYMDHMS:(NSDate *)date;
/// -- yyyy年M月d日
+ (NSString *)timeFormatYDM:(NSDate *)date;
/// -- yyyy年M月
+ (NSString *)timeFormatYM:(NSDate *)date;
/// -- M月d日
+ (NSString *)timeFormatMD:(NSDate *)date;
/// -- HH:mm:ss
+ (NSString *)timeFormatHMS:(NSDate *)date;
/// -- HH:mm 24小时制
+ (NSString *)timeFormatHM:(NSDate *)date;
/// a hh:mm -- 12小时制
+ (NSString *)timeFormatAHM:(NSDate *)date;
/// MM/yyyy
+ (NSString *)timeFormatMY:(NSDate *)date;
/// -- 获取日
+ (NSInteger)timeDayForDate:(NSDate *)date;
///  -- 获取月份
+ (NSInteger)timeMonthForDate:(NSDate *)date;
/// -- 获取年份
+ (NSInteger)timeYearForDate:(NSDate *)date;

#pragma mark --  Time
/// a hh:mm -- 12小时制
+ (NSDate *)dateForAHM:(NSString *)timeStr;
/// -- yyyy-MM-dd HH:mm:ss
+ (NSDate *)dateForYMDHMS:(NSString *)timeStr;

///< 获取当前时间的: 前一周(day:-7)丶前一个月(month:-30)丶前一年(year:-1)的时间戳
+ (NSTimeInterval)ddpGetExpectTimestamp:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day;

/// -- 计算与当前相差几天
+ (NSInteger)componentDaysWithTargetDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
