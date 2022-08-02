//
//  TaskListViewController.swift
//  CoreDataDemo
//
//  Created by Илья Гусаров on 01.08.2022.
//

import UIKit

protocol TaskViewControllerDelegate {
    func reloadData()
}

class TaskListViewController: UITableViewController {
    
    private let cellID = "task"
    private var taskList: [Task] = []
    private var tempCellId = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavBar()
        fetchData()
    }
    
    private func setupNavBar() {
        title = "Task bar"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask))
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
    }
    
    @objc private func addNewTask() {
        showAlert(with: "New task", and: "What do you want to do?", for: "New task")
    }

    private func fetchData() {
        StorageManager.shared.fetchData { tasks in
            self.taskList = tasks
            self.tableView.reloadData()
        }
    }
        
    private func showAlert(with title: String, and message: String, for placeholder: String, editTask: Bool = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            if editTask {
                self.edit(task)
            } else {
                self.save(task)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = placeholder
        }
        
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        StorageManager.shared.save(with: taskName) { task in
            self.taskList.append(task)
        }
        
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
    }
    
    private func edit(_ taskName: String) {
        taskList[tempCellId].title = taskName
        let cellIndex = IndexPath(row: tempCellId, section: 0)
        tableView.reloadRows(at: [cellIndex], with: .automatic)
        StorageManager.shared.saveContext()
    }
}

extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        
        cell.contentConfiguration = content
        return cell
    }
        
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = taskList[indexPath.row]
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            StorageManager.shared.delete(with: task)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let task = taskList[indexPath.row].title else { return }
        tempCellId = indexPath.row
        showAlert(with: "Edit task", and: "As you wish", for: task, editTask: true)
    }
}

extension TaskListViewController: TaskViewControllerDelegate {
    func reloadData() {
        fetchData()
        tableView.reloadData()
    }
}

