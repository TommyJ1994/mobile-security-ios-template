//
//  StorageService.swift
//  secure-ios-app
//
//  Created by Tom Jackman on 20/11/2017.
//  Copyright © 2017 Wei Li. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftKeychainWrapper

protocol StorageService {
    func list() -> [Note]
    func read(identifier: Int) -> Note
    func create(title: String, content: String)
    func edit(identifier: Int, title: String, content: String)
    func delete(identifier: Int)
}

class RealmStorageService: StorageService {

    let realm: Realm
    let encryptionKey: Data
    let keychainWrapper: KeychainWrapper

    /**
     - Initilise the Realm Storage Service
     
     - Parameter kcWrapper: the swift keychain wrapper
     */
    init(kcWrapper: KeychainWrapper, encryptionKey: Data) {
        self.keychainWrapper = kcWrapper
        self.encryptionKey = encryptionKey
        
        let encryptionConfig = Realm.Configuration(encryptionKey: self.encryptionKey)
        self.realm = try! Realm(configuration: encryptionConfig)
    }
    
    /**
     - List the stored entities from the realm db
     
     - Returns: an array of Notes
     */
    func list() -> [Note] {
        let notes = self.realm.objects(Note.self)
        let notesArray = notes.toArray()
        return notesArray
    }
    
    /**
     - Create the stored entity
     
     - Paramater title: the title of the note
     - Paramater content: the content of the note
     */
    func create(title: String, content: String) {
        var id = generateId()
        let createdAt = getDate()
        
        // ensure the ID is unique
        while !isIdentifierUnique(identifier: id) {
            id = generateId()
        }
        
        // create the note object
        let note = Note()
        note.id = id
        note.title = title
        note.content = content
        note.createdAt = createdAt
        note.storageProvider = "Realm"
        
        // add the note to the db
        try! realm.safeWrite {
            self.realm.add(note)
        }
    }
    
    /**
     - Check if a note already exists in the db with the same identifier
     
     - Parameter identifier: The identifier of the note
     
     - Returns: true/false based on if a note with the same identifier already exists in the db
     */
    func isIdentifierUnique(identifier: Int) -> Bool {
        let identifiers = realm.objects(Note.self).filter("id = \(identifier)")
        return identifiers.count == 0
    }
    
    /**
     - Read the stored entity
     
     - Parameter identifier: The identifier of the note
     
     - Returns: a note object
     */
    func read(identifier: Int) -> Note {
        let noteResult = self.realm.objects(Note.self).filter("id = \(identifier)")
        let note = noteResult.first
        return note!
    }
    
    /**
     - Edit the stored entity
     
     - Parameter identifier: The identifier of the note
     - Parameter title: The title of the note
     - Parameter content: The content of the note
     */
    func edit(identifier: Int, title: String, content: String) {
        let notes = realm.objects(Note.self).filter("id = \(identifier)")
        let note = notes.first

        // update the note with the given id
        try! realm.write {
            note?.title = title
            note?.content = content
        }
    }
    
    /**
     - Delete the stored entity
     
     - Parameter identifier: The identifier of the note
     */
    func delete(identifier: Int) {
        let noteToDelete = self.realm.objects(Note.self).filter("id = \(identifier)")
        
        // delete the note
        try! realm.write {
            realm.delete(noteToDelete)
        }
    }
    
    /**
     - Generate a random ID for an entity that will be created.
     
     - Returns: A new Int with a random number.
    */
    func generateId() -> Int {
        return Int(arc4random_uniform(65))
    }
    
    /**
     - Get the current date to record the create date for an entity that will be created.
     
     - Returns: The current date in Date format.
     */
    func getDate() -> Date {
        let currentDate = Date()
        return currentDate
    }
    
    /**
     - Generate an encryption key for thr realm db
     
     - Returns: An encryption key
     */
        class func generateEncryptionKey() -> Data {
        let byteLength = 64
        let bytes = [UInt32](repeating: 0, count: byteLength).map { _ in arc4random_uniform(UInt32(byteLength)) }
        let data = Data(bytes: bytes, count: byteLength)
        return data
    }
    
    /**
     - Get the encryption key for the realm db
     
     - Parameter kcWrapper: the keychain wrapper instance
     - Parameter keychainAlias: the refernence alias for the encryption key stored in the keychain
     
     - Returns: the encryption key
     */
    class func getEncryptionKey(kcWrapper: KeychainWrapper, keychainAlias: String) -> Data? {
        guard let encryptionKey = kcWrapper.data(forKey: keychainAlias) else {
            let newEncryptionKey = generateEncryptionKey()
            kcWrapper.set(newEncryptionKey, forKey: keychainAlias)
            return newEncryptionKey
        }
        return encryptionKey
    }
}

// extension to provide safe writes to the realm db
extension Realm {
    
    /**
     - Provide a way to only write transaction when one is not already in progress
     */
    public func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
}

// extension to convert realm db result format into notes array format
extension Results {
    
    /**
    - Convert the realm result format to an array
     
    - Returns: an array of notes
    */
    func toArray() -> [Note] {
        var array = [Note]()
        for result in self {
            array.append(result as! Note)
        }
        return array
    }
}




