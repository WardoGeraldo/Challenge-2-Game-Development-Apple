//
//  Either.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation

enum Either<L, R> {
    case left(L)
    case right(R)
}
