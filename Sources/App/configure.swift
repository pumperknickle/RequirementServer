import Fluent
import FluentPostgresDriver
import Vapor
import Queues
import QueuesRedisDriver

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor",
        password: Environment.get("DATABASE_PASSWORD") ?? "password",
        database: Environment.get("DATABASE_NAME") ?? "vapor"
    ), as: .psql)

    app.migrations.add(CreateRequirementVersion())
    app.migrations.add(CreateTagModel())
    
    try app.autoMigrate().wait()
    
    try app.queues.use(.redis(url: "redis://scheduler:6379"))
    let combindJob = TrainCombinedJob()
    app.queues.schedule(combindJob).hourly().at(10)
    try app.queues.startScheduledJobs()

    // register routes
    try routes(app)
}
