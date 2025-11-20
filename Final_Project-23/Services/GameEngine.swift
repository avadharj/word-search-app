//
//  GameEngine.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import Foundation

class GameEngine {
    let wordValidator = WordValidator.shared
    let soundManager = SoundManager.shared
    
    func canSelectLetter(at index: Int, selectedIndices: [Int], cube: Cube) -> Bool {
        // First letter can always be selected
        if selectedIndices.isEmpty {
            return true
        }
        
        // Check if letter is a neighbor of the last selected letter
        guard let lastIndex = selectedIndices.last else { return false }
        let neighbors = cube.getNeighbors(of: lastIndex)
        return neighbors.contains(index) && !selectedIndices.contains(index)
    }
    
    func validateWord(_ word: String, foundWords: [String]) -> Bool {
        let uppercaseWord = word.uppercased()
        guard uppercaseWord.count >= 3 else { return false }
        guard !foundWords.contains(uppercaseWord) else { return false }
        return wordValidator.isValidWord(uppercaseWord)
    }
    
    func buildWord(from indices: [Int], cube: Cube) -> String {
        return indices.compactMap { index in
            cube.letter(at: index)?.character
        }.map { String($0) }.joined().uppercased()
    }
    
    func processWordSelection(at index: Int, gameState: GameState) {
        let cube = gameState.cube
        
        // Check if we can select this letter
        if canSelectLetter(at: index, selectedIndices: gameState.selectedIndices, cube: cube) {
            // Add to selection
            gameState.selectedIndices.append(index)
            
            // Play selection sound and haptic
            soundManager.playSound("letterSelect")
            soundManager.playHaptic(.light)
            
            // Build current word
            let word = buildWord(from: gameState.selectedIndices, cube: cube)
            gameState.currentWord = word
            
            // Check if it's a valid word
            if validateWord(word, foundWords: gameState.wordsFound) {
                // Word is valid - add it
                gameState.addWord(word)
                
                // Play success sound and haptic
                soundManager.playSound("wordFound")
                soundManager.playHaptic(.success)
                
                // Mark letters as used
                for selectedIndex in gameState.selectedIndices {
                    gameState.cube.useLetter(at: selectedIndex)
                }
                
                // Check if any letters were removed
                let removedCount = gameState.selectedIndices.filter { 
                    cube.letter(at: $0)?.isRemoved == true 
                }.count
                
                if removedCount > 0 {
                    soundManager.playSound("letterRemove")
                    soundManager.playHaptic(.medium)
                }
                
                // Reset selection
                gameState.resetSelection()
            } else {
                // Check if it's a valid prefix
                if !wordValidator.isPrefix(word) {
                    // Invalid prefix - reset selection
                    soundManager.playSound("wordInvalid")
                    soundManager.playHaptic(.error)
                    gameState.resetSelection()
                }
            }
        } else if gameState.selectedIndices.contains(index) {
            // If clicking on a selected letter, deselect from that point
            if let position = gameState.selectedIndices.firstIndex(of: index) {
                gameState.selectedIndices = Array(gameState.selectedIndices[..<position])
                let word = buildWord(from: gameState.selectedIndices, cube: cube)
                gameState.currentWord = word
                soundManager.playHaptic(.light)
            }
        } else {
            // Invalid selection
            soundManager.playHaptic(.error)
        }
    }
}

