import AuthenticationServices
import Foundation

public enum OIDAuthClientLoginType: String {
    case authorizationCode = "code"
}

public class WindowWebAuthenticationPresentationContext: NSObject, ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}

public enum AuthClientError: Error {
    case invalidAuthorizeUrl
    case invalidWellKnownUrl
    case failedToDecodeWellKnown(Error)
    case badWellKnownResponse
    case failedToBuildAuthorizeUrl
    case authorizeFailed(String, String?)
    case stateMismatch
    case badTokenResponse
    case badRefreshTokenResponse
    case missingConfiguration
    case unableToAcquireToken
}

public class OIDTokenResponse: Codable {
    public var accessToken: String
    public var tokenType: String
    public var expiresIn: Int
    public var refreshToken: String?
    public var refreshTokenExpiresIn: Int?
    public var idToken: String?
}

extension URL {
    func queryValue(for key: String) -> String? {
        let components = URLComponents(string: absoluteString)
        return components?.queryItems?.first { $0.name == key }?.value
    }
}

public protocol OIDAuthConfiguration {
    var authorizeUrl: URL { get }
    var tokenUrl: URL { get }
}

public struct StaticAuthConfiguration: OIDAuthConfiguration {
    public var authorizeUrl: URL
    public var tokenUrl: URL

    public init(authorizeUrl: URL, tokenUrl: URL) {
        self.authorizeUrl = authorizeUrl
        self.tokenUrl = tokenUrl
    }
}

public struct WellKnownAuthConfiguration: OIDAuthConfiguration, Decodable {
    public var authorizeUrl: URL
    public var tokenUrl: URL

    enum CodingKeys: String, CodingKey {
        case authorizeUrl = "authorizationEndpoint", tokenUrl = "tokenEndpoint"
    }
}
