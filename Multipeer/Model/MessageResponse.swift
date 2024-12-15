//
//  MessageResponse.swift
//  Multipeer
//
//  Created by Dason Tiovino on 15/12/24.
//

import MultipeerConnectivity

struct MessageResponse: Identifiable{
    let id: UUID = .init()
    let peerID: MCPeerID
    let message: String
}
