//
//  CategoriesViewController.swift
//  iOSImprooAdmin
//
//  Created by Zakhar Garan on 01.11.17.
//  Copyright © 2017 Zakhar Garan. All rights reserved.
//

import UIKit

class CategoriesViewController: UIViewController {
    
    @IBOutlet weak var categoriesTableView: UITableView?
    @IBOutlet weak var newCategoryTextField: UITextField?
    
    var section: Section = .Activities {
        didSet {
            loadCategories()
        }
    }
    
    var categories = [String]() {
        didSet {
            categoriesTableView?.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }

    func loadCategories(){
        FirestoreManager.shared.loadCategories(forSection: section) { (categories, error) in
            guard error == nil, let categories = categories else {
                self.showError(error)
                return
            }
            self.categories = categories
        }
    }
    
    @IBAction func sectionChanged(_ sender: UISegmentedControl) {
        guard let newSection = Section(rawValue: sender.titleForSegment(at: sender.selectedSegmentIndex)!) else { return }
        section = newSection
    }
    
    @IBAction func addCategory() {
        guard let newCategory = newCategoryTextField?.text, !newCategory.isEmpty else { return }
        categories.append(newCategory)
        categories.sort()
        saveCategories()
        newCategoryTextField?.text = ""
    }
    
    func saveCategories() {
        FirestoreManager.shared.uploadCategories(forSection: section, categories: categories.sorted()) { error in
            if let error = error {
                self.showError(error)
            }
        }
    }
}

extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row]
        return cell
    }
}

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            categories.remove(at: indexPath.row)
            saveCategories()
        }
    }
}
