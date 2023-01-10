//
//  TaskDAOProtocol.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 28/12/22.
//

import Foundation
import CloudKit

protocol TaskDAOProtocol {
    func fetchAll(completion: @escaping (Result<[CKRecord], Error>) -> Void)
    func create(_ task: Task, completion: @escaping (Result<CKRecord, Error>) -> Void)
}
