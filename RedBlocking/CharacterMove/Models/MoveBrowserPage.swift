//
//  MoveBrowserPage.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/13.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

struct MoveBrowserPage: Hashable, Identifiable {
    let id: String
    let navigationTitle: String
    let sections: [MoveBrowserSection]
}
