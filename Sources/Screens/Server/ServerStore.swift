import Combine
import Foundation

class ServerStore: ObservableObject {
    @Published private var _entities: [Entity] = []

    var entities: [Entity] {
        _entities
    }

    init() {
        _entities.append(Entity(
            id: UUID().uuidString,
            name: "Voltaserve Cloud",
            apiURL: "https://api.cloud.voltaserve.com",
            idpURL: "https://idp.cloud.voltaserve.com",
            isCloud: true,
            isActive: true
        ))
    }

    func getAll() -> [Entity] {
        _entities
    }

    func getAt(_ index: Int) -> Entity {
        _entities[index]
    }

    func create(_ entity: Entity) {
        _entities.append(entity)
    }

    func delete(_ id: String) {
        if let index = _entities.firstIndex(where: { $0.id == id }),
           _entities[index].isActive {
            activateCloud()
        }
        _entities.removeAll(where: { $0.id == id })
    }

    private func activateCloud() {
        if let index = _entities.firstIndex(where: { $0.isCloud }) {
            _entities[index].isActive = true
        }
    }

    func update(_ id: String, value: Entity) {
        if let index = _entities.firstIndex(where: { $0.id == id }) {
            _entities[index].name = value.name
            _entities[index].apiURL = value.apiURL
            _entities[index].idpURL = value.idpURL
        }
    }

    func activate(_ id: String) {
        for index in _entities.indices {
            _entities[index].isActive = false
        }
        if let index = _entities.firstIndex(where: { $0.id == id }) {
            _entities[index].isActive = true
        }
    }

    struct Entity {
        var id: String
        var name: String
        var apiURL: String
        var idpURL: String
        var isCloud: Bool
        var isActive: Bool
    }
}
