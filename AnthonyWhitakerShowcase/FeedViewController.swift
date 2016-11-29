//
//  FeedViewController.swift
//  AnthonyWhitakerShowcase
//
//  Created by Anthony Whitaker on 11/24/16.
//  Copyright © 2016 Anthony Whitaker. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FeedViewController: UIViewController {
    
    @IBOutlet weak var feedTableView: UITableView!
    var posts = [Post]()
    static var imageCache = NSCache<NSString, UIImage>()

    override func viewDidLoad() {
        super.viewDidLoad()

        feedTableView.delegate = self
        feedTableView.dataSource = self
        
        feedTableView.estimatedRowHeight = 300
        
        // FIXME: Loads every post ever made. Limit to most recent posts.
        DataService.instance.REF_POSTS.observe(.value, with: {snapshot in
            if snapshot.value != nil { // FIXME: Potential to destabilize UI with numerous updates from other users.
                print(snapshot.value!)
                
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshots {
                        print("SNAP: \(snap)")
                        
                        if let postData = snap.value as? Dictionary<String, Any> {
                            let postKey = snap.key
                            if let post = Post(postKey: postKey, data: postData) {
                                self.posts.append(post)
                            }
                        }
                    }
                }
                  
                self.feedTableView.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        // Potentially dispose of extra posts.
        // TODO: Dump cache
        // May have issue with several large images being scaled down.
        // TODO: Ensure images are scaled properly before being uploaded/downloaded.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        
        //FIXME: Row height should be calculated dynamically to fit contents.
        if post.imageUrl == nil {
            return 175
        } else {
            return feedTableView.estimatedRowHeight
        }
    }
}

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        print(post.postDescription)
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as? PostTableViewCell {
            cell.request?.cancel()
            
            var image: UIImage?
            
            if let url = post.imageUrl {
                image = FeedViewController.imageCache.object(forKey: url as NSString)
            }
            
            cell.configureCell(post, image: image)
            return cell
        }
        
        return PostTableViewCell()
    }
}
