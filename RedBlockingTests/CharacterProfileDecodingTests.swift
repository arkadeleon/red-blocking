//
//  CharacterProfileDecodingTests.swift
//  RedBlockingTests
//
//  Created by Leon Li on 2026/3/16.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Testing
@testable import RedBlocking

struct CharacterProfileDecodingTests {

    static let allCharacterNames = [
        "Alex", "Chun-Li", "Dudley", "Elena", "Gouki",
        "Hugo", "Ibuki", "Ken", "Makoto", "Necro",
        "Oro", "Q", "Remy", "Ryu", "Sean",
        "Twelve", "Urien", "Yang", "Yun",
    ]

    private func makeRepository() -> MoveRepository {
        MoveRepository(bundle: .main, resourceRootURL: TestPaths.resourcesURL)
    }

    @Test("Profile loads and identifiers are non-empty", arguments: allCharacterNames)
    func profileLoadsWithNonEmptyIdentifiers(characterName: String) throws {
        let profile = try makeRepository().loadProfile(resourceName: "\(characterName).yml")
        #expect(profile.id.isEmpty == false, "id must not be empty for \(characterName)")
        #expect(profile.displayName.isEmpty == false, "displayName must not be empty for \(characterName)")
    }

    @Test("Profile has exactly 5 move groups in schema order", arguments: allCharacterNames)
    func profileHasFiveMoveGroupsInSchemaOrder(characterName: String) throws {
        let profile = try makeRepository().loadProfile(resourceName: "\(characterName).yml")
        let expected: [MoveGroupID] = [.airNormals, .groundNormals, .commandNormals, .specialMoves, .superArts]
        #expect(
            profile.moveGroups.map(\.id) == expected,
            "\(characterName): moveGroup IDs are not in schema order"
        )
    }

    @Test("All move entries have exclusively children or detail", arguments: allCharacterNames)
    func allEntriesHaveExclusiveChildrenOrDetail(characterName: String) throws {
        let profile = try makeRepository().loadProfile(resourceName: "\(characterName).yml")
        for group in profile.moveGroups {
            verifyExclusivity(in: group.entries, context: "\(characterName)/\(group.id.rawValue)")
        }
    }

    // MARK: - Helpers

    private func verifyExclusivity(
        in entries: [MoveEntry],
        context: String,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        for entry in entries {
            #expect(
                (entry.children != nil) != (entry.detail != nil),
                "Entry '\(entry.id)' in \(context) must have exactly one of children or detail",
                sourceLocation: sourceLocation
            )
            if let children = entry.children {
                verifyExclusivity(
                    in: children,
                    context: "\(context)/\(entry.id)",
                    sourceLocation: sourceLocation
                )
            }
        }
    }
}
