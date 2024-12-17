//
//  FilterUtilities.swift
//  Multipeer
//
//  Created by Dason Tiovino on 17/12/24.
//

import Foundation
import NetworkExtension

open class FilterUtilities {
    
    // MARK: Properties
    public static let defaults = UserDefaults(suiteName: "group.com.dasontio.Multipeer")
    open class func shouldAllowAccess(_ flow: NEFilterFlow) -> Bool {
        //access to your app and certains url should be allowd handling
        if #available(iOS 11.0, *) {
            if let bundleId = flow.sourceAppIdentifier {
                if bundleId == "group.com.dasontio.Multipeer"{
                    return true
                }
            }
        } else {
            // Fallback on earlier versions
            let hostname = FilterUtilities.getFlowHostname(flow)
            print("host name is \(hostname)")
            if hostname.isEmpty {
                return true
            }
        }
        return defaults?.bool(forKey: "rules") ?? true
    }
    
    
    /// Get the hostname from a browser flow.
    open class func getFlowHostname(_ flow: NEFilterFlow) -> String {
        guard let browserFlow : NEFilterBrowserFlow = flow as? NEFilterBrowserFlow,
            let url = browserFlow.url,
            let hostname = url.host
            , flow is NEFilterBrowserFlow
            else { return "" }
        return hostname
    }
}

