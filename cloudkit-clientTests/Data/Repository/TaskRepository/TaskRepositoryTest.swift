//
//  TaskRepositoryTest.swift
//  cloudkit-clientTests
//
//  Created by Thiago Henrique on 31/12/22.
//

import XCTest
@testable import cloudkit_client
import CloudKit

final class TaskRepositoryTest: XCTestCase {
    func test_fetchAllTasks_when_no_values_return_empty_list() {
        let (sut, (taskMock, subtaskMock)) = makeSUT()
        taskMock.fetchAllData = { .success([]) }
        subtaskMock.fetchSubtaskData = { .success(CKRecord(recordType: "SubtaskItem")) }
        
        sut.fetchAllTasks { result in
            switch result {
            case .success(let taskList):
                XCTAssertEqual([], taskList)
            case .failure(_):
                XCTFail("List should be initialized with zero values")
            }
        }
    }
    
    func test_fetchAllTasks_when_no_values_fetch_called_only_once() {
        let (sut, (taskSpy, subtaskSpy)) = makeSUT()
        taskSpy.fetchAllData = { .success([]) }
        subtaskSpy.fetchSubtaskData = { .success(CKRecord(recordType: "SubtaskItem")) }
        
        sut.fetchAllTasks { _ in }
        XCTAssertEqual(taskSpy.fetchAllCalled, 1)
        XCTAssertEqual(subtaskSpy.fetchSubtaskCalled, 0)
    }
    
    func test_fetchAllTasks_when_value_should_map_correctly() {
        let (sut, (taskSpy, subtaskSpy)) = makeSUT()
        
        let inputData = CKRecord(recordType: "TaskItem")
        
        inputData.setValuesForKeys([
            "isOpen": true,
            "name": "",
            "subtasks": []
        ])
        
        taskSpy.fetchAllData = { .success([ inputData ]) }
        subtaskSpy.fetchSubtaskData = { .success(CKRecord(recordType: "SubtaskItem")) }

        sut.fetchAllTasks { result in
            switch result {
            case .success(let tasklist):
                XCTAssertEqual(
                    tasklist.filter {
                        $0 == Task(isOpen: true, name: "", subtasks: [])
                }.count, 1)
            case .failure(let error):
                XCTFail("unexpected error raised by fetchAllTask function: \(error.localizedDescription)")
            }
        }
    }
    
    func test_fetchAllTasks_when_value_should_map_all_subtasks_correctly() {
        let (sut, (taskSpy, subtaskSpy)) = makeSUT()
        let inputData = CKRecord(recordType: "TaskItem")
        let subtaskRecord = CKRecord(recordType: "SubtaskItem")
        
        inputData.setValuesForKeys([ "isOpen": true, "name": "" ])
        subtaskRecord.setValuesForKeys([ "done": false, "name": "", "task": CKRecord.Reference(record: inputData, action: .none) ])
        inputData.setValuesForKeys([ "subtasks": [ CKRecord.Reference(record: subtaskRecord, action: .none)] ])
    
        taskSpy.fetchAllData = { .success([ inputData ]) }
        subtaskSpy.fetchSubtaskData = { .success(subtaskRecord) }
        
        let expectedTask = Task(isOpen: true, name: "", subtasks: [])
        let expectedSubtask = Subtask(done: false, name: "", task: expectedTask)
        
        sut.fetchAllTasks { result in
            switch result {
                case .success(let tasklist):
                    XCTAssertEqual(tasklist.filter {
                        $0.subtasks.contains(expectedSubtask)
                    }.count, 1)
                case .failure(let error):
                    XCTFail("unexpected error raised by fetchAllTask function: \(error.localizedDescription)")
            }
        }
    }

}


extension TaskRepositoryTest: Testing {
    typealias SutAndDoubles = (TaskRepository, (TaskDAOMock, SubtaskDAOMock))
    func makeSUT() -> SutAndDoubles {
        let taskDAOSpy = TaskDAOMock()
        let subtaskDAOSpy = SubtaskDAOMock()
        
        let sut = TaskRepository(
            taskDAO: taskDAOSpy,
            subtaskDAO: subtaskDAOSpy
        )
        
        return (sut, (taskDAOSpy, subtaskDAOSpy))
    }
}



