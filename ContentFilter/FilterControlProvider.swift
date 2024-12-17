//
//  FilterControlProvider.swift
//  ContentFilter
//
//  Created by Dason Tiovino on 16/12/24.
//

import NetworkExtension
import Foundation
import Multipeer

import NetworkExtension

class FilterControlProvider: NEFilterControlProvider {

    public static let defaults = UserDefaults(suiteName: "group.com.dasontio.Multipeer")
    
    override init() {
        super.init()
    }
    
    private let blockedDomains: [String] = [
        "youtube.com",
        "www.youtube.com"
    ]
    
    override func startFilter(completionHandler: @escaping ((any Error)?) -> Void) {
        FilterControlProvider.defaults?.object(forKey: "")
        completionHandler(nil)
    }
    
    override func stopFilter(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
        
    /// Handle a new flow of network data
    override func handleNewFlow(_ flow: NEFilterFlow, completionHandler: @escaping (NEFilterControlVerdict) -> Void) {
        if let host = flow.url?.host?.lowercased(){
            for domain in blockedDomains{
                if (host.hasSuffix(domain)){
                    completionHandler(.drop(withUpdateRules: false))
                    return
                }
            }
        }
        // Add code to determine if the flow should be dropped or not, downloading new rules if required
        completionHandler(.allow(withUpdateRules: false))
    }
    
    
}
