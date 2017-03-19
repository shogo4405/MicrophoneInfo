import UIKit
import AVFoundation

final class ViewController: UIViewController {

    @IBOutlet var textView:UITextView?

    let lockQueue:DispatchQueue = DispatchQueue(label: "com.github.shogo4405.MicrophoneInfo.lock")

    var session:AVCaptureSession?
    var sampleBuffer:CMSampleBuffer? = nil {
        didSet {
            guard oldValue == nil else {
                return
            }
            appendText("\(sampleBuffer)")
        }
    }
    var audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
    var audioOutput:AVCaptureAudioDataOutput?

    var format:CMAudioFormatDescription? {
        didSet {
            appendText("\(format)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        session = AVCaptureSession()

        appendText("Launched")
        appendText("\(AVAudioSession.sharedInstance().currentRoute)")

        do {
            let input = try AVCaptureDeviceInput(device: audioDevice)
            guard session!.canAddInput(input) else {
                appendText("can't add an audio device")
                return
            }
            session?.addInput(input)
            let output = AVCaptureAudioDataOutput()
            output.setSampleBufferDelegate(self, queue: lockQueue)
            session?.addOutput(output)
        } catch {
            appendText("can't add an audio device")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ViewController.didAVAudioSessionRouteChangeNotification(_:)),
            name: NSNotification.Name.AVAudioSessionRouteChange, object: nil
        )
        session?.startRunning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        session?.stopRunning()
        super.viewWillDisappear(animated)
    }

    func didAVAudioSessionRouteChangeNotification(_ notification: Notification) {
        appendText("-----didAVAudioSessionRouteChangeNotification-----")
        appendText("\(AVAudioSession.sharedInstance().currentRoute)")
        session?.beginConfiguration()
        for i in (session?.inputs)! {
            session?.removeInput((i as! AVCaptureInput))
        }
        for o in (session?.outputs)! {
            session?.removeOutput((o as! AVCaptureOutput))
        }
        do {
            let input = try AVCaptureDeviceInput(device: audioDevice)
            session?.addInput(input)
            let output = AVCaptureAudioDataOutput()
            output.setSampleBufferDelegate(self, queue: lockQueue)
            session?.addOutput(output)
        } catch {
            appendText("can't add an audio device")
        }
        session?.commitConfiguration()
        
    }

    func appendText(_ text:String) {
        DispatchQueue.main.async {
            let txt:String = self.textView?.text ?? ""
            self.textView?.text = txt + "\n" + text
        }
    }
}

extension ViewController: AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if (!CMFormatDescriptionEqual(format, CMSampleBufferGetFormatDescription(sampleBuffer))) {
            format = CMSampleBufferGetFormatDescription(sampleBuffer)
        }
    }
}
