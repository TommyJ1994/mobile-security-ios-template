//
//  StorageInteractor.swift
//  secure-ios-app
//
//  Created by Tom Jackman on 20/11/2017.
//  Copyright © 2017 Wei Li. All rights reserved.
//

import Foundation
import RealmSwift

/* Business logic for the storage view. */
protocol StorageInteractor: StorageListener {
    var storageService: StorageService {get}
    var router: StorageRouter? {get set}
}

class StorageInteractorImpl: StorageInteractor {

    let storageService: StorageService
    var router: StorageRouter?
    
    /*
     - Initiliase the Storage Service
     */
    init(storageService: StorageService) {
        self.storageService = storageService
    }
    
    /*
     - List notes stored in storage
     
     - Returns: an array of Note objects from the storage service
     */
    func list() -> [Note] {
        return self.storageService.list()
    }
    
    /*
     - Read an individual note using the storage service
     
     - Parameter identifier: the identifier of the note to retrieve
     
     - Returns: a single note
     */
    func read(identifier: Int) -> Note {
        return self.storageService.read(identifier: identifier)
    }
    
    /*
     - Create a new note using the storage service
     
     - Parameter title: the title of the note
     - Parameter content: the content of the note
    */
    func create(title: String, content: String) {
       self.storageService.create(title: title, content: content)
    }
    
    /*
     - Update an existing note using the storage service
     
     - Parameter identifier: the identifier of the note to update
     - Parameter title: the new title of the note
     - Parameter content: the new content of the note
     */
    func edit(identifier: Int, title: String, content: String) {
        self.storageService.edit(identifier: identifier, title: title, content: content)
    }
    
    /*
     - Delete a note using the storage service
     
     - Parameter identifier: the identifier of the note to delete
     */
    func delete(identifier: Int) {
        self.storageService.delete(identifier: identifier)
    }
}
