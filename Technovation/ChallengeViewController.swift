//
//  ChallengeViewController.swift
//  Technovation
//
//  Created by Vicky Liu on 4/28/20.
//  Copyright © 2020 Vicky Liu. All rights reserved.
//

import UIKit
import BEMCheckBox
import Firebase

class ChallengeViewController: UIViewController {

    @IBOutlet weak var challengeLabel: UILabel!
    @IBOutlet weak var completionCheckBox: BEMCheckBox!
    @IBOutlet weak var completionNoticeLabel: UILabel!
    @IBOutlet weak var suggestionLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var wordBank = String()
    var isHidden = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDataIfNeeded() { didLoad in
            print (didLoad)
        }
        generateWord()
        formatGesture()
        let leftButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(popToPrevious))
        leftButton.image = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))
        leftButton.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    let defaults = UserDefaults.standard
    let defaultsKey = "lastRefresh"
    let calender = Calendar.current
    
    @objc private func popToPrevious() {
        navigationController?.popViewController(animated: true)
    }
    
    func formatGesture() {
        let rightRecognizer = UISwipeGestureRecognizer(target: self, action:
        #selector(executeSwipe(_:)))
        rightRecognizer.direction = .right
        self.view.addGestureRecognizer(rightRecognizer)
    }
    
    @objc func executeSwipe(_ sender: UISwipeGestureRecognizer) {
        popToPrevious()
    }
    
    func setupUI(){
        self.view.backgroundColor = UIColor(cgColor: Constants.blue)
        
        //set up challengeLabel
        challengeLabel.font = UIFont(name: "FredokaOne-Regular", size: 30)
        challengeLabel.textColor = .white
        
        //set up suggestionLabel
        suggestionLabel.font = UIFont(name: "FredokaOne-Regular", size: 20)
        suggestionLabel.textColor = UIColor(cgColor: Constants.red)
        
        //set up completionLabel
        completionNoticeLabel.font = UIFont(name: "FredokaOne-Regular", size: 30)
        completionNoticeLabel.textColor = .white
        completionNoticeLabel.alpha = 0
        
        //set up scrollView
        scrollView.layer.cornerRadius = Constants.cornerR
        scrollView.layer.masksToBounds = true
        
        //get if the check box had been checked
        let checked = defaults.bool(forKey: Constants.checkBoxKey)
        if checked{
            //set up check box
            completionCheckBox.onAnimationType = .fill
            completionCheckBox.offAnimationType = .fill
            completionCheckBox.onTintColor = UIColor(cgColor: Constants.red)
            completionCheckBox.onFillColor = UIColor(cgColor: Constants.red)
            completionCheckBox.tintColor = UIColor(cgColor: Constants.red)
            
            self.scrollView.isHidden = self.defaults.object(forKey: Constants.isHidden) as! Bool
        } else {
            completionCheckBox.hideBox = true
            completionCheckBox.on = false
            completionCheckBox.isEnabled = false
            completionNoticeLabel.text = "You already completed your challenge for today!"
            completionNoticeLabel.alpha = 1
            challengeLabel.alpha = 0
            scrollView.isHidden = true
        }
        
    }
    
    @IBAction func didCheckBox(_ sender: Any) {
        defaults.set(false, forKey: Constants.checkBoxKey)
        Firestore.firestore().settings = FirestoreSettings()
        let db = Firestore.firestore()
        
        //get no of points from Firestore to local storage
        let docRef = db.collection("users").document(Constants.uID!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                Constants.points = document.get("points") as? Int
                print("Number of points from Firestore: \(String(describing: Constants.points))")
                
                //save points to Firestore
                let newPoints = (Constants.points ?? 0) + 5
                db.collection("users").document(Constants.uID!).updateData([
                    "points": newPoints
                ]){ err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Firestore points +5, now: \(newPoints)")
                        Constants.points = newPoints
                        self.completionCheckBox.isEnabled = false
                    }
                }
            }
        }
    }
    

    func loadDataIfNeeded(completion: (String) -> Void) {

        if isRefreshRequired() {
            // update the challenge
            defaults.set(Date(), forKey: defaultsKey)
            getChallenge()
            completion("no previous data exists")
        } else {
            challengeLabel.text = defaults.string(forKey: Constants.dailyChallengeKey)
            suggestionLabel.text = defaults.string(forKey: Constants.suggestionKey)
            self.scrollView.isHidden = self.defaults.object(forKey: Constants.isHidden) as! Bool
            setupUI()
            completion("previous data exists")
        }
    }

    func isRefreshRequired() -> Bool {

        guard let lastRefreshDate = defaults.object(forKey: defaultsKey) as? Date else {
            return true
        }
        
        //if it's not the same day
        if let diff = calender.dateComponents([.day], from: lastRefreshDate, to: Date()).day, diff >= 1 {
            return true
        } else {
            return false
        }
    }
    
    func getChallenge(){
        //grab challenges from Firebase
        Firestore.firestore().settings = FirestoreSettings()
        let db = Firestore.firestore()
        var challengeArray: Array<String> = []
        var suggestionArray: Array<String> = []
        let randomNum = Int.random(in: 0..<30)
        //let randomNum = 13
        var challenge: String = ""
        //get challenges from db
        let docRef = db.collection("challenges").document("oneMonth")
        docRef.getDocument { (document, error) in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                if let document = document, document.exists {
                    challengeArray = (document.get("challenges") as? Array)!
                    challenge = challengeArray[randomNum]
                    if randomNum == 19 {
                        self.challengeLabel.text = (challenge.prefix(14) + self.wordBank + challenge.suffix(66))
                    }
                    else {
                    self.challengeLabel.text = challenge
                    }
                    if randomNum > 12 && randomNum < 19 {
                        self.defaults.set(false, forKey: Constants.isHidden)
                        let docRefSug = db.collection("challenges").document("suggestion")
                        docRefSug.getDocument { (document, error) in
                            if let error = error {
                                print("Error writing document: \(error)")
                            } else {
                                if let document = document, document.exists {
                                    suggestionArray = (document.get("suggestions") as? Array)!
                                    self.suggestionLabel.text = "Suggestions:\n\n" +  suggestionArray[randomNum-13] + "\n\n\(suggestionArray[randomNum-7])"
                                    self.defaults.set(self.suggestionLabel.text, forKey: Constants.suggestionKey)
                                }
                            }
                        }
                    }
                    else {
                        self.defaults.set(true, forKey: Constants.isHidden)
                    }
                    
                    self.scrollView.isHidden = self.defaults.object(forKey: Constants.isHidden) as! Bool
                    
                    //save data within location for access within the same day
                    self.defaults.set(self.challengeLabel.text, forKey: Constants.dailyChallengeKey)
                    //refresh checkbox memory
                    self.defaults.set(true, forKey: Constants.checkBoxKey)
                    self.setupUI()
                }
            }
        }
    }
    
    func generateWord(){
        let db = Firestore.firestore()
        var nounArray: Array<String> = []
        var verbArray: Array<String> = []
        var adjArray: Array<String> = []
        var noun: String = ""
        var verb: String = ""
        var adj: String = ""
        let docRef = db.collection("challenges").document("wordBank")
        docRef.getDocument { (document, error) in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                if let document = document, document.exists {
                    nounArray = (document.get("noun") as? Array)!
                    verbArray = (document.get("verb") as? Array)!
                    adjArray = (document.get("adj") as? Array)!
                    noun = nounArray[Int.random(in: 0..<10)]
                    verb = verbArray[Int.random(in: 0..<10)]
                    adj = adjArray[Int.random(in: 0..<10)]
                    self.wordBank = "\"" + noun + "\", \"" + verb + "\", and \"" + adj + "\""
                }
            }
        }
    }
}
