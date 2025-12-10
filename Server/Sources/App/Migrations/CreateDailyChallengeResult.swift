import Fluent

struct CreateDailyChallengeResult: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("daily_challenge_results")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("challenge_id", .string, .required)
            .field("score", .int, .required)
            .field("words_found", .int, .required)
            .field("completed_at", .datetime)
            .unique(on: "user_id", "challenge_id") // One result per user per challenge
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("daily_challenge_results").delete()
    }
}

