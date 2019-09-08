import Vapor
import Fluent
import FluentPostgreSQL
import Crypto

struct UserController:RouteCollection{
    func boot(router: Router) throws {
        
        let userRoute = router.grouped("api", "user")
        let authMiddleware = AuthenticationMiddleware()
        let protected = userRoute.grouped(authMiddleware)

        protected.get("me", use: me)
        protected.get(use: all)
        protected.get(User.parameter, use: user)
        protected.put(UserUpdateData.self, use:updateMe)
        userRoute.group(SecretMiddleware.self) { secretGroup in
            secretGroup.post(User.self, use: register)
            secretGroup.post(UserLogin.self, at:"login", use: login)
            secretGroup.delete(User.parameter, use: deleteUser)
            secretGroup.put(UserAdminUpdateData.self, at: User.parameter, use: updateUser)
        }
    }
    
    func all(_ req:Request) throws -> Future<[User.Public]>{
        return User.query(on: req).decode(data: User.Public.self).all()
    }

    func user(_ req:Request) throws -> Future<User.Public>{
        return try req.parameters.next(User.self).convertToPublic()
    }
    
    func me(_ req:Request) throws -> Future<User.Public>{
        guard let user = try req.privateContainer.make(UserCache.self).user else {
            throw Abort(.notFound, reason: "user not found")
        }
        return req.future(user.convertToPublic())
    }
    func updateMe(_ req:Request, newUser:UserUpdateData) throws -> Future<User.Public>{
        guard let user = try req.privateContainer.make(UserCache.self).user else{
            throw Abort(.notFound, reason:"user not found")
        }
        user.name = newUser.name
        return user.save(on: req).convertToPublic()
    }
    
    func register(_ req:Request, user:User) throws -> Future<User.Public>{
        user.password = try BCrypt.hash(user.password)
        return user.save(on: req).convertToPublic()
    }
    
    func updateUser(_ req:Request, newUser:UserAdminUpdateData) throws -> Future<User.Public>{
        return try req.parameters.next(User.self).flatMap({ oldUser in
            if try req.privateContainer.make(UserCache.self).user?.id != oldUser.id {
                throw Abort(.unauthorized, reason: "it's not you!")
            }
            oldUser.name = newUser.name
            oldUser.email = newUser.email
            return oldUser.save(on: req).convertToPublic()
        })
    }
    
    func deleteUser(_ req:Request) throws -> Future<HTTPStatus>{
        return try req.parameters.next(User.self).flatMap({ user in
            if try req.privateContainer.make(UserCache.self).user?.id != user.id {
                throw Abort(.unauthorized, reason: "it's not you!")
            }
            return user.delete(on: req)
                .transform(to: HTTPStatus.noContent)
        })
    }

    func login(_ req:Request, userLogin:UserLogin) throws -> Future<Token>{
        return User.query(on: req).filter(\.email == userLogin.email).first().flatMap({ user in
            guard let user = user else {
                throw Abort(.notFound, reason:"wrong user or password")
            }
            let isRight = try BCrypt.verify(userLogin.password, created: user.password)
            if isRight {
                let token = try Token.generate(for: user)
                return try Token.query(on: req).filter(\.userID, .equal, user.requireID()).all().flatMap(to: Token.self, { users in
                    return users.map{$0.delete(on: req)}.flatten(on: req).transform(to: token.save(on: req))
                })
            }
            else{
                throw Abort(.notFound, reason:"wrong user or password")
            }
        })
    }
}

