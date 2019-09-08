import Vapor

final class SecretMiddleware:Middleware {
    let secret:String
    
    init(secret:String){
        self.secret = secret
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        guard request.http.headers.firstValue(name: .secret) == secret else {
            throw Abort(.unauthorized, reason: "Incorrect X-Secret header.")
        }
        return try next.respond(to: request)
    }
}


extension HTTPHeaderName {
    public static let secret = HTTPHeaderName("X-Secret")
}

extension SecretMiddleware:ServiceType{
    static func makeService(for container: Container) throws -> SecretMiddleware {
        let secret:String
        switch container.environment{
        case .development:
            secret = "foo"
        default:
            guard let envSecret = Environment.get("SECRET") else{
                let reason = """
                    NO $SECRET set on environment. \
                    Use "export SECRET =<secret>"
                    """
                throw Abort(.internalServerError, reason:reason)
            }
            secret = envSecret
        }
        return SecretMiddleware(secret: secret)
    }
}
