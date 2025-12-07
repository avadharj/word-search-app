import Fluent
import Vapor

final class GameStatistics: Model, Content {
    static let schema = "game_statistics"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "total_games")
    var totalGames: Int
    
    @Field(key: "total_words")
    var totalWords: Int
    
    @Field(key: "total_score")
    var totalScore: Int
    
    @Field(key: "high_score")
    var highScore: Int
    
    @Field(key: "longest_word")
    var longestWord: String?
    
    @Timestamp(key: "last_updated", on: .update)
    var lastUpdated: Date?
    
    init() {}
    
    init(id: UUID? = nil, userID: UUID, totalGames: Int = 0, totalWords: Int = 0, totalScore: Int = 0, highScore: Int = 0, longestWord: String? = nil) {
        self.id = id
        self.$user.id = userID
        self.totalGames = totalGames
        self.totalWords = totalWords
        self.totalScore = totalScore
        self.highScore = highScore
        self.longestWord = longestWord
    }
}

struct StatisticsRequest: Content {
    let totalGames: Int
    let totalWords: Int
    let totalScore: Int
    let highScore: Int
    let longestWord: String?
}

