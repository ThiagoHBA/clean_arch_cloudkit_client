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
    
    func displayTaskList(_ tasks: [Task]) {
        receivedMessages.append(.displayTaskList(tasks))
    }
    
    func displayError(title: String, message: String) {
        receivedMessages.append(.displayError(title, message))
    }
    
    func showLoading() {
        receivedMessages.append(.showLoading)
    }
    
    func hideLoading() {
        receivedMessages.append(.hideLoading)
    }
}

