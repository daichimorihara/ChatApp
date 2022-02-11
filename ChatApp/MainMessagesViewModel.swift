//
//  MainMessagesViewModel.swift
//  ChatApp
//
//  Created by Daichi Morihara on 2022/02/11.
//

import SwiftUI

class MainMessagesViewModel: ObservableObject {
    @Published var chatUser: ChatUser?
    @Published var errorMessage: String = ""
    @Published var isUserCurrentlyLoggedOut = false
    
    init() {
        fetchCurrentUser()
        
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser == nil
        }
        
    }
    
    // Mark - Intents
    
    func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Couldn't find firebase uid"
            return
        }
        
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                return
            }
            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found"
                return
            }
            
            self.chatUser = ChatUser(data: data)
            
        }
    }
    
    func hundleSignOut() {
        self.isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
    
}
