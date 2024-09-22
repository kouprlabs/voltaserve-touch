import SwiftUI
import UIKit

extension View {
    @ViewBuilder
    func modifierIf(condition: Bool, modifier: (Self) -> some View) -> some View {
        if condition {
            modifier(self)
        } else {
            self
        }
    }

    @ViewBuilder
    func modifierIfPad(modifier: (Self) -> some View) -> some View {
        modifierIf(condition: UIDevice.current.userInterfaceIdiom == .pad, modifier: modifier)
    }

    @ViewBuilder
    func modifierIfPhone(modifier: (Self) -> some View) -> some View {
        modifierIf(condition: UIDevice.current.userInterfaceIdiom == .phone, modifier: modifier)
    }
}
