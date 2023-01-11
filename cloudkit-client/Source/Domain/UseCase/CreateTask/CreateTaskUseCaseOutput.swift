//
//  CreateTaskUseCaseOutput.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 10/01/23.
//

import Foundation

protocol CreateTaskUseCaseOutput {
    func errorWhileCreatingTask(_ error: Error)
    func succesfullyCreateTask(_ task: Task)
}
