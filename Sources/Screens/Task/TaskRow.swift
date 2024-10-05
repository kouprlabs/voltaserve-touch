import SwiftUI
import VoltaserveCore

struct TaskRow: View {
    @Environment(\.colorScheme) private var colorScheme
    private let task: VOTask.Entity

    init(_ task: VOTask.Entity) {
        self.task = task
    }

    var body: some View {
        VStack {
            HStack(spacing: VOMetrics.spacingSm) {
                if task.status == .running, task.isIndeterminate {
                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle")
                        .symbolEffect(.rotate, options: .repeat(.continuous))
                        .font(.title2)
                        .foregroundStyle(Color.blue400)
                } else if task.status == .waiting {
                    Image(systemName: "clock.arrow.trianglehead.2.counterclockwise.rotate.90")
                        .font(.title2)
                        .foregroundStyle(Color.gray400)
                } else if task.status == .success {
                    Image(systemName: "checkmark.circle")
                        .font(.title2)
                        .foregroundStyle(Color.green400)
                } else if task.status == .error {
                    Image(systemName: "exclamationmark.circle")
                        .font(.title2)
                        .foregroundStyle(Color.red400)
                }
                if let object = task.payload?.object {
                    VStack(alignment: .leading) {
                        Text(object)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Text(task.name)
                            .font(.footnote)
                            .foregroundStyle(Color.gray500)
                            .lineLimit(3)
                            .truncationMode(.tail)
                    }
                } else {
                    Text(task.name)
                        .font(.footnote)
                        .foregroundStyle(Color.gray500)
                        .lineLimit(3)
                        .truncationMode(.tail)
                }
                Spacer()
            }
            if task.status == .running, !task.isIndeterminate {
                ProgressView(value: CGFloat(task.percentage ?? 0), total: 100)
                    .progressViewStyle(.linear)
                    .tint(colorScheme == .dark ? .white : .black)
            }
        }
    }
}

#Preview {
    NavigationStack {
        Form {
            List {
                NavigationLink(destination: Color.clear) {
                    TaskRow(.init(
                        id: UUID().uuidString,
                        name: "Measuring image dimensions.",
                        isIndeterminate: true,
                        userID: UUID().uuidString,
                        status: .running,
                        payload: VOTask.Payload(object: "human-freedom-index-2022.pdf")
                    ))
                }
                NavigationLink(destination: Color.clear) {
                    TaskRow(.init(
                        id: UUID().uuidString,
                        name: "Waiting.",
                        isIndeterminate: true,
                        userID: UUID().uuidString,
                        status: .waiting,
                        payload: VOTask.Payload(object: "Kubernetes-Patterns-2nd-Edition.pdf")
                    ))
                }
                NavigationLink(destination: Color.clear) {
                    TaskRow(.init(
                        id: UUID().uuidString,
                        name: "Creating thumbnail.",
                        isIndeterminate: true,
                        userID: UUID().uuidString,
                        status: .success,
                        payload: VOTask.Payload(object: "In_the_Conservatory.tiff")
                    ))
                }
                NavigationLink(destination: Color.clear) {
                    TaskRow(.init(
                        id: UUID().uuidString,
                        name: "Deleting.",
                        error: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                        isIndeterminate: true,
                        userID: UUID().uuidString,
                        status: .error,
                        payload: VOTask.Payload(object: "Choose-an-automation-tool-ebook-Red-Hat-Developer.pdf")
                    ))
                }
                NavigationLink(destination: Color.clear) {
                    TaskRow(.init(
                        id: UUID().uuidString,
                        name: "Lorem ipsum <u>dolor</u> <i>sit</i> amet.",
                        percentage: 50,
                        isIndeterminate: false,
                        userID: UUID().uuidString,
                        status: .running
                    ))
                }
            }
        }
    }
}
