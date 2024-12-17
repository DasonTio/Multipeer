//
//  MultipeerManager.swift
//  Multipeer
//
//  Created by Dason Tiovino on 14/12/24.
//

import Foundation
import MultipeerConnectivity
import Combine

final class MultipeerManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate, ObservableObject {
    
    /// Service type must be 5 - 11 characters length
    public let peerID: MCPeerID = .init(displayName: UIDevice.current.name)
    private let serviceType = "nearby-devices"
    private var advertiser: MCNearbyServiceAdvertiser
    private var browser: MCNearbyServiceBrowser
    internal var session: MCSession
    
    internal let messagePublisher = PassthroughSubject<MessageResponse, Never>()
    internal var subscriptions = Set<AnyCancellable>()
    
    // MARK: Published Variables
    @Published public var isAdvertised: Bool = false {
        didSet{
            isAdvertised ? advertiser.startAdvertisingPeer() : advertiser.stopAdvertisingPeer()
        }
    }
    @Published public var peers: [PeerDevice] = []
    @Published public var permissionRequest: PermissionRequest?
    @Published public var selectedPeer: PeerDevice? {
        didSet {
            connect()
        }
    }
    @Published public var joinedPeer: [PeerDevice] = []
    @Published public var messages: [MessageResponse] = []
    
    
    // MARK: Setup Multipeer Connectivity
    override init() {
        session = .init(peer: peerID)
        advertiser = .init(
            peer: peerID,
            discoveryInfo: nil,
            serviceType: serviceType
        )
        browser = .init(peer: peerID, serviceType: serviceType)
        
        super.init()
        
        session.delegate = self
        
        messagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                let message = $0.message
                if message.hasSuffix(".com") {
                    var storageMessage = FilterUtilities.defaults?.stringArray(forKey: "domain") ?? []
                    
                    if !storageMessage.contains(message) {
                        storageMessage.append(message)
                        FilterUtilities.defaults?.set(storageMessage, forKey: "domain")
                        print("Message appended: \(message)")
                    } else {
                        print("Message already exists in storage.")
                    }
                } else {
                    print("Message does not end with .com, so it was not added.")
                }
                self?.messages.append($0)
            }
            .store(in: &subscriptions)
        
        session.delegate = self
        browser.delegate = self
        advertiser.delegate = self
    }
    
    public func startBrowse(){
        peers = []
        browser.startBrowsingForPeers()
    }
    
    public func stopBrowse(){
        browser.stopBrowsingForPeers()
    }
    
    // MARK: Add connection for other device
    public func show(peerId: MCPeerID) {
        guard let first = peers.first(where: { $0.peerID == peerId }) else {
            return
        }
        
        joinedPeer.append(first)
    }

    public func send(string: String) {
        guard let data = string.data(using: .utf8) else {
            return
        }
        
        let connectedPeers = session.connectedPeers
        if connectedPeers.isEmpty {
            print("No peers connected.")
            return
        }
        
        do {
            try session.send(data, toPeers: connectedPeers, with: .reliable)
            
            messagePublisher.send(MessageResponse(peerID: peerID, message: string))
        } catch {
            print("Error sending message: \(error.localizedDescription)")
        }
    }
}

private extension MultipeerManager{
    // MARK: Add connection for our device
    func connect() {
        guard let selectedPeer else {
            return
        }
        
        if session.connectedPeers.contains(selectedPeer.peerID) {
            joinedPeer.append(selectedPeer)
        } else {
            browser.invitePeer(selectedPeer.peerID, to: session, withContext: nil, timeout: 60)
        }
    }
}
