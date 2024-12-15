//
//  ContentView.swift
//  Multipeer
//
//  Created by Dason Tiovino on 14/12/24.
//
import SwiftUI
import MultipeerConnectivity

struct ContentView: View {
    @StateObject private var mpManager: MultipeerManager = .init()
    @State private var isNavigateToMessageView: Bool = false

    var body: some View {
        NavigationStack{
            List($mpManager.peers, rowContent: {peer in
                Button(action: {
                    mpManager.selectedPeer = peer.wrappedValue
                }){
                    HStack{
                        Image(systemName: "iphone.gen1")
                            .imageScale(.large)
                        
                        Text("\(peer.wrappedValue.peerID.displayName)")
                    }.foregroundStyle(.black)
                }
            })
            .alert(
                item: $mpManager.permissionRequest,
                content: { request in
                Alert(
                    title: Text("Do you want to join \(request.peerId.displayName)"),
                    primaryButton: .default(Text("Yes"), action: {
                        request.onRequest(true)
                        mpManager.show(peerId: request.peerId)
                    }),
                    secondaryButton: .cancel(Text("No"), action: {
                        request.onRequest(false)
                    })
                )
            })
            .onAppear{
                mpManager.startBrowse()
            }
            .onDisappear{
                mpManager.stopBrowse()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Toggle("Press to be discoverable", isOn: $mpManager.isAdvertised)
                        .toggleStyle(.switch)
                }
            }
            .navigationDestination(isPresented: $isNavigateToMessageView){
                MessageView(mpManager: mpManager)
            }
            .onChange(of: mpManager.joinedPeer, initial: false) {_, current in
                if(!current.isEmpty){
                    isNavigateToMessageView = true
                }
            }
        }
        
    }
}


#Preview {
    ContentView()
}
