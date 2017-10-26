//
//  ItemsTableViewManager.swift
//  iOSImprooAdmin
//
//  Created by Zakhar Garan on 26.10.17.
//  Copyright © 2017 Zakhar Garan. All rights reserved.
//

import UIKit

protocol ItemsTableViewManagerDelegate {
    var selectedSection: Section { get }
    var itemsTableView: UITableView! { get }
}

class ItemsTableViewManager: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var items = [Item]() {
        didSet {
            delegate.itemsTableView.reloadData()
        }
    }
    var selectItemAction: (Item)->()
    var delegate: ItemsTableViewManagerDelegate
    
    init(delegate: ItemsTableViewManagerDelegate, selectItemAction: @escaping (Item)->()) {
        self.delegate = delegate
        self.selectItemAction = selectItemAction
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectItemAction(items[indexPath.row])
    }
    
    func loadItems() {
        FirestoreManager.shared.loadDocuments(forSection: delegate.selectedSection) { (items, error) in
            if let items = items {
                self.items = items
            } else {
                print(error!.localizedDescription)
            }
        }
    }
}

