// Created by deovinsum

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords: [String] = []
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var pointsStat = 0
    
    
    var body: some View {
        
        NavigationStack {
            
                Text("Points: \(pointsStat)")
            
            List {
                Section {
                    TextField("Enter new word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                        }
                    }
                }
            }
            
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("New Game") {
                        startGame()
                    }
                }
            }
            
            .navigationTitle(rootWord)
            
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 3 else { return }
        
        guard isInitial(word: answer) else {
            wordError(title: "Answer matches with initial word", message: "Be more original!")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word already used", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can not spell this word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can not just make them up, you know!")
            return
        }
        
        pointsStat += answer.count
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "badword"
                usedWords = []
                pointsStat = 0
                newWord = ""
                return
            }
        }
        
        fatalError("Couldn't load start.txt from main bundle.")
        
    }
    
    func isInitial(word: String) -> Bool {
        word != rootWord
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
        
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
