//
//  TaskRepository.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 26/12/22.
//

import Foundation
import CloudKit

class TaskRepository: TaskRepositoryProtocol {
    let taskDAO: TaskDAOProtocol
    let subtaskDAO: SubtaskDAOProtocol

    init(taskDAO: TaskDAOProtocol, subtaskDAO: SubtaskDAOProtocol) {
        self.taskDAO = taskDAO
        self.subtaskDAO = subtaskDAO
    }
    
    func fetchAllTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        var taskList: [Task] = [Task]()
        
        taskDAO.fetchAll { [weak self] result in
            switch result {
                case .success(let records):
                    if records.isEmpty { completion(.success([])) }
                    records.forEach { record in
                        var mappedTask = Task(
                            isOpen: (record["isOpen"] as! Int64) == 1,
                            name: record["name"] as! String,
                            subtasks: []
                        )
                        
                        self?.fetchReferenceSubtask(from: record, to: mappedTask, completion: { subtasks in
                            mappedTask.subtasks = subtasks
                        })
                        
                        taskList.append(mappedTask)
                    }
                
                    completion(.success(taskList))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
                               
    }

    private func fetchReferenceSubtask(from record: CKRecord, to task: Task, completion: @escaping ([Subtask]) -> Void) {
        var subtasks: [Subtask] = [Subtask]()
        let references = record["subtasks"] as! [CKRecord.Reference]
        
        references.forEach { reference in
            subtaskDAO.fetchSubtask(id: reference.recordID) { result in
                switch result {
                    case .success(let record):
                        let subtask = Subtask(
                            done: (record["done"] as! Int64) == 1,
                            name: record["name"] as! String,
                            task: task
                        )
                    
                        subtasks.append(subtask)
                        break
                    case .failure(_):
                        break // how to deal?
                }
            }
        }
        completion(subtasks)
    }
}
