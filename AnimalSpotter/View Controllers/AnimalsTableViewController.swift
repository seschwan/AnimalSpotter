//
//  AnimalsTableViewController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AnimalsTableViewController: UITableViewController {
    
    private var animalNames: [String] = []
    
    let apiController = APIController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if apiController.bearer == nil {
            performSegue(withIdentifier: "LoginViewModalSegue", sender: self)
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animalNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnimalCell", for: indexPath)
        
        // Configure the cell...
        cell.textLabel?.text = animalNames[indexPath.row]
        
        return cell
    }
    
    // MARK: - Actions
    @IBAction func getAnimals(_ sender: UIBarButtonItem) {
        apiController.fetchAllAnimalNames { result in
            if let names = try? result.get() {
                DispatchQueue.main.async {
                    self.animalNames = names
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAnimalDetailSegue",
            let detailVC = segue.destination as? AnimalDetailViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                detailVC.animalName = animalNames[indexPath.row]
            }
            detailVC.apiController = apiController
        }
        else if segue.identifier == "LoginViewModalSegue" {
            if let loginVC = segue.destination as? LoginViewController {
                loginVC.apiController = apiController
            }
        }
    }
}
