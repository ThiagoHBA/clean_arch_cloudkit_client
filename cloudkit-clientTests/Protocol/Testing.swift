//
//  Testing.swift
//  cloudkit-clientTests
//
//  Created by Thiago Henrique on 31/12/22.
//

import Foundation

protocol Testing {
    associatedtype SutAndDoubles
    func makeSUT() -> SutAndDoubles
}
