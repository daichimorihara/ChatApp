//
//  ContentView.swift
//  ChatApp
//
//  Created by Daichi Morihara on 2022/02/08.
//

import SwiftUI


struct LoginView: View {
    
    let didCompleteLoginProcess: () -> ()
    
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
                    loginPicker
                    
                    if !isLoginMode { iconButton }
                    
                    
                    loginInput
                    
                    HStack {
                        Spacer()
                        loginButton
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
    
    var loginPicker: some View {
        Picker("Picker", selection: $isLoginMode) {
            Text("Log In")
                .tag(true)
            Text("Create Account")
                .tag(false)
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    var iconButton: some View {
        Button {
            isShowingImagePicker.toggle()
        } label: {
            
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 128, height: 128)
                    .clipped()
                    .cornerRadius(64)
            } else {
                Image(systemName: "person.fill")
                    .foregroundColor(.black)
                    .font(.system(size: 64))
                    .padding()
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 64)
                    .stroke(.black ,lineWidth: 3)
        )
    }
    
    var loginInput: some View {
        Group {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                //.textInputAutocapitalization(nil)
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
        }
        .padding()
        .background(.white)
    }
    
    var loginButton: some View {
        Button {
            handleAction()
        } label: {
            Text(isLoginMode ? "Log In" : "Create Account")
                .foregroundColor(.white)
                .padding()
                .font(.system(size: 14, weight: .bold))
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
            self.didCompleteLoginProcess()
        }
    }
    
    private func createNewAccount() {
        if self.image == nil {
            self.message = "You must select an image"
            return
        }
        
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
                
                guard let url = url else { return }
                self.storeUserInformation(imageProfileUrl: url)
                
            }
        }
    }
    
    private func storeUserInformation(imageProfileUrl: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = ["email": self.email, "uid": uid, "profileImageUrl": imageProfileUrl.absoluteString]
        FirebaseManager.shared.firestore.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                print(error)
                self.message = "\(error)"
                return
            }
            print("Success")
            self.didCompleteLoginProcess()
        }
    }
    
 }

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//    }
//}
