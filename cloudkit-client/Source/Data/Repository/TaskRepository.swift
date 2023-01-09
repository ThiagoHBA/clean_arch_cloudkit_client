//
//  TaskRepository.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 26/12/22.
//

import Foundation

class TaskRepository<Mapper: TaskMapperProtocol> {
    let taskDAO: TaskDAOProtocol
    let errorHandler: DataSourceErrorHandler
    let mapper: Mapper
    
    init(taskDAO: TaskDAOProtocol, errorHandler: DataSourceErrorHandler, mapper: Mapper) {
        self.taskDAO = taskDAO
        self.errorHandler = errorHandler
        self.mapper = mapper
    }
}

extension TaskRepository: TaskRepositoryProtocol {
    func fetchAllTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        var taskList: [Task] = [Task]()
        
        self.taskDAO.fetchAll { result in
            switch result {
                case .success(let records):
                    if records.isEmpty { completion(.success([])) }
                    records.forEach { record in
                        self.mapper.mapToDomain(record) { task, error in
                            if let entity = task {
                                if error == nil { taskList.append(entity) }
                                // entity & error
                            }
                        }
                    }
                    completion(.success(taskList))
                case .failure(let error):
                    completion(.failure(self.errorHandler.handleError(error)))
            }
        }
        
    }
}

