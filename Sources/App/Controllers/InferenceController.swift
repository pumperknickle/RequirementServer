import Fluent
import Vapor
import RQTFoundation
import VaporOpenAPI

struct InferenceController: RouteCollection {
    typealias RequirementVersionType = RequirementVersionImpl
    typealias PredictionType = PredictedTagImpl
    func boot(routes: RoutesBuilder) throws {
        let requirementVersions = routes.grouped("infer")
        requirementVersions.post(use: infer)
            .summary("Predict Tags for Requirements")
            .description("Returns a set of tags using a ssequence labelling model with contextual string embeddings.")
            .tags("Inference")
    }

    func infer(req: TypedRequest<InferenceContext>) throws -> EventLoopFuture<[PredictionType]> {
        let requirementVersions = try req.content.decode([RequirementVersionType].self)
        return req.eventLoop.future(Trainer.infer(for: requirementVersions))
    }
}

extension InferenceController {
    struct InferenceContext: RouteContext {
        public typealias RequestBodyType = [RequirementVersionType]

        public static let defaultContentType: HTTPMediaType? = nil
        public static let shared = Self()

        public let success: ResponseContext<[PredictionType]> = .init { response in
            response.headers.contentType = .json
            response.status = .ok
        }
    }

}
