import AuthenticationServices
import Foundation

public enum OIDAuthStorageInfo {
  case accessToken
  case idToken
  case expiration
}

public enum OIDAuthStorageStoreValue {
  case accessToken(String)
  case idToken(String)
  case expiration(Int)
}

/**
    Storage to be used by OIDAuthClient.
    When various information like access_token, id_token, etc need to be persisted.
*/
public protocol OIDAuthStorage {
  func store(value: OIDAuthStorageStoreValue)
  func retrieve(info: OIDAuthStorageInfo) -> OIDAuthStorageStoreValue
}

// public class OIDAuthKeychainStorage: OIDAuthStorage {}

public enum OIDAuthClientLoginType: String {
  case implicit = "token"
  case implicitIdToken = "id_token"
  case authorizationCode = "code"
}

/**
    An Open ID OAuth 2.0 Client which can be used to performs actions against Authentication Server
    such as logging in, getting user information, logging out, etc.
*/
// public protocol OIDAuthClient {
//  func login(type: OIDAuthClientLoginType,
//             redirectURL: URL,
//             scopes: [String],
//             on presentationContextProvider: ASWebAuthenticationPresentationContextProviding,
//             prefersEphemeralWebBrowserSession: Bool) -> ASWebAuthenticationSession
//
////  func authorize()
////  func token()
//
//  func endSession()
// }

public protocol OIDAuthStateGenerator {
  func generate() -> String
}

public class DefaultAuthStateGenerator: OIDAuthStateGenerator {
  public init() {}
  
  public func generate() -> String {
    return NSUUID().uuidString
  }
}

public class WindowWebAuthenticationPresentationContext: NSObject, ASWebAuthenticationPresentationContextProviding {
  public func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
    return ASPresentationAnchor()
  }
}

public enum AuthClientError: Error {
  case invalidAuthorizeUrl
  case failedToBuildAuthorizeUrl
}

public class AuthClient {
  private var clientID: String
  private var configuration: OIDAuthConfiguration
  private var stateGenerator: OIDAuthStateGenerator

  public init(clientID: String, configuration: OIDAuthConfiguration, stateGenerator: OIDAuthStateGenerator = DefaultAuthStateGenerator()) {
    self.clientID = clientID
    self.configuration = configuration
    self.stateGenerator = stateGenerator
  }

  private func buildWebAuthSession(type: OIDAuthClientLoginType = .authorizationCode,
                                   redirectURL: URL,
                                   scopes: [String] = ["openid"],
                                   prefersEphemeralWebBrowserSession: Bool = false) throws -> ASWebAuthenticationSession
  {
    let components = URLComponents(string: configuration.authorizeUrl.absoluteString)
    guard var components = components else {
      throw AuthClientError.invalidAuthorizeUrl
    }
    components.queryItems = [
      "client_id": clientID,
      "response_type": type.rawValue,
      "redirect_uri": redirectURL.absoluteString,
      "scope": scopes.joined(separator: " "),
      "state": stateGenerator.generate(),
    ].map { URLQueryItem(name: $0, value: $1) }
    guard let authorizeUrl = components.url else {
      throw AuthClientError.failedToBuildAuthorizeUrl
    }
    let authSession = ASWebAuthenticationSession(
      url: authorizeUrl,
      callbackURLScheme: redirectURL.scheme
    ) { url, error in
        if let error = error {
          print(error)
//                        completion(.failure(error))
        } else if let url = url {
          print(url)
//                        completion(.success(url))
        }
    }

    if #available(iOS 13.0, *) {
      authSession.prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession
    } else {
      // Fallback on earlier versions
    }
    return authSession
  }

  @available(iOS 13.0, *)
  public func login(type: OIDAuthClientLoginType = .authorizationCode,
                    redirectURL: URL,
                    scopes: [String] = ["openid"],
                    on presentationContextProvider: ASWebAuthenticationPresentationContextProviding = WindowWebAuthenticationPresentationContext(),
                    prefersEphemeralWebBrowserSession: Bool = false) throws -> ASWebAuthenticationSession
  {
    let authSession = try buildWebAuthSession(type: type, redirectURL: redirectURL, scopes: scopes, prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession)
    authSession.presentationContextProvider = presentationContextProvider
    authSession.start()
    return authSession
  }

  public func endSession() {}
}

/**
    Configuration to be used by OIDAuthClient.
    This can be automatically loaded via OpenID well-known endpoint most commonly located at
    `{baseAuthServerUrl}/.well-known/openid-configuration`
*/
public protocol OIDAuthConfiguration {
  var authorizeUrl: URL { get }
  var tokenUrl: URL { get }
  var endSessionUrl: URL { get }
}

public struct StaticAuthConfiguration: OIDAuthConfiguration {
  public var authorizeUrl: URL
  public var tokenUrl: URL
  public var endSessionUrl: URL

  public init(authorizeUrl: URL, tokenUrl: URL, endSessionUrl: URL) {
    self.authorizeUrl = authorizeUrl
    self.tokenUrl = tokenUrl
    self.endSessionUrl = endSessionUrl
  }
}
