//
//  StorageViewController.swift
//  secure-ios-app
//
//  Created by Tom Jackman on 20/11/2017.
//  Copyright © 2017 Wei Li. All rights reserved.
//

import Foundation
import UIKit
import SCLAlertView

protocol StorageListener {
    func list() -> [Note]
    func read(identifier: Int) -> Note
    func create(title: String, content: String)
    func edit(identifier: Int, title: String, content: String)
    func delete(identifier: Int)
}

/* The view controller for the storage view. */
class StorageViewController: UITableViewController {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    var storageListener: StorageListener?
    var notes = [Note]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadNotes()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     - Display a modal to create a note
     
     - Parameter sender: the sender button linked to this function
     */
    @IBAction func onCreateTapped(_ sender: UIBarButtonItem) {
        
        // create the view
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        let title = alert.addTextField("Enter your Title")
        let content = alert.addTextView()
        
        // define the close action
        alert.addButton("Close") {
            let alertViewResponder: SCLAlertViewResponder = SCLAlertView().showSuccess("", subTitle: "")
            alertViewResponder.close()
        }
        
        // define the create action
        alert.addButton("Create") {
            if (title.text?.isEmpty)! {
                self.showErrorAlert(title: "Error Creating Note", message: "Note Title Cannot Be Empty!")
            } else {
                self.createNote(title: title.text!, content: content.text!)
            }
        }
        
        // show the modal
        alert.showSuccess("Create Note", subTitle: "Create an Encrypted Note")
    }
    
    /**
     - Display a modal to edit a note
     
     - Parameter identifier: the identifier of the note to edit
     */
    func showEditModal(identifier: Int) {
        // get the note details
        let note = self.readNote(identifier: identifier)
        
        // create the view
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        
        let alert = SCLAlertView(appearance: appearance)
        
        // prefill the text fields with the current note title/content
        let title = alert.addTextField("Enter your Title")
        title.text = note.title
        let content = alert.addTextView()
        content.text = note.content
        
        // define the close action
        alert.addButton("Close") {
            let alertViewResponder: SCLAlertViewResponder = SCLAlertView().showEdit("", subTitle: "")
            alertViewResponder.close()
        }
        
        // define the create action
        alert.addButton("Update") {
            self.editNote(identifier: identifier, title: title.text!, content: content.text!)
        }
        
        // show the modal
        alert.showEdit("Update Note", subTitle: "Update an Encrypted Note")
    }
    
    /**
     - Display a modal to show the note details
     
     - Parameter identifier: the identifier of the note to show
     */
    func showReadModal(identifier: Int) {
        // get the note details
        let note = self.readNote(identifier: identifier)
        
        // create the view
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        
        // define the close action
        alert.addButton("Close") {
            let alertViewResponder: SCLAlertViewResponder = SCLAlertView().showInfo("", subTitle: "")
            alertViewResponder.close()
        }
        
        // show the modal
        alert.showInfo(note.title, subTitle: note.content)
    }
    
    /**
     - Function to load/re-load notes to display in the UI
     */
    func loadNotes() {
        let storedNotes = self.storageListener?.list()
        self.notes = storedNotes!
        self.tableView.reloadData()
    }
    
    /**
     - Get a note from the storage service
     
     - Parameter identifier: the identifier of the note to get
     */
    func readNote(identifier: Int) -> Note {
        let note = self.storageListener?.read(identifier: identifier)
        return note!
    }
    
    /**
     - Create a note using the storage service
     
     - Parameter title: the title of the note
     - Parameter content: the content of the note
     */
    func createNote(title: String, content: String) {
        self.storageListener?.create(title: title, content: content)
        self.loadNotes()
    }
    
    /**
     - Edit a note using the storage service
     
     - Parameter identifier: the identifier of the note to get
     - Parameter title: the title of the note
     - Parameter content: the content of the note
     */
    func editNote(identifier: Int, title: String, content: String) {
        self.storageListener?.edit(identifier: identifier, title: title, content: content)
        self.loadNotes()
        self.showSuccessAlert(title: title, message: "Note Successfully Updated")
    }
    
    /**
     - Delete a note using the storage service
     
     - Parameter identifier: the identifier of the note to delete
     */
    func deleteNote(title: String, identifier: Int) {
        self.storageListener?.delete(identifier: identifier)
        self.loadNotes()
        self.showSuccessAlert(title: title, message: "Note Succesfully Deleted")
    }
    
    /**
     - Set the number of sections required in the table
     
     - Returns: The number of sections
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    /**
     - Set the number of rows required in the section
     
     - Returns: The number of notes
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notes.count
    }
    
    /**
     - Setup of the table view to reference the table in the storyboard
     
     - Returns: An individual cell in the table list
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "NoteTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NoteTableViewCell
        
        // Fetches the appropriate note for the data source layout.
        let note = self.notes[indexPath.row]
        
        // set the properties for the cell
        cell.textLabel?.text = note.title
        
        return cell
    }
    
    /**
     - Handler for selections on the table cells
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let noteIdentifier = self.notes[indexPath.row].id
        self.showReadModal(identifier: noteIdentifier)
    }
    
    /**
     - Define the edit and delete buttons with actions when tapped
     */
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            let noteIdentifier = self.notes[index.row].id
            let noteTitle = self.notes[index.row].title
            self.deleteNote(title: noteTitle, identifier: noteIdentifier)
        }
        delete.backgroundColor = .red
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            let noteIdentifier = self.notes[index.row].id
            self.showEditModal(identifier: noteIdentifier)
        }
        edit.backgroundColor = .purple
        
        return [delete, edit]
    }
    
    /**
     - Show a success alert with a given title and message
     
     - Parameter title: the title of the alert
     - Parameter message: the message of the alert
     */
    func showSuccessAlert(title: String, message: String) {
        SCLAlertView().showSuccess(title, subTitle: message)
    }
    
    
    /**
     - Show an info alert with a given title and message
     
     - Parameter title: the title of the alert
     - Parameter message: the message of the alert
     */
    func showInfoAlert(title: String, message: String) {
        SCLAlertView().showInfo(title, subTitle: message)
    }
    
    
    /**
     - Show an error alert with a given title and message
     
     - Parameter title: the title of the alert
     - Parameter message: the message of the alert
     */
    func showErrorAlert(title: String, message: String) {
        SCLAlertView().showError(title, subTitle: message)
    }
    
}
