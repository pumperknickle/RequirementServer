import Fluent
import Vapor
import RQTFoundation

struct RequirementVersionController: RouteCollection {
    typealias RequirementVersionType = RequirementVersionImpl
    func boot(routes: RoutesBuilder) throws {
        let requirementVersions = routes.grouped("requirementVersions")
        requirementVersions.get(use: index)
        requirementVersions.post(use: create)
        requirementVersions.group(":id") { reqVersion in
            reqVersion.delete(use: delete)
        }
    }

    func index(req: Request) throws -> EventLoopFuture<[RequirementVersionType]> {
        return RequirementVersionModel.query(on: req.db).all().mapEach { $0.convertToDTO() }
    }

    func create(req: Request) throws -> EventLoopFuture<RequirementVersionType> {
        let requirementVersionDTO = try req.content.decode(RequirementVersionType.self)
        guard let requirementVersionModel = RequirementVersionModel(dto: requirementVersionDTO) else { throw Abort(.notAcceptable) }
        return requirementVersionModel.create(on: req.db).map { requirementVersionModel.convertToDTO() }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let idString = req.parameters.get("id") else { throw Abort(.notAcceptable) }
        guard let uuid = UUID(uuidString: idString) else { throw Abort(.notAcceptable) }
        return RequirementVersionModel.find(uuid, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
