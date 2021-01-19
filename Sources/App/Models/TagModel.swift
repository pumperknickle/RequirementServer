import Fluent
import Vapor
import RQTFoundation

final class TagModel: Model, Content {
    static let schema = "tags"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "target_id")
    var target: RequirementVersionModel
    
    @OptionalField(key: "span")
    var span: Double?
    
    @Field(key: "attribute")
    var attribute: String
    
    @OptionalField(key: "value")
    var value: String?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() { }
    
    init(id: UUID?, target: UUID, span: UInt64?, attribute: String, value: String?, createdAt: Date?) {
        self.id = id
        self.$target.id = target
        if let span = span {
            self.span = Double(span)
        }
        self.attribute = attribute
        self.value = value
        self.createdAt = createdAt
    }
    
    init?<T: Tag>(dto: T) {
        if let id = dto.id {
            guard let uuid = UUID(uuidString: id.description) else { return nil }
            self.id = uuid
        }
        guard let targetuuid = UUID(uuidString: dto.target.description) else { return nil }
        self.$target.id = targetuuid
        if let span = dto.span, let combined = UInt64(a: span.0, b: span.1) {
            self.span = Double(combined)
        }
        self.value = dto.value
        self.attribute = dto.attribute
        self.createdAt = dto.createdAt
    }
    
    func convertToDTO<T: Tag>() -> T {
        return T(id: T.ID(id!.uuidString)!, target: T.ID(self.$target.id.uuidString)!, span: self.span != nil ? UInt64(self.span!).parts : nil, attribute: attribute, value: value, createdAt: createdAt)
    }
}
