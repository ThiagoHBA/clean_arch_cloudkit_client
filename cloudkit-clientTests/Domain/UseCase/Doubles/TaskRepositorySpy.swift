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
    
    // MARK: - Completions
    var fetchAllTasksData: (() -> (Result<[Task], Error>))?
    
    // MARK: - Protocol Functions
    func fetchAllTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        assert(fetchAllTasksData != nil)
        fetchAllTasksCalled += 1
        completion(fetchAllTasksData!())
    }
    
    func createTask(_ task: cloudkit_client.Task, completion: @escaping (Result<cloudkit_client.Task, Error>) -> Void) {
        
    }
}
