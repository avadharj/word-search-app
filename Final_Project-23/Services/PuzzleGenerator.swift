//
//  PuzzleGenerator.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import Foundation

class PuzzleGenerator {
    static let shared = PuzzleGenerator()
    private let wordValidator = WordValidator.shared
    
    // Common words that are easier to embed in puzzles
    private let commonWords = [
        "CAT", "DOG", "BAT", "RAT", "MAT", "HAT", "SAT", "FAT",
        "THE", "AND", "FOR", "ARE", "BUT", "NOT", "YOU", "ALL",
        "CAN", "HER", "WAS", "ONE", "OUR", "OUT", "DAY", "GET",
        "HAS", "HIM", "HIS", "HOW", "ITS", "MAY", "NEW", "NOW",
        "OLD", "SEE", "TWO", "WHO", "BOY", "DID", "LET", "PUT",
        "SAY", "SHE", "TOO", "USE", "WORD", "ABLE", "BACK", "BALL",
        "BAND", "BANK", "BASE", "BEAR", "BEAT", "BEEN", "BELL", "BEST",
        "BILL", "BIRD", "BLOW", "BLUE", "BOAT", "BODY", "BOOK", "BORN",
        "BOTH", "BOYS", "BUSY", "CALL", "CALM", "CAME", "CAMP", "CARD",
        "CARE", "CASE", "CAST", "CAVE", "CHIP", "CITY", "CLAY", "CLUB",
        "COAL", "COAT", "CODE", "COLD", "COME", "COOK", "COOL", "COPY",
        "CORD", "CORE", "CORN", "COST", "CREW", "CROP", "CROW", "CUBE"
    ]
    
    private init() {}
    
    func generatePuzzle(size: Int, difficulty: Difficulty) -> Puzzle {
        let cube = Cube(size: size)
        var cubeLetters: [Letter] = []
        var validWords: Set<String> = []
        
        // Generate base letters
        let totalCells = size * size * size
        var letterGrid = Array(repeating: Array(repeating: Array(repeating: Character("A"), count: size), count: size), count: size)
        
        // First, try to embed some valid words
        let wordsToEmbed = selectWordsForEmbedding(size: size, difficulty: difficulty)
        validWords = embedWords(wordsToEmbed, into: &letterGrid, size: size)
        
        // Fill remaining cells with random letters
        fillRemainingCells(&letterGrid, size: size)
        
        // Convert 3D grid to letter array
        for i in 0..<totalCells {
            let x = i % size
            let y = (i / size) % size
            let z = i / (size * size)
            
            let letter = Letter(
                id: i,
                character: letterGrid[z][y][x],
                position: Puzzle.calculatePosition(index: i, size: size),
                usageCount: 0
            )
            cubeLetters.append(letter)
        }
        
        cube.letters = cubeLetters
        
        return Puzzle(cube: cube, validWords: validWords)
    }
    
    private func selectWordsForEmbedding(size: Int, difficulty: Difficulty) -> [String] {
        let maxWords: Int
        let minWordLength: Int
        let maxWordLength: Int
        
        switch difficulty {
        case .easy:
            maxWords = min(5, size * size)
            minWordLength = 3
            maxWordLength = 4
        case .medium:
            maxWords = min(8, size * size * 2)
            minWordLength = 3
            maxWordLength = 5
        case .hard:
            maxWords = min(12, size * size * size)
            minWordLength = 4
            maxWordLength = 6
        }
        
        let filteredWords = commonWords.filter { word in
            word.count >= minWordLength && word.count <= maxWordLength &&
            wordValidator.isValidWord(word)
        }
        
        return Array(filteredWords.shuffled().prefix(maxWords))
    }
    
    private func embedWords(_ words: [String], into grid: inout [[[Character]]], size: Int) -> Set<String> {
        var embeddedWords: Set<String> = []
        var usedPositions = Set<[Int]>()
        
        for word in words {
            if let path = findValidPath(for: word, in: grid, size: size, excluding: usedPositions) {
                // Place word along path
                for (index, char) in word.enumerated() {
                    let pos = path[index]
                    grid[pos[2]][pos[1]][pos[0]] = char
                    usedPositions.insert(pos)
                }
                embeddedWords.insert(word)
            }
        }
        
        return embeddedWords
    }
    
    private func findValidPath(for word: String, in grid: [[[Character]]], size: Int, excluding usedPositions: Set<[Int]>) -> [[Int]]? {
        // Try multiple random starting positions
        for _ in 0..<50 {
            let startX = Int.random(in: 0..<size)
            let startY = Int.random(in: 0..<size)
            let startZ = Int.random(in: 0..<size)
            
            let startPos = [startX, startY, startZ]
            if usedPositions.contains(startPos) { continue }
            
            if let path = findPath(from: startPos, for: word, in: grid, size: size, excluding: usedPositions) {
                return path
            }
        }
        
        return nil
    }
    
    private func findPath(from start: [Int], for word: String, in grid: [[[Character]]], size: Int, excluding usedPositions: Set<[Int]>, path: [[Int]] = []) -> [[Int]]? {
        var currentPath = path
        currentPath.append(start)
        
        if currentPath.count == word.count {
            return currentPath
        }
        
        let nextCharIndex = currentPath.count
        let nextChar = word[word.index(word.startIndex, offsetBy: nextCharIndex)]
        
        // Get neighbors
        let neighbors = getNeighbors3D(start, size: size)
        
        for neighbor in neighbors.shuffled() {
            if usedPositions.contains(neighbor) { continue }
            if currentPath.contains(neighbor) { continue }
            
            // Check if this position has the right character or is empty
            let char = grid[neighbor[2]][neighbor[1]][neighbor[0]]
            if char == "A" || char == nextChar {
                if let result = findPath(from: neighbor, for: word, in: grid, size: size, excluding: usedPositions, path: currentPath) {
                    return result
                }
            }
        }
        
        return nil
    }
    
    private func getNeighbors3D(_ pos: [Int], size: Int) -> [[Int]] {
        let x = pos[0]
        let y = pos[1]
        let z = pos[2]
        var neighbors: [[Int]] = []
        
        for dx in -1...1 {
            for dy in -1...1 {
                for dz in -1...1 {
                    if dx == 0 && dy == 0 && dz == 0 { continue }
                    
                    let nx = x + dx
                    let ny = y + dy
                    let nz = z + dz
                    
                    if nx >= 0 && nx < size && ny >= 0 && ny < size && nz >= 0 && nz < size {
                        neighbors.append([nx, ny, nz])
                    }
                }
            }
        }
        
        return neighbors
    }
    
    private func fillRemainingCells(_ grid: inout [[[Character]]], size: Int) {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        
        for z in 0..<size {
            for y in 0..<size {
                for x in 0..<size {
                    if grid[z][y][x] == "A" {
                        grid[z][y][x] = letters.randomElement() ?? "A"
                    }
                }
            }
        }
    }
}

enum Difficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var cubeSize: Int {
        switch self {
        case .easy: return 3
        case .medium: return 3
        case .hard: return 4
        }
    }
    
    var description: String {
        switch self {
        case .easy:
            return "3x3x3 cube with shorter words"
        case .medium:
            return "3x3x3 cube with medium words"
        case .hard:
            return "4x4x4 cube with longer words"
        }
    }
}

