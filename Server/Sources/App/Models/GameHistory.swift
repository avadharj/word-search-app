import Fluent
import Vapor

final class GameHistory: Model, Content {
    static let schema = "game_history"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "score")
    var score: Int
    
    @Field(key: "words_found")
    var wordsFound: Int
    
    @Field(key: "words")
    var words: [String]
    
    @Timestamp(key: "played_at", on: .create)
    var playedAt: Date?
    
    init() {}
    
    init(id: UUID? = nil, userID: UUID, score: Int, wordsFound: Int, words: [String]) {
        self.id = id
        self.$user.id = userID
        self.score = score
        self.wordsFound = wordsFound
        self.words = words
    }
}

struct GameHistoryRequest: Content {
    let score: Int
    let wordsFound: Int
    let words: [String]
}

