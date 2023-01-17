//
//  TaskResultBuilderAutoclosure.swift
//  TaskGroups
//
//  Created by Antoine van der Lee on 12/01/2023.
//

import Foundation

@resultBuilder
struct TaskBuilderAutoclosure {

    typealias BuildClosure<Success: Sendable> = () async -> Success

    static func buildExpression<Success1>(_ closure: @Sendable @autoclosure @escaping () -> Task<Success1, Never>) -> [Task<Success1, Never>] {
        [closure()]
    }

    static func buildBlock<Success2: Sendable>(_ tasks: [Task<Success2, Never>]) -> [Task<Success2, Never>] {
        tasks
//            .map { closure in
//            Task { closure() }
//        }
    }


//    static func buildExpression<Success>(_ closure: @Sendable @autoclosure @escaping () async -> Success) async -> [Task<Success, Never>] {
//        let task = Task(operation: closure)
//        return [task]
//    }
//
//    static func buildBlock<Success: Sendable>(_ tasks: (@Sendable () async -> Success)...) -> [Task<Success, Never>] {
//        return tasks.map { closure in
//            let task = Task(operation: closure)
//            return task
//        }
//    }

    static func buildFinalResult<Success: Sendable>(_ tasks: [Task<Success, Never>]) -> Task<[Success], Never> {
        return Task {
            await withTaskGroup(of: Success.self, returning: [Success].self) { taskGroup in
                tasks.forEach { task in
                    taskGroup.addTask {
                        await task.value
                    }
                }

                return await taskGroup.reduce(into: [Success]()) { partialResult, name in
                    partialResult.append(name)
                }
            }
        }
    }

}

func withTaskGroupAutoclosure<Success: Sendable>(@TaskBuilderAutoclosure builder: () -> Task<[Success], Never>) async -> Task<[Success], Never> {
    return builder()
}
