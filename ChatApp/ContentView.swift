//
//  ContentView.swift
//  ChatApp
//
//  Created by Daichi Morihara on 2022/02/08.
//

import SwiftUI


struct ContentView: View {
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var message = ""
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Picker("Picker", selection: $isLoginMode) {
                        Text("Log In")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if !isLoginMode {
                        Button {
                            
                        } label: {
                            Image(systemName: "person.fill")
                                .font(.system(size: 64))
                                .padding()
                        }
                    }
                    
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            //.textInputAutocapitalization(nil)
                            .autocapitalization(.none)
                        
                        SecureField("Password", text: $password)
                    }
                    .padding()
                    .background(.white)
                    
                    HStack {
                        Spacer()
                        Button {
                            handleAction()
                        } label: {
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .foregroundColor(.white)
                                .padding()
                                .font(.system(size: 14, weight: .bold))
                        }
                        Spacer()
                    }
                    .background(.blue)
                    
                    Text(message)
                        .foregroundColor(.red)
                }
                .padding()
            }
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .background(Color.gray.opacity(0.15))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func handleAction() {
        if isLoginMode {
            loginUser()
        } else {
            createNewAccount()
        }
    }
    
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Failed to login user:", error)
                self.message = "Failed to login user: \(error)"
                return
            }
            print("Successfully logged in as user: \(result?.user.uid ?? "")")
            self.message = "Successfully logged in as user: \(result?.user.uid ?? "")"
        }
    }
    
    private func createNewAccount() {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Failed to create user: ", error)
                self.message = "Failed to create user: \(error)"
                return
            }
            
            print("Successfully created user: \(result?.user.uid ?? "")")
            self.message = "Successfully created user: \(result?.user.uid ?? "")"
        }
    }
 }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
