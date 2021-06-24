import Foundation

class CameraManager {
  enum CameraError: Error {
    case noDirectory, noPhoto, processErr
  }
  
  private let fileManager = FileManager.default

  // file:///home/pi/Documents
  private lazy var documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
  
  @discardableResult
  private func shell(command: String) -> Int32? {
    let task = Process()
    if #available(macOS 10.13, *) {
      task.executableURL = URL(string: "/usr/bin/env")
    } else {
      task.launchPath = "/usr/bin/env"
    }
    task.arguments = ["bash", "-c", command]
    if #available(macOS 10.13, *) {
      do {
        try task.run()
      } catch let err {
        print("err: ", err.localizedDescription)
        return nil
      }
    } else {
      task.launch()
    }
    task.waitUntilExit()
    return task.terminationStatus
  }
  
  func photoData() -> Result<Data, CameraError> {
    if !fileManager.fileExists(atPath: documentURL.path) {
      do {
        try fileManager.createDirectory(atPath: documentURL.path, withIntermediateDirectories: true, attributes: nil)
      } catch {
        print("couldn't create document directory")
        return .failure(.noDirectory)
      }
    }

    let path = documentURL.appendingPathComponent("tassImg.jpg")

    let state = shell(command: "raspistill -o \(path.path)")

    if state == 0 {
      do {
        let photo = try Data(contentsOf: path)
        print("success get a photo: \(photo.count)")
        return .success(photo)
      } catch (let err) {
        print("err occured \(err.localizedDescription)")
        return .failure(.noPhoto)
      }
    } else {
      return .failure(.processErr)
    }
    
  }
  
}
