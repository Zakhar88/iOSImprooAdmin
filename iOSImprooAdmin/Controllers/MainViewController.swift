//
//  MainViewController.swift
//  iOSImprooAdmin
//
//  Created by Zakhar Garan on 30.10.17.
//  Copyright © 2017 Zakhar Garan. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UpdateDelegate {
    
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var selectedSection: Section = .Articles {
        didSet {
            loadItems()
        }
    }
    
    var items = [Item]() {
        didSet {
            itemsTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemsTableView.addBorder(width: 1, color: UIColor.lightGray.withAlphaComponent(0.6))
        loadItems()
    }
    
    @IBAction func sectionChanged(_ sender: UISegmentedControl) {
        guard let newSection = Section(rawValue: sender.titleForSegment(at: sender.selectedSegmentIndex)!) else {
            showAlert(title: "Failed to get new Section.", message: "@IBAction func sectionChanged(_ sender: UISegmentedControl)")
            return
        }
        selectedSection = newSection
    }
    
    @IBAction func showAboutTextAlertController() {

    }
    
    func loadItems() {
        activityIndicatorView.startAnimating()
        itemsTableView.isUserInteractionEnabled = false
        FirestoreManager.shared.loadDocuments(forSection: selectedSection) { (items, error) in
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
                self.itemsTableView.isUserInteractionEnabled = true
                if let items = items {
                    self.items = items
                } else {
                    self.showError(error)
                }
            }
        }
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateEditViewController") as! CreateEditViewController
        editViewController.setInitialItem(items[indexPath.row], section: selectedSection)
        editViewController.delegate = self
        navigationController?.pushViewController(editViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            FirestoreManager.shared.removeItem(forSection: selectedSection, id: items[indexPath.row].id, completion: { error in
                if let error = error {
                    self.showError(error)
                }
                tableView.reloadData()
            })
        }
    }
}
