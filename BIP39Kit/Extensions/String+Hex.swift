//
//  String+Hex.swift
//  BIP39Kit
//
//  Created by Elliott Minns on 23/03/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation
import CommonCrypto

extension String {
  
  /// Create `Data` from hexadecimal string representation
  ///
  /// This takes a hexadecimal representation and creates a `Data` object. Note, if the string has any spaces or non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
  ///
  /// - returns: Data represented by this hexadecimal string.
  
  func hexadecimal() -> Data? {
    var data = Data(capacity: self.count / 2)
    
    let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
    regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, flags, stop in
      let byteString = (self as NSString).substring(with: match!.range)
      var num = UInt8(byteString, radix: 16)!
      data.append(&num, count: 1)
    }
    
    guard data.count > 0 else { return nil }
    
    return data
  }
  
  func pbkdf2SHA1(salt: Data, keyByteCount: Int, rounds: Int) -> Data? {
    return pbkdf2(hash:CCPBKDFAlgorithm(kCCPRFHmacAlgSHA1),  salt: salt, keyByteCount: keyByteCount, rounds:rounds)
  }
  
  func pbkdf2SHA256(salt: Data, keyByteCount: Int, rounds: Int) -> Data? {
    return pbkdf2(hash:CCPBKDFAlgorithm(kCCPRFHmacAlgSHA256), salt: salt, keyByteCount: keyByteCount, rounds:rounds)
  }
  
  func pbkdf2SHA512(salt: Data, keyByteCount: Int, rounds: Int) -> Data? {
    return pbkdf2(hash:CCPBKDFAlgorithm(kCCPRFHmacAlgSHA512), salt: salt, keyByteCount: keyByteCount, rounds: rounds)
  }

  func pbkdf2(hash: CCPBKDFAlgorithm, salt: Data, keyByteCount: Int, rounds: Int) -> Data? {
    let passwordData = self.data(using:String.Encoding.utf8)!
    var derivedKeyData = Data(repeating:0, count:keyByteCount)
    
    let derivationStatus = derivedKeyData.withUnsafeMutableBytes {derivedKeyBytes in
      salt.withUnsafeBytes { saltBytes in
        
        CCKeyDerivationPBKDF(
          CCPBKDFAlgorithm(kCCPBKDF2),
          self, passwordData.count,
          saltBytes, salt.count,
          hash,
          UInt32(rounds),
          derivedKeyBytes, derivedKeyData.count)
      }
    }
    if (derivationStatus != 0) {
      print("Error: \(derivationStatus)")
      return nil;
    }
    
    return derivedKeyData
  }
}
