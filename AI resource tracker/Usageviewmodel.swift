import Foundation
import Combine

@MainActor
final class UsageViewModel: ObservableObject {
    @Published var usages: [UsageData] = []

    var menuBarLabel: String {
        guard let primary = usages.first else { return "—" }
        let pct = Int(primary.used * 100)
        return "\(pct)%"
    }

    private var providers: [UsageProvider] = []
    private var timers: [AnyCancellable] = []
    private var authManager: AuthManager?

    init() {
        // Provider will be added after auth is configured
    }
    
    func configure(with authManager: AuthManager) {
        self.authManager = authManager
        if authManager.isAuthenticated {
            addProvider(ClaudeCodeProvider(authManager: authManager))
        }
    }

    func addProvider(_ provider: UsageProvider) {
        providers.append(provider)
        startPolling(provider)
        Task { await refresh(provider) }
    }

    private func startPolling(_ provider: UsageProvider) {
        let timer = Timer.publish(every: provider.refreshInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { await self?.refresh(provider) }
            }
        timers.append(timer)
    }

    private func refresh(_ provider: UsageProvider) async {
        guard let data = await provider.fetchUsage() else { return }
        if let idx = usages.firstIndex(where: { $0.providerName == provider.name }) {
            usages[idx] = data
        } else {
            usages.append(data)
        }
    }
}
