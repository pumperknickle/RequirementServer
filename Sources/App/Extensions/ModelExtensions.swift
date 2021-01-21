import Foundation
import RQTFoundation
import Vapor
import OpenAPIKit
import OpenAPIReflection
import Sampleable

extension RequirementVersionImpl: Content { }

extension RequirementTagImpl: Content { }

extension RequirementVersionImpl: Sampleable {
    public static var samples: [Self] {
        let sample1 = RequirementVersionImpl(id: UUID().description, text: "The FLIGHT_INFORMATION_SYSTEM shall display the TRACKING_INFORMATION for relevant aircraft", source: nil, createdAt: Date())
        let sample2 = RequirementVersionImpl(id: UUID().description, text: "The GPS shall, where there is sufficient space, display the USER_LOCATION", source: nil, createdAt: Date())
        let sample3 = RequirementVersionImpl(id: UUID().description, text: "The GPS shall display the USER_LOCATION", source: sample2.id!, createdAt: Date())
        return [sample1, sample2, sample3]
    }
    
    public static var sample: Self { return samples.randomElement()! }
}

extension RequirementTagImpl: Sampleable {
    public static var samples: [Self] {
        let sample1 = RequirementTagImpl(id: UUID().description, target: UUID().description, span: (10, 21), attribute: "Amibiguous Term", value: nil, createdAt: Date())
        let sample2 = RequirementTagImpl(id: UUID().description, target: UUID().description, span: nil, attribute: "Passive Voice", value: nil, createdAt: Date())
        return [sample1, sample2]
    }
    
    public static var sample: Self { return samples.randomElement()! }
}

extension RequirementVersionImpl: OpenAPIEncodedSchemaType {
    public static func openAPISchema(using encoder: JSONEncoder) throws -> JSONSchema {
        return try genericOpenAPISchemaGuess(using: encoder)
    }
}

extension RequirementTagImpl: OpenAPIEncodedSchemaType {
    public static func openAPISchema(using encoder: JSONEncoder) throws -> JSONSchema {
        return try genericOpenAPISchemaGuess(using: encoder)
    }
}

extension RequirementVersionImpl: ResponseEncodable {
    public func encodeResponse(for request: Request) -> EventLoopFuture<Response> {
        return request.eventLoop
            .makeSucceededFuture(())
            .flatMapThrowing {
                try Response(body: .init(data: JSONEncoder().encode(self)))
        }
    }
}

extension RequirementTagImpl: ResponseEncodable {
    public func encodeResponse(for request: Request) -> EventLoopFuture<Response> {
        return request.eventLoop
            .makeSucceededFuture(())
            .flatMapThrowing {
                try Response(body: .init(data: JSONEncoder().encode(self)))
        }
    }
}
