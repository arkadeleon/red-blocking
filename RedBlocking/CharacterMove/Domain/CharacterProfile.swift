//
//  CharacterProfile.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/13.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Foundation

struct CharacterProfile: Decodable, Equatable, Hashable {
    let id: String
    let displayName: String
    let introduction: CharacterIntroduction
    let moveGroups: [MoveGroup]

    private enum CodingKeys: String, CodingKey {
        case character
        case introduction
        case moveGroups
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let character = try container.decode(CharacterPayload.self, forKey: .character)

        id = character.id
        displayName = character.displayName
        introduction = try container.decode(CharacterIntroduction.self, forKey: .introduction)
        moveGroups = try container.decode([MoveGroup].self, forKey: .moveGroups)

        guard moveGroups.map(\.id) == MoveGroupID.allCases else {
            throw DecodingError.dataCorruptedError(
                forKey: .moveGroups,
                in: container,
                debugDescription: "moveGroups must contain the 5 fixed group ids in schema order."
            )
        }
    }
}

extension CharacterProfile {
    private struct CharacterPayload: Decodable {
        let id: String
        let displayName: String
    }
}

struct CharacterIntroduction: Decodable, Equatable, Hashable {
    let displayTitle: String
    let body: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        displayTitle = try container.decode(String.self, forKey: .displayTitle)
        body = try container.decode(String.self, forKey: .body)

        guard body.containsNonWhitespace else {
            throw DecodingError.dataCorruptedError(
                forKey: .body,
                in: container,
                debugDescription: "introduction.body must not be empty."
            )
        }
    }
}

extension CharacterIntroduction {
    private enum CodingKeys: String, CodingKey {
        case displayTitle
        case body
    }
}

struct MoveGroup: Decodable, Equatable, Hashable {
    let id: MoveGroupID
    let displayTitle: String
    let entries: [MoveEntry]
}

enum MoveGroupID: String, CaseIterable, Decodable, Equatable, Hashable {
    case airNormals = "air_normals"
    case groundNormals = "ground_normals"
    case commandNormals = "command_normals"
    case specialMoves = "special_moves"
    case superArts = "super_arts"
}

struct MoveEntry: Decodable, Equatable, Hashable {
    let id: String
    let displayName: String
    let children: [MoveEntry]?
    let variants: [MoveVariant]?
    let detail: MoveDetail?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let hasChildrenKey = container.contains(.children)
        let hasVariantsKey = container.contains(.variants)
        let hasDetailKey = container.contains(.detail)

        id = try container.decode(String.self, forKey: .id)
        displayName = try container.decode(String.self, forKey: .displayName)
        children = try container.decodeIfPresent([MoveEntry].self, forKey: .children)
        variants = try container.decodeIfPresent([MoveVariant].self, forKey: .variants)
        detail = try container.decodeIfPresent(MoveDetail.self, forKey: .detail)

        let presentCount = [hasChildrenKey, hasVariantsKey, hasDetailKey].filter { $0 }.count
        guard presentCount == 1 else {
            throw DecodingError.dataCorruptedError(
                forKey: .detail,
                in: container,
                debugDescription: "MoveEntry must contain exactly one of children, variants, or detail."
            )
        }

        if let children, children.isEmpty {
            throw DecodingError.dataCorruptedError(
                forKey: .children,
                in: container,
                debugDescription: "MoveEntry.children must not be empty."
            )
        }

        if let variants, variants.isEmpty {
            throw DecodingError.dataCorruptedError(
                forKey: .variants,
                in: container,
                debugDescription: "MoveEntry.variants must not be empty."
            )
        }
    }
}

extension MoveEntry {
    private enum CodingKeys: String, CodingKey {
        case id
        case displayName
        case children
        case variants
        case detail
    }
}

struct MoveVariant: Decodable, Equatable, Hashable {
    let id: String
    let displayName: String
    let detail: MoveDetail
}

struct MoveDetail: Decodable, Equatable, Hashable {
    let displayName: String
    let command: String?
    let superCancel: String?
    let `guard`: String?
    let blocking: String?
    let startup: String?
    let active: String?
    let recovery: String?
    let damage: String?
    let chipDamage: String?
    let stun: String?
    let stunReduction: String?
    let meterGain: MeterGain?
    let frameAdvantage: FrameAdvantage?
    let stats: LabeledValueMap?
    let noteGroups: [MoveNoteGroup]
    let media: MoveMedia?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        displayName = try container.decode(String.self, forKey: .displayName)
        command = try container.decodeIfPresent(String.self, forKey: .command)
        superCancel = try container.decodeIfPresent(String.self, forKey: .superCancel)
        `guard` = try container.decodeIfPresent(String.self, forKey: .guardValue)
        blocking = try container.decodeIfPresent(String.self, forKey: .blocking)
        startup = try container.decodeIfPresent(String.self, forKey: .startup)
        active = try container.decodeIfPresent(String.self, forKey: .active)
        recovery = try container.decodeIfPresent(String.self, forKey: .recovery)
        damage = try container.decodeIfPresent(String.self, forKey: .damage)
        chipDamage = try container.decodeIfPresent(String.self, forKey: .chipDamage)
        stun = try container.decodeIfPresent(String.self, forKey: .stun)
        stunReduction = try container.decodeIfPresent(String.self, forKey: .stunReduction)
        meterGain = try container.decodeIfPresent(MeterGain.self, forKey: .meterGain)
        frameAdvantage = try container.decodeIfPresent(FrameAdvantage.self, forKey: .frameAdvantage)
        stats = try container.decodeIfPresent(LabeledValueMap.self, forKey: .stats)
        noteGroups = try container.decodeIfPresent([MoveNoteGroup].self, forKey: .noteGroups) ?? []
        media = try container.decodeIfPresent(MoveMedia.self, forKey: .media)

        guard displayName.containsNonWhitespace else {
            throw DecodingError.dataCorruptedError(
                forKey: .displayName,
                in: container,
                debugDescription: "MoveDetail.displayName must not be empty."
            )
        }
    }
}

extension MoveDetail {
    private enum CodingKeys: String, CodingKey {
        case displayName
        case command
        case superCancel
        case guardValue = "guard"
        case blocking
        case startup
        case active
        case recovery
        case damage
        case chipDamage
        case stun
        case stunReduction
        case meterGain
        case frameAdvantage
        case stats
        case noteGroups
        case media
    }
}

struct MoveMedia: Decodable, Equatable, Hashable {
    let kind: Kind
    let displayLabel: String
    let skillName: String
    let characterCode: String
    let skillCode: String
}

extension MoveMedia {
    enum Kind: String, Decodable, Equatable, Hashable {
        case motionPlayer = "motion_player"
    }
}

struct MoveLabeledValue: Decodable, Equatable, Hashable {
    let id: String
    let label: String
    let value: String
}

struct MeterGain: Decodable, Equatable, Hashable {
    let whiff: String?
    let `guard`: String?
    let hit: String?
    let bl: String?
    let throwSuccess: String?
    let onWhiff: String?
}

struct FrameAdvantage: Decodable, Equatable, Hashable {
    let `guard`: String?
    let hit: String?
    let standingHit: String?
    let crouchingHit: String?
}

struct LabeledValueMap: Decodable, Equatable, Hashable {
    let pairs: [(label: String, value: String)]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicKey.self)
        pairs = try container.allKeys.map { key in
            let value = try container.decode(String.self, forKey: key)
            return (label: key.stringValue, value: value)
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.pairs.count == rhs.pairs.count else { return false }
        return zip(lhs.pairs, rhs.pairs).allSatisfy { l, r in l.label == r.label && l.value == r.value }
    }

    func hash(into hasher: inout Hasher) {
        for pair in pairs {
            hasher.combine(pair.label)
            hasher.combine(pair.value)
        }
    }

    var isEmpty: Bool { pairs.isEmpty }
}

private struct DynamicKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    init(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) { nil }
}

struct MoveNoteGroup: Decodable, Equatable, Hashable {
    let id: String
    let displayTitle: String
    let entries: [String]
}

private extension String {
    var containsNonWhitespace: Bool {
        trimmedLength > 0
    }

    private var trimmedLength: Int {
        trimmingCharacters(in: .whitespacesAndNewlines).count
    }
}
