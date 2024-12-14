//
//  MultipeerManager.swift
//  Multipeer
//
//  Created by Dason Tiovino on 14/12/24.
//

import Foundation
import MultipeerConnectivity
import SwiftUI

// Define a struct for received messages
struct ReceivedMessage: Identifiable, Hashable {
    let id = UUID()
    let sender: String
    let content: String
}

// Define a struct for discovered peers
struct DiscoveredPeer: Identifiable, Hashable {
    let id = UUID()
    let peerID: MCPeerID
    let displayName: String
}

class MultipeerSession: NSObject, ObservableObject {
    // MARK: - Properties

    private let serviceType = "chat-svc" // Ensure it's valid (max 15 chars, lowercase)

    #if os(macOS)
    private let myPeerId = MCPeerID(displayName: Host.current().localizedName ?? "Mac")
    #else
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    #endif
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser

    @Published var receivedMessages: [ReceivedMessage] = []
    @Published var connectedPeers: [MCPeerID] = []
    @Published var discoveredPeers: [DiscoveredPeer] = []
    @Published var invitationHandler: ((Bool, MCSession?) -> Void)?

    var session: MCSession

    // MARK: - Initializer

    override init() {
        self.session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)

        super.init()

        self.session.delegate = self
        self.serviceAdvertiser.delegate = self
        self.serviceBrowser.delegate = self

        self.startAdvertising()
        self.startBrowsing()
        
        // Listen for invitation responses
        NotificationCenter.default.addObserver(self, selector: #selector(handleInvitation(_:)), name: .didReceiveInvitation, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Start/Stop Advertising and Browsing

    func startAdvertising() {
        self.serviceAdvertiser.startAdvertisingPeer()
        print("Started advertising as \(myPeerId.displayName)")
    }

    func stopAdvertising() {
        self.serviceAdvertiser.stopAdvertisingPeer()
        print("Stopped advertising")
    }

    func startBrowsing() {
        self.serviceBrowser.startBrowsingForPeers()
        print("Started browsing for peers")
    }

    func stopBrowsing() {
        self.serviceBrowser.stopBrowsingForPeers()
        print("Stopped browsing for peers")
    }

    // MARK: - Inviting Peers

    func invitePeer(_ peer: DiscoveredPeer) {
        serviceBrowser.invitePeer(peer.peerID, to: session, withContext: nil, timeout: 10)
        print("Invited peer: \(peer.displayName)")
        // Optionally, remove the peer from discoveredPeers to avoid duplicate invitations
        DispatchQueue.main.async {
            self.discoveredPeers.removeAll { $0.peerID == peer.peerID }
        }
    }

    // MARK: - Sending Data

    func send(data: String) {
        if session.connectedPeers.count > 0 {
            if let dataToSend = data.data(using: .utf8) {
                do {
                    try session.send(dataToSend, toPeers: session.connectedPeers, with: .reliable)
                    print("Sent data: \(data)")
                } catch let error {
                    print("Error sending data: \(error.localizedDescription)")
                }
            }
        } else {
            print("No connected peers to send data to")
        }
    }

    // MARK: - Disconnect

    func disconnect() {
        self.session.disconnect()
        self.stopAdvertising()
        self.stopBrowsing()
        DispatchQueue.main.async {
            self.connectedPeers = []
            self.receivedMessages = []
            self.discoveredPeers = []
        }
        print("Disconnected session")
    }

    // MARK: - Handle Invitations

    @objc func handleInvitation(_ notification: Notification) {
        guard let peerID = notification.object as? MCPeerID else { return }
        // You can use a delegate or another mechanism to present a prompt to the user
        // For simplicity, we'll assume the user always accepts invitations here
        if let handler = self.invitationHandler {
            handler(true, self.session)
            self.invitationHandler = nil
        }
    }
}

// MARK: - MCSessionDelegate

extension MultipeerSession: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
            switch state {
            case .connected:
                print("Connected to \(peerID.displayName)")
            case .connecting:
                print("Connecting to \(peerID.displayName)")
            case .notConnected:
                print("Disconnected from \(peerID.displayName)")
            @unknown default:
                print("Unknown state for \(peerID.displayName)")
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let receivedString = String(data: data, encoding: .utf8) {
            let message = ReceivedMessage(sender: peerID.displayName, content: receivedString)
            DispatchQueue.main.async {
                self.receivedMessages.append(message)
                print("Received data from \(peerID.displayName): \(receivedString)")
            }
        }
    }

    // Unused delegate methods
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) { }
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension MultipeerSession: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Failed to start advertising: \(error.localizedDescription)")
        // Optionally, handle specific error codes
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Received invitation from \(peerID.displayName)")
        // Store the invitation handler to present a prompt to the user
        DispatchQueue.main.async {
            self.invitationHandler = invitationHandler
            // Post a notification or use a delegate to inform the UI
            NotificationCenter.default.post(name: .didReceiveInvitation, object: peerID)
        }
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension MultipeerSession: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Failed to start browsing: \(error.localizedDescription)")
        // Optionally, handle specific error codes
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String : String]?) {
        print("Found peer: \(peerID.displayName)")
        // Avoid adding self to the discovered peers
        if peerID != myPeerId {
            let newPeer = DiscoveredPeer(peerID: peerID, displayName: peerID.displayName)
            DispatchQueue.main.async {
                if !self.discoveredPeers.contains(newPeer) {
                    self.discoveredPeers.append(newPeer)
                }
            }
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID.displayName)")
        DispatchQueue.main.async {
            self.discoveredPeers.removeAll { $0.peerID == peerID }
        }
    }
}

// MARK: - Notification Extension

extension Notification.Name {
    static let didReceiveInvitation = Notification.Name("didReceiveInvitation")
}
