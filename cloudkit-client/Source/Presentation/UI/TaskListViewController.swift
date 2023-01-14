//
//  ViewController.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 24/12/22.
//

import UIKit

class TaskListViewController: UIViewController {
    let presenter: TaskListPresenting
    private(set) var tasks: [Task] = [Task]()
    
    let label: UILabel =  {
        let label = UILabel()
        label.text = "Label"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "add"
        button.style = .plain
        button.target = self
        button.action = #selector(addButtonTapped)
        return button
    }()

    init(presenter: TaskListPresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label)
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = addButton
        navigationItem.rightBarButtonItem?.tintColor = .systemBlue
        configureConstraints()
        presenter.initState()
    }
    
    @objc func addButtonTapped() {
        let alert = UIAlertController(
            title: "Adicionar taréfa",
            message: "Digite o nome da taréfa a ser adicionada",
            preferredStyle: .alert
        )
        createTaskDialog(alert) { [weak self] taskName in
            self?.presenter.createTask(
                Task(
                    isOpen: false,
                    name: taskName,
                    subtasks: []
                )
            )
        }
    }
    
    func createTaskDialog (
        _ alert: UIAlertController,
        completion: (() -> Void)? = nil,
        action: @escaping (String) -> Void
    ) {
        alert.addTextField { (textField) in
            textField.placeholder = "Escreva aqui"
        }
        
        alert.addAction(
            UIAlertAction(
                title: "Cancelar",
                style: .cancel,
                handler: nil
            )
        )

        let saveAction = UIAlertAction (
            title: "OK",
            style: .default,
            handler: { [weak alert] (_) in
                action(alert?.textFields![0].text ?? "")
            })
        
        alert.addAction(saveAction)
        saveAction.isEnabled = false

        NotificationCenter.default.addObserver (
            forName: UITextField.textDidChangeNotification,
            object: alert.textFields![0],
            queue: OperationQueue.main
        ) { (notification) in
            saveAction.isEnabled = alert.textFields![0].text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""
        }

        self.present(alert, animated: true, completion: completion)
    }
}


extension TaskListViewController: TaskListViewProtocol {
    func includeTask(_ task: Task, completion: @escaping () -> Void) {
        tasks.append(task)
        completion()
    }
    
    func showLoading(completion: @escaping () -> Void) {
        label.text = "Start Loading"
        completion()
    }
    
    func hideLoading(completion: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            self?.label.text = "Finish Loading"
            completion()
        }
    }
    
    func displayTaskList(_ tasks: [Task], completion: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            self?.label.text = "Displaying tasks..."
            print(tasks)
            self?.tasks = tasks
            completion()
        }
    }
    
    func displayError(title: String, message: String, completion: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            self?.label.text = "Error: \(title) - \(message)"
            completion()
        }
    }
}

extension TaskListViewController {
    func configureConstraints() {
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
