//
//  ContentView.swift
//  Example-SwiftUI
//
//  Created by Nicholas Mata on 8/21/23.
//

import OIDAuth
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
          Button {
            let config = StaticAuthConfiguration(authorizeUrl: URL(string: "https://authorization-server.com/authorize")!,
                                                 tokenUrl: URL(string: "https://authorization-server.com/token")!,
                                                 endSessionUrl: URL(string: "https://authorization-server.com/authorize")!)
            AuthClient(clientId: "XboI9iUIUNWBGjXm6mmWg8AZ", configuration: config)
          } label: {
            Text("Sign in")
          }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
