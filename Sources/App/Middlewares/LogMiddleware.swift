import Vapor

final class LogMiddleware:Middleware{
    let logger:Logger
    
    init(logger:Logger){
        self.logger = logger
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        let start = Date()
        
        return try next.respond(to: request).map({ res in
            self.log(res, start:start, for: request)
            return res
        })
    }
    
    func log(_ res:Response, start:Date, for req:Request){
        let reqInfo = "\(req.http.method.string) \(req.http.url.path)"
        let resInfo = "\(res.http.status.code) " + "\(res.http.status.reasonPhrase)"
        let time
            = Date().timeIntervalSince(start).milliSeconds
        logger.info("\(reqInfo) -> \(resInfo) [\(time)]")
    }

}

extension LogMiddleware:ServiceType{
    static func makeService(for container: Container) throws -> Self {
        return try .init(logger:container.make())
    }
}


extension TimeInterval{
    var milliSeconds:String{
        return "\(Int((self.truncatingRemainder(dividingBy: 1)) * 1000)) ms"
    }
}
