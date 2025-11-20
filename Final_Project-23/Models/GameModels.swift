//
//  GameModels.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import Foundation
import simd

// MARK: - Game State
class GameState: ObservableObject {
    @Published var score: Int = 0
    @Published var wordsFound: [String] = []
    @Published var currentWord: String = ""
    @Published var selectedIndices: [Int] = []
    @Published var cube: Cube
    @Published var isPaused: Bool = false
    @Published var gameOver: Bool = false
    
    init(cube: Cube) {
        self.cube = cube
    }
    
    func addWord(_ word: String) {
        guard !wordsFound.contains(word) else { return }
        wordsFound.append(word)
        calculateScore(for: word)
    }
    
    func calculateScore(for word: String) {
        let baseScore = word.count * 10
        let bonus = word.count >= 6 ? (word.count - 5) * 20 : 0
        score += baseScore + bonus
    }
    
    func resetSelection() {
        selectedIndices = []
        currentWord = ""
    }
}

// MARK: - Cube
class Cube: ObservableObject {
    let size: Int // Cube dimension (e.g., 3x3x3)
    @Published var letters: [Letter]
    
    init(size: Int = 3) {
        self.size = size
        self.letters = []
    }
    
    func letter(at index: Int) -> Letter? {
        guard index >= 0 && index < letters.count else { return nil }
        return letters[index]
    }
    
    func useLetter(at index: Int) {
        guard index >= 0 && index < letters.count else { return }
        letters[index].usageCount += 1
        objectWillChange.send()
    }
    
    func getNeighbors(of index: Int) -> [Int] {
        let x = index % size
        let y = (index / size) % size
        let z = index / (size * size)
        
        var neighbors: [Int] = []
        
        // Check all 26 possible neighbors (3D)
        for dx in -1...1 {
            for dy in -1...1 {
                for dz in -1...1 {
                    if dx == 0 && dy == 0 && dz == 0 { continue }
                    
                    let nx = x + dx
                    let ny = y + dy
                    let nz = z + dz
                    
                    if nx >= 0 && nx < size &&
                       ny >= 0 && ny < size &&
                       nz >= 0 && nz < size {
                        let neighborIndex = nz * size * size + ny * size + nx
                        neighbors.append(neighborIndex)
                    }
                }
            }
        }
        
        return neighbors
    }
}

// MARK: - Letter
struct Letter: Identifiable {
    let id: Int
    let character: Character
    var position: SIMD3<Float>
    var usageCount: Int = 0
    var isSelected: Bool = false
    
    static let maxUsage = 3
    var isRemoved: Bool {
        usageCount >= Letter.maxUsage
    }
}

// MARK: - Puzzle
struct Puzzle {
    let cube: Cube
    let validWords: Set<String>
    
    static func generate(size: Int = 3) -> Puzzle {
        let cube = Cube(size: size)
        
        // Generate random letters for the cube
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var cubeLetters: [Letter] = []
        
        let totalCells = size * size * size
        for i in 0..<totalCells {
            let randomChar = letters.randomElement() ?? "A"
            let letter = Letter(
                id: i,
                character: randomChar,
                position: calculatePosition(index: i, size: size),
                usageCount: 0
            )
            cubeLetters.append(letter)
        }
        
        cube.letters = cubeLetters
        
        // For now, return empty valid words set
        // In a full implementation, this would embed valid words
        return Puzzle(cube: cube, validWords: Set<String>())
    }
    
    static func calculatePosition(index: Int, size: Int) -> SIMD3<Float> {
        let x = Float(index % size) - Float(size - 1) / 2.0
        let y = Float((index / size) % size) - Float(size - 1) / 2.0
        let z = Float(index / (size * size)) - Float(size - 1) / 2.0
        return SIMD3<Float>(x, y, z)
    }
}

