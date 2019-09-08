import Vapor
import Fluent
import FluentPostgreSQL

final class AuthenticationMiddleware:Middleware{
    func respond(to request:Request, chainingTo next:Responder) throws -> Future<Response>{
        guard let authorization = request.http.headers.firstValue(name: .authorization) else{
            throw Abort(.unauthorized, reason: "missing authorization")
        }
        guard let range = authorization.range(of: "Bearer ") else {
            throw Abort(.unauthorized, reason: "wrong format for authorization")
        }
                
        let token = authorization[range.upperBound...]
        let tokenString = String(token)
        return Token.query(on: request)
            .filter(\.token, .equal, tokenString)
            .first()
            .unwrap(or: Abort(.unauthorized, reason: "Invalid Token"))
            .flatMap({ token in
                return token.user.get(on: request).flatMap({ user in
                    let userCache = try request.privateContainer.make(UserCache.self)
                    userCache.user = user
                    return try next.respond(to: request)
                })
            })
    }
}

