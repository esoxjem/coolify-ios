import SwiftUI

struct ServiceDetailView: View {
    let service: Service
    var viewModel: ServicesViewModel
    @State private var isPerformingAction = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerCard
                urlsCard
                descriptionCard
            }
            .padding()
        }
        .navigationTitle("Service")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerContent
        }
        .padding()
        .background { MeshGradient.coolifyService() }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay { headerBorder }
    }

    private var headerContent: some View {
        HStack {
            headerIcon
            headerLabels
            Spacer()
            actionButtons
        }
    }

    private var headerIcon: some View {
        Image(systemName: "square.stack.3d.up")
            .font(.largeTitle)
            .foregroundStyle(.coolifyPurple)
            .symbolEffect(.bounce, options: .nonRepeating)
    }

    private var headerLabels: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(service.name)
                .font(.title2)
                .fontWeight(.bold)
            statusBadge
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        if let status = service.capitalizedStatus {
            StatusBadge(
                status: status,
                color: service.statusColor
            )
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            toggleButton
            restartButton
        }
    }

    private var toggleButton: some View {
        Button {
            performToggleAction()
        } label: {
            toggleButtonLabel
        }
        .disabled(isPerformingAction)
    }

    private var toggleButtonLabel: some View {
        Image(systemName: toggleIconName)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 40, height: 40)
            .background(toggleButtonColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var toggleIconName: String {
        service.isRunning ? "stop.fill" : "play.fill"
    }

    private var toggleButtonColor: Color {
        service.isRunning ? .coolifyError : .coolifySuccess
    }

    private func performToggleAction() {
        isPerformingAction = true
        Task {
            if service.isRunning {
                await viewModel.stopService(service)
            } else {
                await viewModel.startService(service)
            }
            isPerformingAction = false
        }
    }

    private var restartButton: some View {
        Button {
            performRestartAction()
        } label: {
            restartButtonLabel
        }
        .disabled(isPerformingAction)
    }

    private var restartButtonLabel: some View {
        Image(systemName: "arrow.clockwise")
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 40, height: 40)
            .background(Color.coolifyWarning)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .symbolEffect(.rotate, isActive: isPerformingAction)
    }

    private func performRestartAction() {
        isPerformingAction = true
        Task {
            await viewModel.restartService(service)
            isPerformingAction = false
        }
    }

    private var headerBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .strokeBorder(.coolifyPurple.opacity(0.3), lineWidth: 1)
    }

    @ViewBuilder
    private var urlsCard: some View {
        if service.hasURLs {
            InfoCard(title: "URLs") {
                urlLinks
            }
        }
    }

    private var urlLinks: some View {
        ForEach(service.urlList, id: \.self) { url in
            urlLink(for: url)
        }
    }

    private func urlLink(for url: String) -> some View {
        Link(destination: urlDestination(for: url)) {
            urlLinkContent(url: url)
        }
    }

    private func urlDestination(for url: String) -> URL {
        URL(string: url) ?? URL(string: "https://example.com")!
    }

    private func urlLinkContent(url: String) -> some View {
        HStack {
            Text(url)
                .font(.subheadline)
                .lineLimit(1)
            Spacer()
            Image(systemName: "arrow.up.right.square")
                .font(.caption)
        }
    }

    @ViewBuilder
    private var descriptionCard: some View {
        if service.hasDescription {
            InfoCard(title: "Description") {
                descriptionText
            }
        }
    }

    private var descriptionText: some View {
        Text(service.description ?? "")
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}

#Preview {
    NavigationStack {
        ServiceDetailView(
            service: Service(
                id: 1,
                uuid: "test-uuid",
                name: "Test Service",
                description: "A test service description",
                status: "running",
                fqdn: "https://example.com,https://api.example.com",
                dockerComposeRaw: nil,
                connectToDockerNetwork: nil,
                isContainerLabelEscapeEnabled: nil,
                createdAt: nil,
                updatedAt: nil
            ),
            viewModel: ServicesViewModel()
        )
    }
}
