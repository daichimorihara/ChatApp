//
//  ChatMessage.swift
//  ChatApp
//
//  Created by Daichi Morihara on 2022/02/13.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct ChatMessage: Identifiable, Codable {
    
    @DocumentID var id: String?
    let fromId: String
    let toId: String
    let text: String
    let timestamp: Timestamp
    
//    init(docuemntId: String, data: [String : Any]) {
//        self.documentId = docuemntId
//        self.fromId = data["fromId"] as? String ?? ""
//        self.toId = data["toId"] as? String ?? ""
//        self.text = data["text"] as? String ?? ""
//    }
}
