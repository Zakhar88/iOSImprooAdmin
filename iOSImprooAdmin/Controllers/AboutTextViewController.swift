//
//  AboutTextViewController.swift
//  iOSImprooAdmin
//
//  Created by Zakhar Garan on 03.11.17.
//  Copyright © 2017 Zakhar Garan. All rights reserved.
//

import UIKit

class AboutTextViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    
    @IBAction func save() {
        FirestoreManager.shared.updateAboutText(with: textView.text)
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutIfNeeded()
        FirestoreManager.shared.getAboutText { aboutText in
            self.textView.text = aboutText
        }
    }
}
