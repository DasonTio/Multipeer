//
//  BlockListManager.swift
//  Multipeer
//
//  Created by Dason Tiovino on 16/12/24.
//

import Foundation
import Combine

final class BlockListManager: ObservableObject {
    @Published var items: [FilterDomain] = []
    
    private let userDefaults: UserDefaults
    static public let blockListKey = "domain"
    
    init() {
        // Initialize UserDefaults with App Group
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.dasontio.Multipeer") else {
            fatalError("Unable to access shared UserDefaults.")
        }
        self.userDefaults = sharedDefaults
        loadBlockList()
    }
    
    func loadBlockList() {
        if let savedDomains = userDefaults.stringArray(forKey: BlockListManager.blockListKey) {
            self.items = savedDomains.map { FilterDomain(text: $0) }
        }
    }
    
    func saveBlockList() {
        let domains = items.map { $0.text.lowercased() }
        userDefaults.set(domains, forKey: BlockListManager.blockListKey)
    }
    
    func addEmptyItem(){
        items.append(FilterDomain(text: ""))
    }
    
    func removeDomains(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        saveBlockList()
    }
}
