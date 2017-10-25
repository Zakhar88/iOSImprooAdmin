//
//  NewItemViewController.swift
//  iOSImprooAdmin
//
//  Created by Zakhar Garan on 24.10.17.
//  Copyright © 2017 Zakhar Garan. All rights reserved.
//

import UIKit

class NewItemViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var sectionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var categoriesTableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var menuTabBar: UITabBar!
    
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var cleanBarButton: UIBarButtonItem!
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var authorField: UITextField!
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var imageUrlField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var idField: UITextField!
    
    @IBOutlet weak var menuTabBarHeightConstraint: NSLayoutConstraint!
    
    //MARK: - Properties
    
    var selectedSection: Section = .Activities
    var sectionCategories = [String]() {
        didSet {
            DispatchQueue.main.async {
                self.categoriesTableView.reloadData()
            }
        }
    }
    
    var categories = [String]() {
        didSet {
            checkSaveButtonAccessibility()
        }
    }
    
    //MARK: - ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutIfNeeded()
        descriptionTextView.addBorder(width: 1, color: UIColor.lightGray.withAlphaComponent(0.6))
        categoriesTableView.addBorder(width: 1, color: UIColor.lightGray.withAlphaComponent(0.6))
        
        loadCategories()
    }
    
    //MARK: - IBActions
    
    @IBAction func sectionChanged(_ sender: UISegmentedControl) {
        guard let newSection = Section(rawValue: sender.titleForSegment(at: sender.selectedSegmentIndex)!) else {
            showAlert(title: "Failed to get new Section.", message: "@IBAction func sectionChanged(_ sender: UISegmentedControl)")
            return
        }
        selectedSection = newSection
        loadCategories()
    }
    
    @IBAction func showHideMenu() {
        UIView.animate(withDuration: 0.4) {
            self.menuTabBarHeightConstraint.constant = self.menuTabBarHeightConstraint.constant == 0 ? 49 : 0
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem?) {
        guard let title = titleField.text, !title.isEmpty, let description = descriptionTextView.text, !description.isEmpty, !categories.isEmpty else {
            showAlert(title: "Failed to get title / description / categories.", message: "@IBAction func saveTapped(_ sender: UIBarButtonItem?)")
            return
        }
        
        var newItemData: [String: Any] = ["title":title, "description": description, "categories": categories]
        
        if let author = authorField.text, !author.isEmpty {
            newItemData["author"] = author
        }
        
        if let url = urlField.text, !url.isEmpty {
            newItemData["url"] = url
        }
        
        activityIndicatorView?.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        FirestoreManager.shared.addDocument(forSection: selectedSection, data: newItemData) { (newItemId, error) in
            
            self.activityIndicatorView?.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            guard let newItemId = newItemId else {
                self.showError(error)
                self.idField.text = error?.localizedDescription
                return
            }
            self.idField.text = newItemId
            self.uploadImage(withName: newItemId)
        }
    }
    
    @IBAction func titleTextFieldEditingChanged(_ sender: UITextField) {
        checkSaveButtonAccessibility()
    }
    
    @IBAction func cleanAllFields() {
        titleField.text = ""
        authorField.text = ""
        urlField.text = ""
        imageUrlField.text = ""
        descriptionTextView.text = ""
        if let selectedRows = categoriesTableView.indexPathsForSelectedRows {
            for row in selectedRows {
                categoriesTableView.deselectRow(at: row, animated: true)
            }
        }
        saveBarButton.isEnabled = false
    }
    
    
    //MARK: - Functions
    
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
    
    func checkSaveButtonAccessibility() {
        saveBarButton.isEnabled = titleField.text?.isEmpty == false  && !descriptionTextView.text.isEmpty && !categories.isEmpty
    }
    
    func uploadImage(withName imageName: String) {
        guard let imageUrlString = imageUrlField.text, imageUrlString.isEmpty else {
            showAlert(title: "Failed to get image URL", message: "func uploadImage(withName: String, completion: @escaping (Error?)->() )")
            return
        }
        StorageManager.uploadImage(byUrl: imageUrlString, withName: imageName, forSection: selectedSection) { (error) in
            if let error = error {
                self.showError(error)
            }
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

extension NewItemViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        categories.append(sectionCategories[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let deselectedCategoryIndex = categories.index(of: sectionCategories[indexPath.row]) else {
            showAlert(title: "Failed to get deselectedCategoryIndex", message: "func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)")
            return
        }
        categories.remove(at: deselectedCategoryIndex)
    }
}

extension NewItemViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        checkSaveButtonAccessibility()
    }
}






