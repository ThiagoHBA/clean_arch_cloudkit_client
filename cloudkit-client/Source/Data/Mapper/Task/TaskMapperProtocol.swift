//
//  TaskMapperProtocol.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 07/01/23.
//

import Foundation
import CloudKit

protocol TaskMapperProtocol: DomainEntityMapper where DTO == CKRecord, DomainEntity == Task {
    var client: CloudKitClientProtocol { get }
    init(client: CloudKitClientProtocol)
    func fetchSubtasksReference(
        _ references: [CKRecord.Reference],
        to task: Task,
        completion: @escaping ([Subtask], [(CKRecord.ID, Error)]) -> Void)
}
