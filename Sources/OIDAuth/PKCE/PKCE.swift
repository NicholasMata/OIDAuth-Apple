//
//  PKCE.swift
//
//
//  Created by Nicholas Mata on 9/7/23.
//

import AuthenticationServices
import CommonCrypto
import Foundation

public protocol PKCE {
    var challengeMethod: String { get }
    func createCodeVerifier() -> String
    func codeChallenge(for verifier: String) -> String
}

public class DefaultPKCE: PKCE {
    public var challengeMethod: String {
        return "S256"
    }

    public init() {}

    public func createCodeVerifier() -> String {
        var buffer = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
        return Data(buffer)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
    }

    public func codeChallenge(for verifier: String) -> String {
        // Dependency: Apple Common Crypto library
        // http://opensource.apple.com//source/CommonCrypto
        guard let data = verifier.data(using: .utf8) else { fatalError() }
        var buffer = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &buffer)
        }
        let hash = Data(buffer)
        return hash.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
    }
}
