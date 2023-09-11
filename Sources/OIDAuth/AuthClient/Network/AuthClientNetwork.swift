//
//  AuthClientNetwork.swift
//
//
//  Created by Nicholas Mata on 9/6/23.
//

import Foundation

public protocol AuthClientNetwork {
    func retrieveToken(for authClient: AuthClient, using code: String, redirectingTo redirectUrl: String, withVerifier verifier: String?) async throws -> Data
    func refreshToken(for authClient: AuthClient, with refreshToken: String, scopes: [String]?) async throws -> Data
    func retrieveConfiguration(fromUrl: String) async throws -> OIDAuthConfiguration
}

public extension AuthClientNetwork {
    func retrieveConfiguration(fromUrl: String) async throws -> OIDAuthConfiguration {
        guard let url = URL(string: fromUrl) else {
            throw AuthClientError.invalidWellKnownUrl
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = (response as? HTTPURLResponse), 200 ... 299 ~= httpResponse.statusCode else {
            throw AuthClientError.badWellKnownResponse
        }
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let configuration = try decoder.decode(WellKnownAuthConfiguration.self, from: data)
            return configuration
        } catch {
            throw AuthClientError.failedToDecodeWellKnown(error)
        }
    }
}
