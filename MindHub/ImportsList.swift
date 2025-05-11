// 导入清单
// 这个文件用于确保所有自定义组件都可以被导入到其他文件中

import Foundation
import SwiftUI
import CoreML
import Charts
import Vision
import NaturalLanguage
import CoreLocation
import CoreData

// 直接导出主要组件，使其在整个应用中可见
// 修正：View是protocol而不是struct
@_exported import SwiftUI

// 允许Foundation类型可被访问
@_exported import Foundation

// 不再直接导出EmotionAnalysisService，避免循环引用
// 改为通过一个函数获取
@MainActor public func getEmotionAnalysisService() -> EmotionAnalysisService {
    return EmotionAnalysisService.shared
}

// 导出常用Foundation类型
@_exported import struct Foundation.Date
@_exported import struct Foundation.URL
@_exported import struct Foundation.UUID
@_exported import struct Foundation.Data
@_exported import class Foundation.JSONEncoder
@_exported import class Foundation.JSONDecoder
