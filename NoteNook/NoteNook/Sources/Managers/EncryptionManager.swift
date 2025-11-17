//
//  EncryptionManager.swift
//  NoteNook
//
//  Handles encryption and decryption of notes using AES-256-GCM.
//  Provides secure local storage with device-specific encryption keys.
//  Swift 6 compatible with full concurrency support and macOS 16 Tahoe APIs.
//

import Foundation
import CryptoKit
import Security
import OSLog

actor EncryptionManager {
    
    // MARK: - Singleton
    
    static let shared = EncryptionManager()
    
    // MARK: - Properties
    
    private let keychainService = "com.notenook.NoteNook"
    private let keychainAccount = "encryption-key-v2-tahoe"
    private let logger = Logger(subsystem: "com.notenook.NoteNook", category: "Encryption")
    
    // MARK: - Initialization
    
    private init() {
        Task {
            // Ensure encryption key exists
            if await getEncryptionKey() == nil {
                _ = await generateAndStoreEncryptionKey()
            } else {
                logger.info("✅ Encryption key loaded from secure keychain (macOS 16 Tahoe)")
            }
        }
    }
    
    // MARK: - Encryption/Decryption
    
    /// Encrypts data using AES-256-GCM with authentication
    /// - Parameter data: Plain data to encrypt
    /// - Returns: Encrypted data including nonce and tag, or nil if encryption fails
    func encrypt(_ data: Data) async -> Data? {
        guard let key = await getEncryptionKey() else {
            logger.error("❌ Encryption failed: No encryption key available")
            return nil
        }
        
        do {
            let symmetricKey = SymmetricKey(data: key)
            let sealedBox = try AES.GCM.seal(data, using: symmetricKey)
            
            // Combine nonce + ciphertext + tag into single data blob
            guard let combined = sealedBox.combined else {
                logger.error("❌ Encryption failed: Could not combine sealed box")
                return nil
            }
            
            logger.debug("✅ Data encrypted successfully (\(data.count) bytes -> \(combined.count) bytes)")
            return combined
        } catch {
            logger.error("❌ Encryption error: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Decrypts data encrypted with AES-256-GCM
    /// - Parameter data: Encrypted data including nonce and tag
    /// - Returns: Decrypted plain data, or nil if decryption fails
    func decrypt(_ data: Data) async -> Data? {
        guard let key = await getEncryptionKey() else {
            logger.error("❌ Decryption failed: No encryption key available")
            return nil
        }
        
        do {
            let symmetricKey = SymmetricKey(data: key)
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
            
            logger.debug("✅ Data decrypted successfully (\(data.count) bytes -> \(decryptedData.count) bytes)")
            return decryptedData
        } catch {
            logger.error("❌ Decryption error: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Key Management
    
    /// Generates a new 256-bit encryption key and stores it securely in Keychain
    /// - Returns: The generated key, or nil if storage fails
    private func generateAndStoreEncryptionKey() async -> Data? {
        // Generate a 256-bit (32-byte) random key using CryptoKit
        let key = SymmetricKey(size: .bits256)
        let keyData = key.withUnsafeBytes { Data($0) }
        
        // Store in Keychain with maximum security for macOS 16 Tahoe
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecAttrSynchronizable as String: false, // Never sync to iCloud
            kSecUseDataProtectionKeychain as String: true
        ]
        
        // Delete any existing key first
        SecItemDelete(query as CFDictionary)
        
        // Add new key
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            logger.info("✅ AES-256 encryption key generated and stored securely in device keychain (macOS 16 Tahoe)")
            return keyData
        } else {
            logger.error("❌ Failed to store encryption key: \(status)")
            return nil
        }
    }
    
    /// Retrieves the encryption key from Keychain
    /// - Returns: The encryption key, or nil if not found
    private func getEncryptionKey() async -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecUseDataProtectionKeychain as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess, let keyData = result as? Data {
            return keyData
        } else if status != errSecItemNotFound {
            logger.warning("⚠️ Keychain access error: \(status)")
        }
        
        return nil
    }
    
    /// Deletes the encryption key from Keychain (use with extreme caution!)
    /// This will make all encrypted data permanently unrecoverable
    func deleteEncryptionKey() async {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess {
            logger.warning("⚠️ Encryption key deleted - all encrypted data is now permanently unrecoverable")
        }
    }
    
    // MARK: - Verification
    
    /// Tests encryption and decryption to verify system is working
    /// - Returns: True if encryption/decryption works correctly
    func verifyEncryption() async -> Bool {
        let testData = "NoteNook encryption test - Swift 6 + macOS 16 Tahoe 🔒".data(using: .utf8)!
        
        guard let encrypted = await encrypt(testData) else {
            logger.error("❌ Encryption verification failed: encrypt returned nil")
            return false
        }
        
        guard let decrypted = await decrypt(encrypted) else {
            logger.error("❌ Encryption verification failed: decrypt returned nil")
            return false
        }
        
        let success = testData == decrypted
        if success {
            logger.info("✅ AES-256-GCM encryption verification passed on macOS 16 Tahoe")
        } else {
            logger.error("❌ Encryption verification failed: data mismatch")
        }
        
        return success
    }
}
