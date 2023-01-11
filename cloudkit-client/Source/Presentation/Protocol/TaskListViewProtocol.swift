//
//  TaskListViewProtocol.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 28/12/22.
//

import Foundation

protocol TaskListViewProtocol {
    func displayTaskList(_ tasks: [Task], completion: @escaping () -> Void)
    func displayError(title: String, message: String, completion: @escaping () -> Void)
    func showLoading(completion: @escaping () -> Void)
    func hideLoading(completion: @escaping () -> Void)
    func includeTask(_ task: Task, completion: @escaping () -> Void)
}
