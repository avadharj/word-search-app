import Fluent
import Vapor

final class User: Model, Content, Authenticatable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Children(for: \.$user)
    var statistics: [GameStatistics]
    
    @Children(for: \.$user)
    var gameHistory: [GameHistory]
    
    init() {}
    
    init(id: UUID? = nil, username: String, email: String, passwordHash: String) {
        self.id = id
        self.username = username
        self.email = email
        self.passwordHash = passwordHash
    }
}

extension User {
    func generateToken() throws -> String {
        let expiration = Date().addingTimeInterval(3600 * 24 * 7) // 7 days
        let payload = UserTokenPayload(
            userId: try self.requireID(),
            expiration: expiration
        )
        return try JWTManager.shared.sign(payload)
    }
}

// User authentication is handled via JWT tokens, not ModelAuthenticatable

struct UserTokenPayload: JWTPayload {
    var userId: UUID
    var exp: ExpirationClaim
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case exp
    }
    
    init(userId: UUID, expiration: Date) {
        self.userId = userId
        self.exp = ExpirationClaim(value: expiration)
    }
    
    func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}

struct UserResponse: Content {
    let id: UUID
    let username: String
    let email: String
}

struct AuthRequest: Content {
    let username: String
    let password: String
}

struct RegisterRequest: Content {
    let username: String
    let email: String
    let password: String
}

struct AuthResponse: Content {
    let token: String
    let expiresAt: Date
    let userId: UUID
    let user: UserResponse
}

