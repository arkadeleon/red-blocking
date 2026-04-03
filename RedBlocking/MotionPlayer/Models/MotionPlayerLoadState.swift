//
//  MotionPlayerLoadState.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

enum MotionPlayerLoadState {
    case idle
    case loading
    case loaded(MotionPlaybackData)
    case failed(String)

    var isLoaded: Bool {
        if case .loaded = self { return true }
        return false
    }
}
