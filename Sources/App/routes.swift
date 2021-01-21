import Fluent
import Vapor

func routes(_ app: Application) throws {
    let apiDocsController = APIDocsController(app: app)
    try app.register(collection: apiDocsController)
    try app.register(collection: RequirementVersionController())
    try app.register(collection: TagController())
}
