//
//  RecordingsTableViewController.swift
//  Name Your Key
//
//  Created by Paul Crompton on 1/30/17.
//  Copyright © 2017 Paul Crompton. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class RecordingsTableViewController: CoreDataTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the title
        title = "Name Your Key"
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Recording")
        fr.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func deleteRecording(recording: Recording) {
        let fm = FileManager.default
        do {
            let url = try fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(recording.filename!)
            try fm.removeItem(at: url)
        } catch {
            print(error.localizedDescription)
        }
        let context = stack.context
        context.delete(recording)
        stack.save()
    }
    
    // MARK: UITableViewDataSource methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "RecordingsTableViewCell")
        let recording = fetchedResultsController!.object(at: indexPath) as! Recording
        cell.textLabel?.text = recording.title
        return cell
    }
    
    // MARK: UITableViewDelegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recording = fetchedResultsController!.object(at: indexPath) as! Recording
        let playAudioVC = storyboard?.instantiateViewController(withIdentifier: "playAudioViewController") as! PlayAudioViewController
        playAudioVC.recording = recording
        show(playAudioVC, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            let recording = self.fetchedResultsController!.object(at: indexPath) as! Recording
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.deleteRecording(recording: recording)
            tableView.endUpdates()
        }
        return [deleteAction]
    }
}
