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
    
    lazy var extensionBundle: Bundle = {

        let extensionsDirectoryURL = URL(fileURLWithPath: "Contents/Library/SystemExtensions", relativeTo: Bundle.main.bundleURL)
        let extensionURLs: [URL]
        do {
            extensionURLs = try FileManager.default.contentsOfDirectory(at: extensionsDirectoryURL,
                                                                        includingPropertiesForKeys: nil,
                                                                        options: .skipsHiddenFiles)
        } catch let error {
            fatalError("Failed to get the contents of \(extensionsDirectoryURL.absoluteString): \(error.localizedDescription)")
        }

        guard let extensionURL = extensionURLs.first else {
            fatalError("Failed to find any system extensions")
        }

        guard let extensionBundle = Bundle(url: extensionURL) else {
            fatalError("Failed to create a bundle with URL \(extensionURL.absoluteString)")
        }

        return extensionBundle
    }()
    
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
                }
            }
            .onAppear {
                mpManager.isAdvertised = true
                mpManager.startBrowse()
                
            }
            .onDisappear {
                mpManager.isAdvertised = false // Stop advertising when view disappears
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
}

#Preview {
    ContentView()
}
