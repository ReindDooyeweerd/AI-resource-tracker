import Foundation

struct UsageData {
    let providerName: String
    let iconName: String
    let used: Double       // 0.0 - 1.0
    let resetDate: Date?
    let details: [UsageDetail]
}

struct UsageDetail {
    let label: String
    let value: String
}

protocol UsageProvider {
    var id: String { get }
    var name: String { get }
    var refreshInterval: TimeInterval { get }
    func fetchUsage() async -> UsageData?
}
