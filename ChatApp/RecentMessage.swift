//
//  RecentMessage.swift
//  ChatApp
//
//  Created by Daichi Morihara on 2022/02/15.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift


struct RecentMessage: Identifiable, Codable {
    @DocumentID var id: String?
    
//    let documentId: String
    let text, email: String
    let fromId, toId: String
    let profileImageUrl: String
    let timestamp: Date
    
    var username: String {
        email.components(separatedBy: "@").first ?? email
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
//    var username: String {
//        email.components(separatedBy: "@").first ?? email
//    }
    
//    var username: String {
//        email.components(separatedBy: "@").first ?? email
//    }
    
//    init(documentId: String, data: [String : Any]) {
//        self.documentId = documentId
//        self.text = data["text"] as? String ?? ""
//        self.email = data["email"] as? String ?? ""
//        self.fromId = data["fromId"] as? String ?? ""
//        self.toId = data["toId"] as? String ?? ""
//        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
//        self.timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date: Date())
//    }
    
}
