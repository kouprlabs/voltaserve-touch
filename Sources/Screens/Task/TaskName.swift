import SwiftUI
import VoltaserveCore

struct TaskName: View {
    private let task: VOTask.Entity

    init(_ task: VOTask.Entity) {
        self.task = task
    }

    var body: some View {
        Form {
            Text(task.name)
        }
        .navigationTitle("Name")
    }
}
