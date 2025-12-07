import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: AuthController())
    try app.register(collection: StatisticsController())
    try app.register(collection: LeaderboardController())
    try app.register(collection: GameHistoryController())
    try app.register(collection: DictionaryController())
}

