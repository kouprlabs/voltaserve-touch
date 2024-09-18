import SwiftUI

struct ErrorAlert: ViewModifier {
    private let isPresented: Binding<Bool>
    private let title: String?
    private let message: String?

    init(isPresented: Binding<Bool>, title: String? = nil, message: String? = nil) {
        self.isPresented = isPresented
        self.title = title
        self.message = message
    }

    func body(content: Content) -> some View {
        content
            .alert(title ?? "Error", isPresented: isPresented) {
                Button("OK") {}
            } message: {
                Text(message ?? "Unexpected error occurred.")
            }
    }
}

extension View {
    func voErrorAlert(isPresented: Binding<Bool>, title: String? = nil, message: String? = nil) -> some View {
        modifier(ErrorAlert(isPresented: isPresented, title: title, message: message))
    }
}
