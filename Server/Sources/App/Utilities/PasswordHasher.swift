import Vapor
import Bcrypt

struct PasswordHasher {
    static func hash(_ password: String) throws -> String {
        return try Bcrypt.hash(password)
    }
    
    static func verify(_ password: String, hash: String) throws -> Bool {
        return try Bcrypt.verify(password, created: hash)
    }
}

