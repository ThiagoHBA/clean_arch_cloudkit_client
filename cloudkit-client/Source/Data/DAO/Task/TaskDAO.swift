//
//  TaskDAO.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 28/12/22.
//

import Foundation
import CloudKit

class TaskDAO: TaskDAOProtocol {
    let client: CloudKitClientProtocol
    
    init(client: CloudKitClientProtocol) {
        self.client = client
    }
    
    func fetchAll(completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        var recordList: [CKRecord] = [CKRecord]()
        var failedRecords: [(CKRecord.ID, Error)] = [(CKRecord.ID, Error)]()
        
        let query = CKQuery(recordType: "TaskItem", predicate: NSPredicate(value: true))
        query.sortDescriptors = [ NSSortDescriptor(key: "modificationDate", ascending: true)]
        
        client.fetchData(query: query) { result in
            switch result {
                case .success(let matchRecords):
                    matchRecords.forEach { recordId, recordResult in
                        switch recordResult {
                            case .success(let record):
                                recordList.append(record)
                            case .failure(let error):
                                failedRecords.append((recordId, error))
                        }
                    }
                    completion(.success(recordList))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    func create(_ task: Task, completion: @escaping (Result<CKRecord, Error>) -> Void) {
        let record = CKRecord(recordType: "TaskItem")
        record.setValuesForKeys([
            "name": task.name,
            "isOpen": task.isOpen,
            "subtasks": task.subtasks
        ])
        client.createRecord(record) { result in
            switch result {
            case .success(let record):
                completion(.success(record))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
