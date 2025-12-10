import Vapor
import Fluent

struct DailyChallengeController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let dailyChallenge = routes.grouped("api", "daily-challenge")
        
        // Submit result (requires auth)
        let protected = dailyChallenge.grouped(UserTokenAuthenticator())
        protected.post(use: submitResult)
        
        // Leaderboard (public, but can be filtered by auth)
        dailyChallenge.get("leaderboard", use: getLeaderboard)
    }
    
    func submitResult(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.auth.require(User.self)
        let resultRequest = try req.content.decode(DailyChallengeResultRequest.self)
        let userID = try user.requireID()
        
        return DailyChallengeResult.query(on: req.db)
            .filter(\.$user.$id == userID)
            .filter(\.$challengeId == resultRequest.challengeId)
            .first()
            .flatMapThrowing { existingResult -> EventLoopFuture<HTTPStatus> in
                if let existing = existingResult {
                    // Update if new score is higher
                    if resultRequest.score > existing.score {
                        existing.score = resultRequest.score
                        existing.wordsFound = resultRequest.wordsFound
                        return existing.update(on: req.db).transform(to: .ok)
                    } else {
                        // Keep existing higher score
                        return req.eventLoop.makeSucceededFuture(.ok)
                    }
                } else {
                    // Create new result
                    let result = DailyChallengeResult(
                        userID: userID,
                        challengeId: resultRequest.challengeId,
                        score: resultRequest.score,
                        wordsFound: resultRequest.wordsFound
                    )
                    return result.create(on: req.db).transform(to: .created)
                }
            }
            .flatMap { $0 }
    }
    
    func getLeaderboard(req: Request) throws -> EventLoopFuture<[DailyChallengeLeaderboardResponse]> {
        guard let challengeId = req.query[String.self, at: "challengeId"] else {
            throw Abort(.badRequest, reason: "challengeId is required")
        }
        let limit = req.query[Int.self, at: "limit"] ?? 100
        
        return DailyChallengeResult.query(on: req.db)
            .filter(\.$challengeId == challengeId)
            .sort(\.$score, .descending)
            .limit(limit)
            .all()
            .flatMap { results in
                guard !results.isEmpty else {
                    return req.eventLoop.makeSucceededFuture([])
                }
                
                let entries = results.enumerated().map { index, result -> EventLoopFuture<DailyChallengeLeaderboardResponse> in
                    return result.$user.get(on: req.db).map { user in
                        DailyChallengeLeaderboardResponse(
                            id: result.id!,
                            playerName: user.username,
                            score: result.score,
                            wordsFound: result.wordsFound,
                            date: result.completedAt ?? Date(),
                            rank: index + 1
                        )
                    }
                }
                return EventLoopFuture.whenAllSucceed(entries, on: req.eventLoop)
            }
    }
}

