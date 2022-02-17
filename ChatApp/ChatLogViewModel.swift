//
//  ChatLogViewModel.swift
//  ChatApp
//
//  Created by Daichi Morihara on 2022/02/12.
//

import Foundation
import Firebase
import simd

class ChatLogViewModel: ObservableObject {
    @Published var chatText = ""
    @Published var message = ""
    @Published var chatMessages = [ChatMessage]()
    @Published var count = 1
    
    let chatUser: ChatUser?
    
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        
        fetchMessages()
    }
    
    func fetchMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        
        FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Failed to fetch snapshot")
                    return
                }
                snapshot.documentChanges.forEach { change in
                    if change.type == .added {
                        do {
                            if let newMessage = try change.document.data(as: ChatMessage.self) {
                                self.chatMessages.append(newMessage)
                            }
                        } catch {
                            print(error)
                        }
                 
                    }
                }
                DispatchQueue.main.async {
                    self.count += 1
                }
            }

        
    }
    
    
    // Mark - Intents
    func handleSend() {
        if self.chatText.isEmpty {
            return
        }
        print(chatText)
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }

        let document = FirebaseManager.shared.firestore.collection("messages").document(fromId).collection(toId).document()
        
        let msgData = ChatMessage(id: document.documentID, fromId: fromId, toId: toId, text: chatText, timestamp: Timestamp())
        
        do {
            try document.setData(from: msgData)
        } catch {
            print(error)
        }

        let recipientDocument = FirebaseManager.shared.firestore.collection("messages").document(toId).collection(fromId).document()
        
        let recipientData = ChatMessage(id: recipientDocument.documentID, fromId: fromId, toId: toId, text: chatText, timestamp: Timestamp())
        
        do {
            try recipientDocument.setData(from: recipientData)
        } catch {
            print(error)
        }
        self.persistRecentMessage()
        self.count += 1
    }
    
    func persistRecentMessage() {
        guard let chatUser = chatUser else { return }
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = self.chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .document(toId)

        
        let recentMessage = RecentMessage(id: document.documentID, text: self.chatText, email: chatUser.email, fromId: uid, toId: toId, profileImageUrl: chatUser.profileImageUrl, timestamp: Date())
        
        do {
            try document.setData(from: recentMessage)
            
        } catch {
            print(error)
        }
        guard let currentUser = FirebaseManager.shared.auth.currentUser else { return }
        
        FirebaseManager.shared.firestore
            .collection("users")
            .document(currentUser.uid)
            .getDocument() { querySnapshot, error in
                if let error = error {
                    print("failed to fetch current user's data: \(error)")
                    return
                }
                let dataDescription = querySnapshot?.data()

                let passiveDocument = FirebaseManager.shared.firestore
                        .collection("recent_messages")
                        .document(toId)
                        .collection("messages")
                        .document(uid)
                
                let passiveRecentMessage = RecentMessage(id: passiveDocument.documentID, text: self.chatText, email: currentUser.email ?? "", fromId: uid, toId: toId, profileImageUrl: dataDescription?["profileImageUrl"] as! String, timestamp: Date())
                
                do {
                    try passiveDocument.setData(from: passiveRecentMessage)
                } catch {
                    print(error)
                }

            }
    }
    
}
