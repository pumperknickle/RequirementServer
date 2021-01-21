import Fluent
import Vapor
import RQTFoundation
import VaporOpenAPI

struct RequirementVersionController: RouteCollection {
    typealias RequirementVersionType = RequirementVersionImpl
    func boot(routes: RoutesBuilder) throws {
        let requirementVersions = routes.grouped("requirementVersions")
        requirementVersions.get(use: index)
            .summary("Get all requirement versions")
            .description("Gets all requirements versions")
            .tags("Requirement")
        requirementVersions.post(use: create)
            .summary("Create requirement version")
            .description("Creates a new requirement version")
            .tags("Requirement")
        requirementVersions.group(":id") { reqVersion in
            reqVersion.delete(use: delete)
            .summary("Delete requirement versions")
            .description("Deletes a requirement version by id")
            .tags("Requirement")
        }
    }

    func index(req: TypedRequest<IndexContext>) throws -> EventLoopFuture<[RequirementVersionType]> {
        return RequirementVersionModel.query(on: req.db).all().mapEach { $0.convertToDTO() }
    }

    func create(req: TypedRequest<CreateContext>) throws -> EventLoopFuture<RequirementVersionType> {
        let requirementVersionDTO = try req.content.decode(RequirementVersionType.self)
        guard let requirementVersionModel = RequirementVersionModel(dto: requirementVersionDTO) else { throw Abort(.notAcceptable) }
        return requirementVersionModel.create(on: req.db).map { requirementVersionModel.convertToDTO() }
    }

    func delete(req: TypedRequest<DeleteContext>) throws -> EventLoopFuture<HTTPStatus> {
        guard let idString = req.parameters.get("id") else { throw Abort(.notAcceptable) }
        guard let uuid = UUID(uuidString: idString) else { throw Abort(.notAcceptable) }
        return RequirementVersionModel.find(uuid, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}

extension RequirementVersionController {
    struct IndexContext: RouteContext {
        public typealias RequestBodyType = EmptyRequestBody

        public static let defaultContentType: HTTPMediaType? = nil
        public static let shared = Self()

        public let success: ResponseContext<[RequirementVersionImpl]> = .init { response in
            response.headers.contentType = .json
            response.status = .ok
        }
    }
    
    struct CreateContext: RouteContext {
        public typealias RequestBodyType = RequirementVersionImpl

        public static let defaultContentType: HTTPMediaType? = nil
        public static let shared = Self()

        public let success: ResponseContext<RequestBodyType> = .init { response in
            response.headers.contentType = .json
            response.status = .ok
        }
    }
    
    struct DeleteContext: RouteContext {
        public typealias RequestBodyType = EmptyRequestBody
        
        public static let defaultContentType: HTTPMediaType? = nil
        public static let shared = Self()
        
        public let success: ResponseContext<EmptyResponseBody> = .init { response in
            response.status = .ok
        }
    }
}
