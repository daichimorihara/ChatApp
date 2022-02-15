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
    
    private func fetchMessages() {
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
                        let data = change.document.data()
                        self.chatMessages.append(.init(docuemntId: change.document.documentID, data: data))
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
        
        let messageData = ["fromId": fromId, "toId": toId, "text": chatText, "timestamp": Timestamp()] as [String : Any]
        
        let document = FirebaseManager.shared.firestore.collection("messages").document(fromId).collection(toId).document()
        
        document.setData(messageData) { error in
            if let error = error {
                print(error)
                self.message = "Failed to save message into Firestore: \(error)"
                return
            }
            print("Successfully saved current user sending message")
        }
        
        let recipientDocument = FirebaseManager.shared.firestore.collection("messages").document(toId).collection(fromId).document()
        
        recipientDocument.setData(messageData) { error in
            if let error = error {
                print(error)
                self.message = "Failed to save message into Firestore: \(error)"
                return
            }
            print("Recipient saved data as well")
            
            self.persistRecentMessage()
            
            // self.chatText = ""
            self.count += 1
            
        }
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
        
        let data = ["fromId": uid,
                    "toId": toId,
                    "text": self.chatText,
                    "timestamp": Timestamp(),
                    "email": chatUser.email,
                    "profileImageUrl": chatUser.profileImageUrl
        ] as [String : Any]
        
        document.setData(data) { error in
            if let error = error {
                print("Failed to save recent message: \(error)")
                return
            }
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
                
                
                let recipientData = ["fromId": uid,
                                     "toId": toId,
                                     "text": self.chatText,
                                     "timestamp": Timestamp(),
                                     "email": currentUser.email ?? "",
                                     "profileImageUrl": dataDescription?["profileImageUrl"] ?? ""
                ] as [String : Any]
                
                FirebaseManager.shared.firestore
                    .collection("recent_messages")
                    .document(toId)
                    .collection("messages")
                    .document(uid)
                    .setData(recipientData) { error in
                        if let error = error {
                            print("Failed to save recipient recent message: \(error)")
                            return
                        }
                        print("Recipient get recent message too")
                    }

            }
        

        
        
    }
    
}
