//
//  TestPaths.swift
//  RedBlockingTests
//
//  Created by Leon Li on 2026/3/16.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Foundation

enum TestPaths {
    /// Absolute URL of the repository root, computed from this file's location.
    static let projectRoot: URL = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent() // TestPaths.swift → RedBlockingTests/
        .deletingLastPathComponent() // RedBlockingTests/ → project root

    /// URL of RedBlocking/Resources — used as the resourceRootURL for MoveRepository.
    static let resourcesURL: URL = projectRoot
        .appendingPathComponent("RedBlocking/Resources")

    /// URL of docs/character_yaml_legacy_browser_snapshots.
    static let snapshotsURL: URL = projectRoot
        .appendingPathComponent("docs/character_yaml_legacy_browser_snapshots")
}
