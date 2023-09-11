//
//  Example_SwiftUIApp.swift
//  Example-SwiftUI
//
//  Created by Nicholas Mata on 8/21/23.
//

import OIDAuth
import SwiftUI

@main
enum Example_SwiftUIAppWrapper {
    static func main() {
        if #available(iOS 14.0, *) {
            Example_SwiftUIApp.main()
        } else {
            UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(SceneDelegate.self))
        }
    }
}

@available(iOS 14.0, *)
struct Example_SwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
