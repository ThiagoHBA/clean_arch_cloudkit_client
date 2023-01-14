//
//  ViewController.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 24/12/22.
//

import UIKit

class TaskListViewController: UIViewController, AlertPresentable {
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
        
        showTextFieldAlert(alert) { [weak self] text in
            self?.presenter.createTask(
                Task(
                    isOpen: false,
                    name: text,
                    subtasks: []
                )
            )
        }
    }
}


extension TaskListViewController: TaskListViewProtocol {
    func includeTask(_ task: Task, completion: @escaping () -> Void) {
        tasks.append(task)
        showAlert(title: "Sucesso!", message: "Taréfa adicionada com sucesso!")
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
