//
//  CreateNewMessageView.swift
//  ChatApp
//
//  Created by Daichi Morihara on 2022/02/12.
//

import SwiftUI
import SDWebImageSwiftUI

struct CreateNewMessageView: View {
    let didSelectNewUser: (ChatUser) -> ()
    
    @Environment(\.dismiss) var dismiss
    @StateObject var vm = CreateNewMessageViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(vm.users) { user in
                    selectButton(user)
                    Divider()
                }
            }
            .navigationTitle("New Message")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }

    func selectButton(_ user: ChatUser) -> some View {
        Button {
            didSelectNewUser(user)
            dismiss()
        } label: {
            HStack(spacing: 16) {
                WebImage(url: URL(string: user.profileImageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipped()
                    .cornerRadius(50)
                    .overlay(RoundedRectangle(cornerRadius: 50)
                                .stroke(.black, lineWidth: 1))
                Text(user.username)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

//struct CreateNewMessageView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateNewMessageView()
//    }
//}
