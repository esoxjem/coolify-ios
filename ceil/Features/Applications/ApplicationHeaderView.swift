import SwiftUI

struct ApplicationHeaderView: View {
    let application: Application
    var viewModel: ApplicationDetailViewModel

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                leftContent
                Spacer()
                actionButtons
            }
        }
        .padding()
        .background {
            MeshGradient.applicationGradient()
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.statusSuccess.opacity(0.3), lineWidth: 1)
        }
    }

    private var leftContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            statusBadge
            urlLink
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        if let status = application.status {
            StatusBadge(
                status: status.capitalized,
                color: application.statusColor
            )
        }
    }

    @ViewBuilder
    private var urlLink: some View {
        if let url = application.displayURL {
            Link(destination: URL(string: url) ?? URL(string: "https://example.com")!) {
                HStack(spacing: 4) {
                    Text(url)
                        .lineLimit(1)
                    Image(systemName: "arrow.up.right.square")
                }
                .font(.monoCaption)
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            startStopButton
            restartButton
            deployButton
        }
    }

    private var startStopButton: some View {
        ActionButton(
            icon: application.isRunning ? "stop.fill" : "play.fill",
            color: application.isRunning ? .statusError : .statusSuccess,
            isLoading: viewModel.isPerformingAction
        ) {
            Task {
                if application.isRunning {
                    await viewModel.stopApplication()
                } else {
                    await viewModel.startApplication()
                }
            }
        }
    }

    private var restartButton: some View {
        ActionButton(
            icon: "arrow.clockwise",
            color: .statusWarning,
            isLoading: viewModel.isPerformingAction
        ) {
            Task {
                await viewModel.restartApplication()
            }
        }
    }

    private var deployButton: some View {
        ActionButton(
            icon: "paperplane.fill",
            color: .brandPurple,
            isLoading: viewModel.isPerformingAction
        ) {
            Task {
                await viewModel.deployApplication()
            }
        }
    }
}
