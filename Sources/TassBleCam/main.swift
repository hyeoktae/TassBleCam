import SwiftyGPIO //Remove this import if you are compiling manually with switfc
#if os(Linux)
import Glibc
#else
import Darwin.C
#endif
import Foundation
import SG90Servo


let uarts = SwiftyGPIO.UARTs(for: .RaspberryPiPlusZero)
let pwms = SwiftyGPIO.hardwarePWMs(for: .RaspberryPiPlusZero)
//var uart = uarts[0]

if let uart = uarts?[0], let pwmFirst = (pwms?[0]), let pwm = pwmFirst[.P18] {
  print("run")
  
  let s1 = SG90Servo(pwm)
  s1.enable()
  uart.configureInterface(speed: .S9600, bitsPerChar: .Eight, stopBits: .One, parity: .None)
  
  print("Ready...")
  
  var buffer: String = "" {
    willSet (new) {
      if new.contains("\n") {
        print("new: ", new)
        if new.contains("read") {
//          uart.writeString("read complete!!!")
          let cam = CameraManager()
          switch cam.photoData() {
          case .success(let data):
            print("success take a photo")
            let temp = [UInt8](Array(data)).map{CChar(bitPattern: $0)}
            uart.writeData(temp)
          case .failure(let err):
            print("Error: \(err.localizedDescription)")
          }
        }
      }
    }
  }
  
  if #available(macOS 10.12, *) {
    let tRead = Thread() {
      while true {
        let s = uart.readString()
        if s != "" {
          buffer += s
        }
        
        if s == "\n" {
          buffer = ""
        }
        
        if let value = Int(s) {
          switch value {
            case 0...60:
              s1.move(to: .left)
            case 61...120:
              s1.move(to: .middle)
            case 121...180:
              s1.move(to: .right)
            default:
              s1.move(to: .left)
          }
          
        }
      }
    }
    
    
    tRead.start()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
      uart.writeString("run\n")
    }
    
    var exit = false
    
    while (!exit) {
      //  let readText = uart.readString()
      //
      //  if readText.contains("exit") {
      //    exit = true
      //    break
      //  }
      
      print("Send: ", terminator: " ")
      var input = readLine(strippingNewline: false)
      exit = (input == "exit\n")
      
      if !exit {
        uart.writeString(input ?? "inputErr")
      }
      
    }
  }
  
}
