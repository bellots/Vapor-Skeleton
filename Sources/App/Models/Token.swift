import Vapor
import FluentPostgreSQL
import Crypto

final class Token:Codable{
    var id:UUID?
    var token:String
    var userID: User.ID
    
    init(token:String, userID:User.ID){
        self.token = token
        self.userID = userID
    }
}

extension Token:PostgreSQLUUIDModel{}
extension Token:Parameter{}
extension Token:Migration{
    static func prepare(on connection:PostgreSQLConnection)->Future<Void>{
        return Database.create(self, on: connection, closure: { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        })
    }
}
extension Token:Content{}


extension Token{
    static func generate(for user:User) throws -> Token{
        let random = try CryptoRandom().generateData(count: 16)
        return try Token(token: random.base64EncodedString(), userID: user.requireID())
    }
}



// ➡️ Relationships

extension Token{
    var user: Parent<Token, User>{
        return parent(\.userID)
    }    
}



    
