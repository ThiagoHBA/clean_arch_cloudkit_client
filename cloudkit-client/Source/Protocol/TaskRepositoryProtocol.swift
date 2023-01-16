//
//  TaskRepositoryProtocol.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 25/12/22.
//
import Foundation

protocol TaskRepositoryProtocol {
    func fetchAllTasks(completion: @escaping (Result<[Task], Error>) -> Void)
    func createTask(_ task: Task, completion: @escaping (Result<Task, Error>) -> Void)
    func findTask(_ task: Task, completion: @escaping (Task?) -> Void)
}
