//
//  VideosViewController.swift
//  MaCherie
//
//  Created by Li, Junlin on 2019/11/18.
//  Copyright © 2019 Leon & Vane. All rights reserved.
//

import UIKit
import AVKit

class VideosViewController: UITableViewController {
    var videos: [S3Object] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.videoCell, for: indexPath)!
        cell.textLabel?.text = (videos[indexPath.row].key as NSString).lastPathComponent
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let baseURL = URL(string: "https://game-institute.nyc3.digitaloceanspaces.com")!
        let url = baseURL.appendingPathComponent(videos[indexPath.row].key)
        
        let playerItem = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: playerItem)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true, completion: nil)
    }
}
