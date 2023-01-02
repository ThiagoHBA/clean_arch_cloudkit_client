//
//  ListTasksUseCase.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 28/12/22.
//

import Foundation

class ListTasksUseCase {
    var repository: TaskRepositoryProtocol
    weak var output: ListTasksUseCaseOutput?
    
    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }
     
    func execute() {
        repository.fetchAllTasks { [weak self] result in
            switch result {
                case .success(let tasks):
                    self?.output?.tasksAreFetched(tasks: tasks)
                case .failure(let error):
                    self?.output?.errorWhileFetchingTasks(error: error)
            }
        }
    }
}
