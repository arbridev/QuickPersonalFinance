//
//  LaunchArguments.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 26/5/23.
//

import Foundation

class LaunchArguments {
    enum Argument: String {
        // A solution using SWIFT_ACTIVE_COMPILATION_CONDITIONS build setting
        // could not be reached for test targets, this is the alternative
        case testing
    }

    static let shared = LaunchArguments()

    private init() {}

    func contains(_ arg: Argument) -> Bool {
        CommandLine.arguments.contains { strArg in
            return String(strArg.suffix(strArg.count - 1)) == arg.rawValue
        }
    }

    func contains(all args: [Argument]) -> Bool {
        for arg in args
        where !CommandLine.arguments.contains(where: {
            String($0.suffix($0.count - 1)) == arg.rawValue
        }) {
            return false
        }
        return true
    }

    func contains(all args: Argument...) -> Bool {
        contains(all: args)
    }
}
