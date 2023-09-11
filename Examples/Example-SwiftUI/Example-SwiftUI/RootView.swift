//
//  Example-SwiftUI
//
//  Created by Nicholas Mata on 9/7/23.
//

import OIDAuth
import SwiftUI

private let wellKnownUrl: String = ".../.well-known/openid-configuration"
private let clientID: String = "INSERT CLIENT ID"
public let scopes: [String] = ["openid"]
public let redirectURL: URL = .init(string: "INSERT REDIRECT URL")!

struct RootView: View {
    @ObservedObject var tokenManager: KeychainTokenManager
    @ObservedObject var authClient: AuthClient

    init() {
        // account can be whatever you want used for keychain key name and UserDefaults key name
        let tokenManager = KeychainTokenManager(account: "app-name")
        self.tokenManager = tokenManager
        // If you want to provide configuration without wellknown endpoint.
//        let config = StaticAuthConfiguration(authorizeUrl: URL(string: ".../authorize")!,
//                                             tokenUrl: URL(string: ".../token")!)
        authClient = AuthClient(clientID: clientID,
                                wellKnownUrl: wellKnownUrl,
                                tokenManager: tokenManager)
    }

    var body: some View {
        if tokenManager.hasValidToken {
            ContentView()
                .environmentObject(tokenManager)
                .environmentObject(authClient)
        } else {
            SignInView()
                .environmentObject(tokenManager)
                .environmentObject(authClient)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
