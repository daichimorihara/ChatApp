//
//  ChatLogView.swift
//  ChatApp
//
//  Created by Daichi Morihara on 2022/02/12.
//

import SwiftUI

struct ChatLogView: View {
    let chatUser: ChatUser?
    @State private var chatText =  ""
    
    var body: some View {
        ZStack {
            messagesView
            VStack {
                Spacer()
                chatBottonBar
                    .background(.white)
            }
            
        }
        .navigationTitle(chatUser?.username ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var messagesView: some View {
        ScrollView {
            ForEach(0...20, id: \.self) { idx in
                HStack {
                    Spacer()
                    Text("Fake Message")
                        .foregroundColor(.white)
                        .padding()
                        .background(.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 6)
            }
        }
        .background(Color(.init(white: 0.9, alpha: 1)))
//        .padding(.vertical)
    }
    
    var chatBottonBar: some View {
        HStack {
            Image(systemName: "photo.on.rectangle")
            ZStack {
                DescriptionPlaceholder()
                TextEditor(text: $chatText).opacity(chatText.isEmpty ? 0.2 : 1)
            }
            .frame(height: 40)
            Button {
                
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.blue)
            .cornerRadius(3)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Description")
                .foregroundColor(.gray)
                .padding(.leading, 5)
            Spacer()
        }
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        ChatLogView(chatUser: nil)
    }
}
