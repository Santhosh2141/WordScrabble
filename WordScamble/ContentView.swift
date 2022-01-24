//
//  ContentView.swift
//  WordScamble
//
//  Created by Santhosh Srinivas on 19/01/22.
//

import SwiftUI

struct ContentView: View {
//    var people = ["Barry Allen", "Cisco Ramon", "Caitlyn Frost", "Iris West", "Harrison Wells"]
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingMsg = false
    
    var body: some View {
        NavigationView{
            List{
                Section{
                    TextField("Enter your Word...", text: $newWord)
                        .autocapitalization(.none)
                }
                
                Section{
                    ForEach(usedWords, id: \.self){ word in
                        HStack{
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit {
                addNewWord()
            }
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingMsg) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
//        List{//(people, id: \.self){
////            Text($0)
//            Text("Good Morning")
//            Section("Static List 1"){
//                Text("Micheal Scott")
//                Text("Jim Halpert")
//                Text("Dwight Schrute")
//            }
//
//            Section("Dynamic List 1"){
//                ForEach(people, id: \.self){
//                    Text($0)
//                }
//            }
//
//            Section("Static List 2"){
//                Text("Holly Flax")
//                Text("Pam Beesly")
//                Text("Angela Martin")
//            }
//        }
//        .listStyle(.grouped)
    }
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(word: answer) else{
            wordError(title: "Used Already", msg: "This word has been used already")
            return
        }
        
        guard isPossible(word: answer) else{
            wordError(title: "Word isnt Possible", msg: "You cant spell that word from the given word")
            return
        }
        
        guard isReal(word: answer) else{
            wordError(title: "Word not recoganised", msg: "You can't just makes such words")
            return
        }
        withAnimation {
            usedWords.insert(answer, at: 0)

        }
        newWord = ""
    }
    
    func startGame(){
        if let startURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startURL){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load any word from the bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool{
        
        var tempWord = rootWord
        
        for letter in word{
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            } else{
                return false
            }
        }
        
        return true
    }
    
//    func loadFile(){
//        if let fileURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
//            if let fileContents = try? String(contentsOf: fileURL){
//                // present means load the contents into fileContents
//            }
//        }
//    }
    
    func isReal(word: String) -> Bool{

//        let input = "a b c"
//        let letters = input.components(separatedBy: " ")
//        let letter = letters.randomElement()
//        let trimmeed = letter?.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        let word = "swift"
        let checker = UITextChecker()

        let range = NSRange(location: 0, length: word.utf16.count)
        let missepelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return missepelledRange.location == NSNotFound
    }
    
    func wordError(title: String, msg: String){
        errorTitle = title
        errorMessage = msg
        showingMsg = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
