//
//  SurveyViewController.swift
//  Technovation
//
//  Created by Vicky Liu on 10/13/20.
//  Copyright © 2020 Vicky Liu. All rights reserved.
//

import UIKit

class SurveyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        formatGesture()
        
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
}
