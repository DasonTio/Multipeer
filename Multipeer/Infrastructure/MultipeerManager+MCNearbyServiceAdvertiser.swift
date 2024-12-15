//
//  MultipeerManager+MCNearbyServiceAdvertiser.swift
//  Multipeer
//
//  Created by Dason Tiovino on 15/12/24.
//

import MultipeerConnectivity

extension MultipeerManager {
    public func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (
            Bool,
            MCSession?
        ) -> Void
    ) {
        permissionRequest = PermissionRequest(
            peerId: peerID,
            onRequest: { [weak self] permission in
                invitationHandler(permission, permission ? self?.session : nil)
            }
        )
    }
}
