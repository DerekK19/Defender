//
//  AudioServiceAgent.swift
//  Mustang
//
//  Created by Derek Knight on 16/07/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import CoreAudio

private let FenderManufacturer: String = "FMIC"

internal class AudioServiceAgent: BaseServiceAgent, AudioServiceAgentProtocol {
    
    // MARK: Constructors
    override init() {
        super.init()
    }
    
    // MARK: - Internal behaviour
    internal func getDevices() -> [DLAudioDevice] {
        var rValue = [DLAudioDevice]()

        rValue.append(contentsOf: getAllDevicesWithManufacturer(FenderManufacturer))
        return rValue
    }
    
    // MARK: - Private behaviour
    // MARK: Private functions
    private func getAllDevicesWithManufacturer(_ manufacturer: String?) -> [DLAudioDevice] {
        var rValue = [DLAudioDevice]()
        var status: OSStatus
        if let devices: [AudioDeviceID] = getArrayProperty(selector: kAudioHardwarePropertyDevices) {
            for device in devices {

                let dManufacturer = getStringProperty(device, selector: kAudioDevicePropertyDeviceManufacturer)
                if dManufacturer != manufacturer ?? dManufacturer { continue }

                var text = "device \(String(format: "0x%08x", device))\n"

                let running: UInt32? = getProperty(device, selector: kAudioDevicePropertyDeviceIsRunning)
                if running != 1 {
                    let clientContext: UnsafeMutableRawPointer = bridge(self)
                    var outIOProcId: AudioDeviceIOProcID? = nil
                    
                    status = AudioDeviceCreateIOProcID(device,
                                                       ioProc,
                                                       clientContext,
                                                       &outIOProcId)
                    logError("AudioDeviceCreateIOProcID", status: status)
                    
                    status = AudioDeviceStart(device, outIOProcId)
                    logError("AudioDeviceStart", status: status)
                    
                    // Wait for device to start
                    sleep(1)
                    
                    let alive: UInt32? = getProperty(device, selector: kAudioDevicePropertyDeviceIsAlive)
                    text += " alive : \(alive != nil ? String(alive!) : "Unknown")\n"
                    let running: UInt32? = getProperty(device, selector: kAudioDevicePropertyDeviceIsRunning)
                    text += " running : \(running != nil ? String(running!) : "Unknown")\n"
                    let dDefault: UInt32? = getProperty(device, selector: kAudioDevicePropertyDeviceCanBeDefaultDevice)
                    text += " can default : \(dDefault != nil ? String(dDefault!) : "Unknown")\n"
                    let sDefault: UInt32? = getProperty(device, selector: kAudioDevicePropertyDeviceCanBeDefaultSystemDevice)
                    text += " can system default : \(sDefault != nil ? String(sDefault!) : "Unknown")\n"
                    let pClass: UInt32? = getProperty(device, selector: kAudioObjectPropertyClass)
                    text += " class : \(pClass != nil ? String(format: "0x%08x", pClass!) : "Unknown"). Is 'deva'? \(pClass == kAudioDeviceClassID)\n"
                    let dName = getStringProperty(device, selector: kAudioDevicePropertyDeviceName)
                    text += " name : \(dName ?? "Unknown")\n"
                    let dManufacturer = getStringProperty(device, selector: kAudioDevicePropertyDeviceManufacturer)
                    text += " manufacturer : \(dManufacturer ?? "Unknown")\n"
                    let icon = getRawHexProperty(device, selector: kAudioDevicePropertyIcon)
                    text += " icon : \(icon ?? "Unknown")\n"
                    let owner: AudioObjectID? = getProperty(device, selector: kAudioObjectPropertyOwner)
                    text += " owner : \(owner != nil ? String(format: "0x%08x", owner!) : "Unknown")\n"
                    let transport: UInt32? = getProperty(device, selector: kAudioDevicePropertyTransportType)
                    text += " transport : \(transport != nil ? String(format: "0x%08x", transport!) : "Unknown"). Is 'bltn'? \(transport == kAudioDeviceTransportTypeBuiltIn). Is 'usb '? \(transport == kAudioDeviceTransportTypeUSB)\n"
                    let serial = getRawHexProperty(device, selector: kAudioObjectPropertySerialNumber)
                    text += " serial : \(serial ?? "Unknown")\n"
                    let firmware = getRawHexProperty(device, selector: kAudioObjectPropertyFirmwareVersion)
                    text += " firmware : \(firmware ?? "Unknown")\n"
                    let latency: UInt32? = getProperty(device, selector: kAudioDevicePropertyLatency)
                    text += " latency : \(latency != nil ? String(latency!) : "Unknown")\n"
                    let dUid: NSUUID? = getUUIDProperty(device, selector: kAudioDevicePropertyDeviceUID)
                    text += " uid : \(dUid?.uuidString ?? "Unknown")\n"
                    let mUid: NSUUID? = getUUIDProperty(device, selector: kAudioDevicePropertyModelUID)
                    text += " model uid : \(mUid?.uuidString ?? "Unknown")\n"
                    let oName = getRawHexProperty(device, selector: kAudioObjectPropertyName)
                    text += " name : \(oName ?? "Unknown")\n"
                    let oManufacturer = getRawHexProperty(device, selector: kAudioObjectPropertyManufacturer)
                    text += " manufacturer : \(oManufacturer ?? "Unknown")\n"
                    let model = getRawHexProperty(device, selector: kAudioObjectPropertyModelName)
                    text += " model : \(model ?? "Unknown")\n"
                    let config: NSUUID? = getUUIDProperty(device, selector: kAudioDevicePropertyConfigurationApplication)
                    text += " config app : \(config?.uuidString ?? "Unknown")\n"
                    let buffer: UInt32? = getProperty(device, selector: kAudioDevicePropertyBufferSize)
                    text += " buffer : \(buffer != nil ? String(buffer!) : "Unknown")\n"
                    if let streams: [AudioStreamID] = getArrayProperty(device, selector: kAudioDevicePropertyStreams, scope: kAudioObjectPropertyScopeInput) {
                        if streams.count > 0 {
                            text += " input\n"
                            for stream in streams {
                                text += "  stream : \(String(format: "0x%08x", stream))\n"
                            }
                            if let config: AudioBufferList = getProperty(device, selector: kAudioDevicePropertyStreamConfiguration, scope: kAudioObjectPropertyScopeInput) {
                                text += debugPrint(config)
                            }
                            if let format: AudioStreamBasicDescription = getProperty(device, selector: kAudioDevicePropertyStreamFormat, scope: kAudioObjectPropertyScopeInput) {
                                text += debugPrint(format)
                            }
                        }
                    }
                    if let controls: [UInt32] = getArrayProperty(device, selector: kAudioObjectPropertyControlList, scope: kAudioObjectPropertyScopeInput) {
                        text += " input controls : \(controls)\n"
                    }
                    if let streams: [UInt32] = getArrayProperty(device, selector: kAudioDevicePropertyStreams, scope: kAudioObjectPropertyScopeOutput) {
                        if streams.count > 0 {
                            text += " output\n"
                            for stream in streams {
                                text += "  stream : \(String(format: "0x%08x", stream))\n"
                            }
                            if let config: AudioBufferList = getProperty(device, selector: kAudioDevicePropertyStreamConfiguration, scope: kAudioObjectPropertyScopeOutput) {
                                text += debugPrint(config)
                            }
                            if let format : AudioStreamBasicDescription = getProperty(device, selector: kAudioDevicePropertyStreamFormat, scope: kAudioObjectPropertyScopeOutput) {
                                text += debugPrint(format)
                            }
                        }
                    }
                    if let controls: [UInt32] = getArrayProperty(device, selector: kAudioObjectPropertyControlList, scope: kAudioObjectPropertyScopeOutput) {
                        text += " output controls : \(controls)\n"
                    }

                    rValue.append(DLAudioDevice(withManufacturer: dManufacturer ?? "", name: dName ?? "", deviceId: device))
                    status = AudioDeviceStop(device, outIOProcId)
                    logError("AudioDeviceStop", status: status)

                    if let outIOProcId = outIOProcId {
                        status = AudioDeviceDestroyIOProcID(device, outIOProcId)
                        logError("AudioDeviceDestroyIOProcID", status: status)
                    }
                }
                logDebug(text)
            }
        }
        return rValue
    }

    // MARK: Property Getters
    
    private func getProperty<T>(_ audioId: AudioDeviceID, selector: AudioObjectPropertySelector, scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal) -> T? {
        var dataSize: UInt32 = 0
        var status: OSStatus
        var propertyAddress = AudioObjectPropertyAddress(mSelector: selector,
                                                         mScope: scope,
                                                         mElement: kAudioObjectPropertyElementMaster)
        
        if !AudioObjectHasProperty(audioId, &propertyAddress) {
            return nil
        }
        
        status = AudioObjectGetPropertyDataSize(audioId,
                                                &propertyAddress,
                                                0,
                                                nil,
                                                &dataSize)
        if status != kAudioHardwareNoError {
            logError("AudioObjectGetPropertyDataSize", status: status)
            return nil
        }
        
        if Int(dataSize) != MemoryLayout<T>.size {
            NSLog("Expected this would be a \(MemoryLayout<T>.size) byte property")
            return nil
        }
        
        let count = Int(dataSize) / MemoryLayout<T>.size
        let dataPtr = UnsafeMutablePointer<T>.allocate(capacity: count)
        defer {dataPtr.deallocate()}
        status = AudioObjectGetPropertyData(audioId,
                                            &propertyAddress,
                                            0,
                                            nil,
                                            &dataSize,
                                            dataPtr)
        if status != kAudioHardwareNoError {
            logError("AudioObjectGetPropertyData", status: status)
            return nil
        }
        return dataPtr.pointee
    }

    private func getArrayProperty<T>(_ audioId: AudioDeviceID = UInt32(kAudioObjectSystemObject), selector: AudioObjectPropertySelector, scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal) -> [T]? {
        
        var dataSize: UInt32 = 0
        var status: OSStatus
        var propertyAddress = AudioObjectPropertyAddress(mSelector: selector,
                                                         mScope: scope,
                                                         mElement: kAudioObjectPropertyElementMaster)
        
        if !AudioObjectHasProperty(audioId, &propertyAddress) {
            return nil
        }
        
        status = AudioObjectGetPropertyDataSize(audioId,
                                                &propertyAddress,
                                                0,
                                                nil,
                                                &dataSize)
        if status != kAudioHardwareNoError {
            logError("AudioObjectGetPropertyDataSize", status: status)
            return nil
        }
        
        let count = Int(dataSize) / MemoryLayout<T>.size
        if count == 0 {
            return nil
        }
        
        let dataPtr = UnsafeMutablePointer<T>.allocate(capacity: count)
        defer {dataPtr.deallocate()}
        status = AudioObjectGetPropertyData(audioId,
                                            &propertyAddress,
                                            0,
                                            nil,
                                            &dataSize,
                                            dataPtr)
        if status != kAudioHardwareNoError {
            logError("AudioObjectGetPropertyData", status: status)
            return nil
        }
        var rValue = [T]()
        for i in 0..<count {
            rValue.append(dataPtr[i])
        }
        return rValue
    }

    private func getStringProperty(_ audioId: AudioDeviceID, selector: AudioObjectPropertySelector, scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal) -> String? {
        
        var dataSize: UInt32 = 512
        var status: OSStatus
        var propertyAddress = AudioObjectPropertyAddress(mSelector: selector,
                                                         mScope: scope,
                                                         mElement: kAudioObjectPropertyElementMaster)
        
        if !AudioObjectHasProperty(audioId, &propertyAddress) {
            return nil
        }
        
        status = AudioObjectGetPropertyDataSize(audioId,
                                                &propertyAddress,
                                                0,
                                                nil,
                                                &dataSize)
        if status != kAudioHardwareNoError {
            logError("AudioObjectGetPropertyDataSize", status: status)
            return nil
        }
        
//        dataSize = 512
        let count = Int(dataSize) + 1
        var dataPtr = UnsafeMutablePointer<CChar>.allocate(capacity: count)
        defer {dataPtr.deallocate()}
        status = AudioObjectGetPropertyData(audioId,
                                            &propertyAddress,
                                            0,
                                            nil,
                                            &dataSize,
                                            UnsafeMutablePointer(dataPtr))
        if status != kAudioHardwareNoError {
            logError("AudioObjectGetPropertyData", status: status)
            return nil
        }
        return String(cString: dataPtr)
    }
    
    private func getUUIDProperty(_ audioId: AudioDeviceID, selector: AudioObjectPropertySelector, scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal) -> NSUUID? {
        var dataSize: UInt32 = 64
        var status: OSStatus
        var propertyAddress = AudioObjectPropertyAddress(mSelector: selector,
                                                         mScope: scope,
                                                         mElement: kAudioObjectPropertyElementMaster)
        
        if !AudioObjectHasProperty(audioId, &propertyAddress) {
            return nil
        }
        
        status = AudioObjectGetPropertyDataSize(audioId,
                                                &propertyAddress,
                                                0,
                                                nil,
                                                &dataSize)
        if status != kAudioHardwareNoError {
            logError("AudioObjectGetPropertyDataSize", status: status)
            return nil
        }
        
        let count = Int(dataSize)
        let dataPtr = UnsafeMutablePointer<UInt8>.allocate(capacity: count)
        defer {dataPtr.deallocate()}
        for i in 0..<count {
            dataPtr[i] = 0
        }
        status = AudioObjectGetPropertyData(audioId,
                                            &propertyAddress,
                                            0,
                                            nil,
                                            &dataSize,
                                            dataPtr)
        if status != kAudioHardwareNoError {
            logError("AudioObjectGetPropertyData", status: status)
            return nil
        }
        let rValue = NSUUID(uuidBytes: dataPtr)
        return rValue
    }

    private func getRawHexProperty(_ audioId: AudioDeviceID, selector: AudioObjectPropertySelector, scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal) -> String? {
        if let data: [UInt8] = self.getArrayProperty(audioId, selector: selector, scope: scope) {
            
            var rValue: String = "0x"
            for i:Int in 0..<data.count {
                let subString = String(format: "%02x", data[i])
                rValue = rValue + subString
            }
            return rValue
        }
        return nil
    }
    
    private func statusToString(_ status: OSStatus) -> String
    {
        switch (status)
        {
        case kAudioHardwareUnspecifiedError:
            return "kAudioHardwareUnspecifiedError"
        case kAudioHardwareNotRunningError:
            return "kAudioHardwareNotRunningError"
        case kAudioHardwareUnknownPropertyError:
            return "kAudioHardwareUnknownPropertyError"
        case kAudioDeviceUnsupportedFormatError:
            return "kAudioDeviceUnsupportedFormatError"
        case kAudioHardwareBadPropertySizeError:
            return "kAudioHardwareBadPropertySizeError"
        case kAudioHardwareIllegalOperationError:
            return "kAudioHardwareIllegalOperationError"
        default:
            return "Unknown CoreAudio Error!"
        }
    }

    private func logError(_ reason: String, status: OSStatus) {
        if status != kAudioHardwareNoError {
            NSLog("\(reason) 0x\(String(format: "%08x", status)) - \(statusToString(status)).")
        }
    }
    
    private func debugPrint(_ object: AudioBufferList) -> String {
        var text = "  config\n"
        text += "   buffers : \(object.mNumberBuffers)\n"
        text += "    channels : \(object.mBuffers.mNumberChannels)\n"
        text += "    byte size : \(object.mBuffers.mDataByteSize)\n"
        return text
    }
    
    private func debugPrint(_ object: AudioStreamBasicDescription) -> String {
        var text = "  format\n"
        text += "   id : \(String(format: "0x%08x", object.mFormatID))\n"
        text += "   sample rate : \(object.mSampleRate)\n"
        text += "   flags : \(String(format: "0x%02x", object.mFormatFlags))\n"
        text += "     packedFloat = \(String(format: "0x%02x", kAudioFormatFlagIsPacked + kAudioFormatFlagIsFloat))\n"
        text += "   channels/frame : \(object.mChannelsPerFrame)\n"
        text += "   frames/packet : \(object.mFramesPerPacket)\n"
        text += "   bytes/packet : \(object.mBytesPerPacket)\n"
        text += "   bytes/frame : \(object.mBytesPerFrame)\n"
        text += "   bits/channel : \(object.mBitsPerChannel)\n"
        return text
    }
    
}

// Local non-class functionality - required for Swift-C interaction
private let verbose = false

func ioProc(inDevice: AudioDeviceID,
            ts: UnsafePointer<AudioTimeStamp>,
            inInputData: UnsafePointer<AudioBufferList>,
            inInputTime: UnsafePointer<AudioTimeStamp>,
            outOutputData: UnsafeMutablePointer<AudioBufferList>,
            inOutputTime: UnsafePointer<AudioTimeStamp>,
            inContext: UnsafeMutableRawPointer?) -> OSStatus {
    
    let clientContext: AudioServiceAgent? = bridge(inContext)
    let timestamp: AudioTimeStamp = ts.pointee
    let inputData: AudioBufferList = inInputData.pointee
    let inputTimeAudioTimeStamp = inInputTime.pointee
    let outputData: AudioBufferList = outOutputData.pointee
    let outputTime: AudioTimeStamp = inOutputTime.pointee
    
    logVerbose(" ioProc called for device \(String(format: "0x%04x", inDevice))")
    logVerbose("  clientContext = \(String(describing: clientContext))")
    logVerbose("  timestamp mSampleTime= \(timestamp.mSampleTime)")
    logVerbose("  inputTimeAudioTimeStamp mSampleTime = \(inputTimeAudioTimeStamp.mSampleTime)")
    logVerbose("  outputTime mSampleTime = \(outputTime.mSampleTime)")
    logVerbose("  inputData mNumberBuffers = \(inputData.mNumberBuffers), \(inputData.mBuffers.mDataByteSize), \(inputData.mBuffers.mNumberChannels)")
    if inputData.mNumberBuffers == 1 {
        let array: [Float32] = arrayFromBuffer(inputData.mBuffers)
        logVerbose("   data(\(array.count))): \(array)")
    }
    logVerbose("  outputData mNumberBuffers = \(outputData.mNumberBuffers), \(outputData.mBuffers.mDataByteSize), \(outputData.mBuffers.mNumberChannels)")
    
    return 0
}

private func bridge<T : AnyObject>(_ obj : T) -> UnsafeMutableRawPointer {
    return UnsafeMutableRawPointer(Unmanaged.passUnretained(obj).toOpaque())
    // return unsafeAddressOf(obj) // ***
}

private func bridge<T : AnyObject>(_ ptr : UnsafeMutableRawPointer?) -> T? {
    if let ptr = ptr {
        return Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
    }
    return nil
    // return unsafeBitCast(ptr, T.self) // ***
}

private func arrayFromBuffer<T>(_ buffer: AudioBuffer) -> [T] {
    let data = NSData(bytes: buffer.mData, length: Int(buffer.mDataByteSize))
    let pointer = UnsafeRawPointer(data.bytes)
    let count = data.length / MemoryLayout<T>.size
    let buffer = UnsafeBufferPointer(start: pointer.assumingMemoryBound(to: T.self), count: count)
    let array = [T](buffer)
    return array
}

private func logVerbose(_ text: String) {
    if (verbose) {
        NSLog(text)
    }
}
