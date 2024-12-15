//
//  MultipeerManager+MCSession.swift
//  Multipeer
//
//  Created by Dason Tiovino on 15/12/24.
//

import MultipeerConnectivity

extension MultipeerManager {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
            
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let last = joinedPeer.last, last.peerID == peerID, let message = String(data: data, encoding: .utf8) else {
            return
        }
        
        messagePublisher.send(MessageResponse(
            peerID: peerID,
            message: message
        ))
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {
            
    }
    
    
}
