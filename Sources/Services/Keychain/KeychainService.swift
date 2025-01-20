//
//  File.swift
//  
//
//  Created by Marcos Vinicius Majeveski De Angeli on 20/01/25.
//

import Foundation

struct KeychainService {
    static func storeKeyValue(keychainKey: String, apiKey: String) -> Bool {

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keychainKey,
            kSecValueData: apiKey
        ]

        // Remove existing item if it exists
        if retrieveKeyValue(at: keychainKey) != nil {
            print("updating API key...")
            deleteKeyValue(for: keychainKey)
        }

        // Add new item
        let addStatus = SecItemAdd(query as CFDictionary, nil)
        return addStatus == errSecSuccess
    }

    static func retrieveKeyValue(at keychainKey: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keychainKey,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecSuccess, let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    @discardableResult
    static func deleteKeyValue(for keychainKey: String) -> Bool {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keychainKey
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}
