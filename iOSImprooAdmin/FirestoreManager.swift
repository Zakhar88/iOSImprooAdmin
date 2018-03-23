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
    
    func loadCategories(forSection section: Section, completion: @escaping ([String]?, Error?)->()) {
        databaseReference.document("ukrainian/\(section.rawValue)").getDocument { (documentSnaphot, error) in
            guard documentSnaphot?.exists == true, let categories = documentSnaphot?.data()["Categories"] as? [String] else {
                completion(nil, error)
                return
            }
            completion(categories, nil)
        }
    }
    
    func loadDocuments(forSection section: Section, completion: @escaping ([Item]?, Error?)->()) {
        databaseReference.collection("ukrainian/\(section.rawValue)/Collection").getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                completion(nil, error)
                return
            }
            completion(documents.flatMap({Item(documentSnapshot: $0)}).sorted{$0.title < $1.title}, nil)
        }
    }
    
    func updateDocument(forSection section: Section, data: [String: Any], id: String? = nil, completion: @escaping (_ id: String?, _ error: Error?)->()) {
        if let id = id {
            databaseReference.collection("ukrainian/\(section.rawValue)/Collection").document(id).setData(data, completion: { error in
                DispatchQueue.main.async { completion(id, error) }
            })
        } else {
            var newDocumentReference: DocumentReference?
            newDocumentReference = databaseReference.collection("ukrainian/\(section.rawValue)/Collection").addDocument(data: data) { error in
                DispatchQueue.main.async { completion(newDocumentReference?.documentID, error) }
            }
        }
    }
    
    func uploadCategories(forSection section: Section, categories: [String], completion: @escaping (Error?)->()) {
        databaseReference.document("ukrainian/\(section.rawValue)").updateData(["Categories": categories]) { error in
            completion(error)
        }
    }
    
    func getAboutText(completion: @escaping (String?)->()) {
        databaseReference.document("ukrainian/Settings").getDocument { (snapshot, error) in
            completion(snapshot?.data()["infoText"] as? String)
        }
    }
    
    func updateAboutText(with newText: String) {
        databaseReference.document("ukrainian/Settings").setData(["infoText" : newText])
    }
    
    func removeItem(forSection section: Section, id: String, completion: @escaping (Error?)->()) {
        databaseReference.collection("ukrainian/\(section.rawValue)/Collection").document(id).delete { error in
            completion(error)
        }
    }
}
