import Fluent
import Vapor

final class DailyChallengeResult: Model, Content {
    static let schema = "daily_challenge_results"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "challenge_id")
    var challengeId: String
    
    @Field(key: "score")
    var score: Int
    
    @Field(key: "words_found")
    var wordsFound: Int
    
    @Timestamp(key: "completed_at", on: .create)
    var completedAt: Date?
    
    init() {}
    
    init(id: UUID? = nil, userID: UUID, challengeId: String, score: Int, wordsFound: Int) {
        self.id = id
        self.$user.id = userID
        self.challengeId = challengeId
        self.score = score
        self.wordsFound = wordsFound
    }
}

struct DailyChallengeResultRequest: Content {
    let challengeId: String
    let score: Int
    let wordsFound: Int
}

struct DailyChallengeLeaderboardResponse: Content {
    let id: UUID
    let playerName: String
    let score: Int
    let wordsFound: Int
    let date: Date
    let rank: Int
}

