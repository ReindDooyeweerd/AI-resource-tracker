import SwiftUI

@main
struct AI_resource_trackerApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var viewModel = UsageViewModel()

    var body: some Scene {
        MenuBarExtra {
            PopoverView(viewModel: viewModel, authManager: authManager)
                .onAppear {
                    viewModel.configure(with: authManager)
                }
        } label: {
            HStack(spacing: 4) {
                Image("BrainIcon")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
                Text(viewModel.menuBarLabel)
                    .monospacedDigit()
            }
        }
        .menuBarExtraStyle(.window)
    }
}
