import Vapor
import FluentPostgreSQL

final class User:Codable{
    var id:Int?
    var name:String
    var email:String
    var password:String
    
    init(name:String, email:String, password:String){
        self.name = name
        self.email = email
        self.password = password
    }
    
    final class Public:Codable{
        var id:Int?
        var name:String
        var email:String
        
        init(id:Int?, name:String, email:String){
            self.id = id
            self.name = name
            self.email = email
        }
    }
}


struct UserUpdateData:Content{
    let name:String
}

struct UserAdminUpdateData:Content{
    let name:String
    let email:String
}


struct UserLogin:Content {
    let email:String
    let password:String
}

extension User.Public:Content{}

extension User:PostgreSQLModel{}
extension User:Parameter{}
extension User:Migration{
    static func prepare( on connection: PostgreSQLConnection)->Future<Void>{
        return Database.create(self, on: connection, closure: { builder in
            try addProperties(to: builder)
            builder.unique(on: \.email)
        })
    }
}

extension User:Content{}


// Transformers

extension User{
    func convertToPublic() ->User.Public{
        return User.Public(id: id, name: name, email: email)
    }
}

extension Future where T:User {
    func convertToPublic()->Future<User.Public>{
        return self.map(to: User.Public.self, { user in
            return user.convertToPublic()
        })
    }
}

// ➡️ Relationships
extension User{
    var links:Children<User, Link>{
        return children(\.userID)
    }
    
    var tokens:Children<User, Token>{
        return children(\.userID)
    }
    var tags:Children<User, Tag>{
        return children(\.userID)
    }
}

    
