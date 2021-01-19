import Fluent

struct CreateRequirementVersion: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("requirementversions")
            .id()
            .field("source_id", .uuid, .references("requirementversions", "id"))
            .field("text", .string, .required)
            .field("created_at", .string)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("requirementversions").delete()
    }
}
