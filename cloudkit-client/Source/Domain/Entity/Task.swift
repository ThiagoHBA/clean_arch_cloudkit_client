//
//  Task.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 26/12/22.
//

import Foundation

struct Task: Equatable {
    let isOpen: Bool
    let name: String
    var subtasks: [Subtask]
}
