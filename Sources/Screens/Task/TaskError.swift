import SwiftUI
import VoltaserveCore

struct TaskError: View {
    private let task: VOTask.Entity

    init(_ task: VOTask.Entity) {
        self.task = task
    }

    var body: some View {
        if let error = task.error {
            Form {
                Text(error)
            }
            .navigationTitle("Error")
        }
    }
}
