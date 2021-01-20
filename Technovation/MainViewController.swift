//
//  MainViewController.swift
//  Technovation
//
//  Created by Samantha Su on 4/27/20.
//  Copyright © 2020 Vicky Liu. All rights reserved.
//
import UIKit
import UserNotifications

class MainViewController : UIViewController, UNUserNotificationCenterDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var customWordTextField: UITextField!
    @IBOutlet weak var customDrillsButton: UIButton!
    
    fileprivate let checker = UITextChecker()
    
    @IBAction func goToCustomDrill(_ sender: Any) {
        guard customWordTextField.text != "" else {return}
        customWordTextField.resignFirstResponder()
        let modePopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ModePopVC") as! ModePopViewController
        modePopup.keyWord = customWordTextField.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        present(modePopup, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customWordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        formatGesture()
        setupUI()
        requestNotificationAccess()
        scheduleNotification()
        customWordTextField.delegate = self
    }

    func setupUI(){
        logo.layer.cornerRadius = Constants.cornerR
//        logo.roundCornersForAspectFit(radius: Constants.cornerR)
        formatTextField(textField: customWordTextField, placeholder: "Custom Word")
        customWordTextField.setLeftPaddingPoints(0)
        customWordTextField.font = UIFont(name: "FredokaOne-Regular", size: 35)
        customWordTextField.textColor = UIColor(displayP3Red: 147.0/255.0, green: 189.0/255.0, blue: 238.0/255.0, alpha: 1)
        
        let menuBtn = UIButton(type: .custom)
            menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 50, height: 50)
            menuBtn.setImage(UIImage(named:"menuIcon"), for: .normal)
        menuBtn.addTarget(self, action: #selector(segueToSideMenu), for: UIControl.Event.touchUpInside)

            let menuBarItem = UIBarButtonItem(customView: menuBtn)
            let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 45)
            currWidth?.isActive = true
            let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 45)
            currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = menuBarItem
        
        let rightButton = UIButton(type: .custom)
        rightButton.frame = CGRect(x: 0.0, y: 0.0, width: 50, height: 50)
        rightButton.setImage(UIImage(named:"userIcon"), for: .normal)
        rightButton.addTarget(self, action: #selector(segueToUserInfo), for: UIControl.Event.touchUpInside)

            let rightBarItem = UIBarButtonItem(customView: rightButton)
            let rWidth = rightBarItem.customView?.widthAnchor.constraint(equalToConstant: 45)
            rWidth?.isActive = true
            let rHeight = rightBarItem.customView?.heightAnchor.constraint(equalToConstant: 45)
            rHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = rightBarItem
    }
    
    @objc private func segueToSideMenu() {
        performSegue(withIdentifier: "segueToSideMenu", sender: self)
    }
    
    @objc private func segueToUserInfo() {
        performSegue(withIdentifier: "segueToUserInfo", sender: self)
    }
    
    func formatGesture() {
        let leftRecognizer = UISwipeGestureRecognizer(target: self, action:
        #selector(executeSwipe(_:)))
        leftRecognizer.direction = .left
        let rightRecognizer = UISwipeGestureRecognizer(target: self, action:
        #selector(executeSwipe(_:)))
        rightRecognizer.direction = .right
        self.view.addGestureRecognizer(leftRecognizer)
        self.view.addGestureRecognizer(rightRecognizer)
    }
    
    @objc func executeSwipe(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            performSegue(withIdentifier: "segueToUserInfo", sender: self)
        }
        if sender.direction == .right {
            performSegue(withIdentifier: "segueToSideMenu", sender: self)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard textField.text?.count != 0 , textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {return}
        let range = NSRange(location: 0, length: textField.text!.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: textField.text!, range: range, startingAt: 0, wrap: false, language: "en")

        if misspelledRange.location == NSNotFound{
            //is word
            customWordTextField.textColor = UIColor(cgColor: Constants.red)
            customDrillsButton.isEnabled = true
        } else{
            customWordTextField.textColor = UIColor(displayP3Red: 147.0/255.0, green: 189.0/255.0, blue: 238.0/255.0, alpha: 1)
            customDrillsButton.isEnabled = false
        }
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func requestNotificationAccess() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func scheduleNotification() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        //notification testing
//        center.removeAllDeliveredNotifications()
//        center.removeAllPendingNotificationRequests()
//        center.getPendingNotificationRequests { (notificationRequests) in
//             for notificationRequest:UNNotificationRequest in notificationRequests {
//                print("notification: ", notificationRequest.identifier)
//            }
//        }
        
        let content = UNMutableNotificationContent()
        content.title = "Vocali Daily Challenge"
        content.subtitle = "Check out today's speech challenge in Vocali!"
        content.sound = UNNotificationSound.default

        // Configure the recurring date.
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current

        dateComponents.hour = 15 // 15:00 hours
           
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(
                 dateMatching: dateComponents, repeats: true)

        //testing
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: "583a086e-db3e-11ea-87d0-0242ac130003", content: content, trigger: trigger)

        // add our notification request
        center.removeAllPendingNotificationRequests()
        center.add(request)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
