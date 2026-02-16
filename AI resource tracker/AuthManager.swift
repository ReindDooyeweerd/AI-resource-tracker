import Foundation
import Security
import Combine

@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false

    private var cachedToken: String?

    init() {
        checkAuthentication()
    }

    func checkAuthentication() {
        cachedToken = readClaudeCodeCredentials()
        isAuthenticated = cachedToken != nil
        print(isAuthenticated ? "✅ Got OAuth token from Claude Code CLI" : "❌ No Claude Code CLI token found in Keychain")
    }

    func getSessionKey() -> String? {
        return cachedToken
    }

    private func readClaudeCodeCredentials() -> String? {
        let username = NSUserName()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "Claude Code-credentials",
            kSecAttrAccount as String: username,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess, let data = result as? Data,
           let credential = String(data: data, encoding: .utf8),
           let jsonData = credential.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
           let claudeAiOauth = json["claudeAiOauth"] as? [String: Any],
           let accessToken = claudeAiOauth["accessToken"] as? String {
            return accessToken
        }

        return nil
    }
}
