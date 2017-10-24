//
//  ViewController.swift
//  iOSImprooAdmin
//
//  Created by Zakhar Garan on 24.10.17.
//  Copyright © 2017 Zakhar Garan. All rights reserved.
//

import UIKit

class NewItemViewController: UIViewController {
    
    @IBOutlet weak var sectionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var titlField: UITextField!
    @IBOutlet weak var authorField: UITextField!
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var categoriesTableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var menuTabBar: UITabBar!

    
    var selectedSection: Section = .Activities
    var sectionCategories = [String]() {
        didSet {
            DispatchQueue.main.async {
                self.categoriesTableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutIfNeeded()
        descriptionTextView.addBorder(width: 1, color: UIColor.lightGray.withAlphaComponent(0.6))
        categoriesTableView.addBorder(width: 1, color: UIColor.lightGray.withAlphaComponent(0.6))
        
        loadCategories()
    }
    
    @IBAction func sectionChanged(_ sender: UISegmentedControl) {
        selectedSection = Section(rawValue: sender.titleForSegment(at: sender.selectedSegmentIndex)!)!
        loadCategories()
    }
    
    @IBAction func showHideMenu() {
        menuTabBar.isHidden = menuTabBar.isHidden ? false : true
    }
    
    func loadCategories() {
        activityIndicatorView?.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        FirestoreManager.shared.loadCategories(forSection: selectedSection) { (categories, error) in
            
            self.activityIndicatorView?.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            guard error == nil else {
                self.showError(error)
                return
            }
            self.sectionCategories = categories ?? []
        }
    }
}

extension NewItemViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = sectionCategories[indexPath.row]
        return cell
    }
}
