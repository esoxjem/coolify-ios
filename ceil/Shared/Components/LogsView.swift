import SwiftUI

struct LogsView: View {
    let logs: String
    let isLoading: Bool
    var onRefresh: (() async -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            if let onRefresh {
                controlsSection(onRefresh: onRefresh)
            }
            logsContent
        }
    }

    private func controlsSection(onRefresh: @escaping () async -> Void) -> some View {
        HStack {
            Spacer()
            refreshButton(onRefresh: onRefresh)
        }
        .padding()
    }

    private func refreshButton(onRefresh: @escaping () async -> Void) -> some View {
        Button {
            Task { await onRefresh() }
        } label: {
            Image(systemName: "arrow.clockwise")
                .symbolEffect(.rotate, isActive: isLoading)
        }
    }

    @ViewBuilder
    private var logsContent: some View {
        if isLoading && logs.isEmpty {
            loadingView
        } else if logs.isEmpty {
            emptyView
        } else {
            logsScrollView
        }
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView {
                Text("Loading logs...")
                    .font(.monoSubheadline)
            }
            Spacer()
        }
    }

    private var emptyView: some View {
        VStack {
            Spacer()
            ContentUnavailableView {
                Label("No Logs", systemImage: "doc.text")
                    .font(.monoHeadline)
            } description: {
                Text("No logs available")
                    .font(.monoSubheadline)
            }
            Spacer()
        }
    }

    private var logsScrollView: some View {
        ScrollView {
            Text(logs)
                .font(.monoCaption)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .textSelection(.enabled)
        }
        .background(Color(.systemBackground))
    }
}
