//
//  TaskListPresenting.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 28/12/22.
//

import Foundation

protocol TaskListPresenting {
    func initState()
    func createTask(_ task: Task)
}
