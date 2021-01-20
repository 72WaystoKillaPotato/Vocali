//
//  LevelsTableViewController.swift
//  Technovation
//
//  Created by Samantha Su on 3/23/20.
//  Copyright © 2020 Vicky Liu. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class LevelsTableViewController: UITableViewController{
    
    let viewModel = StandardViewModel()
    let cellSpacingHeight = CGFloat(15)
    var userSelectedCell = -1
    var index = 0
    
    var mode = String()
    
    override func viewDidLoad() {
        
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.backgroundView = UIImageView(image: UIImage(named: "gradient"))
        super.viewDidLoad()
        self.registerTableViewCells()
    }    

    @IBAction func signOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
    }
    
    func registerTableViewCells(){
        let levelCell = UINib(nibName: "LevelTableViewCell", bundle: nil)
        self.tableView.register(levelCell, forCellReuseIdentifier: "LevelCell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // set the number of cells
        let numSections = viewModel.levels.count
        return numSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    // Set the spacing between sections
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }

    // Make the background color show through
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LevelCell", for: indexPath)
        if let cell = tableView.dequeueReusableCell(withIdentifier: "LevelCell") as? LevelTableViewCell{
            //set keyword for each level
            cell.keywordLabel.text = viewModel.levels[indexPath.section].keyWord
            //limits the bonds of the shadows to upper left corner
            cell.contentView.layer.masksToBounds = true
            cell.layer.shadowOpacity = 0.2
            cell.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            return cell
        }
        print("unable to employ custom cell")
        return cell
    }
    
    func presentPopVC(){
        let modePopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ModePopVC") as! ModePopViewController
        modePopup.keyWordIndex = userSelectedCell
        modePopup.modalPresentationStyle = .popover

        present(modePopup, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        userSelectedCell = indexPath.section
        presentPopVC()
    }
}
