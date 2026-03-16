//
//  LegacyBrowserSnapshot.swift
//  RedBlockingTests
//
//  Created by Leon Li on 2026/3/16.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Foundation

struct LegacyBrowserSnapshot: Decodable {
    let schemaVersion: Int
    let characterId: String
    let resourceName: String
    let rootPage: LegacyPage
}

struct LegacyPage: Decodable {
    let navigationTitle: String
    let sections: [LegacySection]
}

struct LegacySection: Decodable {
    let sectionTitle: String?
    let rows: [LegacyRow]
}

struct LegacyRow: Decodable {
    let rowTitle: String
    let rowSubtitle: String?
    let rowKind: String
    let actionEntry: LegacyActionEntry
    let children: LegacyPage?
}

struct LegacyActionEntry: Decodable {
    let type: String
    let navigationTitle: String?
    let characterCode: String?
    let skillCode: String?
}
