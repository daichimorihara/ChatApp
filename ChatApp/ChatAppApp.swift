//
//  ChatAppApp.swift
//  ChatApp
//
//  Created by Daichi Morihara on 2022/02/08.
//

import SwiftUI

@main
struct ChatAppApp: App {
    @StateObject var vm = MainMessagesViewModel()
    var body: some Scene {
        WindowGroup {
            MainMessagesView(vm: vm)
        }
    }
}
