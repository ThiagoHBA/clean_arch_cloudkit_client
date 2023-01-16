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
        
        self.taskDAO.fetchAll { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                case .success(let records):
                    if records.isEmpty { completion(.success([])) }
                    records.forEach { record in
                        strongSelf.mapper.mapToDomain(record) { task, error in
                            if let error = error { completion(.failure(error)) }
                            if let entity = task {
                                taskList.append(entity)
                                if taskList.count == records.count {
                                    completion(.success(taskList))
                                }
                            }
                        }
                    }
                case .failure(let error):
                    completion(.failure(strongSelf.errorHandler.handleError(error)))
            }
        }
    }
    
    func createTask(_ task: Task, completion: @escaping (Result<Task, Error>) -> Void) {
        self.taskDAO.create(task) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                case .success(let record):
                    strongSelf.mapper.mapToDomain(record) { task, error in
                        if let error = error {
                            completion(.failure(error))
                        }
                        if let entity = task { completion(.success(entity)) }
                    }
                case .failure(let error):
                    completion(.failure(strongSelf.errorHandler.handleError(error)))
            }
        }
    }
    
    func findTask(_ task: Task, completion: @escaping (Task?) -> Void) {
        self.taskDAO.find(task) { [weak self] record in
            if let record = record {
                self?.mapper.mapToDomain(record) { task, error in
                    completion(task)
                }
                return
            }
            completion(nil)
        }
    }
}

