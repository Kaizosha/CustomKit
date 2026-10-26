import CustomKit
import CustomKitCatalog
import KaizoshaPlayer
import KaizoshaPlayerUI
import SwiftUI
import UniformTypeIdentifiers

struct PlayerKitExample: View {
    @State private var session: PlayerSession?
    @State private var selectedURL: URL?
    @State private var scopedURL: URL?
    @State private var isChoosingMovie = false
    @State private var rate: Float = 1
    @State private var clearGlass = false
    @State private var showsNativeControls = true
    @State private var failure: String?

    var body: some View {
        ExperimentPage(
            title: "PlayerKit",
            subtitle: "A local movie, real transport, and one native player.",
            source: "Together · KaizoshaPlayerKit",
            api: """
            import KaizoshaPlayer
            import KaizoshaPlayerUI

            @State private var session = PlayerSession()

            NativePlayerView(session: session)
                .task {
                    try? await session.load(MediaResource(url: localMovie))
                }
                .onDisappear { session.close() }
            """
        ) {
            VStack(spacing: 24) {
                if let session {
                    NativePlayerView(session: session)
                        .frame(height: 230)
                        .clipShape(.rect(cornerRadius: 24))
                        .accessibilityIdentifier("player.video")
                    Text(session.resource?.title ?? "Choose a movie")
                        .font(.system(.title3, design: .serif))
                    if showsNativeControls {
                        transport(session)
                    }
                    if let failure {
                        Label(failure, systemImage: "exclamationmark.triangle")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    ProgressView("Preparing local movie")
                        .frame(height: 230)
                }
                Button("Choose local movie", systemImage: "folder") {
                    isChoosingMovie = true
                }
                .buttonStyle(.glass)
                .controlSize(.large)
                .accessibilityIdentifier("player.choose")
            }
            .padding(24)
        } controls: {
            Section("Transport") {
                Picker("Speed", selection: $rate) {
                    Text("0.5×").tag(Float(0.5))
                    Text("1×").tag(Float(1))
                    Text("1.5×").tag(Float(1.5))
                    Text("2×").tag(Float(2))
                }
                .pickerStyle(.segmented)
                Toggle("Show transport controls", isOn: $showsNativeControls)
                Toggle("Clear glass", isOn: $clearGlass)
            }
            Section {
                Button("Use Kaizōsha sample", systemImage: "arrow.counterclockwise") {
                    selectedURL = nil
                    rate = 1
                    clearGlass = false
                    showsNativeControls = true
                    if let session {
                        Task { await seek(session, to: 0) }
                    }
                }
                Button("Choose local movie", systemImage: "folder") { isChoosingMovie = true }
            }
        }
        .task(id: selectedURL) { await loadMovie() }
        .onChange(of: rate) { _, value in
            do { try session?.setRate(value) }
            catch { failure = "This playback speed is unavailable." }
        }
        .onDisappear {
            session?.close()
            session = nil
            releaseFileAccess()
        }
        .fileImporter(isPresented: $isChoosingMovie, allowedContentTypes: [.movie]) { result in
            switch result {
            case .success(let url): selectedURL = url
            case .failure: failure = "The movie could not be opened."
            }
        }
    }

    private func transport(_ session: PlayerSession) -> some View {
        VStack(spacing: 16) {
            SwiftUI.Slider(
                value: Binding(
                    get: { min(session.position, session.duration ?? 1) },
                    set: { session.updateScrubbing(to: $0) }
                ),
                in: 0...max(session.duration ?? 1, 1),
                onEditingChanged: { editing in
                    if editing { session.beginScrubbing() }
                    else {
                        Task {
                            do { try await session.endScrubbing(at: session.position) }
                            catch is CancellationError {}
                            catch { failure = "The movie could not seek to this position." }
                        }
                    }
                }
            )
            .accessibilityLabel("Movie position")
            .tint(.teal)
            GeometryReader { geometry in
                PlayerTransportControls(
                    isPlayRequested: session.state == .playing || session.state == .waiting,
                    availableWidth: geometry.size.width,
                    playPauseLabel: session.state == .playing || session.state == .waiting ? "Pause" : "Play",
                    backwardLabel: "Back ten seconds",
                    forwardLabel: "Forward ten seconds",
                    appearance: clearGlass ? .clear : .adaptive,
                    onTogglePlayback: {
                        if session.state == .playing || session.state == .waiting { session.pause() }
                        else {
                            Task {
                                do { try await session.play() }
                                catch is CancellationError {}
                                catch { failure = "The movie could not begin playback." }
                            }
                        }
                    },
                    onSkip: { delta in Task { await seek(session, to: session.position + delta) } }
                )
                .frame(maxWidth: .infinity)
            }
            .frame(height: 76)
        }
    }

    private func loadMovie() async {
        session?.close()
        releaseFileAccess()
        failure = nil
        let next = PlayerSession()
        session = next
        guard let url = selectedURL ?? Bundle.main.url(forResource: "KaizoshaSample", withExtension: "mov") else {
            failure = "Choose a local movie to try playback."
            return
        }
        if selectedURL != nil, url.startAccessingSecurityScopedResource() { scopedURL = url }
        do {
            try await next.load(MediaResource(url: url, title: selectedURL == nil ? "Made by Kaizōsha" : url.deletingPathExtension().lastPathComponent))
            try next.setRate(rate)
        } catch is CancellationError {
            next.close()
        } catch {
            failure = "This movie could not be loaded. Choose another local file."
        }
    }

    private func seek(_ session: PlayerSession, to position: Double) async {
        do { try await session.seek(to: max(0, min(position, session.duration ?? position))) }
        catch is CancellationError {}
        catch { failure = "The movie could not seek to this position." }
    }

    private func releaseFileAccess() {
        scopedURL?.stopAccessingSecurityScopedResource()
        scopedURL = nil
    }
}
