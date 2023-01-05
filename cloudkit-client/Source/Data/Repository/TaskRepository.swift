//
//  TaskRepository.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 26/12/22.
//

import Foundation

class TaskRepository: TaskRepositoryProtocol {
    let taskDAO: TaskDAOProtocol
    let errorHandler: DataSourceErrorHandler
    let mapper: TaskMapper
    
    init(
        taskDAO: TaskDAOProtocol, errorHandler: DataSourceErrorHandler, mapper: TaskMapper) {
            self.taskDAO = taskDAO
            self.errorHandler = errorHandler
            self.mapper = mapper
        }
    
    func fetchAllTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        var taskList: [Task] = [Task]()
        
        taskDAO.fetchAll { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                case .success(let records):
                    if records.isEmpty { completion(.success([])) }
                    records.forEach { record in
                        strongSelf.mapper.mapToDomain(record) { task, error in
                            if let error = error { completion(.failure(error)) }
                            if let entity = task { taskList.append(entity) }
                        }
                    }
                    completion(.success(taskList))
                case .failure(let error):
                    completion(.failure(strongSelf.errorHandler.handleError(error)))
            }
        }
        
    }
}

