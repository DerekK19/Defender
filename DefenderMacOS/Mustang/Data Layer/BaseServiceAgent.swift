//
//  BaseServiceAgent.swift
//  Mustang
//
//  Created by Derek Knight on 5/08/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

// from mach
internal let  MACH_PORT_NULL: mach_port_t       = 0

// from mach/error.h
internal func err_system(_ x: UInt32)->UInt32 {return (((x)&0x3f)<<26)}
internal func err_sub(_ x: UInt32)->UInt32 {return (((x)&0xfff)<<14)}

// from IOReturn.h
internal let sys_iokit                          = err_system(0x38)
internal let sub_iokit_common                   = err_sub(0)
internal let sub_iokit_usb                      = err_sub(1)

// from IOMessage.h
internal func iokit_common_msg(_ message: UInt32)->UInt32 {return (sys_iokit|sub_iokit_common|message)}

internal let kIOMessageServiceIsTerminated      = iokit_common_msg(0x010)
internal let kIOMessageServiceIsSuspended       = iokit_common_msg(0x020)
internal let kIOMessageServiceIsResumed         = iokit_common_msg(0x030)

internal let kIOMessageServiceIsRequestingClose = iokit_common_msg(0x100)
internal let kIOMessageServiceIsAttemptingOpen  = iokit_common_msg(0x101)
internal let kIOMessageServiceWasClosed         = iokit_common_msg(0x110)

internal let kIOMessageServiceBusyStateChange   = iokit_common_msg(0x120)

internal let kIOMessageConsoleSecurityChange    = iokit_common_msg(0x128)

internal let kIOMessageServicePropertyChange    = iokit_common_msg(0x130)

internal let kIOMessageCanDevicePowerOff        = iokit_common_msg(0x200)
internal let kIOMessageDeviceWillPowerOff       = iokit_common_msg(0x210)
internal let kIOMessageDeviceWillNotPowerOff    = iokit_common_msg(0x220)
internal let kIOMessageDeviceHasPoweredOn       = iokit_common_msg(0x230)

internal let kIOMessageCopyClientID             = iokit_common_msg(0x330)

internal let kIOMessageSystemCapabilityChange   = iokit_common_msg(0x340)
internal let kIOMessageDeviceSignaledWakeup     = iokit_common_msg(0x350)

internal let kIOReturnExclusiveAccess: kern_return_t = -536870203

// from IOCFPlugin.h
internal let kIOCFPlugInInterfaceID = CFUUIDGetConstantUUIDWithBytes(nil,
                                                                     0xC2, 0x44, 0xE8, 0x58, 0x10, 0x9C, 0x11, 0xD4,
                                                                     0x91, 0xD4, 0x00, 0x50, 0xE4, 0xC6, 0x42, 0x6F)
// Fender constants
private let FenderVendorId: Int = 0x1ed8

// Apple constants
private let AppleVendorId: Int = 0x05ac
private let iPhoneProductId: Int = 0x12a8

// ThingM constants
private let ThingMVendorId: Int = 0x27b8

enum DataMode {
    case Mock
    case Real
}

class BaseServiceAgent {
    
    let verbose = false
    let dataDebug = false
    
    let vendorId = FenderVendorId
    
    // MARK: Logging and debugging
    internal func logError(_ reason: String, kr: kern_return_t) {
        if kr != kIOReturnSuccess {
            ULog.error("%@ 0x%08x", reason, kr)
        }
    }
    internal func logError(_ reason: String, hr: HRESULT) {
        if hr != 0 {
            ULog.error("%@ 0x%08x", reason, hr)
        }
    }
    
    internal func logVerbose(_ text: String) {
        if (verbose) {
            ULog.verbose("%@", text)
        }
    }
    
    internal func logDebug(_ text: String) {
        if (verbose) {
            ULog.debug("%@", text)
        }
    }
}
