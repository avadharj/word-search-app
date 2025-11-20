import Vapor
import Fluent

struct GameHistoryController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let protected = routes.grouped("api", "game-history")
            .grouped(UserTokenAuthenticator())
        
        protected.post(use: syncGameHistory)
        protected.get(use: getGameHistory)
    }
    
    func syncGameHistory(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.auth.require(User.self)
        let historyRequests = try req.content.decode([GameHistoryRequest].self)
        
        let histories = historyRequests.map { historyRequest in
            GameHistory(
                userID: user.requireID(),
                score: historyRequest.score,
                wordsFound: historyRequest.wordsFound,
                words: historyRequest.words
            )
        }
        
        return histories.create(on: req.db).transform(to: .created)
    }
    
    func getGameHistory(req: Request) throws -> EventLoopFuture<[GameHistory]> {
        let user = try req.auth.require(User.self)
        let limit = req.query[Int.self, at: "limit"] ?? 100
        
        return GameHistory.query(on: req.db)
            .filter(\.$user.$id == user.requireID())
            .sort(\.$playedAt, .descending)
            .limit(limit)
            .all()
    }
}

