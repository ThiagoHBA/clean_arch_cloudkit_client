//
//  CreateTaskUseCaseOutputSpy.swift
//  cloudkit-clientTests
//
//  Created by Thiago Henrique on 10/01/23.
//

import Foundation
@testable import cloudkit_client

class CreateTaskUseCaseOutputSpy {
    enum Message: Equatable, CustomStringConvertible {
        case errorWhileCreatingTask(Error)
        case succesfullyCreateTask(Task)
        
        var description: String {
            switch self {
                case .errorWhileCreatingTask(let error):
                    return "Error raised with data: \(error)"
                case .succesfullyCreateTask(let task):
                    return "Successfuly create task with data: \(task)"
            }
        }
        
        static func == (lhs: CreateTaskUseCaseOutputSpy.Message, rhs: CreateTaskUseCaseOutputSpy.Message) -> Bool {
            return lhs.description == rhs.description
        }
    }
    
    private(set) var receivedMessages: [Message] = [Message]()
}

extension CreateTaskUseCaseOutputSpy: CreateTaskUseCaseOutput {
    func succesfullyCreateTask(_ task: Task) {
        receivedMessages.append(.succesfullyCreateTask(task))
    }
    
    func errorWhileCreatingTask(_ error: Error) {
        receivedMessages.append(.errorWhileCreatingTask(error))
    }
}
