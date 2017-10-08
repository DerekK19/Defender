//
//  WebServiceAgent.swift
//  Mustang
//
//  Created by Derek Knight on 5/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import AFNetworking
import ObjectMapper

internal class WebServiceAgent: WebServiceAgentProtocol  {
    
    fileprivate let appId = "vcCH3xdtJURgbQ5ruJj0IKHKoZCJFCbA3kgCOnJSzcWj9Y69zqfXsPAMP6nJ76PLzi4zmmGSjeITTs6iElFW871d7jHjLKLvjculAQabhdPjupUKFM72ufYYTCtqRHDx"
    fileprivate let deviceId = "7WISLoZVBY1eRioCZd1ilBdIHJPMqnC3AVnsCRrI8xl76xEKDgh7FArP9mIqozHb5pQOiwJ5zXDREqN3fsRSbHhMnki6D4JjNqoAAc2mV1klmGRVDhM8gO5dTotMO0gC"
    
    fileprivate var token: String?
    
    fileprivate var manager: AFHTTPSessionManager!
    
    init() {
        manager = AFHTTPSessionManager(sessionConfiguration: URLSessionConfiguration.default)
    }
    
    func login(username: String, password: String, onSuccess: @escaping () -> (), onFail: @escaping () -> ()) {
        let requestSerializer = AFHTTPRequestSerializer()
        manager.requestSerializer = requestSerializer
        webservicePOST(request: "login",
                       parameters: ["username":username,
                                    "password":password,
                                    "remember":"1"],
                       onSuccess: { (document: XMLDocument) in
                        self.token = document.rootElement()?.elements(forName: "login").first?.elements(forName: "token").first?.stringValue
                        if self.token != nil {
                            onSuccess()
                            return
                        }
                        onFail()
        },
                       onFail: { (error: Error?) in
                        onFail()
        })
    }
    
    func logout(onSuccess: @escaping () -> (), onFail: @escaping () -> ()) {
        webservicePOST(request: "logout",
                       parameters: ["token" : token ?? ""],
                       onSuccess: { (document: XMLDocument) in
                        self.token = nil
                        onSuccess()
                       },
                       onFail: { (error: Error?) in
                        onFail()
                       })
    }
    
    func search(forTitle title: String, pageNumber: UInt, maxReturn: UInt, onSuccess: @escaping (_ response: DLSearchResponse) -> (), onFail: @escaping () -> ()) {
        let allowedCharacterSet = (CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted)
        let escapedTitle = title.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
        webserviceGET(endpoint: "presets",
                      parameters: ["token" : token ?? "",
                                   "request" : "browse",
                                   "type" : "presets",
                                   "limit" : "\(maxReturn)",
                                   "page" : "\(pageNumber)",
                                   "q" : escapedTitle!],
                      onSuccess: { (json: Dictionary<String, Any>) in
                        if let dlObject = Mapper<DLSearchResponse>().map(JSON: json) {
                            onSuccess(dlObject)
                            return
                        }
                        onFail()
                      },
                      onFail: { (error: Error?) in
                                    onFail()
                      })
    }
    
    // MARK: Private functions
    fileprivate func webservicePOST(request: String, parameters: [String : String], onSuccess: @escaping (_ document: XMLDocument) -> (), onFail: @escaping (_ error: Error?) -> ()) {
        manager.responseSerializer = AFHTTPResponseSerializer()
        let baseParameters: [String : String] = [
            "api_version": "1.1",
            "software" : "2.0",
            "appid" : appId,
            "deviceid" : deviceId,
            "request" : request]
        var allParameters = [String : String]()
        allParameters.merge(with: baseParameters)
        allParameters.merge(with: parameters)
        manager.post("https://fuse.fender.com/webService.php",
                     parameters: allParameters,
                     progress: { (progress) in
                     },
                     success: { (task: URLSessionDataTask, data: Any?) in
                        if let data = data as? Data {
                            if let xml = String(data: data, encoding: String.Encoding.utf8) {
                                let document: XMLDocument?
                                do {
                                    document = try XMLDocument(xmlString: xml, options: XMLNode.Options(rawValue: 0))
                                    if let document = document {
                                        onSuccess(document)
                                        return
                                    }
                                }
                                catch  {
                                    NSLog("XML Doc failed")
                                }
                            }
                        }
                        onFail(nil)
                     },
                     failure: { (task: URLSessionDataTask?, error: Error) in
                        NSLog("HTTP POST failed: \(error)")
                        onFail(error)
                     })
    }
    
    fileprivate func webserviceGET(endpoint: String, parameters: [String : String], onSuccess: @escaping (_ json: Dictionary<String, Any>) -> (), onFail: @escaping (_ error: Error?) -> ()) {
        let requestSerializer = AFHTTPRequestSerializer()
        requestSerializer.setValue("2.0", forHTTPHeaderField: "FUSE_API_VERSION")
        requestSerializer.setValue(appId, forHTTPHeaderField: "FUSE_API_TOKEN")
        requestSerializer.setValue(deviceId, forHTTPHeaderField: "FUSE_DEVICE_TOKEN")
        requestSerializer.setValue("json", forHTTPHeaderField: "FUSE_API_RESPONSE_FORMAT")
        manager.requestSerializer = requestSerializer
        manager.responseSerializer = AFJSONResponseSerializer()
        let baseParameters: [String : String] = [
            "api_version": "1.1",
            "software" : "2.0",
            "appid" : appId,
            "deviceid" : deviceId]
        var allParameters = [String : String]()
        allParameters.merge(with: baseParameters)
        allParameters.merge(with: parameters)
        
        manager.get("https://fuse.fender.com/web_service/\(endpoint)",
                     parameters: allParameters,
                     progress: { (progress) in
                     },
                     success: { (task: URLSessionDataTask, data: Any?) in
                        if let data = data as? Dictionary<String, Any> {
                            onSuccess(data)
                            return
                        }
                        onFail(nil)
                     },
                     failure: { (task: URLSessionDataTask?, error: Error) in
                        NSLog("HTTP GET failed: \(error)")
                        onFail(error)
                     })
    }
    
}

