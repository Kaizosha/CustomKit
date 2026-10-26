import SwiftUI

public extension View {
    func hapticSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        hapticsEnabled: Bool = true,
        detents: Set<PresentationDetent> = [.medium, .large],
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        modifier(HapticSheetModifier(
            isPresented: isPresented,
            hapticsEnabled: hapticsEnabled,
            detents: detents,
            sheetContent: content
        ))
    }
}

private struct HapticSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let hapticsEnabled: Bool
    let detents: Set<PresentationDetent>
    let sheetContent: () -> SheetContent
    @State private var selectedDetent: PresentationDetent

    init(
        isPresented: Binding<Bool>,
        hapticsEnabled: Bool,
        detents: Set<PresentationDetent>,
        sheetContent: @escaping () -> SheetContent
    ) {
        _isPresented = isPresented
        self.hapticsEnabled = hapticsEnabled
        self.detents = detents.isEmpty ? [.large] : detents
        self.sheetContent = sheetContent
        _selectedDetent = State(initialValue: Self.initialDetent(in: self.detents))
    }

    private static func initialDetent(in detents: Set<PresentationDetent>) -> PresentationDetent {
        if detents.contains(.medium) { return .medium }
        if detents.contains(.large) { return .large }
        return detents.first ?? .large
    }

    func body(content: Content) -> some View {
        content
            .sensoryFeedback(.impact(weight: .light), trigger: isPresented) { _, _ in hapticsEnabled }
            .sheet(isPresented: $isPresented) {
                sheetContent()
                    .presentationDetents(detents, selection: $selectedDetent)
                    .presentationDragIndicator(.visible)
                    .presentationSizing(.page)
                    .sensoryFeedback(.selection, trigger: selectedDetent) { _, _ in hapticsEnabled }
                    .onChange(of: detents) { _, _ in
                        if !detents.contains(selectedDetent) {
                            selectedDetent = Self.initialDetent(in: detents)
                        }
                    }
            }
    }
}
