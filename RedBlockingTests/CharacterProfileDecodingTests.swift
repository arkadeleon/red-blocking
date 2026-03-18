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

    @Test("Profile has move groups in schema order", arguments: allCharacterNames)
    func profileHasMoveGroupsInSchemaOrder(characterName: String) throws {
        let profile = try makeRepository().loadProfile(resourceName: "\(characterName).yml")
        let ids = profile.moveGroups.map(\.id)
        let withTC: [MoveGroupID] = [.groundNormals, .airNormals, .specialMoves, .superArts, .leverInputMoves, .normalThrows, .commonMoves, .targetCombos]
        let withoutTC: [MoveGroupID] = [.groundNormals, .airNormals, .specialMoves, .superArts, .leverInputMoves, .normalThrows, .commonMoves]
        #expect(
            ids == withTC || ids == withoutTC,
            "\(characterName): moveGroup IDs are not in schema order"
        )
    }

    @Test("All move entries have exactly one of children, variants, or detail", arguments: allCharacterNames)
    func allEntriesHaveExclusiveChildrenVariantsOrDetail(characterName: String) throws {
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
            let presentCount = [entry.children != nil, entry.variants != nil, entry.detail != nil]
                .filter { $0 }.count
            #expect(
                presentCount == 1,
                "Entry '\(entry.id)' in \(context) must have exactly one of children, variants, or detail",
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
