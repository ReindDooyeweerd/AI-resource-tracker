import Foundation

final class ClaudeCodeProvider: UsageProvider {
    let id = "claude-code"
    let name = "Claude Code"
    let refreshInterval: TimeInterval = 30

    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    func fetchUsage() async -> UsageData? {
        return await fetchFromAPI()
    }

    private func fetchFromAPI() async -> UsageData? {
        return await doFetch(isRetry: false)
    }

    private func doFetch(isRetry: Bool) async -> UsageData? {
        let accessToken = await MainActor.run { authManager.getSessionKey() }
        guard let accessToken else {
            print("⚠️ Missing OAuth access token")
            return nil
        }

        let urlString = "https://api.anthropic.com/api/oauth/usage"
        guard let url = URL(string: urlString) else { return nil }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("oauth-2025-04-20", forHTTPHeaderField: "anthropic-beta")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        print("📡 Fetching usage from Anthropic API...")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("📊 API Response: \(httpResponse.statusCode)")

                if httpResponse.statusCode == 200 {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("✅ Got usage data!")
                        return parseAPIResponse(json)
                    }
                } else {
                    let responseBody = String(data: data, encoding: .utf8) ?? "no body"
                    print("❌ API Error \(httpResponse.statusCode): \(responseBody)")

                    if (httpResponse.statusCode == 401 || httpResponse.statusCode == 403) && !isRetry {
                        // Try refreshing the token
                        print("🔄 Attempting token refresh...")
                        let refreshed = await authManager.refreshToken()
                        if refreshed {
                            return await doFetch(isRetry: true)
                        }
                        // Refresh failed — re-check auth state
                        await MainActor.run {
                            authManager.checkAuthentication()
                        }
                    }
                }
            }
        } catch {
            print("⚠️ API error: \(error)")
        }

        return nil
    }

    private func parseAPIResponse(_ json: [String: Any]) -> UsageData {
        var details: [UsageDetail] = []
        var usedFraction: Double = 0.0
        var resetDate: Date?

        if let fiveHour = json["five_hour"] as? [String: Any] {
            if let utilization = fiveHour["utilization"] as? Int {
                usedFraction = Double(utilization) / 100.0
                details.append(UsageDetail(label: "5-Hour Window", value: "\(utilization)% used"))
            }

            if let resetsAtString = fiveHour["resets_at"] as? String {
                let isoFormatter = ISO8601DateFormatter()
                isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let date = isoFormatter.date(from: resetsAtString) {
                    resetDate = date
                }
            }
        }

        return UsageData(
            providerName: name,
            iconName: "BrainIcon",
            used: usedFraction,
            resetDate: resetDate,
            details: details
        )
    }
}
