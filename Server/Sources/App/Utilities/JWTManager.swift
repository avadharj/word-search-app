import Vapor
import JWT

struct JWTManager {
    static let shared = JWTManager()
    
    private let signer: JWTSigner
    
    private init() {
        // In production, use a secure key from environment
        let secret = Environment.get("JWT_SECRET") ?? "your-secret-key-change-in-production-min-32-chars-long"
        let key = SymmetricKey(string: secret)
        self.signer = JWTSigner.hs256(key: key)
    }
    
    func sign(_ payload: UserTokenPayload) throws -> String {
        let jwt = JWT(payload: payload)
        return try jwt.sign(using: signer)
    }
    
    func verify(_ token: String) throws -> UserTokenPayload {
        let jwt = try JWT<UserTokenPayload>(from: token, verifiedBy: signer)
        return jwt.payload
    }
}

