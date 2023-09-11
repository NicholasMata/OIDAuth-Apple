//
//  AuthClient.swift
//
//
//  Created by Nicholas Mata on 9/6/23.
//

import AuthenticationServices
import Foundation

public class AuthClient: ObservableObject {
    public private(set) var clientID: String
    private var _configuration: OIDAuthConfiguration? = nil
    private var _wellKnownUrl: String?
    public var configuration: OIDAuthConfiguration {
        get async throws {
            if let configuration = _configuration {
                return configuration
            }
            guard let wellKnownUrl = _wellKnownUrl else {
                throw AuthClientError.missingConfiguration
            }
            return try await network.retrieveConfiguration(fromUrl: wellKnownUrl)
        }
    }

    private var stateGenerator: StateGenerator
    private var network: AuthClientNetwork
    private var tokenManager: TokenManager
    private var pkce: PKCE?

    public init(clientID: String,
                wellKnownUrl: String,
                tokenManager: TokenManager,
                network: AuthClientNetwork = DefaultAuthClientNetwork(),
                stateGenerator: StateGenerator = DefaultStateGenerator(),
                pkce: PKCE? = DefaultPKCE())
    {
        self.clientID = clientID
        _wellKnownUrl = wellKnownUrl
        _configuration = nil
        self.tokenManager = tokenManager
        self.network = network
        self.stateGenerator = stateGenerator
        self.pkce = pkce
    }

    public init(clientID: String,
                tokenManager: TokenManager,
                configuration: OIDAuthConfiguration,
                network: AuthClientNetwork = DefaultAuthClientNetwork(),
                stateGenerator: StateGenerator = DefaultStateGenerator(),
                pkce: PKCE? = DefaultPKCE())
    {
        self.clientID = clientID
        _configuration = configuration
        self.tokenManager = tokenManager
        self.network = network
        self.stateGenerator = stateGenerator
        self.pkce = pkce
    }

    private func buildWebAuthSession(type: OIDAuthClientLoginType = .authorizationCode,
                                     authorizeUrl: URL,
                                     redirectUrl: URL,
                                     state: String,
                                     scopes: [String] = ["openid"],
                                     codeChallenge: String?,
                                     codeChallengeMethod: String?,
                                     prefersEphemeralWebBrowserSession: Bool = false,
                                     completion: @escaping ASWebAuthenticationSession.CompletionHandler) throws -> ASWebAuthenticationSession
    {
        let components = URLComponents(string: authorizeUrl.absoluteString)
        guard var components = components else {
            throw AuthClientError.invalidAuthorizeUrl
        }
        var queryComponents = [
            "client_id": clientID,
            "response_type": type.rawValue,
            "redirect_uri": redirectUrl.absoluteString,
            "scope": scopes.joined(separator: " "),
            "state": state,
        ]
        if type == .authorizationCode,
           let codeChallenge = codeChallenge,
           let codeChallengeMethod = codeChallengeMethod
        {
            queryComponents["code_challenge"] = codeChallenge
            queryComponents["code_challenge_method"] = codeChallengeMethod
        }
        components.queryItems = queryComponents.map { URLQueryItem(name: $0, value: $1) }
        guard let authorizeUrl = components.url else {
            throw AuthClientError.failedToBuildAuthorizeUrl
        }
        let authSession = ASWebAuthenticationSession(
            url: authorizeUrl,
            callbackURLScheme: redirectUrl.scheme,
            completionHandler: completion
        )
        if #available(iOS 13.0, *) {
            authSession.prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession
        } else {
            // Fallback on earlier versions
        }
        return authSession
    }

    @MainActor
    @available(iOS 13.0, *)
    public func login(type: OIDAuthClientLoginType = .authorizationCode,
                      redirectURL: URL,
                      scopes: [String] = ["openid"],
                      on presentationContextProvider: ASWebAuthenticationPresentationContextProviding = WindowWebAuthenticationPresentationContext(),
                      prefersEphemeralWebBrowserSession: Bool = false) async throws
    {
        let codeVerifier = pkce?.createCodeVerifier()
        var codeChallenge: String? = nil
        if let codeVerifier = codeVerifier {
            codeChallenge = pkce?.codeChallenge(for: codeVerifier)
        }
        let configuration = try await configuration
        let state = stateGenerator.generate()
        let url: URL = try await withCheckedThrowingContinuation { continuation in
            do {
                let authSession = try buildWebAuthSession(type: type,
                                                          authorizeUrl: configuration.authorizeUrl,
                                                          redirectUrl: redirectURL,
                                                          state: state,
                                                          scopes: scopes,
                                                          codeChallenge: codeChallenge,
                                                          codeChallengeMethod: pkce?.challengeMethod,
                                                          prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession)
                { url, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let url = url {
                        continuation.resume(returning: url)
                    }
                }

                authSession.presentationContextProvider = presentationContextProvider
                authSession.start()
            } catch {
                continuation.resume(throwing: error)
            }
        }

        let error = url.queryValue(for: "error")
        let errorDescription = url.queryValue(for: "error_description")
        if let error = error {
            throw AuthClientError.authorizeFailed(error, errorDescription)
        }
        let serverState = url.queryValue(for: "state")
        guard serverState == state else {
            return
        }

        switch type {
        case .authorizationCode:
            guard let code = url.queryValue(for: "code") else {
                return
            }
            let response = try await network.retrieveToken(for: self, using: code, redirectingTo: redirectURL.absoluteString, withVerifier: codeVerifier)
            tokenManager.decode(from: response)
        }
    }

    public func acquireToken(skipStorage: Bool = false, scopes: [String]? = nil) async throws -> String {
        if let accessToken = tokenManager.accessToken, accessToken.isValid(), !skipStorage, scopes != nil {
            return accessToken.token
        }
        guard let refreshToken = tokenManager.refreshToken, refreshToken.isValid() else {
            throw AuthClientError.unableToAcquireToken
        }
        let response = try await network.refreshToken(for: self, with: refreshToken.token, scopes: scopes)
        tokenManager.decode(from: response)
        guard let accessToken = tokenManager.accessToken, accessToken.isValid() else {
            throw AuthClientError.unableToAcquireToken
        }
        return accessToken.token
    }

    public func endSession() {
        tokenManager.accessToken = nil
        tokenManager.refreshToken = nil
    }
}
