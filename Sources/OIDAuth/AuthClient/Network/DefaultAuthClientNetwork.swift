//
//  DefaultAuthClientNetwork.swift
//
//
//  Created by Nicholas Mata on 9/6/23.
//

import Foundation

public class DefaultAuthClientNetwork: AuthClientNetwork {
    private var session: URLSession
    public init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    public func retrieveToken(for authClient: AuthClient, using code: String, redirectingTo redirectUrl: String, withVerifier verifier: String?) async throws -> Data {
        let clientID = authClient.clientID
        let tokenUrl = try await authClient.configuration.tokenUrl
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded",
        ]

        var body = "grant_type=authorization_code&client_id=\(clientID)&code=\(code)&redirect_uri=\(redirectUrl)"
        if let verifier = verifier {
            body += "&code_verifier=\(verifier)"
        }
        let bodyData = body.data(using: String.Encoding.utf8)!
        var request = URLRequest(url: tokenUrl,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = bodyData as Data

        let (responseBody, response) = try await session.data(for: request)
        guard let httpResponse = (response as? HTTPURLResponse), 200 ... 299 ~= httpResponse.statusCode else {
            throw AuthClientError.badTokenResponse
        }
        return responseBody
    }

    public func refreshToken(for authClient: AuthClient, with refreshToken: String, scopes: [String]?) async throws -> Data {
        let tokenUrl = try await authClient.configuration.tokenUrl
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded",
        ]

        var body = "grant_type=refresh_token&refresh_token=\(refreshToken)"
        if let scopes = scopes?.joined(separator: " ") {
            body += "&scopes=\(scopes)"
        }
        let bodyData = body.data(using: String.Encoding.utf8)!
        var request = URLRequest(url: tokenUrl,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = bodyData as Data

        let (responseBody, response) = try await session.data(for: request)
        guard let httpResponse = (response as? HTTPURLResponse), 200 ... 299 ~= httpResponse.statusCode else {
            throw AuthClientError.badRefreshTokenResponse
        }
        return responseBody
    }
}
