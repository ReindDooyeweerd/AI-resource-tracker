import Foundation
import Security
import Combine
import SQLite3

@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var organizationId: String?
    
    private let sessionKeyService = "com.ai-resource-tracker.sessionKey"
    private let orgIdKey = "organizationId"
    
    init() {
        checkAuthentication()
    }
    
    func checkAuthentication() {
        // Get org ID from .claude.json first
        if let orgId = readOrgIdFromClaudeConfig() {
            saveOrganizationId(orgId)
            print("✅ Got org ID: \(orgId)")
        }
        
        // Read OAuth token from Keychain
        if let token = readClaudeCodeCredentials() {
            saveSessionKey(token)
            print("✅ Got OAuth token from Keychain")
            isAuthenticated = true
            return
        }
        
        print("❌ No OAuth token found in Keychain")
        isAuthenticated = false
    }
    
    private func readClaudeCodeCredentials() -> String? {
        let username = NSUserName()
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "Claude Code-credentials",
            kSecAttrAccount as String: username,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess, let data = result as? Data {
            if let credential = String(data: data, encoding: .utf8),
               let jsonData = credential.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
               let claudeAiOauth = json["claudeAiOauth"] as? [String: Any],
               let accessToken = claudeAiOauth["accessToken"] as? String {
                return accessToken
            }
        }
        
        return nil
    }
    
    private func readOrgIdFromClaudeConfig() -> String? {
        guard let homeDir = ProcessInfo.processInfo.environment["HOME"] else {
            return nil
        }
        
        let configPath = "\(homeDir)/.claude.json"
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: configPath)),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let oauthAccount = json["oauthAccount"] as? [String: Any],
              let orgId = oauthAccount["organizationUuid"] as? String else {
            return nil
        }
        
        print("✅ Found organization ID in .claude.json: \(orgId)")
        return orgId
    }
    
    func getSessionKey() -> String? {
        return getFromKeychain(service: sessionKeyService)
    }
    
    func saveSessionKey(_ value: String) {
        saveToKeychain(service: sessionKeyService, value: value)
        isAuthenticated = true
    }
    
    func saveOrganizationId(_ value: String) {
        UserDefaults.standard.set(value, forKey: orgIdKey)
        organizationId = value
    }
    
    func signOut() {
        deleteFromKeychain(service: sessionKeyService)
        UserDefaults.standard.removeObject(forKey: orgIdKey)
        isAuthenticated = false
        organizationId = nil
    }
    
    // MARK: - Keychain Helpers
    
    private func saveToKeychain(service: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "claude-code",
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func getFromKeychain(service: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "claude-code",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let value = String(data: data, encoding: .utf8) {
            return value
        }
        
        return nil
    }
    
    private func deleteFromKeychain(service: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "claude-code"
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
