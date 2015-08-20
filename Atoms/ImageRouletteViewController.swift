//
//  ImageRouletteViewController.swift
//  Atoms
//
//  Created by Robert Brown on 8/4/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import UIKit

class ImageRouletteViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var wordLabel: UILabel!
    private let queue = OperationQueue()
    
    @IBAction func tappedNewWordButton(sender: UIButton) {
        newWord()
    }
    
    private func newWord() {
        randomWordURL()
            |> DownloadPipeOperation()
            |> extractWordOperation()
            |> setWordOperation()
            |> createWordURLOperation()
            |> DownloadPipeOperation()
            |> parseImageJSONOperation()
            |> DownloadPipeOperation()
            |> ImageReadOperation()
            |> setImageOperation()
            |> queue
    }
    
    private func randomWordURL() -> Requestable {
        return "http://randomword.setgetgo.com/get.php"
    }
    
    private func extractWordOperation() -> PipeOperation<NSURL,String> {
        return PipeClosureOperation<NSURL,String> { url, _ in
            defer {
                do {
                    try NSFileManager.defaultManager().removeItemAtURL(url)
                }
                catch {}
            }
            do {
                return try String(contentsOfURL: url).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            }
            catch {
                return nil
            }
        }
    }
    
    private func setWordOperation() -> PipeOperation<String,String> {
        return PipeClosureOperation<String,String> { word, _ in
            dispatch_async(dispatch_get_main_queue()) {
                self.wordLabel.text = word
            }
            return word
        }
    }
    
    private func createWordURLOperation() -> PipeOperation<String,Requestable> {
        return PipeClosureOperation<String,Requestable> { word in
            return "https://ajax.googleapis.com/ajax/services/search/images?v=1.0&as_filetype=jpg&rsz=1&safe=high&imgsz=medium&q=\(word)"
        }
    }
    
    private func parseImageJSONOperation() -> PipeOperation<NSURL,Requestable> {
        return PipeClosureOperation<NSURL,Requestable> { url, _ in
            do {
                guard let data = NSData(contentsOfURL: url) else { return nil }
                guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary else { return nil }
                guard let imageURLs = json.valueForKeyPath("responseData.results.unescapedUrl") as? [String] else { return nil }
                return imageURLs.first
            }
            catch {
                return nil
            }
        }
    }
    
    private func setImageOperation() -> PipeOperation<UIImage,Void> {
        return PipeClosureOperation<UIImage,Void> { image, _ in
            dispatch_async(dispatch_get_main_queue()) {
                self.imageView.image = image
            }
        }
    }
}
