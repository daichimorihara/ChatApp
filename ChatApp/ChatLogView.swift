//
//  ChatLogView.swift
//  ChatApp
//
//  Created by Daichi Morihara on 2022/02/12.
//

import SwiftUI

struct ChatLogView: View {
    
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        self.vm = .init(chatUser: chatUser)
    }
    
    @ObservedObject var vm: ChatLogViewModel
    
    
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
    
    static var bottomId = "bottom"
    
    var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ForEach(vm.chatMessages) { message in
                    MessageView(message: message)
                }
                HStack { Spacer() }
                .frame(height: 50)
                .id(Self.bottomId)
            }
            .background(Color(.init(white: 0.9, alpha: 1)))
            .onReceive(vm.$count) { _ in
                withAnimation(.linear(duration: 0.4)) {
                    proxy.scrollTo(Self.bottomId, anchor: .bottom)
                }
            }
        }
//        .padding(.vertical)
    }
    
    var chatBottonBar: some View {
        HStack {
            Image(systemName: "photo.on.rectangle")
            ZStack {
                DescriptionPlaceholder()
                TextEditor(text: $vm.chatText).opacity(vm.chatText.isEmpty ? 0.2 : 1)
            }
            .frame(height: 40)
            Button {
                vm.handleSend()
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

struct MessageView: View {
    let message: ChatMessage
    
    var body: some View {
        if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
            HStack {
                Spacer()
                Text(message.text)
                    .foregroundColor(.white)
                    .padding()
                    .background(.blue)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.top, 6)
        } else {
            HStack {
                Text(message.text)
                    .foregroundColor(.black)
                    .padding()
                    .background(.white)
                    .cornerRadius(8)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 6)
        }
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
