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
                .frame(width: 58, height: 58)
                .clipped()
                .cornerRadius(58)
                .overlay(RoundedRectangle(cornerRadius: 58).stroke(.black, lineWidth: 1))
            
//            Image(systemName: "person.fill")
//                .font(.system(size: 40))
            
            VStack(alignment: .leading, spacing: 4) {

                Text(vm.chatUser?.username ?? "Unknown")
                    .font(.system(size: 18, weight: .bold))
                HStack {
                    Circle()
                        .fill()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    
                    Text("online")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
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
            ForEach(vm.recentMessages) { recentMessage in
                NavigationLink(destination: Text("y")) {
                    VStack {
                        HStack(spacing: 12) {
                            WebImage(url: URL(string: recentMessage.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 58, height: 58)
                                .clipped()
                                .cornerRadius(58)
                                .overlay(RoundedRectangle(cornerRadius: 58).stroke(.black, lineWidth: 1))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(recentMessage.username)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.primary)
                                    
                                Text(recentMessage.text)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
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
