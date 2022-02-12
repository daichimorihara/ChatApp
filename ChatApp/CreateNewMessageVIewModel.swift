//
//  CreateNewMessageVIewModel.swift
//  ChatApp
//
//  Created by Daichi Morihara on 2022/02/12.
//

import Foundation

class CreateNewMessageViewModel: ObservableObject {
    @Published var users = [ChatUser]()
    @Published var message = ""
    
    init() {
        fetchAllUsers()
    }
    
    func fetchAllUsers() {
        FirebaseManager.shared.firestore.collection("users").getDocuments { documentsSnapshot, error in
            if let error = error {
                self.message = "Failed to fetch users: \(error)"
                print("Failed to fetch users: \(error)")
                return
            }
            documentsSnapshot?.documents.forEach { snapshot in
                let data = snapshot.data()
                let user = ChatUser(data: data)
                if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
                    self.users.append(user)
                }
            }
        }
    }
}
