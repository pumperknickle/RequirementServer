import Fluent
import Vapor
import RQTFoundation

struct TagController: RouteCollection {
    typealias TagType = RequirementTagImpl
    func boot(routes: RoutesBuilder) throws {
        let tags = routes.grouped("tags")
        tags.get(use: index)
        tags.post(use: create)
        tags.group(":id") { tag in
            tag.delete(use: delete)
        }
    }
    
    func index(req: Request) throws -> EventLoopFuture<[TagType]> {
        return TagModel.query(on: req.db).all().mapEach { $0.convertToDTO() }
    }

    func create(req: Request) throws -> EventLoopFuture<TagType> {
        let tagDTO = try req.content.decode(TagType.self)
        guard let tagModel = TagModel(dto: tagDTO) else { throw Abort(.notAcceptable) }
        return tagModel.create(on: req.db).map { tagModel.convertToDTO() }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let idString = req.parameters.get("id") else { throw Abort(.notAcceptable) }
        guard let uuid = UUID(uuidString: idString) else { throw Abort(.notAcceptable) }
        return TagModel.find(uuid, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
