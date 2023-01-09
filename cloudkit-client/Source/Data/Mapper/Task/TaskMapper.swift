//
//  TaskMapper.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 04/01/23.
//

import Foundation
import CloudKit

struct DomainEntityMapperError: LocalizedError, CustomStringConvertible {
    var domainEntityErrorDescription: String
    var recoverySuggestion: String?
    
    var description: String {  return
        "\(domainEntityErrorDescription) \(recoverySuggestion ?? "")"
    }
}

struct TaskMapper: TaskMapperProtocol {
    let client: CloudKitClientProtocol
    
    init(client: CloudKitClientProtocol) { self.client = client }
    
    func mapToDomain(_ dto: CKRecord, completion: @escaping (Task?, Error?) -> Void) {
        if let isOpen = dto["isOpen"] as? Int64,
           let name = dto["name"] as? String,
           let subtasksReference = dto["subtasks"] as? [CKRecord.Reference] {
            
            var task = Task(
                isOpen: isOpen == 1,
                name: name,
                subtasks: []
            )
            
            fetchSubtasksReference(subtasksReference, to: task) { subtaskList, failureSubtasks in
                task.subtasks = subtaskList
                if !failureSubtasks.isEmpty {
                    completion(
                        nil,
                        DomainEntityMapperError(
                            domainEntityErrorDescription: "Ocorreu um erro no mapeamento dos dados do servidor!",
                            recoverySuggestion: "Verifique se existe uma atualização do aplicativo e tente novamente!"
                        )
                    )
                    return
                }
                completion(task, nil)
            }
        }
    }
    
    func fetchSubtasksReference(
        _ references: [CKRecord.Reference],
        to task: Task,
        completion: @escaping ([Subtask], [(CKRecord.ID, Error)]) -> Void
    ) {
        var subtasks: [Subtask] = [Subtask]()
        var failureSubtasks: [(CKRecord.ID, Error)] = [(CKRecord.ID, Error)]()
        
        if references.isEmpty { completion([], []) }
        references.forEach { reference in
            client.fetchPerId(reference.recordID) { result in
                switch result {
                    case .success(let record):
                        let subtask = Subtask(
                            done: (record["done"] as! Int64) == 1,
                            name: record["name"] as! String,
                            task: task
                        )
                        subtasks.append(subtask)
                    case .failure(let error):
                        failureSubtasks.append((reference.recordID, error))
                }
                completion(subtasks, failureSubtasks)
            }
        }
        
    }
   
}
