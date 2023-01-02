//
//  SubtaskDAOProtocol.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 28/12/22.
//

import Foundation
import CloudKit

protocol SubtaskDAOProtocol {
    func fetchSubtask(id: CKRecord.ID, completion: @escaping (Result<CKRecord, Error>) -> Void)
}
