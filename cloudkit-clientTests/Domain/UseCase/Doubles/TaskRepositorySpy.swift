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
    private(set) var createTaskCalled = 0
    
    // MARK: - Completions
    var fetchAllTasksData: (() -> (Result<[Task], Error>))?
    var findTaskData: (() -> Task?)?
    var createTaskData: (() -> (Result<Task, Error>))?
    
    // MARK: - Protocol Functions
    func fetchAllTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        assert(fetchAllTasksData != nil)
        fetchAllTasksCalled += 1
        completion(fetchAllTasksData!())
    }
    
    func createTask(_ task: Task, completion: @escaping (Result<Task, Error>) -> Void) {
        assert(createTaskData != nil)
        createTaskCalled += 1
        completion(createTaskData!())
    }
    
    func findTask(_ task: Task, completion: @escaping (Task?) -> Void) {
        assert(findTaskData != nil)
        findTaskCalled += 1
        completion(findTaskData!())
    }
}
