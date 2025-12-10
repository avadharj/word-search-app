import Vapor
import Fluent

struct StatisticsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let protected = routes.grouped("api", "statistics")
            .grouped(UserTokenAuthenticator())
        
        protected.post(use: syncStatistics)
        protected.get(use: getStatistics)
    }
    
    func syncStatistics(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.auth.require(User.self)
        let statsRequest = try req.content.decode(StatisticsRequest.self)
        let userID = try user.requireID()
        
        return GameStatistics.query(on: req.db)
            .filter(\.$user.$id == userID)
            .first()
            .flatMapThrowing { existingStats -> EventLoopFuture<HTTPStatus> in
                if let stats = existingStats {
                    // Update existing
                    stats.totalGames = statsRequest.totalGames
                    stats.totalWords = statsRequest.totalWords
                    stats.totalScore = statsRequest.totalScore
                    stats.highScore = max(stats.highScore, statsRequest.highScore)
                    if let longest = statsRequest.longestWord, longest.count > (stats.longestWord?.count ?? 0) {
                        stats.longestWord = longest
                    }
                    return stats.update(on: req.db).transform(to: .ok)
                } else {
                    // Create new
                    let stats = GameStatistics(
                        userID: try user.requireID(),
                        totalGames: statsRequest.totalGames,
                        totalWords: statsRequest.totalWords,
                        totalScore: statsRequest.totalScore,
                        highScore: statsRequest.highScore,
                        longestWord: statsRequest.longestWord
                    )
                    return stats.create(on: req.db).transform(to: .created)
                }
            }
            .flatMap { $0 }
    }
    
    func getStatistics(req: Request) throws -> EventLoopFuture<GameStatistics> {
        let user = try req.auth.require(User.self)
        let userID = try user.requireID()
        
        return GameStatistics.query(on: req.db)
            .filter(\.$user.$id == userID)
            .first()
            .unwrap(or: Abort(.notFound, reason: "Statistics not found"))
    }
}

