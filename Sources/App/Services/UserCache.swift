import Vapor

// Service to keep logged user during the request cycle

final class UserCache: Service {
    var user: User?
}

extension Request {
    var user: User? {
        get {
            return (try? privateContainer.make(UserCache.self))?.user
        }
        
        set {
            (try? privateContainer.make(UserCache.self))?.user = newValue
        }
    }
}
