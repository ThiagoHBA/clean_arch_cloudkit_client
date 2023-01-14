//
//  TaskMapperSpy.swift
//  cloudkit-clientTests
//
//  Created by Thiago Henrique on 07/01/23.
//

import Foundation
import CloudKit
@testable import cloudkit_client

class TaskMapperSpy: TaskMapperProtocol {
    var client: CloudKitClientProtocol
    
    required init(client: CloudKitClientProtocol) {
        self.client = client
    }
    
    private(set) var mapToDomainCalled = 0
    var mapToDomainData: (() -> (Task?, Error?))?
    
    func mapToDomain(_ dto: CKRecord, completion: @escaping (Task?, Error?) -> Void) {
        assert(mapToDomainData != nil)
        self.mapToDomainCalled += 1
        let completionData = mapToDomainData!()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(completionData.0, completionData.1)
        }
    }
    
    func fetchSubtasksReference (
        _ references: [CKRecord.Reference],
        to task: Task,
        completion: @escaping ([Subtask], [(CKRecord.ID, Error)]) -> Void) {
        
    }
}
