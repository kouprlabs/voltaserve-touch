import SwiftUI
import VoltaserveCore

struct TaskPayload: View {
    private let task: VOTask.Entity

    init(_ task: VOTask.Entity) {
        self.task = task
    }

    var body: some View {
        if let object = task.payload?.object {
            Form {
                Text(object)
            }
            .navigationTitle("Payload")
        }
    }
}
