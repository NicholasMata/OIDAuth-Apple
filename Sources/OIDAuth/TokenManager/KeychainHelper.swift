//
//  KeychainHelper.swift
//
//
//  Created by Nicholas Mata on 9/6/23.
//

import Foundation

class KeychainHelper {
    static func removeData(forService service: String, account: String) -> Bool {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }

    static func storeData(data: Data, forService service: String, account: String) -> Bool {
        _ = removeData(forService: service, account: account)
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: data,
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    static func retrieveData(service: String, account: String) -> Data? {
        let query: [CFString: Any] = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true,
        ]

        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)

        return (result as? Data)
    }
}
