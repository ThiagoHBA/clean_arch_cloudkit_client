//
//  ListTasksUseCaseOutput.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 07/01/23.
//

import Foundation

protocol ListTasksUseCaseOutput {
    func tasksAreFetched(tasks: [Task])
    func errorWhileFetchingTasks(error: Error)
}
