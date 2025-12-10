import Vapor
import Fluent

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("api", "auth")
        auth.post("register", use: register)
        auth.post("login", use: login)
        
        // Also support /api/auth for login (iOS app uses this)
        routes.post("api", "auth", use: login)
    }
    
    func register(req: Request) throws -> EventLoopFuture<AuthResponse> {
        try RegisterRequest.validate(content: req)
        let registerRequest = try req.content.decode(RegisterRequest.self)
        
        // Check if user exists
        return User.query(on: req.db)
            .filter(\.$username == registerRequest.username)
            .first()
            .flatMap { existingUser in
                if existingUser != nil {
                    return req.eventLoop.makeFailedFuture(Abort(.conflict, reason: "Username already exists"))
                }
                
                // Check email
                return User.query(on: req.db)
                    .filter(\.$email == registerRequest.email)
                    .first()
                    .flatMapThrowing { existingEmail -> EventLoopFuture<AuthResponse> in
                        if existingEmail != nil {
                            return req.eventLoop.makeFailedFuture(Abort(.conflict, reason: "Email already exists"))
                        }
                        
                        // Create user
                        let passwordHash = try PasswordHasher.hash(registerRequest.password)
                        let user = User(
                            username: registerRequest.username,
                            email: registerRequest.email,
                            passwordHash: passwordHash
                        )
                        
                        return user.save(on: req.db).flatMapThrowing {
                            let expiration = Date().addingTimeInterval(3600 * 24 * 7) // 7 days
                            let token = try user.generateToken()
                            
                            let response = AuthResponse(
                                token: token,
                                expiresAt: expiration,
                                userId: user.id!,
                                user: UserResponse(id: user.id!, username: user.username, email: user.email)
                            )
                            
                            return response
                        }
                    }
                    .flatMap { $0 }
            }
    }
    
    func login(req: Request) throws -> EventLoopFuture<AuthResponse> {
        try AuthRequest.validate(content: req)
        let authRequest = try req.content.decode(AuthRequest.self)
        
        return User.query(on: req.db)
            .filter(\.$username == authRequest.username)
            .first()
            .unwrap(or: Abort(.unauthorized, reason: "Invalid credentials"))
            .flatMapThrowing { user in
                guard try PasswordHasher.verify(authRequest.password, hash: user.passwordHash) else {
                    throw Abort(.unauthorized, reason: "Invalid credentials")
                }
                
                let expiration = Date().addingTimeInterval(3600 * 24 * 7) // 7 days
                let token = try user.generateToken()
                
                let response = AuthResponse(
                    token: token,
                    expiresAt: expiration,
                    userId: user.id!,
                    user: UserResponse(id: user.id!, username: user.username, email: user.email)
                )
                
                return response
            }
    }
}

extension RegisterRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("username", as: String.self, is: .count(3...))
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(6...))
    }
}

extension AuthRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("username", as: String.self, is: !.empty)
        validations.add("password", as: String.self, is: !.empty)
    }
}

