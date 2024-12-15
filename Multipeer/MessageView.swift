//
//  MessageView.swift
//  Multipeer
//
//  Created by Dason Tiovino on 15/12/24.
//

import SwiftUI

struct MessageView: View{
    
    @StateObject var mpManager: MultipeerManager
    @State private var text: String = ""
    
    var body: some View{
        NavigationView{
            VStack{
                ScrollView{
                    VStack{
                        ForEach(mpManager.messages){ model in
                            let isMe =  model.peerID == mpManager.peerID
                            HStack{
                                Text("\(model.message)")
                                    .padding()
                                    .background(
                                       RoundedRectangle(cornerRadius: 12)
                                           .fill(isMe ? Color.green.opacity(0.5) : Color.blue.opacity(0.5))
                                   )
                                    
                            }.frame(
                                maxWidth: .infinity,
                                alignment: Alignment(
                                    horizontal: isMe ? .trailing : .leading,
                                    vertical: .center
                                )
                            )
                        }
                    }
                    .padding()
                }
                HStack{
                    RoundedRectangle(
                        cornerSize: CGSize(width: 32,height: 32)
                    )
                    .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                    .fill(Color.white)
                    .frame(maxHeight: 50 )
                    .overlay{
                        TextField(text: $text){
                            Text("Type some message here...")
                        }
                        .padding()
                    }
                    
                    Button(action: {
                        mpManager.send(string: text)
                    }){
                        Circle()
                            .fill(.white)
                            .frame(width: 50, height: 50)
                            .overlay{
                                Image(systemName: "paperplane")
                            }
                    }
                        
                }
                .padding()
                .background(Color.background)
                
            }
        }
        
    }
}

