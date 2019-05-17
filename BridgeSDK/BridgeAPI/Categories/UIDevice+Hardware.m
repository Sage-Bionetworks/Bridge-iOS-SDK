/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

// Thanks to Emanuele Vulcano, Kevin Ballard/Eridius, Ryandjohnson, Matt Brown, etc.

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "UIDevice+Hardware.h"

@implementation UIDevice (Hardware)
/*
 Platforms
 
 iFPGA ->        ??
 
 iPhone1,1 ->    iPhone 1G, M68
 iPhone1,2 ->    iPhone 3G, N82
 iPhone2,1 ->    iPhone 3GS, N88
 iPhone3,1 ->    iPhone 4/AT&T, N89
 iPhone3,2 ->    iPhone 4/Other Carrier?, ??
 iPhone3,3 ->    iPhone 4/Verizon, TBD
 iPhone4,1 ->    (iPhone 4S/GSM), TBD
 iPhone4,2 ->    (iPhone 4S/CDMA), TBD
 iPhone4,3 ->    (iPhone 4S/???)
 iPhone5,1 ->    iPhone Next Gen, TBD
 iPhone5,1 ->    iPhone Next Gen, TBD
 iPhone5,1 ->    iPhone Next Gen, TBD
 
 iPod1,1   ->    iPod touch 1G, N45
 iPod2,1   ->    iPod touch 2G, N72
 iPod2,2   ->    Unknown, ??
 iPod3,1   ->    iPod touch 3G, N18
 iPod4,1   ->    iPod touch 4G, N80
 
 // Thanks NSForge
 iPad1,1   ->    iPad 1G, WiFi and 3G, K48
 iPad2,1   ->    iPad 2G, WiFi, K93
 iPad2,2   ->    iPad 2G, GSM 3G, K94
 iPad2,3   ->    iPad 2G, CDMA 3G, K95
 iPad3,1   ->    (iPad 3G, WiFi)
 iPad3,2   ->    (iPad 3G, GSM)
 iPad3,3   ->    (iPad 3G, CDMA)
 iPad4,1   ->    (iPad 4G, WiFi)
 iPad4,2   ->    (iPad 4G, GSM)
 iPad4,3   ->    (iPad 4G, CDMA)
 
 AppleTV2,1 ->   AppleTV 2, K66
 AppleTV3,1 ->   AppleTV 3, ??
 
 i386, x86_64 -> iPhone Simulator
 */


#pragma mark sysctlbyname utils
- (NSString *) getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

- (NSString *) platform
{
    return [self getSysInfoByName:"hw.machine"];
}


// Thanks, Tom Harrington (Atomicbird)
- (NSString *) hwmodel
{
    return [self getSysInfoByName:"hw.model"];
}

#pragma mark sysctl utils
- (NSUInteger) getSysInfo: (uint) typeSpecifier
{
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results;
}

- (NSUInteger) cpuFrequency
{
    return [self getSysInfo:HW_CPU_FREQ];
}

- (NSUInteger) busFrequency
{
    return [self getSysInfo:HW_BUS_FREQ];
}

- (NSUInteger) cpuCount
{
    return [self getSysInfo:HW_NCPU];
}

- (NSUInteger) totalMemory
{
    return [self getSysInfo:HW_PHYSMEM];
}

- (NSUInteger) userMemory
{
    return [self getSysInfo:HW_USERMEM];
}

- (NSUInteger) maxSocketBufferSize
{
    return [self getSysInfo:KIPC_MAXSOCKBUF];
}

#pragma mark file system -- Thanks Joachim Bean!

/*
 extern NSString *NSFileSystemSize;
 extern NSString *NSFileSystemFreeSize;
 extern NSString *NSFileSystemNodes;
 extern NSString *NSFileSystemFreeNodes;
 extern NSString *NSFileSystemNumber;
 */

- (NSNumber *) totalDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemSize];
}

- (NSNumber *) freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeSize];
}

#pragma mark platform type and name utils
// emm 2017-10-20 Apple appears to have added an undocumented NSString property named platformType to UIDevice, which broke this
- (NSUInteger) _platformType
{
    NSString *platform = [self platform];
    
    // The ever mysterious iFPGA
    if ([platform isEqualToString:@"iFPGA"])        return UIDeviceIFPGA;
    
    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"])    return UIDevice1GiPhone;
    if ([platform isEqualToString:@"iPhone1,2"])    return UIDevice3GiPhone;
    if ([platform hasPrefix:@"iPhone2"])            return UIDevice3GSiPhone;
    if ([platform hasPrefix:@"iPhone3"])            return UIDevice4iPhone;
    if ([platform hasPrefix:@"iPhone4"])            return UIDevice4SiPhone;
    if ([platform isEqualToString:@"iPhone5,3"])    return UIDevice5CiPhone;
    if ([platform isEqualToString:@"iPhone5,4"])    return UIDevice5CiPhone;
    if ([platform hasPrefix:@"iPhone5"])            return UIDevice5iPhone;
    if ([platform hasPrefix:@"iPhone6"])            return UIDevice5SiPhone;
    if ([platform isEqualToString:@"iPhone7,1"])    return UIDevice6PlusiPhone;
    if ([platform isEqualToString:@"iPhone7,2"])    return UIDevice6iPhone;
    if ([platform isEqualToString:@"iPhone8,1"])    return UIDevice6SiPhone;
    if ([platform isEqualToString:@"iPhone8,2"])    return UIDevice6SPlusiPhone;
    if ([platform isEqualToString:@"iPhone8,4"])    return UIDeviceSEiPhone;
    if ([platform isEqualToString:@"iPhone9,1"])    return UIDevice7iPhone;
    if ([platform isEqualToString:@"iPhone9,3"])    return UIDevice7iPhone;
    if ([platform isEqualToString:@"iPhone9,2"])    return UIDevice7PlusiPhone;
    if ([platform isEqualToString:@"iPhone9,4"])    return UIDevice7PlusiPhone;
    if ([platform isEqualToString:@"iPhone10,1"])   return UIDevice8iPhone;
    if ([platform isEqualToString:@"iPhone10,4"])   return UIDevice8iPhone;
    if ([platform isEqualToString:@"iPhone10,2"])   return UIDevice8PlusiPhone;
    if ([platform isEqualToString:@"iPhone10,5"])   return UIDevice8PlusiPhone;
    if ([platform isEqualToString:@"iPhone10,3"])   return UIDeviceXiPhone;
    if ([platform isEqualToString:@"iPhone10,6"])   return UIDeviceXiPhone;
    if ([platform isEqualToString:@"iPhone11,8"])   return UIDeviceXRiPhone;
    if ([platform isEqualToString:@"iPhone11,2"])   return UIDeviceXSiPhone;
    if ([platform isEqualToString:@"iPhone11,6"])   return UIDeviceXSMaxiPhone;


    // iPod
    if ([platform hasPrefix:@"iPod1"])              return UIDevice1GiPod;
    if ([platform hasPrefix:@"iPod2"])              return UIDevice2GiPod;
    if ([platform hasPrefix:@"iPod3"])              return UIDevice3GiPod;
    if ([platform hasPrefix:@"iPod4"])              return UIDevice4GiPod;
    if ([platform hasPrefix:@"iPod5"])              return UIDevice5GiPod;
    if ([platform hasPrefix:@"iPod7"])              return UIDevice6GiPod;


    // iPad
    if ([platform hasPrefix:@"iPad1"])              return UIDevice1GiPad;
    if ([platform isEqualToString:@"iPad2,1"])      return UIDevice2GiPad;
    if ([platform isEqualToString:@"iPad2,2"])      return UIDevice2GiPad;
    if ([platform isEqualToString:@"iPad2,3"])      return UIDevice2GiPad;
    if ([platform isEqualToString:@"iPad2,4"])      return UIDevice2GiPad;
    if ([platform isEqualToString:@"iPad2,5"])      return UIDeviceMini1iPad;
    if ([platform isEqualToString:@"iPad2,6"])      return UIDeviceMini1iPad;
    if ([platform isEqualToString:@"iPad2,7"])      return UIDeviceMini1iPad;
    if ([platform isEqualToString:@"iPad3,1"])      return UIDevice3GiPad;
    if ([platform isEqualToString:@"iPad3,2"])      return UIDevice3GiPad;
    if ([platform isEqualToString:@"iPad3,3"])      return UIDevice3GiPad;
    if ([platform isEqualToString:@"iPad3,4"])      return UIDevice4GiPad;
    if ([platform isEqualToString:@"iPad3,5"])      return UIDevice4GiPad;
    if ([platform isEqualToString:@"iPad3,6"])      return UIDevice4GiPad;
    if ([platform isEqualToString:@"iPad4,1"])      return UIDeviceAir1iPad;
    if ([platform isEqualToString:@"iPad4,2"])      return UIDeviceAir1iPad;
    if ([platform isEqualToString:@"iPad4,3"])      return UIDeviceAir1iPad;
    if ([platform isEqualToString:@"iPad4,4"])      return UIDeviceMini2iPad;
    if ([platform isEqualToString:@"iPad4,5"])      return UIDeviceMini2iPad;
    if ([platform isEqualToString:@"iPad4,6"])      return UIDeviceMini2iPad;
    if ([platform isEqualToString:@"iPad4,7"])      return UIDeviceMini3iPad;
    if ([platform isEqualToString:@"iPad4,8"])      return UIDeviceMini3iPad;
    if ([platform isEqualToString:@"iPad4,9"])      return UIDeviceMini3iPad;
    if ([platform isEqualToString:@"iPad5,1"])      return UIDeviceMini4iPad;
    if ([platform isEqualToString:@"iPad5,2"])      return UIDeviceMini4iPad;
    if ([platform isEqualToString:@"iPad5,3"])      return UIDeviceAir2iPad;
    if ([platform isEqualToString:@"iPad5,4"])      return UIDeviceAir2iPad;
    if ([platform isEqualToString:@"iPad6,7"])      return UIDevicePro12_9_1GiPad;
    if ([platform isEqualToString:@"iPad6,8"])      return UIDevicePro12_9_1GiPad;
    if ([platform isEqualToString:@"iPad6,3"])      return UIDevicePro9_7iPad;
    if ([platform isEqualToString:@"iPad6,4"])      return UIDevicePro9_7iPad;
    if ([platform isEqualToString:@"iPad6,11"])     return UIDevice5GiPad;
    if ([platform isEqualToString:@"iPad6,12"])     return UIDevice5GiPad;
    if ([platform isEqualToString:@"iPad7,1"])      return UIDevicePro12_9_2GiPad;
    if ([platform isEqualToString:@"iPad7,2"])      return UIDevicePro12_9_2GiPad;
    if ([platform isEqualToString:@"iPad7,3"])      return UIDevicePro10_5iPad;
    if ([platform isEqualToString:@"iPad7,4"])      return UIDevicePro10_5iPad;
    if ([platform isEqualToString:@"iPad7,5"])      return UIDevice6GiPad;
    if ([platform isEqualToString:@"iPad7,6"])      return UIDevice6GiPad;
    if ([platform isEqualToString:@"iPad8,1"])      return UIDevicePro11iPad;
    if ([platform isEqualToString:@"iPad8,2"])      return UIDevicePro11iPad;
    if ([platform isEqualToString:@"iPad8,3"])      return UIDevicePro11iPad;
    if ([platform isEqualToString:@"iPad8,4"])      return UIDevicePro11iPad;
    if ([platform isEqualToString:@"iPad8,5"])      return UIDevicePro12_9_3GiPad;
    if ([platform isEqualToString:@"iPad8,6"])      return UIDevicePro12_9_3GiPad;
    if ([platform isEqualToString:@"iPad8,7"])      return UIDevicePro12_9_3GiPad;
    if ([platform isEqualToString:@"iPad8,8"])      return UIDevicePro12_9_3GiPad;
    if ([platform isEqualToString:@"iPad11,1"])     return UIDeviceMini5GiPad;
    if ([platform isEqualToString:@"iPad11,2"])     return UIDeviceMini5GiPad;
    if ([platform isEqualToString:@"iPad11,3"])     return UIDeviceAir3GiPad;
    if ([platform isEqualToString:@"iPad11,4"])     return UIDeviceAir3GiPad;

    // Apple TV
    if ([platform hasPrefix:@"AppleTV2"])           return UIDeviceAppleTV2;
    if ([platform hasPrefix:@"AppleTV3"])           return UIDeviceAppleTV3;
    if ([platform hasPrefix:@"AppleTV5"])           return UIDeviceAppleTV4;
    if ([platform isEqualToString:@"AppleTV6,2"])   return UIDeviceAppleTV4K;
    
    // Apple Watch
    if ([platform hasPrefix:@"Watch1"])             return UIDeviceWatch;
    if ([platform isEqualToString:@"Watch2,6"])     return UIDeviceWatchSeries1;
    if ([platform isEqualToString:@"Watch2,7"])     return UIDeviceWatchSeries1;
    if ([platform isEqualToString:@"Watch2,3"])     return UIDeviceWatchSeries2;
    if ([platform isEqualToString:@"Watch2,4"])     return UIDeviceWatchSeries2;
    if ([platform isEqualToString:@"Watch3,1"])     return UIDeviceWatchSeries3;
    if ([platform isEqualToString:@"Watch3,2"])     return UIDeviceWatchSeries3;
    if ([platform isEqualToString:@"Watch3,3"])     return UIDeviceWatchSeries3;
    if ([platform isEqualToString:@"Watch3,4"])     return UIDeviceWatchSeries3;
    if ([platform isEqualToString:@"Watch4,1"])     return UIDeviceWatchSeries4;
    if ([platform isEqualToString:@"Watch4,2"])     return UIDeviceWatchSeries4;
    if ([platform isEqualToString:@"Watch4,3"])     return UIDeviceWatchSeries4;
    if ([platform isEqualToString:@"Watch4,4"])     return UIDeviceWatchSeries4;

    if ([platform hasPrefix:@"iPhone"])             return UIDeviceUnknowniPhone;
    if ([platform hasPrefix:@"iPod"])               return UIDeviceUnknowniPod;
    if ([platform hasPrefix:@"iPad"])               return UIDeviceUnknowniPad;
    if ([platform hasPrefix:@"AppleTV"])            return UIDeviceUnknownAppleTV;
    if ([platform hasPrefix:@"Watch"])              return UIDeviceUnknownWatch;

    // Simulator thanks Jordan Breeding
    if ([platform hasSuffix:@"86"] || [platform isEqual:@"x86_64"])
    {
        BOOL smallerScreen = [[UIScreen mainScreen] bounds].size.width < 768;
        return smallerScreen ? UIDeviceSimulatoriPhone : UIDeviceSimulatoriPad;
    }
    
    return UIDeviceUnknown;
}

- (NSString *) platformString
{
    switch ([self _platformType])
    {
        case UIDevice1GiPhone: return IPHONE_1G_NAMESTRING;
        case UIDevice3GiPhone: return IPHONE_3G_NAMESTRING;
        case UIDevice3GSiPhone: return IPHONE_3GS_NAMESTRING;
        case UIDevice4iPhone: return IPHONE_4_NAMESTRING;
        case UIDevice4SiPhone: return IPHONE_4S_NAMESTRING;
        case UIDevice5iPhone: return IPHONE_5_NAMESTRING;
        case UIDevice5SiPhone: return IPHONE_5S_NAMESTRING;
        case UIDevice5CiPhone: return IPHONE_5C_NAMESTRING;
        case UIDevice6iPhone: return IPHONE_6_NAMESTRING;
        case UIDevice6PlusiPhone: return IPHONE_6PLUS_NAMESTRING;
        case UIDevice6SiPhone: return IPHONE_6S_NAMESTRING;
        case UIDevice6SPlusiPhone: return IPHONE_6SPLUS_NAMESTRING;
        case UIDeviceSEiPhone: return IPHONE_SE_NAMESTRING;
        case UIDevice7iPhone: return IPHONE_7_NAMESTRING;
        case UIDevice7PlusiPhone: return IPHONE_7PLUS_NAMESTRING;
        case UIDevice8iPhone: return IPHONE_8_NAMESTRING;
        case UIDevice8PlusiPhone: return IPHONE_8PLUS_NAMESTRING;
        case UIDeviceXiPhone: return IPHONE_X_NAMESTRING;
        case UIDeviceXRiPhone: return IPHONE_XR_NAMESTRING;
        case UIDeviceXSiPhone: return IPHONE_XS_NAMESTRING;
        case UIDeviceXSMaxiPhone: return IPHONE_XSMAX_NAMESTRING;
        case UIDeviceUnknowniPhone: return [NSString stringWithFormat:@"%@ [%@]", IPHONE_UNKNOWN_NAMESTRING, [self platform]];
            
        case UIDevice1GiPod: return IPOD_1G_NAMESTRING;
        case UIDevice2GiPod: return IPOD_2G_NAMESTRING;
        case UIDevice3GiPod: return IPOD_3G_NAMESTRING;
        case UIDevice4GiPod: return IPOD_4G_NAMESTRING;
        case UIDevice5GiPod: return IPOD_5G_NAMESTRING;
        case UIDevice6GiPod: return IPOD_6G_NAMESTRING;
        case UIDeviceUnknowniPod: return [NSString stringWithFormat:@"%@ [%@]", IPOD_UNKNOWN_NAMESTRING, [self platform]];
            
        case UIDevice1GiPad : return IPAD_1G_NAMESTRING;
        case UIDevice2GiPad : return IPAD_2G_NAMESTRING;
        case UIDeviceMini1iPad: return IPAD_MINI1_NAMESTRING;
        case UIDevice3GiPad : return IPAD_3G_NAMESTRING;
        case UIDevice4GiPad : return IPAD_4G_NAMESTRING;
        case UIDeviceAir1iPad: return IPAD_AIR1_NAMESTRING;
        case UIDeviceMini2iPad: return IPAD_MINI2_NAMESTRING;
        case UIDeviceMini3iPad: return IPAD_MINI3_NAMESTRING;
        case UIDeviceMini4iPad: return IPAD_MINI4_NAMESTRING;
        case UIDeviceAir2iPad: return IPAD_AIR2_NAMESTRING;
        case UIDevicePro12_9_1GiPad: return IPAD_PRO_12_9_1G_NAMESTRING;
        case UIDevicePro9_7iPad: return IPAD_PRO_9_7_NAMESTRING;
        case UIDevice5GiPad : return IPAD_5G_NAMESTRING;
        case UIDevicePro12_9_2GiPad: return IPAD_PRO_12_9_2G_NAMESTRING;
        case UIDevicePro10_5iPad: return IPAD_PRO_10_5_NAMESTRING;
        case UIDevice6GiPad: return IPAD_6G_NAMESTRING;
        case UIDevicePro11iPad: return IPAD_PRO_11_NAMESTRING;
        case UIDevicePro12_9_3GiPad: return IPAD_PRO_12_9_3G_NAMESTRING;
        case UIDeviceMini5GiPad: return IPAD_MINI_5G_NAMESTRING;
        case UIDeviceAir3GiPad: return IPAD_AIR_3G_NAMESTRING;
        case UIDeviceUnknowniPad : return [NSString stringWithFormat:@"%@ [%@]", IPAD_UNKNOWN_NAMESTRING, [self platform]];
            
        case UIDeviceAppleTV2 : return APPLETV_2G_NAMESTRING;
        case UIDeviceAppleTV3 : return APPLETV_3G_NAMESTRING;
        case UIDeviceAppleTV4 : return APPLETV_4G_NAMESTRING;
        case UIDeviceAppleTV4K : return APPLETV_4K_NAMESTRING;
        case UIDeviceUnknownAppleTV: return [NSString stringWithFormat:@"%@ [%@]", APPLETV_UNKNOWN_NAMESTRING, [self platform]];
            
        case UIDeviceWatch : return WATCH_NAMESTRING;
        case UIDeviceWatchSeries1 : return WATCH_S1_NAMESTRING;
        case UIDeviceWatchSeries2 : return WATCH_S2_NAMESTRING;
        case UIDeviceWatchSeries3 : return WATCH_S3_NAMESTRING;
        case UIDeviceWatchSeries4 : return WATCH_S4_NAMESTRING;
        case UIDeviceUnknownWatch : return [NSString stringWithFormat:@"%@ [%@]", WATCH_UNKNOWN_NAMESTRING, [self platform]];
            
        case UIDeviceSimulator: return SIMULATOR_NAMESTRING;
        case UIDeviceSimulatoriPhone: return SIMULATOR_IPHONE_NAMESTRING;
        case UIDeviceSimulatoriPad: return SIMULATOR_IPAD_NAMESTRING;
        case UIDeviceSimulatorAppleTV: return SIMULATOR_APPLETV_NAMESTRING;
        case UIDeviceSimulatorWatch: return SIMULATOR_WATCH_NAMESTRING;

        case UIDeviceIFPGA: return IFPGA_NAMESTRING;
            
        default: return [NSString stringWithFormat:@"%@ [%@]", IOS_FAMILY_UNKNOWN_DEVICE, [self platform]];
    }
}

- (BOOL) hasRetinaDisplay
{
    return ([UIScreen mainScreen].scale == 2.0f);
}

- (UIDeviceFamily) deviceFamily
{
    NSString *platform = [self platform];
    if ([platform hasPrefix:@"iPhone"]) return UIDeviceFamilyiPhone;
    if ([platform hasPrefix:@"iPod"]) return UIDeviceFamilyiPod;
    if ([platform hasPrefix:@"iPad"]) return UIDeviceFamilyiPad;
    if ([platform hasPrefix:@"AppleTV"]) return UIDeviceFamilyAppleTV;
    if ([platform hasPrefix:@"Watch"]) return UIDeviceFamilyWatch;

    return UIDeviceFamilyUnknown;
}

#pragma mark MAC addy
// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to mlamb.
- (NSString *) macaddress
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Error: Memory allocation error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2\n");
        free(buf); // Thanks, Remy "Psy" Demerest
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    free(buf);
    return outstring;
}

- (NSString *)deviceInfo {
    NSString *deviceModel = [self platformString];
    NSString *osName = [self systemName];
    NSString *osVersion = [self systemVersion];
    return [NSString stringWithFormat:@"%@; %@/%@", deviceModel, osName, osVersion];
}

// Illicit Bluetooth check -- cannot be used in App Store
/*
 Class  btclass = NSClassFromString(@"GKBluetoothSupport");
 if ([btclass respondsToSelector:@selector(bluetoothStatus)])
 {
 printf("BTStatus %d\n", ((int)[btclass performSelector:@selector(bluetoothStatus)] & 1) != 0);
 bluetooth = ((int)[btclass performSelector:@selector(bluetoothStatus)] & 1) != 0;
 printf("Bluetooth %s enabled\n", bluetooth ? "is" : "isn't");
 }
 */
@end
