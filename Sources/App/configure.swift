import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {

    try services.register(FluentPostgreSQLProvider())
    
    
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    var databases = DatabasesConfig()
    let databaseConfig = PostgreSQLDatabaseConfig(hostname: "{{Skeleton | lowercase}}", username: "vapor", database: "{{Skeleton | lowercase}}", password: "password")
//    let databaseConfig = PostgreSQLDatabaseConfig(hostname: "localhost", username: "vapor", database: "{{Skeleton | lowercase}}", password: "password")
    let database = PostgreSQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .psql)
    services.register(databases)
    
    
    // Service for logs
    services.register(LogMiddleware.self)
    services.register(MyErrorMiddleware.self)
    
    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(MyErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(LogMiddleware.self)
    services.register(middlewares)
    
    services.register(SecretMiddleware.self)
    

    // Configure migrations
    var migrations = MigrationConfig()

    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Link.self, database: .psql)
    migrations.add(model: Tag.self, database: .psql)
    migrations.add(model: LinkTagPivot.self, database: .psql)
    migrations.add(model: Token.self, database: .psql)
    services.register(migrations)
    
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
    
    services.register() { _ in UserCache() }

}
