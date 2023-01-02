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
        let query = CKQuery(recordType: "TaskItem", predicate: NSPredicate(value: true))
        query.sortDescriptors = [ NSSortDescriptor(key: "modificationDate", ascending: true)]
        client.fetchData(query: query, completion: completion)
    }
    
    func create() {}
    
    func update() {}
    
    func delete() {}
}
