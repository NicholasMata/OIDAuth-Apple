//
//  ContentView.swift
//  Example-SwiftUI
//
//  Created by Nicholas Mata on 9/7/23.
//

import OIDAuth
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authClient: AuthClient
    @EnvironmentObject var tokenManager: KeychainTokenManager

    var body: some View {
        VStack(spacing: 20) {
            Button {
                Task.detached {
                    try await authClient.acquireToken(skipStorage: true, scopes: scopes)
                }
            } label: {
                Text("Refresh")
            }
            if let idToken = tokenManager.idToken {
                VStack(alignment: .leading, spacing: 2) {
                    Text("ID Token").bold()
                    Text(idToken).lineLimit(2).contextMenu(ContextMenu(menuItems: {
                        Button("Copy", action: {
                            UIPasteboard.general.string = idToken
                        })
                    }))
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            if let accessToken = tokenManager.accessToken {
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Access Token").bold()
                        Text(accessToken.token).lineLimit(2).contextMenu(ContextMenu(menuItems: {
                            Button("Copy", action: {
                                UIPasteboard.general.string = accessToken.token
                            })
                        }))
                    }.frame(maxWidth: .infinity, alignment: .leading)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Retrieved On").bold()
                        Text("\(accessToken.retrievedOn)")
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            Button {
                withAnimation {
                    authClient.endSession()
                }
            } label: {
                Text("Sign Out")
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
