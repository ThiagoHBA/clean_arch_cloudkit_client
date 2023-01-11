//
//  ListTasksUseCaseOutputSpy.swift
//  cloudkit-clientTests
//
//  Created by Thiago Henrique on 09/01/23.
//

import Foundation
@testable import cloudkit_client

class ListTasksUseCaseOutputSpy: ListTasksUseCaseOutput {
    enum Message: Equatable, CustomStringConvertible {
        static func == (lhs: ListTasksUseCaseOutputSpy.Message, rhs: ListTasksUseCaseOutputSpy.Message) -> Bool {
            return lhs.description == rhs.description
        }
        
        case tasksAreFetched([Task])
        case errorWhileFetchingTasks(Error)
        
        var description: String {
            switch self {
                case .tasksAreFetched(let taskList):
                    return "Tasks fetched with data \(taskList)"
                case .errorWhileFetchingTasks(let error):
                    return "Error while fetching tasks: \(error.localizedDescription)"
            }
        }
    }
    
    private(set) var receivedMessages: [Message] = [Message]()
    
    func tasksAreFetched(tasks: [Task]) {
        receivedMessages.append(.tasksAreFetched(tasks))
    }
    
    func errorWhileFetchingTasks(error: Error) {
        receivedMessages.append(.errorWhileFetchingTasks(error))
    }
}
