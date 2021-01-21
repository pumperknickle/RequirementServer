import Fluent
import Vapor
import RQTFoundation

final class TagModel: Model, Content {
    static let schema = "tags"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "target_id")
    var target: RequirementVersionModel
    
    @OptionalField(key: "left")
    var left: Int?
    
    @OptionalField(key: "right")
    var right: Int?
    
    @Field(key: "attribute")
    var attribute: String
    
    @OptionalField(key: "value")
    var value: String?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() { }
    
    init(id: UUID?, target: UUID, span: (Int, Int)?, attribute: String, value: String?, createdAt: Date?) {
        self.id = id
        self.$target.id = target
        self.left = span?.0
        self.right = span?.1
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
        self.left = dto.left
        self.right = dto.right
        self.value = dto.value
        self.attribute = dto.attribute
        self.createdAt = dto.createdAt
    }
    
    func convertToDTO<T: Tag>() -> T {
        if let left = self.left, let right = self.right {
            return T(id: T.ID(id!.uuidString)!, target: T.ID(self.$target.id.uuidString)!, span: (left, right), attribute: attribute, value: value, createdAt: createdAt)
        }
        return T(id: T.ID(id!.uuidString)!, target: T.ID(self.$target.id.uuidString)!, span: nil, attribute: attribute, value: value, createdAt: createdAt)
    }
}
