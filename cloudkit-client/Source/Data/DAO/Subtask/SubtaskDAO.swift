//
//  SubtaskDAO.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 28/12/22.
//

import Foundation
import CloudKit

class SubtaskDAO: SubtaskDAOProtocol {
    let client: CloudKitClientProtocol
    
    init(client: CloudKitClientProtocol) {
        self.client = client
    }
    
    func fetchSubtask(id: CKRecord.ID, completion: @escaping (Result<CKRecord, Error>) -> Void) {
        client.fetchPerId(id, completion: completion)
    }
}
