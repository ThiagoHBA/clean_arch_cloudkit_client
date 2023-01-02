//
//  ViewController.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 24/12/22.
//

import UIKit

class TaskListViewController: UIViewController {
    let presenter: TaskListPresenting
    
    let label: UILabel =  {
        let label = UILabel()
        label.text = "Label"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(presenter: TaskListPresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label)
        view.backgroundColor = .white
        configureConstraints()
        presenter.initState()
    }
}


extension TaskListViewController: TaskListViewProtocol {
    func showLoading() {
        label.text = "Start Loading"
    }
    
    func hideLoading() {
        DispatchQueue.main.async { [weak self] in
            self?.label.text = "Finish Loading"
        }
    }
    
    func displayTaskList(_ tasks: [Task]) {
        DispatchQueue.main.async { [weak self] in
            self?.label.text = "Displaying tasks..."
        }
    }
    
    func displayError(title: String, message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.label.text = "Error: \(title) - \(message)"
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
