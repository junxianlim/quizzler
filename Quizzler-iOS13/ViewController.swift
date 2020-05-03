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
    
    let multiChoiceQuestions: [Question] = [
        Question(
            text: "Which is the largest organ in the human body?",
            choices: ["Heart", "Skin", "Large Intenstine"],
            answer: "Skin"
        ),
        Question(
            text: "Five dollars is worth how many nickels?",
            choices: ["25", "50", "100"],
            answer: "100"
        ),
        Question(
            text: "What do the letters in the GMT time zone stand for?",
            choices: [
                "Global Meridian Time",
                "General Median Time",
                "Greenwich Mean Time"
            ],
            answer: "Greenwich Mean Time"
        ),
        Question(
            text: "In past times, what would a gentleman keep in his fob pocket?",
            choices: ["Notebook", "Handkerchief", "Watch"],
            answer: "Watch"
        ),
        Question(
            text: "How would one say goodbye in Spanish?",
            choices: ["Au Revoir", "Adiós", "Salir"],
            answer: "Adiós"
        ),
        Question(
            text: "Which of these colours is NOT featured in the logo for Google?",
            choices: ["Green", "Orange", "Blue"],
            answer: "Orange"
        ),
        Question(
            text:  "What type of animal was Harambe?",
            choices: ["Panda", "Gorilla", "Crocodile"],
            answer: "Gorilla"
        ),
        Question(
            text: "Where is Tasmania located?",
            choices: ["Indonesia", "Australia", "Scotland"],
            answer: "Australia"
        )
    ]
    
    let trueFalseQuestions: [Question] = [
        Question(
            text: "A slug's blood is green",
            choices: trueFalseChoices,
            answer: "True"
        ),
        Question(
            text: "The total surface area of two human lungs is approximately 70 square metres.",
            choices: trueFalseChoices,
            answer: "True"
        ),
        Question(
            text: "In London, UK, if you happen to die in the House of Parliament, you are technically entitled to a state funeral, because the building is considered too sacred a place",
            choices: trueFalseChoices,
            answer: "False"
        ),
        Question(
            text: "It is illegal to pee in the Ocean in Portugal",
            choices: trueFalseChoices,
            answer: "True"
        ),
        Question(
            text: "You can lead a cow down stairs but not up stairs.",
            choices: trueFalseChoices,
            answer: "False"
        ),
        Question(
            text: "Google was originally called 'Backrub'",
            choices: trueFalseChoices,
            answer: "True"
        ),
        Question(
            text: "The loudest sound produced by any animal is 188 decibels. That animal is the African Elephant.",
            choices: trueFalseChoices,
            answer: "False"
        ),
        Question(
            text: "No piece of square dry paper can be folded in half more than 7 times.",
            choices: trueFalseChoices,
            answer: "False"
        ),
        Question(
            text: "Chocolate affects a dog's heart and nervous system; a few ounces are enough to kill a small dog.",
            choices: trueFalseChoices,
            answer: "True"
        )
    ]
    
    var player: AVAudioPlayer!
    var answer: String = ""
    var currentScore: Int = 0
    var totalQuestions: Int = 0
    var quizQuestionsState: [Question] = []
    
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
        let gameMode: [String: [Question]] = [
            "Multiple Choice Questions": multiChoiceQuestions,
            "True/False Questions": trueFalseQuestions
        ]
        initializeQuestions(questions: gameMode[selectedQuiz]!)
    }
    
    // Load questions into game state
    func initializeQuestions(questions: [Question]) {
        totalQuestions = questions.count
        quizQuestionsState = questions
        getNewQuestion()
    }
    
    // Fetch a new question
    func getNewQuestion() {
        let choiceButtons = [buttonOne, buttonTwo, buttonThree]
        let questionNumber = Int.random(in: 0...quizQuestionsState.count - 1)
        let q = quizQuestionsState[questionNumber]
        
        // Hide all buttons first
        hideButtons()
        
        // Set new answer, and reveal button
        for (i, e) in q.choices.enumerated() {
            choiceButtons[i]?.setTitle(e, for: .normal)
            choiceButtons[i]?.isHidden = false
        }
        
        // Remove question from pool
        quizQuestionsState.remove(at: questionNumber)

        answer = q.answer
        questionLabel.text = q.text
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
