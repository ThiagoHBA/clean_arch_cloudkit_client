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
    var fetchAllTasksData: (() -> (Result<[Task], Error>))?
    
    func fetchAllTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        assert(fetchAllTasksData != nil)
        fetchAllTasksCalled += 1
        completion(fetchAllTasksData!())
    }
}
