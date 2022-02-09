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
    @State private var isShowingImagePicker = false
    @State private var image: UIImage?
    
    
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
                            isShowingImagePicker.toggle()
                        } label: {
                            
                            if let image = image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 128, height: 128)
                                    .cornerRadius(64)
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 64))
                                    .padding()
                            }
                        }
                        .overlay(RoundedRectangle(cornerRadius: 64)
                                    .stroke(.black ,lineWidth: 3)
                        )
                        
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
        .fullScreenCover(isPresented: $isShowingImagePicker) {
            ImagePicker(image: $image)
                .ignoresSafeArea()
        }
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
                print("Failed to login user: \(error)")
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
                print("Failed to create user: \(error)")
                self.message = "Failed to create user: \(error)"
                return
            }
            
            print("Successfully created user: \(result?.user.uid ?? "")")
            self.message = "Successfully created user: \(result?.user.uid ?? "")"
            self.persistImageToStorage()
        }
    }
    
    private func persistImageToStorage() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                self.message = "Failed to push image to Storage: \(error)"
                return
            }
            
            ref.downloadURL { url, error in
                if let error = error {
                    self.message = "Failed to retrieve downloadURL: \(error)"
                    return
                }
                
                self.message = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                print(url?.absoluteString)
                
            }
            
        }
        
    }
    
 }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
