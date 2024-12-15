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
                self?.messages.append($0)
            }
            .store(in: &subscriptions)
        
        session.delegate = self
        browser.delegate = self
        advertiser.delegate = self
    }
    
    public func startBrowse(){
        browser.startBrowsingForPeers()
    }
    
    public func stopBrowse(){
        browser.stopBrowsingForPeers()
    }
    
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
        
        try? session.send(data, toPeers: [joinedPeer.last!.peerID], with: .reliable)

        messagePublisher.send(MessageResponse(
            peerID: peerID,
            message: string)
        )
    }
}

private extension MultipeerManager{
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
