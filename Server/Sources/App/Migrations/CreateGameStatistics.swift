import Fluent

struct CreateGameStatistics: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("game_statistics")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("total_games", .int, .required)
            .field("total_words", .int, .required)
            .field("total_score", .int, .required)
            .field("high_score", .int, .required)
            .field("longest_word", .string)
            .field("last_updated", .datetime)
            .unique(on: "user_id")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("game_statistics").delete()
    }
}

