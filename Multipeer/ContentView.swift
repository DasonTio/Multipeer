//
//  ContentView.swift
//  Multipeer
//
//  Created by Dason Tiovino on 14/12/24.
//
import SwiftUI
import MultipeerConnectivity

struct ContentView: View {
    @ObservedObject var multipeerSession = MultipeerSession()
    @State private var message: String = ""
    @State private var isConnected: Bool = false
    @State private var showInvitationAlert: Bool = false
    @State private var incomingPeer: MCPeerID?

    var body: some View {
        NavigationView {
            VStack {
                // Connection Status
                HStack {
                    Image(systemName: isConnected ? "checkmark.circle" : "xmark.circle")
                        .foregroundColor(isConnected ? .green : .red)
                    Text(isConnected ? "Connected" : "Disconnected")
                        .foregroundColor(isConnected ? .green : .red)
                    Spacer()
                }
                .padding()

                // List of Connected Peers and Discovered Peers
                List {
                    // Connected Peers Section
                    Section(header: Text("Connected Peers")) {
                        if multipeerSession.connectedPeers.isEmpty {
                            Text("No peers connected")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(multipeerSession.connectedPeers, id: \.self) { peer in
                                HStack {
                                    Image(systemName: "person.circle")
                                        .foregroundColor(.blue)
                                    Text(peer.displayName)
                                }
                            }
                        }
                    }

                    // Discovered Peers Section
                    Section(header: Text("Nearby Devices")) {
                        if multipeerSession.discoveredPeers.isEmpty {
                            Text("No nearby devices found")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(multipeerSession.discoveredPeers) { peer in
                                HStack {
                                    Image(systemName: "person.crop.circle.badge.plus")
                                        .foregroundColor(.green)
                                    Text(peer.displayName)
                                    Spacer()
                                    Button(action: {
                                        multipeerSession.invitePeer(peer)
                                    }) {
                                        Text("Invite")
                                            .foregroundColor(.white)
                                            .padding(6)
                                            .background(Color.blue)
                                            .cornerRadius(6)
                                    }
                                }
                            }
                        }
                    }

                    // Received Messages Section
                    Section(header: Text("Received Messages")) {
                        if multipeerSession.receivedMessages.isEmpty {
                            Text("No messages received")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(multipeerSession.receivedMessages) { message in
                                VStack(alignment: .leading) {
                                    Text(message.sender)
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                    Text(message.content)
                                        .font(.body)
                                }
                                .padding(4)
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())

                // Message Input and Send Button
                HStack {
                    TextField("Enter message", text: $message)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)

                    Button(action: {
                        multipeerSession.send(data: message)
                        message = ""
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding()
                            .background(message.isEmpty ? Color.gray : Color.blue)
                            .clipShape(Circle())
                    }
                    .disabled(message.isEmpty)
                    .padding(.trailing)
                }
                .padding(.bottom)
            }
            .navigationTitle("Multipeer Chat")
            .navigationBarItems(trailing:
                Button(action: {
                    multipeerSession.disconnect()
                }) {
                    Text("Disconnect")
                        .foregroundColor(.red)
                }
            )
            .onReceive(multipeerSession.$connectedPeers) { peers in
                // Update connection status based on peers count
                isConnected = !peers.isEmpty
            }
            .onReceive(NotificationCenter.default.publisher(for: .didReceiveInvitation)) { notification in
                if let peerID = notification.object as? MCPeerID {
                    incomingPeer = peerID
                    showInvitationAlert = true
                }
            }
            .alert(isPresented: $showInvitationAlert) {
                Alert(
                    title: Text("Connection Invitation"),
                    message: Text("\(incomingPeer?.displayName ?? "A peer") wants to connect. Do you accept?"),
                    primaryButton: .default(Text("Accept")) {
                        multipeerSession.invitationHandler?(true, multipeerSession.session)
                        incomingPeer = nil
                    },
                    secondaryButton: .cancel() {
                        multipeerSession.invitationHandler?(false, nil)
                        incomingPeer = nil
                    }
                )
            }
        }
    }
}


#Preview {
    ContentView()
}
