import SwiftUI

struct VOStoragePicker: View {
    @Binding private var valueBinding: Int?
    @State private var value: Int?
    @State private var unit: StorageUnit?
    @State private var mask = true

    init(value: Binding<Int?>) {
        _valueBinding = value
    }

    var body: some View {
        TextField(
            "Storage Capacity",
            value: Binding<Int>(
                get: {
                    if let value {
                        if mask {
                            return value.convertFromByte(to: value.storageUnit)
                        } else if let unit {
                            return value.convertFromByte(to: unit)
                        }
                    }
                    return 0
                },
                set: {
                    mask = false
                    value = Int($0).normalizeToByte(from: unit ?? .byte)
                }
            ),
            formatter: NumberFormatter()
        )
        .onChange(of: value) { _, newValue in
            if let newValue, mask {
                unit = newValue.storageUnit
            }
        }
        Picker("Unit", selection: $unit) {
            Text("B").tag(StorageUnit.byte)
            Text("MB").tag(StorageUnit.megabyte)
            Text("GB").tag(StorageUnit.gigabyte)
            Text("TB").tag(StorageUnit.terabyte)
        }
        .onAppear {
            if let valueBinding {
                mask = true
                value = valueBinding
            }
        }
        .onChange(of: unit) { _, newUnit in
            if let newUnit, let value {
                let visibleCapacity = value.convertFromByte(to: value.storageUnit)
                self.value = visibleCapacity.normalizeToByte(from: newUnit)
            }
        }
        .onChange(of: value) { _, newInternalValue in
            if let newInternalValue {
                valueBinding = newInternalValue
            }
        }
    }
}

#Preview {
    @Previewable @State var value: Int? = 5_000_000_000
    Form {
        Section {
            VOStoragePicker(value: $value)
        }
        Section {
            if let value {
                Text("\(value)")
            }
        }
    }
}
