//
//  S3.swift
//  MaCherie
//
//  Created by Li, Junlin on 2019/11/18.
//  Copyright © 2019 Leon & Vane. All rights reserved.
//

import Foundation

struct S3Object: Decodable {
    var key: String
    var lastModified: Date
    var size: Int?
    
    enum CodingKeys: String, CodingKey {
        case key = "Key"
        case lastModified = "LastModified"
        case size = "Size"
    }
}

struct S3ObjectList: Decodable {
    var nextMarker: String?
    var isTruncated: Bool
    var objects: [S3Object]?
    
    enum CodingKeys: String, CodingKey {
        case nextMarker = "NextMarker"
        case isTruncated = "IsTruncated"
        case objects = "Contents"
    }
}
