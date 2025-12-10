import Vapor
import JWTKit

struct JWTManager {
    static let shared = JWTManager()
    
    private let signers: JWTSigners
    
    private init() {
        // In production, use a secure key from environment
        let secret = Environment.get("JWT_SECRET") ?? "your-secret-key-change-in-production-min-32-chars-long"
        let signers = JWTSigners()
        signers.use(.hs256(key: secret))
        self.signers = signers
    }
    
    func sign(_ payload: UserTokenPayload) throws -> String {
        return try signers.sign(payload)
    }
    
    func verify(_ token: String) throws -> UserTokenPayload {
        return try signers.verify(token, as: UserTokenPayload.self)
    }
}

