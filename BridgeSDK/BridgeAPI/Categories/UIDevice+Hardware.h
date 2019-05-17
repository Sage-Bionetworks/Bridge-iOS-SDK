/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 
 BD - From https://github.com/erica/uidevice-extension
 */

// maintainer's note: up-to-date mappings between new device identifiers and name strings can be found here https://www.theiphonewiki.com/wiki/Models ~emm 2017-01-06

#import <UIKit/UIKit.h>

#define IFPGA_NAMESTRING                @"iFPGA"

#define IPHONE_1G_NAMESTRING            @"iPhone 1G"
#define IPHONE_3G_NAMESTRING            @"iPhone 3G"
#define IPHONE_3GS_NAMESTRING           @"iPhone 3GS"
#define IPHONE_4_NAMESTRING             @"iPhone 4"
#define IPHONE_4S_NAMESTRING            @"iPhone 4S"
#define IPHONE_5_NAMESTRING             @"iPhone 5"
#define IPHONE_5S_NAMESTRING            @"iPhone 5S"
#define IPHONE_5C_NAMESTRING            @"iPhone 5C"
#define IPHONE_6_NAMESTRING             @"iPhone 6"
#define IPHONE_6PLUS_NAMESTRING         @"iPhone 6+"
#define IPHONE_6S_NAMESTRING            @"iPhone 6S"
#define IPHONE_6SPLUS_NAMESTRING        @"iPhone 6S+"
#define IPHONE_SE_NAMESTRING            @"iPhone SE"
#define IPHONE_7_NAMESTRING             @"iPhone 7"
#define IPHONE_7PLUS_NAMESTRING         @"iPhone 7+"
#define IPHONE_8_NAMESTRING             @"iPhone 8"
#define IPHONE_8PLUS_NAMESTRING         @"iPhone 8+"
#define IPHONE_X_NAMESTRING             @"iPhone X"
#define IPHONE_XR_NAMESTRING            @"iPhone XR"
#define IPHONE_XS_NAMESTRING            @"iPhone XS"
#define IPHONE_XSMAX_NAMESTRING         @"iPhone XS Max"
#define IPHONE_UNKNOWN_NAMESTRING       @"Unknown iPhone"

#define IPOD_1G_NAMESTRING              @"iPod touch 1G"
#define IPOD_2G_NAMESTRING              @"iPod touch 2G"
#define IPOD_3G_NAMESTRING              @"iPod touch 3G"
#define IPOD_4G_NAMESTRING              @"iPod touch 4G"
#define IPOD_5G_NAMESTRING              @"iPod touch 5G"
#define IPOD_6G_NAMESTRING              @"iPod touch 6G"
#define IPOD_UNKNOWN_NAMESTRING         @"Unknown iPod"

#define IPAD_1G_NAMESTRING              @"iPad 1G"
#define IPAD_2G_NAMESTRING              @"iPad 2G"
#define IPAD_MINI1_NAMESTRING           @"iPad Mini"
#define IPAD_3G_NAMESTRING              @"iPad 3G"
#define IPAD_4G_NAMESTRING              @"iPad 4G"
#define IPAD_AIR1_NAMESTRING            @"iPad Air"
#define IPAD_MINI2_NAMESTRING           @"iPad Mini 2"
#define IPAD_MINI3_NAMESTRING           @"iPad Mini 3"
#define IPAD_MINI4_NAMESTRING           @"iPad Mini 4"
#define IPAD_AIR2_NAMESTRING            @"iPad Air 2"
#define IPAD_PRO_12_9_1G_NAMESTRING     @"iPad Pro, 12.9\""
#define IPAD_PRO_9_7_NAMESTRING         @"iPad Pro, 9.7\""
#define IPAD_5G_NAMESTRING              @"iPad 5G"
#define IPAD_PRO_12_9_2G_NAMESTRING     @"iPad Pro, 12.9\" 2G"
#define IPAD_PRO_10_5_NAMESTRING        @"iPad Pro, 10.5\""
#define IPAD_6G_NAMESTRING              @"iPad 6G"
#define IPAD_PRO_11_NAMESTRING          @"iPad Pro, 11\""
#define IPAD_PRO_12_9_3G_NAMESTRING     @"iPad Pro, 12.9\" 3G"
#define IPAD_MINI_5G_NAMESTRING         @"iPad Mini 5G"
#define IPAD_AIR_3G_NAMESTRING          @"iPad Air 3G"
#define IPAD_UNKNOWN_NAMESTRING         @"Unknown iPad"

#define APPLETV_2G_NAMESTRING           @"Apple TV 2G"
#define APPLETV_3G_NAMESTRING           @"Apple TV 3G"
#define APPLETV_4G_NAMESTRING           @"Apple TV 4G"
#define APPLETV_4K_NAMESTRING           @"Apple TV 4K"
#define APPLETV_UNKNOWN_NAMESTRING      @"Unknown Apple TV"

#define WATCH_NAMESTRING                @"Apple Watch"
#define WATCH_S1_NAMESTRING             @"Apple Watch Series 1"
#define WATCH_S2_NAMESTRING             @"Apple Watch Series 2"
#define WATCH_S3_NAMESTRING             @"Apple Watch Series 3"
#define WATCH_S4_NAMESTRING             @"Apple Watch Series 4"
#define WATCH_UNKNOWN_NAMESTRING        @"Unknown Apple Watch"

#define IOS_FAMILY_UNKNOWN_DEVICE       @"Unknown iOS device"

#define SIMULATOR_NAMESTRING            @"iPhone Simulator"
#define SIMULATOR_IPHONE_NAMESTRING     @"iPhone Simulator"
#define SIMULATOR_IPAD_NAMESTRING       @"iPad Simulator"
#define SIMULATOR_APPLETV_NAMESTRING    @"Apple TV Simulator" // :)
#define SIMULATOR_WATCH_NAMESTRING      @"Apple Watch Simulator"

typedef enum {
    UIDeviceUnknown,
    
    UIDeviceSimulator,
    UIDeviceSimulatoriPhone,
    UIDeviceSimulatoriPad,
    UIDeviceSimulatorAppleTV,
    UIDeviceSimulatorWatch,
    
    UIDevice1GiPhone,
    UIDevice3GiPhone,
    UIDevice3GSiPhone,
    UIDevice4iPhone,
    UIDevice4SiPhone,
    UIDevice5iPhone,
    UIDevice5SiPhone,
    UIDevice5CiPhone,
    UIDevice6iPhone,
    UIDevice6PlusiPhone,
    UIDevice6SiPhone,
    UIDevice6SPlusiPhone,
    UIDeviceSEiPhone,
    UIDevice7iPhone,
    UIDevice7PlusiPhone,
    UIDevice8iPhone,
    UIDevice8PlusiPhone,
    UIDeviceXiPhone,
    UIDeviceXRiPhone,
    UIDeviceXSiPhone,
    UIDeviceXSMaxiPhone,

    UIDevice1GiPod,
    UIDevice2GiPod,
    UIDevice3GiPod,
    UIDevice4GiPod,
    UIDevice5GiPod,
    UIDevice6GiPod,

    UIDevice1GiPad,
    UIDevice2GiPad,
    UIDeviceMini1iPad,
    UIDevice3GiPad,
    UIDevice4GiPad,
    UIDeviceAir1iPad,
    UIDeviceMini2iPad,
    UIDeviceMini3iPad,
    UIDeviceMini4iPad,
    UIDeviceAir2iPad,
    UIDevicePro12_9_1GiPad,
    UIDevicePro9_7iPad,
    UIDevice5GiPad,
    UIDevicePro12_9_2GiPad,
    UIDevicePro10_5iPad,
    UIDevice6GiPad,
    UIDevicePro11iPad,
    UIDevicePro12_9_3GiPad,
    UIDeviceMini5GiPad,
    UIDeviceAir3GiPad,
    
    UIDeviceAppleTV2,
    UIDeviceAppleTV3,
    UIDeviceAppleTV4,
    UIDeviceAppleTV4K,
    
    UIDeviceWatch,
    UIDeviceWatchSeries1,
    UIDeviceWatchSeries2,
    UIDeviceWatchSeries3,
    UIDeviceWatchSeries4,
    
    UIDeviceUnknowniPhone,
    UIDeviceUnknowniPod,
    UIDeviceUnknowniPad,
    UIDeviceUnknownAppleTV,
    UIDeviceUnknownWatch,
    UIDeviceIFPGA,
    
} UIDevicePlatform;

typedef enum {
    UIDeviceFamilyiPhone,
    UIDeviceFamilyiPod,
    UIDeviceFamilyiPad,
    UIDeviceFamilyAppleTV,
    UIDeviceFamilyWatch,
    UIDeviceFamilyUnknown,
    
} UIDeviceFamily;

@interface UIDevice (Hardware)
- (NSString *) platform;
- (NSString *) hwmodel;
- (NSUInteger) _platformType;
- (NSString *) platformString;

- (NSUInteger) cpuFrequency;
- (NSUInteger) busFrequency;
- (NSUInteger) cpuCount;
- (NSUInteger) totalMemory;
- (NSUInteger) userMemory;

- (NSNumber *) totalDiskSpace;
- (NSNumber *) freeDiskSpace;

- (NSString *) macaddress;

- (BOOL) hasRetinaDisplay;
- (UIDeviceFamily) deviceFamily;

- (NSString *) deviceInfo;

@end
