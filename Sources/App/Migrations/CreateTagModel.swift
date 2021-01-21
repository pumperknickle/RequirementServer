import Fluent

struct CreateTagModel: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("tags")
            .id()
            .field("target_id", .uuid, .required, .references("requirementversions", "id"))
            .field("left", .int)
            .field("right", .int)
            .field("attribute", .string, .required)
            .field("value", .string)
            .field("created_at", .string)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("tags").delete()
    }
}
