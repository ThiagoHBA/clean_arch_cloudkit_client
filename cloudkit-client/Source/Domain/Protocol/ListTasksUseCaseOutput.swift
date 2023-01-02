//
//  ListTasksUseCaseOutput.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 28/12/22.
//

import Foundation

protocol ListTasksUseCaseOutput: AnyObject {
    func tasksAreFetched(tasks: [Task])
    func errorWhileFetchingTasks(error: Error)
}
