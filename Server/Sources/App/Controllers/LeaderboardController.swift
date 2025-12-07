import Vapor
import Fluent

struct LeaderboardController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let leaderboard = routes.grouped("api", "leaderboard")
        leaderboard.get(use: getLeaderboard)
    }
    
    func getLeaderboard(req: Request) throws -> EventLoopFuture<[LeaderboardEntryResponse]> {
        let limit = req.query[Int.self, at: "limit"] ?? 100
        
        return GameStatistics.query(on: req.db)
            .join(User.self, on: \GameStatistics.$user.$id == \User.$id)
            .sort(\.$highScore, .descending)
            .limit(limit)
            .all()
            .flatMap { stats in
                let entries = stats.enumerated().map { index, stat -> EventLoopFuture<LeaderboardEntryResponse> in
                    return stat.$user.get(on: req.db).map { user in
                        LeaderboardEntryResponse(
                            id: stat.id!,
                            playerName: user.username,
                            score: stat.highScore,
                            wordsFound: stat.totalWords,
                            date: stat.lastUpdated ?? Date(),
                            rank: index + 1
                        )
                    }
                }
                return EventLoopFuture.whenAllSucceed(entries, on: req.eventLoop)
            }
    }
}

struct LeaderboardEntryResponse: Content {
    let id: UUID
    let playerName: String
    let score: Int
    let wordsFound: Int
    let date: Date
    let rank: Int
}

