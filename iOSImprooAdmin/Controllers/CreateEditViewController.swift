//
//  MainViewController.swift
//  iOSImprooAdmin
//
//  Created by Zakhar Garan on 24.10.17.
//  Copyright © 2017 Zakhar Garan. All rights reserved.
//

import UIKit

protocol UpdateDelegate {
    func loadItems()
}

class CreateEditViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var sectionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var categoriesTableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var cleanBarButton: UIBarButtonItem!
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var authorField: UITextField!
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var imageUrlField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var idField: UITextField!
    
    //MARK: - Properties
    
    var initialItem: Item?
    var delegate: UpdateDelegate?
    var selectedSection: Section = .Articles {
        didSet {
            loadCategories()
            if selectedSection == .Courses {
                authorField.text = "Prometheus"
            }
        }
    }
    
    var sectionCategories = [String]() {
        didSet {
            DispatchQueue.main.async {
                self.categoriesTableView.reloadData()
                self.preselectCategoriesForInitialItem()
            }
        }
    }
    
    var selectedCategories = [String]() {
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
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem?) {
        guard let title = titleField.text, !title.isEmpty, let description = descriptionTextView.text, !description.isEmpty, !selectedCategories.isEmpty else {
            showAlert(title: "Failed to get title / description / categories.", message: "@IBAction func saveTapped(_ sender: UIBarButtonItem?)")
            return
        }
        
        var newItemData: [String: Any] = ["title":title, "description": description, "categories": selectedCategories]
        
        if let author = authorField.text, !author.isEmpty {
            newItemData["author"] = author
        }
        
        if let url = urlField.text, !url.isEmpty {
            newItemData["url"] = url
        }
        
        activityIndicatorView?.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        FirestoreManager.shared.updateDocument(forSection: selectedSection, data: newItemData, id: initialItem?.id) { (newItemId, error) in
            
            guard let newItemId = newItemId else {
                self.activityIndicatorView?.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
                self.showError(error)
                self.idField.text = error?.localizedDescription
                return
            }
            self.idField.text = newItemId
            
            if let imageUrlString = self.imageUrlField.text, !imageUrlString.isEmpty {
                self.uploadImage(withName: newItemId, fromUrl: imageUrlString)
            } else {
                self.activityIndicatorView?.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
                if self.initialItem == nil {
                    self.showAlert(title: "Failed to get image URL", message: "func uploadImage(withName: String, completion: @escaping (Error?)->())")
                } else {
                    self.delegate?.loadItems()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    @IBAction func cleanAllFields() {
        let alertController = UIAlertController(title: "Clean all fields?", message: nil, preferredStyle: .alert)
        let cleanAction = UIAlertAction(title: "Clean", style: .destructive) { _ in
            self.clean()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cleanAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func textFieldsEditingChanged(_ sender: UITextField) {
        checkSaveButtonAccessibility()
        if selectedSection == .Courses && sender == titleField {
            if sender.text?.first != "«" {
                sender.text?.insert("«", at: (sender.text?.startIndex)!)
            }
            if sender.text?.last != "»" {
                sender.text?.append("»")
            }
        }
    }
    
    @IBAction func deleteTapped(_ sender: UIBarButtonItem?) {
        let alertController = UIAlertController(title: "Delete item?", message: nil, preferredStyle: .alert)
        let cleanAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            guard let id = self.idField.text else { return }
            FirestoreManager.shared.removeItem(forSection: self.selectedSection, id: id) { error in
                if let error = error {
                    self.showError(error)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cleanAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    //MARK: - Functions
    
    func clean() {
        titleField.text = ""
        if selectedSection != .Courses {
            authorField.text = ""
        }
        urlField.text = ""
        imageUrlField.text = ""
        descriptionTextView.text = ""
        idField.text = ""
        saveBarButton.isEnabled = false
        deselectaAllCategories()
        selectedCategories = [String]()
    }
    
    func deselectaAllCategories() {
        if let selectedRows = categoriesTableView.indexPathsForSelectedRows {
            for row in selectedRows {
                categoriesTableView.deselectRow(at: row, animated: true)
            }
        }
    }
    
    func loadCategories(){
        activityIndicatorView?.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        FirestoreManager.shared.loadCategories(forSection: selectedSection) { (categories, error) in
            
            self.activityIndicatorView?.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            guard error == nil, let categories = categories else {
                self.showError(error)
                return
            }
            self.sectionCategories = categories.sorted()
        }
    }
    
    func checkSaveButtonAccessibility() {
        if let initialItem = initialItem {
            saveBarButton.isEnabled = titleField.text != initialItem.title || descriptionTextView.text != initialItem.description || selectedCategories != initialItem.categories || authorField.text != (initialItem.author ?? nil) || urlField.text != (initialItem.url?.absoluteString ?? "") || imageUrlField.text?.isEmpty == false
        } else {
            saveBarButton.isEnabled = titleField.text?.isEmpty == false  && !descriptionTextView.text.isEmpty && !selectedCategories.isEmpty
        }
    }
    
    func uploadImage(withName imageName: String, fromUrl urlString: String) {
        StorageManager.uploadImage(byUrl: urlString, withName: imageName, forSection: selectedSection) { (error) in
            self.activityIndicatorView?.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if let error = error {
                self.showError(error)
            } else {
                self.clean()
            }
        }
    }
    
    func setInitialItem(_ item: Item, section: Section) {
        view.layoutIfNeeded()
        title = "Edit"
        sectionSegmentedControl.isEnabled = false
        for index in 0..<sectionSegmentedControl.numberOfSegments {
            if sectionSegmentedControl.titleForSegment(at: index) == section.rawValue {
                sectionSegmentedControl.selectedSegmentIndex = index
                break
            }
        }
        
        initialItem = item
        titleField.text = item.title
        authorField.text = item.author
        urlField.text = item.url?.absoluteString
        descriptionTextView.text = item.description
        idField.text = item.id
        selectedCategories = item.categories
        
        selectedSection = section
        deleteBarButton.isEnabled = true
    }
    
    private func preselectCategoriesForInitialItem() {
        if let categories = initialItem?.categories {
            categories.forEach({ category in
                if let index = sectionCategories.index(of: category) {
                    categoriesTableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
                }
            })
        }
    }
}

extension CreateEditViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = sectionCategories[indexPath.row]
        return cell
    }
}

extension CreateEditViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategories.append(sectionCategories[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let deselectedCategoryIndex = selectedCategories.index(of: sectionCategories[indexPath.row]) else {
            showAlert(title: "Failed to get deselectedCategoryIndex", message: "func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)")
            return
        }
        selectedCategories.remove(at: deselectedCategoryIndex)
    }
}

extension CreateEditViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        checkSaveButtonAccessibility()
    }
}
