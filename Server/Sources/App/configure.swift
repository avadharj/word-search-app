import Vapor
import Fluent
import FluentPostgresDriver

public func configure(_ app: Application) throws {
    // Configure database
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 5432,
        username: Environment.get("DATABASE_USERNAME") ?? "postgres",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: Environment.get("DATABASE_NAME") ?? "wordsearch"
    ), as: .psql)
    
    // Configure migrations
    app.migrations.add(CreateUser())
    app.migrations.add(CreateGameStatistics())
    app.migrations.add(CreateGameHistory())
    app.migrations.add(CreateDailyChallengeResult())
    
    // Run migrations
    try app.autoMigrate().wait()
    
    // Register routes
    try routes(app)
    
    // Configure CORS for iOS app
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin],
        allowCredentials: true
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(cors, at: .beginning)
    
}

