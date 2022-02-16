//
//  ChatUser.swift
//  ChatApp
//
//  Created by Daichi Morihara on 2022/02/11.
//

import Foundation


struct ChatUser: Identifiable {
    var id: String { uid }

    let uid: String
    let email: String
    let profileImageUrl: String

    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? "Email N/A"
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
    }

    var username: String {
        email.components(separatedBy: "@").first ?? email
    }
    
}
