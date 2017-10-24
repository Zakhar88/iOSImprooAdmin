//
//  FirestoreManager.swift
//  Improo
//
//  Created by Zakhar Garan on 19.10.17.
//  Copyright © 2017 GaranZZ. All rights reserved.
//

import Firebase

class FirestoreManager {
    static let shared = FirestoreManager()
    static let allCategories = "Усі категорії"
    
    private let databaseReference: Firestore!
    
    private init() {
        databaseReference = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        let db = Firestore.firestore()
        db.settings = settings
    }
    
    func loadInfo(completion: @escaping (String?, Error?)->()) {
        databaseReference.document("ukrainian/info").getDocument { (documentSnapshot, error) in
            guard let infoText = documentSnapshot?.data()["text"] as? String else {
                completion(nil, error)
                return
            }
            completion(infoText, nil)
        }
    }
    
    func loadCategories(forSection section: Section, completion: @escaping ([String]?, Error?)->()) {
        databaseReference.document("ukrainian/\(section.rawValue)").getDocument { (documentSnaphot, error) in
            guard documentSnaphot?.exists == true, var categories = documentSnaphot?.data()["Categories"] as? [String] else {
                completion(nil, error)
                return
            }
            completion(categories, nil)
        }
    }
    
//    func loadDocuments(forSection section: Section, completion: @escaping ([Item]?, Error?)->()) {
//        databaseReference.collection("ukrainian/\(section.rawValue)/Collection").getDocuments { (querySnapshot, error) in
//            guard let documents = querySnapshot?.documents else {
//                completion(nil, error)
//                return
//            }
//            completion(documents.flatMap({Item(documentSnapshot: $0, section: section)}).sorted{$0.title < $1.title}, nil)
//        }
//    }
}
