//
//  PeerDevice.swift
//  Multipeer
//
//  Created by Dason Tiovino on 15/12/24.
//

import Foundation
import MultipeerConnectivity

struct PeerDevice: Identifiable, Hashable{
    let id: UUID = .init()
    let peerID: MCPeerID
}
