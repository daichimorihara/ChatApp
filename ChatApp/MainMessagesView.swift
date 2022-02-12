//
//  MainMessagesView.swift
//  ChatApp
//
//  Created by Daichi Morihara on 2022/02/11.
//

import SwiftUI
import SDWebImageSwiftUI

struct MainMessagesView: View {
    
    @State private var isShowingLogOut = false
    @StateObject var vm = MainMessagesViewModel()
    @State private var isShowingNewMessageScreen = false
    @State private var chatUser: ChatUser?
    @State private var isShowingChatLogView = false
    
    var body: some View {
        NavigationView {
            VStack {
                customNavigatioinBar
                mainBody
                NavigationLink("", isActive: $isShowingChatLogView) {
                    ChatLogView(chatUser: self.chatUser)
                }
                
            }
            .navigationBarHidden(true)
            .overlay(newMessageButton, alignment: .bottom)
            .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut) {
                LoginView(didCompleteLoginProcess: {
                    vm.isUserCurrentlyLoggedOut = false
                    vm.fetchCurrentUser()
                })
            }
        }
    }
    
    var customNavigatioinBar: some View {
        HStack(spacing: 16) {
            
            WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 45)
                            .stroke(.black, lineWidth: 1))
            
//            Image(systemName: "person.fill")
//                .font(.system(size: 40))
            
            VStack(alignment: .leading, spacing: 4) {

                Text(vm.chatUser?.username ?? "Unknown")
                    .font(.system(size: 16, weight: .bold))
                HStack {
                    Circle()
                        .fill()
                        .foregroundColor(.green)
                        .frame(width: 16, height: 16)
                    
                    Text("online")
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Button {
                isShowingLogOut.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal)
        .confirmationDialog(Text("Settings"), isPresented: $isShowingLogOut, titleVisibility: .visible) {
            Button("Sign Out") {
                vm.hundleSignOut()
            }
            
        }
    }
    
    
    var mainBody: some View {
        ScrollView {
            ForEach(1...20, id: \.self) { idx in
                NavigationLink(destination: Text("y")) {
                    VStack {
                        HStack {
                            Image(systemName: "person.fill")
                                .font(.system(size: 32))
                                .padding(8)
                                .overlay(RoundedRectangle(cornerRadius: 32)
                                            .stroke(lineWidth: 2)
                                            
                                
                                )
                            
                            VStack(alignment: .leading) {
                                Text("Username")
                                    .font(.system(size: 16, weight: .bold))
                                    
                                Text("Message sent to user")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("22d")
                        }
                        .padding(.horizontal)
                        Divider()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    var newMessageButton: some View {
        Button {
            isShowingNewMessageScreen.toggle()
        } label: {
            HStack {
                Spacer()
                Text("+ New Message")
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
            .background(.blue)
            .cornerRadius(32)
            .padding(.horizontal)
        }
        .fullScreenCover(isPresented: $isShowingNewMessageScreen) {
            CreateNewMessageView(didSelectNewUser: { user in
                self.chatUser = user
                isShowingChatLogView.toggle()
            })
        }
    }

}

//struct MainMessagesView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainMessagesView()
//    }
//}
