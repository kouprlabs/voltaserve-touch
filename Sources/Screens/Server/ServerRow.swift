import SwiftUI

struct ServerRow: View {
    @EnvironmentObject private var serverStore: ServerStore
    @Environment(\.editMode) private var editMode
    @Environment(\.colorScheme) private var colorScheme
    private let server: ServerStore.Entity
    private let action: (() -> Void)?
    private let onDelete: (() -> Void)?

    init(
        _ server: ServerStore.Entity,
        action: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.server = server
        self.action = action
        self.onDelete = onDelete
    }

    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: VOMetrics.spacingSm) {
                if editMode?.wrappedValue == .active && !server.isCloud {
                    Button {
                        onDelete?()
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .scaleEffect(1.2)
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.borderless)
                }
                // Checkmark
                if server.isActive && editMode?.wrappedValue != .active {
                    checkmark
                }
                // Spacer
                if (!server.isActive && editMode?.wrappedValue != .active) ||
                    (editMode?.wrappedValue == .active && server.isCloud) {
                    spacer
                }
                Text(server.name)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                if server.isCloud {
                    Image("social")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(VOMetrics.borderRadiusXs)
                        .overlay {
                            RoundedRectangle(cornerRadius: VOMetrics.borderRadiusXs)
                                .stroke(voBorderColor(colorScheme: colorScheme), lineWidth: 1)
                        }
                        .frame(width: 20, height: 20)
                }
            }
        }
        .swipeActions {
            if !server.isCloud {
                Button(role: .destructive) {
                    onDelete?()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }

    var checkmark: some View {
        Image(systemName: "checkmark")
            .foregroundStyle(.blue)
            .fontWeight(.medium)
            .frame(width: 20, height: 20)
    }

    var spacer: some View {
        Color.clear
            .frame(width: 20, height: 20)
    }
}
