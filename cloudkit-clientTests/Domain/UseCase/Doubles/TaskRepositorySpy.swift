//
//  TaskRepositorySpy.swift
//  cloudkit-clientTests
//
//  Created by Thiago Henrique on 09/01/23.
//

import Foundation
@testable import cloudkit_client

class TaskRepositorySpy: TaskRepositoryProtocol {
    private(set) var fetchAllTasksCalled = 0
    private(set) var findTaskCalled = 0
    
    // MARK: - Completions
    var fetchAllTasksData: (() -> (Result<[Task], Error>))?
    var findTaskData: (() -> Task?)?
    
    // MARK: - Protocol Functions
    func fetchAllTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        assert(fetchAllTasksData != nil)
        fetchAllTasksCalled += 1
        completion(fetchAllTasksData!())
    }
    
    func createTask(_ task: cloudkit_client.Task, completion: @escaping (Result<cloudkit_client.Task, Error>) -> Void) {
        
    }
    
    func findTask(_ task: Task, completion: @escaping (Task?) -> Void) {
        assert(findTaskData != nil)
        findTaskCalled += 1
        completion(findTaskData!())
    }
}
