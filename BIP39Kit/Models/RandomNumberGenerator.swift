//
//  RandomNumberGenerator.swift
//  BIP39Kit
//
//  Created by Elliott Minns on 23/03/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

protocol RandomNumberGenerator {
  static func generate(length: Int) -> Data?
}

struct SecureRandomNumberGenerator: RandomNumberGenerator {
  static func generate(length: Int) -> Data? {
    var data = Data(count: length)
    let result = data.withUnsafeMutableBytes {
      (mutableBytes: UnsafeMutablePointer<UInt8>) -> Int32 in
      SecRandomCopyBytes(kSecRandomDefault, data.count, mutableBytes)
    }
    if (result == errSecSuccess) {
      return data
    } else {
      return nil
    }
  }
}
