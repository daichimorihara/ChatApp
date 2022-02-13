//
//  ChatLogViewModel.swift
//  ChatApp
//
//  Created by Daichi Morihara on 2022/02/12.
//

import Foundation
import Firebase

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
            self.chatText = ""
            self.count += 1
        }
        
        let recipientDocument = FirebaseManager.shared.firestore.collection("messages").document(toId).collection(fromId).document()
        
        recipientDocument.setData(messageData) { error in
            if let error = error {
                print(error)
                self.message = "Failed to save message into Firestore: \(error)"
                return
            }
            print("Recipient saved data as well")
        }
    }
    
}
