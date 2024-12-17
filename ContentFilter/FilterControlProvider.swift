//
//  FilterControlProvider.swift
//  ContentFilter
//
//  Created by Dason Tiovino on 16/12/24.
//

import NetworkExtension

class FilterControlProvider: NEFilterControlProvider {

    public static let defaults = UserDefaults(suiteName: "group.com.dasontio.Multipeer")
    
    private var blockedDomains: [String]
    
    override init() {
        blockedDomains = [
            "youtube.com",
            "www.youtube.com"
        ]
        super.init()
    }
    
    override func startFilter(completionHandler: @escaping ((any Error)?) -> Void) {
        FilterUtilities.defaults?.stringArray(forKey: "domain")?.forEach{[weak self] domain in
            self?.blockedDomains.append(domain)
        }
        completionHandler(nil)
    }
    
    /// Handle a new flow of network data
    override func handleNewFlow(_ flow: NEFilterFlow, completionHandler: @escaping (NEFilterControlVerdict) -> Void) {
        var updatedBlockedDomains = blockedDomains
        
        if let additionalBlockedDomains = FilterUtilities.defaults?.stringArray(forKey: "domain") {
            updatedBlockedDomains.append(contentsOf: additionalBlockedDomains)
        }
        
        if let host = flow.url?.host?.lowercased() {
            for domain in updatedBlockedDomains {
                if host.hasSuffix(domain) {
                    completionHandler(.drop(withUpdateRules: false))
                    return
                }
            }
        }
        
        completionHandler(.allow(withUpdateRules: false))
    }
    
}
