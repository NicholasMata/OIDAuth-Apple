//
//  SignInView.swift
//  Example-SwiftUI
//
//  Created by Nicholas Mata on 8/21/23.
//

import OIDAuth
import SwiftUI

struct SignInView: View {
    @EnvironmentObject var client: AuthClient
    @State var signInError: Error? = nil

    var body: some View {
        VStack {
            Button {
                Task {
                    do {
                        try await client.login(redirectURL: redirectURL,
                                               scopes: scopes,
                                               prefersEphemeralWebBrowserSession: true)
                    } catch {
                        signInError = error
                    }
                }
            } label: {
                Text("Sign in")
            }

            if let signInError = signInError {
                Text(signInError.localizedDescription).foregroundColor(Color.red)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
