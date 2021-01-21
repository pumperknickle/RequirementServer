import Vapor
import VaporOpenAPI
import Foundation
import Yams

final class APIDocsController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.get("docs", use: view)
            .summary("View API Documentation")
            .description("API Documentation is served using the Redoc web app.")
            .tags("Documentation")
        routes.get("docs", "openapi.yml", use: show)
            .summary("Download API Documentation")
            .description("Retrieve the OpenAPI documentation as a YAML file.")
            .tags("Documentation")
    }

    let app: Application

    init(app: Application) {
        self.app = app
    }

    func view(_ req: TypedRequest<ViewContext>) -> EventLoopFuture<Response> {
        let html =
        """
        <!DOCTYPE html>
        <html>
          <head>
            <title>ReDoc</title>
            <!-- needed for adaptive design -->
            <meta charset="utf-8"/>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <link href="https://fonts.googleapis.com/css?family=Montserrat:300,400,700|Roboto:300,400,700" rel="stylesheet">
            <!--
            ReDoc doesn't change outer page styles
            -->
            <style>
              body {
                margin: 0;
                padding: 0;
              }
            </style>
          </head>
          <body>
            <redoc spec-url='/docs/openapi.yml'></redoc>
            <script src="https://cdn.jsdelivr.net/npm/redoc@next/bundles/redoc.standalone.js"> </script>
          </body>
        </html>
        """

        return req.response.success.encode(html)
    }

    func show(_ req: TypedRequest<ShowContext>) throws -> EventLoopFuture<Response> {

        // TODO: Add support for ContentEncoder to JSONAPIOpenAPI
        let jsonEncoder = JSONEncoder()
        if #available(macOS 10.12, *) {
            jsonEncoder.dateEncodingStrategy = .iso8601
            jsonEncoder.outputFormatting = .sortedKeys
        }
        #if os(Linux)
        jsonEncoder.dateEncodingStrategy = .iso8601
        jsonEncoder.outputFormatting = .sortedKeys
        #endif

        let info = OpenAPI.Document.Info(
            title: "Requirements Server API",
            description:
            ###"""
            ## Requirements Server
            The requirements server exists to hold all versions of requirements and all related tags throughout the Requirements Clarification Process (RCP). This will be used as a source of training data for fine-tuning custom language models and training sequence tagging models for a variety of tasks including ambiguity detection, term sense disambiguation, etc. Provides a flexible and well documented backend model for tagging and managing requirements.
            """###,
            version: "1.0"
        )

        let servers = [
            OpenAPI.Server(url: URL(string: "https://\(app.http.server.configuration.hostname)")!)
        ]

        let paths = try app.routes.openAPIPathItems(using: jsonEncoder)

        let document = OpenAPI.Document(
            info: info,
            servers: servers,
            paths: paths,
            components: .noComponents,
            security: []
        )

        return req
            .response
            .success
            .encode(try YAMLEncoder().encode(document))
    }
}

// MARK: - Contexts
extension APIDocsController {
    struct ShowContext: RouteContext {
        typealias RequestBodyType = EmptyRequestBody

        static let defaultContentType: HTTPMediaType? = nil
        static let shared = Self()

        let success: ResponseContext<String> = .init { response in
            response.headers.contentType = .init(type: "application", subType: "x-yaml")
            response.status = .ok
        }
    }

    struct ViewContext: RouteContext {
        typealias RequestBodyType = EmptyRequestBody

        static let defaultContentType: HTTPMediaType? = nil
        static let shared = Self()

        let success: ResponseContext<String> = .init { response in
            response.headers.contentType = .html
            response.status = .ok
        }
    }
}
