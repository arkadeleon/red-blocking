//
//  MusicViewController.swift
//  MaCherie
//
//  Created by Li, Junlin on 2019/11/18.
//  Copyright © 2019 Leon & Vane. All rights reserved.
//

import UIKit
import AVKit

class MusicViewController: UITableViewController {
    private let player = AVPlayer()
    private var items: [AVPlayerItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc private func refreshControlAction(_ sender: Any) {
        let url = URL(string: "https://game-institute.nyc3.digitaloceanspaces.com/?prefix=ma-cherie/music/")!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let objectList = try? decoder.decode(S3ObjectList.self, from: data)
            
            self.items = objectList?.objects?.map { (object) -> AVPlayerItem in
                let baseURL = URL(string: "https://game-institute.nyc3.digitaloceanspaces.com")!
                let url = baseURL.appendingPathComponent(object.key)
                let item = AVPlayerItem(url: url)
                return item
            } ?? []
            self.tableView.reloadData()
        }.resume()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        player.replaceCurrentItem(with: item)
        player.play()
    }
}
