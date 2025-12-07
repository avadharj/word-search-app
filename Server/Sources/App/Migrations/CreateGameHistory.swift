import Fluent

struct CreateGameHistory: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("game_history")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("score", .int, .required)
            .field("words_found", .int, .required)
            .field("words", .array(of: .string), .required)
            .field("played_at", .datetime)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("game_history").delete()
    }
}

