//
//  VoluntarySutteringViewController.swift
//  Technovation
//
//  Created by Vicky Liu on 10/13/20.
//  Copyright © 2020 Vicky Liu. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class VoluntarySutteringViewController: UIViewController, AVSpeechSynthesizerDelegate {
    
    let voices = AVSpeechSynthesisVoice.speechVoices()
    let voiceSynth = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatGesture()
        self.voiceSynth.delegate = self
        
        let leftButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(popToPrevious))
        leftButton.image = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))
        leftButton.tintColor = UIColor(cgColor: Constants.blue)
        self.navigationItem.leftBarButtonItem = leftButton
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
    
    @objc private func popToPrevious() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func voluntaryStuttering(_ sender: Any) {
        let utterance = AVSpeechUtterance(string: "Ha ha happy")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.3
        voiceSynth.speak(utterance)
    }
}
