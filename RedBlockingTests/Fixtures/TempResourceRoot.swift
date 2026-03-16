//
//  TempResourceRoot.swift
//  RedBlockingTests
//
//  Created by Leon Li on 2026/3/16.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Foundation
@testable import RedBlocking

/// Creates a temporary directory layout that MoveRepository can read from.
/// Each instance creates an isolated directory — safe for parallel tests.
struct TempResourceRoot {
    let url: URL

    init() throws {
        url = FileManager.default.temporaryDirectory
            .appendingPathComponent("RedBlockingTests-\(UUID().uuidString)")
        let dataDir = url.appendingPathComponent("CharacterData")
        try FileManager.default.createDirectory(at: dataDir, withIntermediateDirectories: true)
    }

    func write(yaml content: String, named fileName: String) throws {
        let fileURL = url.appendingPathComponent("CharacterData/\(fileName)")
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    func makeRepository() -> MoveRepository {
        MoveRepository(bundle: .main, resourceRootURL: url)
    }

    func cleanup() {
        try? FileManager.default.removeItem(at: url)
    }
}
