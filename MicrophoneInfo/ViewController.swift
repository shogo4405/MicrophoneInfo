import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet var textView:UITextView?
    var session:AVCaptureSession?
    var audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)

    override func viewDidLoad() {
        super.viewDidLoad()
        session = AVCaptureSession()
        
        appendText("Launched")

        do {
            let input = try AVCaptureDeviceInput(device: audioDevice)
            guard session!.canAddInput(input) else {
                appendText("can't add an audio device")
                return
            }
        } catch {
            appendText("can't add an audio device")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session?.startRunning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session?.stopRunning()
    }

    func appendText(_ text:String) {
        let txt:String = textView?.text ?? ""
        textView?.text = txt + "\n" + text
    }
}
