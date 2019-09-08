import Vapor
import Fluent
import FluentPostgreSQL

struct TokenController:RouteCollection{
    func boot(router: Router) throws {
        
        let tokenRoute = router.grouped("api", "token")
        
        tokenRoute.group(SecretMiddleware.self) { secretGroup in
            secretGroup.get(use: all)
            secretGroup.get(Token.parameter, use: token)
            secretGroup.post(Token.self, use: save)
            secretGroup.delete(Token.parameter, use: delete)
        }
    }
    
    func all(_ req:Request) throws -> Future<[Token]>{
        return Token.query(on: req).all()
    }

    func token(_ req:Request) throws -> Future<Token>{
        return try req.parameters.next(Token.self)
    }

    func save(_ req:Request, token:Token) throws -> Future<Token>{
        return token.save(on: req)
    }

    func delete(_ req:Request) throws -> Future<HTTPStatus>{
        let token = try req.parameters.next(Token.self)
        return token.delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }
    
}

