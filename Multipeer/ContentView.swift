//
//  ContentView.swift
//  Multipeer
//
//  Created by Dason Tiovino on 14/12/24.

import SwiftUI
import NetworkExtension

struct ContentView: View {
    @StateObject private var blockListManager = BlockListManager()
    @StateObject private var mpManager: MultipeerManager = .init()
    @State private var isNavigateToMessageView: Bool = false
    @State private var focusedField: UUID?
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Filter")) {
                    ForEach($blockListManager.items) { $item in
                        HStack {
                            TextField("example.com", text: $item.text)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .onSubmit {
                                    blockListManager.saveBlockList()
                                }
                        }
                    }
                    .onDelete { indexSet in
                        blockListManager.removeDomains(at: indexSet)
                    }
                    
                    Button(action: {
                        blockListManager.addEmptyItem()
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add New Item")
                        }
                    }
                }
                
                Section(header: Text("Nearby Devices")) {
                    ForEach(mpManager.peers) { peer in
                        Button(action: {
                            mpManager.selectedPeer = peer
                        }) {
                            HStack {
                                Image(systemName: "iphone.gen1")
                                    .imageScale(.large)
                                
                                Text("\(peer.peerID.displayName)")
                            }
                            .foregroundStyle(.black)
                        }
                    }
                }
            }
            .alert(
                item: $mpManager.permissionRequest,
                content: { request in
                    Alert(
                        title: Text("Do you want to join \(request.peerId.displayName)?"),
                        primaryButton: .default(Text("Yes"), action: {
                            request.onRequest(true)
                            mpManager.show(peerId: request.peerId)
                        }),
                        secondaryButton: .cancel(Text("No"), action: {
                            request.onRequest(false)
                        })
                    )
                }
            )
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack{
                        Button(action: {
                            mpManager.selectedPeer = PeerDevice(peerID: mpManager.peerID)
                            isNavigateToMessageView = true
                        }) {
                            Image(systemName: "message")
                                .foregroundStyle(.black)
                                .padding()
                                .background(
                                    Circle().fill(Color(UIColor.systemGray5))
                                )
                        }
                        Button(action:{
                            askPermission()
                        }){
                            Image(systemName: "arrow.clockwise")
                                .foregroundStyle(.black)
                                .padding()
                                .background(
                                    Circle().fill(Color(UIColor.systemGray5))
                                )
                        }
                    }
                    
                    
                    
                }
            }
            .onAppear {
                askPermission()
                mpManager.isAdvertised = true
                mpManager.startBrowse()
            }
            .onDisappear {
                mpManager.isAdvertised = false 
                mpManager.stopBrowse()
            }
            .navigationDestination(isPresented: $isNavigateToMessageView) {
                MessageView(mpManager: mpManager)
            }
            .onChange(of: mpManager.joinedPeer) { _, current in
                if !current.isEmpty {
                    isNavigateToMessageView = true
                }
            }
        }
    }
    
    func askPermission(){
//        FilterUtilities.defaults?.setValue(false, forKey: "rules")
        blockListManager.loadBlockList()
        NEFilterManager.shared().loadFromPreferences{error in
            if let  saveError = error {
                print("Failed to save the filter configuration: \(saveError)")
            }
        }
        
        if NEFilterManager.shared().providerConfiguration == nil {
            let newConfiguration = NEFilterProviderConfiguration()
            newConfiguration.organization = "Multipeer"
            newConfiguration.filterBrowsers = true
            newConfiguration.filterSockets = true
            NEFilterManager.shared().providerConfiguration = newConfiguration
        }
        NEFilterManager.shared().isEnabled = true
        NEFilterManager.shared().saveToPreferences { error in
            if let  saveError = error {
                print("Failed to save the filter configuration: \(saveError)")
            }
        }
        
    }
}

#Preview {
    ContentView()
}
