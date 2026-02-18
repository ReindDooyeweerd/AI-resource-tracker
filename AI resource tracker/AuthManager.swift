import Foundation
import Security
import Combine

@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false

    init() {
        checkAuthentication()
    }

    func checkAuthentication() {
        let token = readAccessToken()
        isAuthenticated = token != nil
        print(isAuthenticated ? "✅ Got OAuth token from Claude Code CLI" : "❌ No Claude Code CLI token found in Keychain")
    }

    /// Always reads fresh from Keychain — never returns a stale cached token
    func getSessionKey() -> String? {
        return readAccessToken()
    }

    /// Attempt to refresh the OAuth token using the stored refresh token
    func refreshToken() async -> Bool {
        guard let credentials = readOAuthCredentials(),
              let refreshToken = credentials["refreshToken"] as? String else {
            print("⚠️ No refresh token available")
            return false
        }

        let clientId = credentials["clientId"] as? String ?? "cli"

        guard let url = URL(string: "https://api.anthropic.com/api/oauth/token") else { return false }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = "grant_type=refresh_token&refresh_token=\(refreshToken)&client_id=\(clientId)"
        request.httpBody = body.data(using: .utf8)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let newAccessToken = json["access_token"] as? String else {
                print("❌ Token refresh failed")
                return false
            }

            // Update the stored credentials in Keychain
            if var credentials = readOAuthCredentials() {
                credentials["accessToken"] = newAccessToken
                if let newRefresh = json["refresh_token"] as? String {
                    credentials["refreshToken"] = newRefresh
                }
                writeOAuthCredentials(credentials)
                print("✅ Token refreshed successfully")
                return true
            }
        } catch {
            print("⚠️ Token refresh error: \(error)")
        }

        return false
    }

    // MARK: - Keychain helpers

    private func readAccessToken() -> String? {
        guard let oauth = readOAuthCredentials(),
              let accessToken = oauth["accessToken"] as? String else {
            return nil
        }
        return accessToken
    }

    private func readOAuthCredentials() -> [String: Any]? {
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
           let claudeAiOauth = json["claudeAiOauth"] as? [String: Any] {
            return claudeAiOauth
        }

        return nil
    }

    private func writeOAuthCredentials(_ oauth: [String: Any]) {
        let username = NSUserName()

        // Read full credential JSON first
        let readQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "Claude Code-credentials",
            kSecAttrAccount as String: username,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(readQuery as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data,
              let credential = String(data: data, encoding: .utf8),
              let jsonData = credential.data(using: .utf8),
              var json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            return
        }

        json["claudeAiOauth"] = oauth

        guard let updatedData = try? JSONSerialization.data(withJSONObject: json),
              let updatedString = String(data: updatedData, encoding: .utf8),
              let writeData = updatedString.data(using: .utf8) else {
            return
        }

        let updateQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "Claude Code-credentials",
            kSecAttrAccount as String: username,
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: writeData,
        ]

        SecItemUpdate(updateQuery as CFDictionary, attributes as CFDictionary)
    }
}
