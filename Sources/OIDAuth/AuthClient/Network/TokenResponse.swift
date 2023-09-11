//
//  TokenResponse.swift
//
//
//  Created by Nicholas Mata on 9/6/23.
//

import Foundation

public protocol TokenResponse {
    var accessToken: String { get }
    var tokenType: String { get }
    var expiresIn: Int { get }
    var refreshToken: String? { get }
    var refreshTokenExpiresIn: Int? { get }
}
