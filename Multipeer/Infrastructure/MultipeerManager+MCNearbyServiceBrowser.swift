//
//  MultipeerManager+MCNearbyServiceBrowser.swift
//  Multipeer
//
//  Created by Dason Tiovino on 15/12/24.
//

import MultipeerConnectivity

extension MultipeerManager {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        peers.append(PeerDevice(peerID: peerID))
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        peers.removeAll(where: {$0.peerID == peerID})
    }
}
