import Fluent
import Vapor
import RQTFoundation
import VaporOpenAPI

struct TagController: RouteCollection {
    typealias TagType = RequirementTagImpl
    func boot(routes: RoutesBuilder) throws {
        let reqTags = routes.grouped("tags")
        reqTags.get(use: index)
            .summary("Get all tags")
            .description("Gets all requirement tags")
            .tags("Tag")
        reqTags.post(use: create)
            .summary("Create tags")
            .description("Creates a new tag")
            .tags("Tag")
        reqTags.group(":id") { tag in
            tag.delete(use: delete)
            .summary("Delete tags")
            .description("Deletes a tag by id")
            .tags("Tag")
        }
    }
    
    func index(req: TypedRequest<IndexContext>) throws -> EventLoopFuture<[TagType]> {
        return TagModel.query(on: req.db).all().mapEach { $0.convertToDTO() }
    }

    func create(req: TypedRequest<CreateContext>) throws -> EventLoopFuture<TagType> {
        let tagDTO = try req.content.decode(TagType.self)
        guard let tagModel = TagModel(dto: tagDTO) else { throw Abort(.notAcceptable) }
        return tagModel.create(on: req.db).map { tagModel.convertToDTO() }
    }

    func delete(req: TypedRequest<DeleteContext>) throws -> EventLoopFuture<HTTPStatus> {
        guard let idString = req.parameters.get("id") else { throw Abort(.notAcceptable) }
        guard let uuid = UUID(uuidString: idString) else { throw Abort(.notAcceptable) }
        return TagModel.find(uuid, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}

extension TagController {
    struct IndexContext: RouteContext {
        public typealias RequestBodyType = EmptyRequestBody

        public static let defaultContentType: HTTPMediaType? = nil
        public static let shared = Self()

        public let success: ResponseContext<[TagType]> = .init { response in
            response.headers.contentType = .json
            response.status = .ok
        }
    }
    
    struct CreateContext: RouteContext {
        public typealias RequestBodyType = TagType

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

