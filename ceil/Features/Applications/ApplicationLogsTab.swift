import SwiftUI

struct ApplicationLogsTab: View {
    var viewModel: ApplicationDetailViewModel
    @State private var lineCount: Int = 100

    var body: some View {
        VStack(spacing: 0) {
            lineCountPicker
            LogsView(
                logs: viewModel.logs,
                isLoading: viewModel.isLoadingLogs,
                onRefresh: { await viewModel.loadLogs(lines: lineCount) }
            )
        }
        .task {
            await viewModel.loadLogs(lines: lineCount)
        }
        .onChange(of: lineCount) { _, newValue in
            Task { await viewModel.loadLogs(lines: newValue) }
        }
    }

    private var lineCountPicker: some View {
        Picker("Lines", selection: $lineCount) {
            Text("50").tag(50)
            Text("100").tag(100)
            Text("200").tag(200)
            Text("500").tag(500)
        }
        .pickerStyle(.segmented)
        .padding()
    }
}
