//               ~MMMMMMMM,.           .,MMMMMMM ..
//              DNMMDMMMMMMMM,.     ..MMMMNMMMNMMM,
//              MMM..   ...NMMM    MMNMM       ,MMM
//             NMM,        , MMND MMMM          .MM
//             MMN             MMMMM             MMM
//            .MM           , MMMMMM ,           MMM
//            .MM            MMM. MMMM           MMM
//            .MM~         .MMM.   NMMN.         MMM
//             MMM        MMMM: .M ..MMM        .MM,
//             MMM.NNMMMMMMMMMMMMMMMMMMMMMMMMMM:MMM,
//         ,,MMMMMMMMMMMMMMM           NMMDNMMMMMMMMN~,
//        MMMMMMMMM,,  OMMM             NMM  . ,MMNMMMMN.
//     ,MMMND  .,MM=  NMM~    MMMMMM+.   MMM.  NMM. .:MMMMM.
//    MMMM       NMM,MMMD   MMM$ZZZMMM:  .NMN.MMM        NMMM
//  MMNM          MMMMMM   MMZO~:ZZZZMM~   MMNMMN         .MMM
//  MMM           MMMMM   MMNZ~~:ZZZZZNM,   MMMM            MMN.
//  MM.           .MMM.   MMZZOZZZZZZZMM.   MMMM            MMM.
//  MMN           MMMMN   MMMZZZZZZZZZNM.   MMMM            MMM.
//  NMMM         .MMMNMN  .MM$ZZZZZZZMMN ..NMMMMM          MMM
//   MMMMM       MMM.MMM~  .MNMZZZZMMMD   MMM MMM .    . NMMN,
//     NMMMM:  ..MM8  MMM,  . MNMMMM:   .MMM:  NMM  ..MMMMM
//     ...MMMMMMNMM    MMM      ..      MMM.    MNDMMMMM.
//        .: MMMMMMMMMMDMMND           MMMMMMMMNMMMMM
//             NMM8MNNMMMMMMMMMMMMMMMMMMMMMMMMMMNMM
//            ,MMM        NMMMDMMMMM NMM.,.     ,MM
//             MMO        ..MMM    NMMM          MMD
//            .MM.         ,,MMM+.MMMM=         ,MMM
//            .MM.            MMMMMM~.           MMM
//             MM=             MMMMM..          .MMN
//             MMM           MMM8 MMMN.          MM,
//             +MMO        MMMN,   MMMMM,       MMM
//             ,MMMMMMM8MMMMM,      . MMNMMMMMMMMM.
//               .NMMMMNMM              DMDMMMMMM

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
