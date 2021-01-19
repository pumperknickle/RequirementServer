import Fluent
import Vapor
import RQTFoundation

final class RequirementVersionModel: Model, Content {
    static let schema = "requirementversions"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "text")
    var text: String
    
    @OptionalParent(key: "source_id")
    var source: RequirementVersionModel?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(id: UUID? = nil, text: String, source: UUID?, createdAt: Date?) {
        self.id = id
        self.text = text
        if let source = source {
            self.$source.id = source
        }
        self.createdAt = createdAt
    }
    
    init?<T: RequirementVersion>(dto: T) {
        if let id = dto.id {
            guard let uuid = UUID(uuidString: id.description) else { return nil }
            self.id = uuid
        }
        self.text = dto.text
        if let source = dto.source {
        guard let sourceuuid = UUID(uuidString: source.description) else { return nil }
            self.$source.id = sourceuuid
        }
        self.createdAt = dto.createdAt
    }
    
    func convertToDTO<T: RequirementVersion>() -> T {
        return T(id: id?.uuidString != nil ? T.ID(id!.uuidString) : nil, text: text, source: source?.id?.uuidString != nil ? T.ID(source!.id!.uuidString) : nil, createdAt: createdAt)
    }
}
