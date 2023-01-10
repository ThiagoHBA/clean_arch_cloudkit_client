//
//  TaskListViewSpy.swift
//  cloudkit-clientTests
//
//  Created by Thiago Henrique on 09/01/23.
//

import Foundation
@testable import cloudkit_client

class TaskListViewSpy: TaskListViewProtocol {
    enum Message: Equatable, CustomStringConvertible {
        case displayTaskList([Task])
        case displayError(String, String)
        case showLoading
        case hideLoading
        
        var description: String {
            switch self {
                case .displayTaskList(let taskList):
                    return "Display task list with data: \(taskList)"
                case .displayError(let title, let message):
                    return "Display error: \(title) - \(message)"
                case .showLoading:
                    return "Show loading called"
                case .hideLoading:
                    return "Hide loading called"
            }
        }
    }
    
    private(set) var receivedMessages: [Message] = [Message]()
    
    func displayTaskList(_ tasks: [cloudkit_client.Task], completion: @escaping () -> Void) {
        receivedMessages.append(.displayTaskList(tasks))
        completion()
    }
    
    func displayError(title: String, message: String, completion: @escaping () -> Void) {
        receivedMessages.append(.displayError(title, message))
        completion()
    }
    
    func showLoading(completion: @escaping () -> Void) {
        receivedMessages.append(.showLoading)
        completion()
    }
    
    func hideLoading(completion: @escaping () -> Void) {
        receivedMessages.append(.hideLoading)
        completion()
    }
}

