//
//  TokenManager.swift
//
//
//  Created by Nicholas Mata on 9/6/23.
//

import Foundation

public protocol TokenManager {
    /// The access token used for making API calls
    var accessToken: Token? { get set }
    var refreshToken: Token? { get set }
    var idToken: String? { get set }
    var hasValidToken: Bool { get }

    func decode(from response: Data)
}

public struct Token {
    /// The number of seconds to pad expiresOn
    static let expirationPadding: Double = 60

    /// The token value
    public var token: String
    /// The number of seconds from retrieval to expiration
    public var expiresIn: Int
    /// The date and time the token was retrieved.
    public var retrievedOn: Date
    /// The date and time the token will expire
    public var expiresOn: Date {
        return retrievedOn.addingTimeInterval(Double(expiresIn))
    }

    /// Whether the token is valid.
    public func isValid() -> Bool {
        return Date() <= expiresOn.addingTimeInterval(-Token.expirationPadding)
    }
}
