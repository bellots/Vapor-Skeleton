import Vapor
import FluentPostgreSQL
extension Model where Self:Parameter{
    public static func make(for parameter: String, using container: Container) throws -> Future<Self> {
        guard let idType = ID.self as? LosslessStringConvertible.Type else {
            throw FluentError(
                identifier: "invalidIDType",
                reason: "Could not convert string to ID.",
                suggestedFixes: ["Conform `\(ID.self)` to `LosslessStringConvertible` to fix this error."]
            )
        }
        
        guard let id = idType.init(parameter) as? ID else {
            throw FluentError(
                identifier: "invalidID",
                reason: "Could not convert parameter \(parameter) to type `\(ID.self)`"
            )
        }
        
        func findModel(in connection: Database.Connection) throws -> Future<Self> {
            return self.find(id, on: connection).map(to: Self.self) { model in
                guard let model = model else {
                    let error = FluentError(identifier: "modelNotFound", reason: "No \(Self.self) with ID \(id) was found")
                    throw NotFound(rootCause:error)
                }
                return model
            }
        }
        
        let dbid = try Self.requireDefaultDatabase()
        if let subcontainer = container as? SubContainer {
            let connection = subcontainer.requestCachedConnection(to: dbid)
            return connection.flatMap(to: Self.self, findModel)
        } else {
            return container.withPooledConnection(to: dbid, closure: findModel)
        }
    }
    
    /// See `Parameter`.
    public static func resolveParameter(_ parameter: String, on container: Container) throws -> Future<Self> {
        return try make(for: parameter, using: container)
    }
}
