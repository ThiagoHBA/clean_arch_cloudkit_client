//
//  UseCase.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 07/01/23.
//

import Foundation

protocol UseCase {
    associatedtype Gateway
    associatedtype UseCaseOutput
    var repository: Gateway { get set }
    var output: UseCaseOutput? { get set }
    init(repository: Gateway)
    func execute()
}
