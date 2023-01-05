//
//  DomainEntityMapper.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 04/01/23.
//

import Foundation

protocol DomainEntityMapper {
    associatedtype DTO
    associatedtype DomainEntity
    func mapToDomain(_ dto: DTO, completion: @escaping (DomainEntity?, Error?) -> Void)
}

