import Combine
import Foundation
import SwiftUI

extension View {
    func sync<T: Equatable>(_ published: Binding<T>, with binding: Binding<T>) -> some View {
        onChange(of: published.wrappedValue) { _, published in
            binding.wrappedValue = published
        }
        .onChange(of: binding.wrappedValue) { _, binding in
            published.wrappedValue = binding
        }
    }
}
