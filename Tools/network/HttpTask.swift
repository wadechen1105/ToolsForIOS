
import Foundation

fileprivate let fileRootFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("download", isDirectory: true)

protocol DownloadComplereCallback {
    func onFinish(_ fileURL: URL)
}

protocol DataTaskProtocol {
    func resume()
}

protocol URLSessionDownloadProtocol {
    func download(with request: URLRequest) -> DataTaskProtocol
}

extension URLSessionDownloadTask: DataTaskProtocol {
    
}

class DownloadURLSession: NSObject, URLSessionDownloadProtocol, URLSessionDownloadDelegate {
    private var fileName: String?
    private var session: URLSession!
    private var _callback: DownloadComplereCallback!
    
    func download(with request: URLRequest) -> DataTaskProtocol {
        fileName = request.url?.lastPathComponent
        Log.i("start download : \(String(describing: fileName))!!")
        return session.downloadTask(with: request) as DataTaskProtocol
    }
    
    init(isBackgroundTask: Bool, _ callback: DownloadComplereCallback) {
        super.init()
        _callback = callback
        if isBackgroundTask {
            let config = URLSessionConfiguration.background(withIdentifier: String(describing: NSObject.hash))
            session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        } else {
            session = URLSession.shared
        }
    }
    
    //callback
    
    /* Sent when a download task that has completed a download.  The delegate should
     * copy or move the file at the given location to a new location as it will be
     * removed when the delegate message returns. URLSession:task:didCompleteWithError: will
     * still be called.
     */
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        Log.d("downloadTask didFinishDownloadingTo :\(location)")
        do {
            let data = try Data(contentsOf: location)
            let url = createFile(data, fileName!)
            _callback.onFinish(url)
        } catch {
            Log.w(error.localizedDescription)
        }
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        Log.d("downloadTask didCompleteWithError :\(String(describing: error))")
    }
    
    
    /* Sent periodically to notify the delegate of download progress. */
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let current: Float = Float(totalBytesWritten)
        let total: Float = Float(totalBytesExpectedToWrite)
        let didwrite: Float = Float(didWriteData)
        Log.i("didWriteData didWriteData, current:\(current), total: \(total), didwrite: \(didwrite)")
        
    }
    
    
    /* Sent when a download has been resumed. If a download failed with an
     * error, the -userInfo dictionary of the error will contain an
     * NSURLSessionDownloadTaskResumeData key, whose value is the resume
     * data.
     */
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didResumeAtOffset fileOffset: Int64,
                    expectedTotalBytes: Int64) {
        
        Log.i("didResumeAtOffset")
        
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        Log.i("urlSessionDidFinishEvents")
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        Log.i("didBecomeInvalidWithError :\(String(describing: error))")
    }
}

/// create folder to save  file
fileprivate func createFile(_ data: Data, _ fileName: String) -> URL {
    
    let fileURL = fileRootFolder.appendingPathComponent(fileName)
    do {
        try FileManager.default.createDirectory(at: fileRootFolder, withIntermediateDirectories: true, attributes: nil)
        Log.d("fileURL :\(String(describing: fileURL))")
        try data.write(to: fileURL, options: .atomic)
    } catch {
        Log.w("create tmp dir or write file fail :\(String(describing: error))")
    }
    return fileURL
}

// clean tmp folder and file
fileprivate func cleanFile(_ url: URL) {
    let dirUrl = url.deletingLastPathComponent()
    
    do {
        try FileManager.default.removeItem(at: dirUrl)
        Log.d("clean fileURL success")
    } catch {
        Log.w("clean file fail :\(String(describing: error))")
    }
}


class DownloadTask: NSObject {
    private let _session: URLSessionDownloadProtocol!
    
    init(_ session: URLSessionDownloadProtocol) {
        _session = session
    }
    
    final func doDownload(_ request: URLRequest) {
        let downloadTask = _session.download(with: request)
        downloadTask.resume()
    }
    
    func getSession() -> URLSessionDownloadProtocol {
        return _session
    }
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////                                   upload                                     //////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// should not use the class, it should to inherit
class UploadTask: NSObject, URLSessionDataDelegate {
    
    /// create tmp folder to save  upload file
    func createTmpFile(_ data: Data) -> URL {
        
        let tmpDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString, isDirectory: true)
        let fileURL = tmpDirectoryURL.appendingPathComponent("data.json")
        do {
            try FileManager.default.createDirectory(at: tmpDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            Log.d("tmp fileURL :\(String(describing: fileURL))")
            try data.write(to: fileURL, options: .atomic)
            
        } catch {
            Log.w("create tmp dir or write file fail :\(String(describing: error))")
        }
        return fileURL
    }
    
    func doUpload(_ request: URLRequest, _ data: Data) {
        //        let session = getSession(delegate: self)
        //        let fileUrl = createTmpFile(data)
        //        let uploadTask: URLSessionUploadTask = session.uploadTask(with: request, fromFile: fileUrl)
        //        uploadTask.resume()
        //        cleanFile(fileUrl)
    }
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let response = dataTask.response else {
            return
        }
        let httpResponse = response as! HTTPURLResponse
        Log.d("## didReceive : \(httpResponse.statusCode)")
    }
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        Log.d("##didSendBodyData bytesSent: \(bytesSent), total:\(totalBytesSent)")
    }
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        Log.d("downloadTask didCompleteWithError :\(String(describing: error))")
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        Log.d("downloadTask forBackgroundURLSession")
    }
    
}
