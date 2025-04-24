//
//  CharacterMove.swift
//  MaCherie
//
//  Created by Leon Li on 2018/6/19.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

struct CharacterMove: Decodable {
    let rowTitle: String?
    let rowDetail: String?
    let next: [Section]?
    let presented: Frames?

    private enum CodingKeys: String, CodingKey {
        case rowTitle = "RowTitle"
        case rowDetail = "RowDetail"
        case next = "Next"
        case presented = "Presented"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rowTitle = try container.decodeIfPresent(String.self, forKey: .rowTitle)
        rowDetail = try container.decodeIfPresent(String.self, forKey: .rowDetail)
        next = try container.decodeIfPresent([String : [Section]].self, forKey: .next)?["Sections"]
        presented = try container.decodeIfPresent(Frames.self, forKey: .presented)
    }
}

extension CharacterMove {
    struct Section: Decodable {
        let sectionTitle: String?
        let rows: [CharacterMove]

        private enum CodingKeys: String, CodingKey {
            case sectionTitle = "SectionTitle"
            case rows = "Rows"
        }
    }
}

extension CharacterMove {
    struct Frames: Decodable {
        let viewController: String
        let characterCode: String
        let skillCode: String
        let skillName: String

        private enum CodingKeys: String, CodingKey {
            case viewController = "ViewController"
            case characterCode = "CharacterCode"
            case skillCode = "SkillCode"
            case skillName = "SkillName"
        }
    }
}
