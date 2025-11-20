import Vapor
import JWT
import Fluent

struct UserTokenAuthenticator: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) -> EventLoopFuture<Response> {
        guard let bearerToken = request.headers.bearerAuthorization?.token else {
            return request.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "Missing authorization token"))
        }
        
        do {
            let payload = try JWTManager.shared.verify(bearerToken)
            
            return User.find(payload.userId, on: request.db)
                .unwrap(or: Abort(.unauthorized, reason: "User not found"))
                .flatMap { user in
                    request.auth.login(user)
                    return next.respond(to: request)
                }
        } catch {
            return request.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "Invalid token"))
        }
    }
}

