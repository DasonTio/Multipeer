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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let message = String(data: data, encoding: .utf8) {
                let messageResponse = MessageResponse(peerID: peerID, message: message)
                self.messagePublisher.send(messageResponse)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {
            
    }
    
    
}
