//
//  TaskListViewProtocol.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 28/12/22.
//

import Foundation

protocol TaskListViewProtocol {
    func displayTaskList(_ tasks: [Task])
    func displayError(title: String, message: String)
    func showLoading()
    func hideLoading()
}
