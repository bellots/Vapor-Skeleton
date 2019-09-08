import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req -> String in
        return "Funziona?!"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, {{Skeleton}}!"
    }
    
    router.get("sum") { req -> SumDatas in
        guard let first = req.query[Int.self, at: "first"],
            let second = req.query[Int.self, at: "second"] else{
                throw Abort(.badRequest)
        }
        return SumDatas(first: first, second: second)
    }
    
    try router.register(collection: UserController())
    try router.register(collection: TokenController())
}

struct SumDatas:Content{
    var first:Int
    var second:Int
}
