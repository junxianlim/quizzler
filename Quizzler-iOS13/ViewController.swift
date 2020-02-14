//
//  ViewController.swift
//  Quizzler-iOS13
//
//  Created by Angela Yu on 12/07/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import UIKit
import AVFoundation

let trueFalseChoices: Array<String> = ["True", "False"]

class ViewController: UIViewController {
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var buttonOne: UIButton!
    @IBOutlet weak var buttonTwo: UIButton!
    @IBOutlet weak var buttonThree: UIButton!
    
    // (Question, (Choices), Answer)
    let multiChoiceQuestions: [(String, Array<String>, String)] = [
        (
            "Which is the largest organ in the human body?",
            ["Heart", "Skin", "Large Intenstine"],
            "Skin"
        ),
        (
            "Five dollars is worth how many nickels?",
            ["25", "50", "100"],
            "100"
        ),
        (
            "What do the letters in the GMT time zone stand for?",
            [
                "Global Meridian Time",
                "General Median Time",
                "Greenwich Mean Time"
            ],
            "Greenwich Mean Time"
        ),
        (
            "In past times, what would a gentleman keep in his fob pocket?",
            ["Notebook", "Handkerchief", "Watch"],
            "Watch"
        ),
        (
            "How would one say goodbye in Spanish?",
            ["Au Revoir", "Adiós", "Salir"],
            "Adiós"
        ),
        (
            "Which of these colours is NOT featured in the logo for Google?",
            ["Green", "Orange", "Blue"],
            "Orange"
        ),
        (
            "What type of animal was Harambe?",
            ["Panda", "Gorilla", "Crocodile"],
            "Gorilla"
        ),
        (
            "Where is Tasmania located?",
            ["Indonesia", "Australia", "Scotland"],
            "Australia"
        ),
    ]
    
    // (Question, (Choices), Answer)
    let trueFalseQuestions: [(String, Array<String>, String)] = [
        (
            "A slug's blood is green",
            trueFalseChoices,
            "True"
        ),
        (
            "The total surface area of two human lungs is approximately 70 square metres.",
            trueFalseChoices,
            "True"
        ),
        (
            "In London, UK, if you happen to die in the House of Parliament, you are technically entitled to a state funeral, because the building is considered too sacred a place",
            trueFalseChoices,
            "False"
        ),
        (
            "It is illegal to pee in the Ocean in Portugal",
            trueFalseChoices,
            "True"
        ),
        (
            "You can lead a cow down stairs but not up stairs.",
            trueFalseChoices,
            "False"
        ),
        (
            "Google was originally called 'Backrub'",
            trueFalseChoices,
             "True"
        ),
        (
            "The loudest sound produced by any animal is 188 decibels. That animal is the African Elephant.",
            trueFalseChoices,
            "False"
        ),
        (
            "No piece of square dry paper can be folded in half more than 7 times.",
            trueFalseChoices,
            "False"
        ),
        (
            "Chocolate affects a dog's heart and nervous system; a few ounces are enough to kill a small dog.",
            trueFalseChoices,
            "True"
        )
    ]
    
    var player: AVAudioPlayer!
    var answer: String = ""
    var currentScore: Int = 0
    var totalQuestions: Int = 0
    var quizQuestionsState: [(String, Array<String>, String)] = [
        ("", [""], "")
    ]
    
    // Available states: choose_quiz, playing, game_over
    var gameState: String = "choose_quiz"
    
    @IBAction func answerButton(_ sender: UIButton) {
        // Choose quiz mode
        if gameState == "choose_quiz" {
            selectQuiz(selectedQuiz: sender.currentTitle!)
            return
        }
        
        if gameState == "playing" {
            resolveAnswer(selectedAnswer: sender.currentTitle!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initializeGameState()
    }
    
    // Initialize/Reinitialize game state
    func initializeGameState() {
        gameState = "choose_quiz"
        questionLabel.text = "Choose a quiz!"
        progressBar.progress = 0
        currentScore = 0
        hideButtons()
        buttonOne.setTitle("Multiple Choice Questions", for: .normal)
        buttonOne.isHidden = false
        buttonTwo.setTitle("True/False Questions", for: .normal)
        buttonTwo.isHidden = false
    }
    
    // Start the quiz with the selected questions
    func selectQuiz(selectedQuiz: String) {
        gameState = "playing"
        switch selectedQuiz {
        case "Multiple Choice Questions":
            initializeQuestions(questions: multiChoiceQuestions)
            return
        case "True/False Questions":
            initializeQuestions(questions: trueFalseQuestions)
            return
        default:
            return
        }
    }
    
    // Load questions into game state
    func initializeQuestions(questions: [(String, Array<String>, String)]) {
        totalQuestions = questions.count
        quizQuestionsState = questions
        getNewQuestion()
    }
    
    // Fetch a new question
    func getNewQuestion() {
        let choiceButtons = [buttonOne, buttonTwo, buttonThree]
        let questionNumber = Int.random(in: 0...quizQuestionsState.count - 1)
        let (question, choices, ans) = quizQuestionsState[questionNumber]
        
        // Hide all buttons first
        hideButtons()
        
        // Set new answer, and reveal button
        for (i, e) in choices.enumerated() {
            choiceButtons[i]?.setTitle(e, for: .normal)
            choiceButtons[i]?.isHidden = false
        }
        
        // Remove question from pool
        quizQuestionsState.remove(at: questionNumber)
        
        answer = ans
        questionLabel.text = question
    }
    
    // Resolve selected choice
    func resolveAnswer(selectedAnswer: String) {
        if selectedAnswer == answer {
            currentScore += 1
            progressBar.setProgress(Float(currentScore) / Float(totalQuestions), animated: true)
            playSound(soundName: "correct")
        } else {
            playSound(soundName: "wrong")
        }
        
        // Check quiz state - continue or end
        if quizQuestionsState.count > 0 {
            getNewQuestion()
        } else {
            hideButtons()
            gameState = "game_over"
            questionLabel.text = "Game over! \n Your final score is \(Int(progressBar.progress * 100))%. \n Tap anywhere to restart."
            // Tap anywhere to restart
            self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(restartGame(_:))))
        }
    }
    
    // Restart game
    @objc func restartGame(_ sender: UITapGestureRecognizer) { self.view.gestureRecognizers?.forEach(self.view.removeGestureRecognizer)
        playSound(soundName: "restart")
        initializeGameState()
    }

    // Hide all choice buttons
    func hideButtons() {
        buttonOne.isHidden = true
        buttonTwo.isHidden = true
        buttonThree.isHidden = true
    }
    
    // Play sound
    func playSound(soundName: String) {
        let url = Bundle.main.url(forResource: soundName, withExtension: "wav")
        player = try! AVAudioPlayer(contentsOf: url!)
        player.play()
    }
}
