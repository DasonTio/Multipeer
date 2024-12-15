//
//  PermissionRequest.swift
//  Multipeer
//
//  Created by Dason Tiovino on 15/12/24.
//

import Foundation
import MultipeerConnectivity

struct PermissionRequest: Identifiable {
    let id = UUID()
    let peerId: MCPeerID
    let onRequest: (Bool) -> Void
}
