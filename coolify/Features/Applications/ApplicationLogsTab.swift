import SwiftUI

struct ApplicationLogsTab: View {
    var viewModel: ApplicationDetailViewModel
    @State private var lineCount: Int = 100

    var body: some View {
        VStack(spacing: 0) {
            controlsSection
            logsContent
        }
        .task {
            await viewModel.loadLogs(lines: lineCount)
        }
    }

    private var controlsSection: some View {
        HStack {
            lineCountPicker
            refreshButton
        }
        .padding()
    }

    private var lineCountPicker: some View {
        Picker("Lines", selection: $lineCount) {
            Text("50").tag(50)
            Text("100").tag(100)
            Text("200").tag(200)
            Text("500").tag(500)
        }
        .pickerStyle(.segmented)
    }

    private var refreshButton: some View {
        Button {
            Task {
                await viewModel.loadLogs(lines: lineCount)
            }
        } label: {
            Image(systemName: "arrow.clockwise")
        }
    }

    @ViewBuilder
    private var logsContent: some View {
        if viewModel.isLoadingLogs {
            loadingView
        } else if viewModel.logs.isEmpty {
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
                    .font(.coolifyMonoSubheadline)
            }
            Spacer()
        }
    }

    private var emptyView: some View {
        VStack {
            Spacer()
            ContentUnavailableView {
                Label("No Logs", systemImage: "doc.text")
                    .font(.coolifyMonoHeadline)
            } description: {
                Text("No logs available")
                    .font(.coolifyMonoSubheadline)
            }
            Spacer()
        }
    }

    private var logsScrollView: some View {
        ScrollView {
            Text(viewModel.logs)
                .font(.coolifyMonoCaption)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .textSelection(.enabled)
        }
        .background(Color(.systemBackground))
    }
}
