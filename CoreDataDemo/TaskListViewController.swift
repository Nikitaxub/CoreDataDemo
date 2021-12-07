//
//  TaskListViewController.swift
//  CoreDataDemo
//
//  Created by Alexey Efimov on 06.12.2021.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    private var taskList: [Task] = []
    private let cellID = "task"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .white
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
        tableView.reloadData()
    }

    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert(with: "New task", and: "What do you want to do?", of: nil, for: nil)
    }
    
    private func updateTask(_ task: Task, for indexPath: IndexPath) {
        showAlert(with: "Update task", and: "What do you want to do?", of: task, for: indexPath)
    }
    
    private func fetchData() {
        taskList = StorageManager.shared.fetchTaskList()
    }
    
    private func showAlert(with title: String, and message: String, of task: Task?, for indexPath: IndexPath?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var saveHandler: (UIAlertAction) -> Void = { _ in }
        if task == nil {
            saveHandler = { _ in
                guard let taskName = alert.textFields?.first?.text, !taskName.isEmpty else { return }
                self.save(taskName)
            }
            alert.addTextField { textField in
                textField.placeholder = "New Task"
            }
        } else {
            saveHandler = { _ in
                guard let taskName = alert.textFields?.first?.text, !taskName.isEmpty, let task = task, let indexPath = indexPath else { return }
                self.update(task, with: taskName, for: indexPath)
            }
            alert.addTextField { textField in
                textField.text = task?.title
                textField.placeholder = "Updating Task"
            }
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: saveHandler)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        let task = StorageManager.shared.saveTask(withName: taskName)
        taskList.append(task)
        
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
    }
    
    private func update(_ task: Task, with name: String, for indexPath: IndexPath) {
        let newTask = StorageManager.shared.updateTask(task, with: name)
        taskList[indexPath.row] = newTask

        tableView.reloadRows(at: [indexPath], with: .automatic) //insertRows(at: [cellIndex], with: .automatic)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = taskList[indexPath.row]
        
        updateTask(task, for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let task = taskList[indexPath.row]
        StorageManager.shared.deleteTask(task)
        
        taskList.remove(at: indexPath.row)
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
