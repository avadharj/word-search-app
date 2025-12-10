import Vapor
import BCrypt

struct PasswordHasher {
    static func hash(_ password: String) throws -> String {
        let digest = try Hash.make(message: password)
        return digest.makeString()
    }
    
    static func verify(_ password: String, hash: String) throws -> Bool {
        return try Hash.verify(message: password, matches: hash)
    }
}

