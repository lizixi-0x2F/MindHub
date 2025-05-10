import Foundation
import HealthKit
import Combine

class HealthKitManager: ObservableObject {
    // 健康数据存储
    private let healthStore = HKHealthStore()
    
    // 发布的健康数据
    @Published var heartRateData: [HKQuantitySample] = []
    @Published var hrvData: [HKQuantitySample] = []
    @Published var sleepData: [HKCategorySample] = []
    @Published var stepCountData: [HKQuantitySample] = []
    @Published var activeEnergyData: [HKQuantitySample] = []
    
    // 日常健康统计
    @Published var dailyHeartRateAverage: Double = 0
    @Published var dailyHRVAverage: Double = 0
    @Published var dailyStepCount: Int = 0
    @Published var dailyActiveEnergy: Double = 0
    @Published var lastNightSleepHours: Double = 0
    
    // 授权状态
    @Published var authorizationStatus: HKAuthorizationStatus = .notDetermined
    
    // 观察者查询
    private var queries: [HKQuery] = []
    
    // 初始化
    init() {
        checkHealthKitAvailability()
    }
    
    // 检查 HealthKit 是否可用
    private func checkHealthKitAvailability() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit 在此设备上不可用")
            return
        }
    }
    
    // 请求 HealthKit 授权
    func requestAuthorization() {
        // 定义需要读取的数据类型
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        // 请求授权
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.authorizationStatus = .sharingAuthorized
                    self?.startObservingHealthData()
                    self?.fetchLatestHealthData()
                } else {
                    if let error = error {
                        print("HealthKit 授权失败: \(error.localizedDescription)")
                    }
                    self?.authorizationStatus = .sharingDenied
                }
            }
        }
    }
    
    // 开始观察健康数据
    private func startObservingHealthData() {
        // 观察心率
        startObservingQuantityType(identifier: .heartRate)
        
        // 观察心率变异性
        startObservingQuantityType(identifier: .heartRateVariabilitySDNN)
        
        // 观察步数
        startObservingQuantityType(identifier: .stepCount)
        
        // 观察活动能量
        startObservingQuantityType(identifier: .activeEnergyBurned)
        
        // 观察睡眠
        startObservingSleepData()
    }
    
    // 观察量化类型数据
    private func startObservingQuantityType(identifier: HKQuantityTypeIdentifier) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else { return }
        
        let query = HKObserverQuery(sampleType: quantityType, predicate: nil) { [weak self] _, _, error in
            if let error = error {
                print("观察 \(identifier.rawValue) 失败: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self?.fetchLatestHealthData()
            }
        }
        
        healthStore.execute(query)
        queries.append(query)
        
        // 启用后台传递
        healthStore.enableBackgroundDelivery(for: quantityType, frequency: .immediate) { success, error in
            if let error = error {
                print("启用 \(identifier.rawValue) 的后台传递失败: \(error.localizedDescription)")
            }
        }
    }
    
    // 观察睡眠数据
    private func startObservingSleepData() {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        
        let query = HKObserverQuery(sampleType: sleepType, predicate: nil) { [weak self] _, _, error in
            if let error = error {
                print("观察睡眠数据失败: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self?.fetchLatestSleepData()
            }
        }
        
        healthStore.execute(query)
        queries.append(query)
        
        // 启用后台传递
        healthStore.enableBackgroundDelivery(for: sleepType, frequency: .immediate) { success, error in
            if let error = error {
                print("启用睡眠数据的后台传递失败: \(error.localizedDescription)")
            }
        }
    }
    
    // 获取最新健康数据
    func fetchLatestHealthData() {
        fetchLatestHeartRateData()
        fetchLatestHRVData()
        fetchLatestStepData()
        fetchLatestActiveEnergyData()
        fetchLatestSleepData()
    }
    
    // 获取最新心率数据
    private func fetchLatestHeartRateData() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] _, samples, error in
            guard let self = self, let samples = samples as? [HKQuantitySample], error == nil else {
                if let error = error {
                    print("获取心率数据失败: \(error.localizedDescription)")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.heartRateData = samples
                self.calculateDailyHeartRateAverage()
            }
        }
        
        healthStore.execute(query)
    }
    
    // 获取最新心率变异性数据
    private func fetchLatestHRVData() {
        guard let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: hrvType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] _, samples, error in
            guard let self = self, let samples = samples as? [HKQuantitySample], error == nil else {
                if let error = error {
                    print("获取心率变异性数据失败: \(error.localizedDescription)")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.hrvData = samples
                self.calculateDailyHRVAverage()
            }
        }
        
        healthStore.execute(query)
    }
    
    // 获取最新步数数据
    private func fetchLatestStepData() {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: stepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] _, samples, error in
            guard let self = self, let samples = samples as? [HKQuantitySample], error == nil else {
                if let error = error {
                    print("获取步数数据失败: \(error.localizedDescription)")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.stepCountData = samples
                self.calculateDailyStepCount()
            }
        }
        
        healthStore.execute(query)
    }
    
    // 获取最新活动能量数据
    private func fetchLatestActiveEnergyData() {
        guard let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: energyType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] _, samples, error in
            guard let self = self, let samples = samples as? [HKQuantitySample], error == nil else {
                if let error = error {
                    print("获取活动能量数据失败: \(error.localizedDescription)")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.activeEnergyData = samples
                self.calculateDailyActiveEnergy()
            }
        }
        
        healthStore.execute(query)
    }
    
    // 获取最新睡眠数据
    private func fetchLatestSleepData() {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let startOfYesterday = calendar.startOfDay(for: yesterday)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfYesterday, end: now, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] _, samples, error in
            guard let self = self, let samples = samples as? [HKCategorySample], error == nil else {
                if let error = error {
                    print("获取睡眠数据失败: \(error.localizedDescription)")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.sleepData = samples
                self.calculateLastNightSleepHours()
            }
        }
        
        healthStore.execute(query)
    }
    
    // 计算每日心率平均值
    private func calculateDailyHeartRateAverage() {
        guard !heartRateData.isEmpty else {
            dailyHeartRateAverage = 0
            return
        }
        
        let unit = HKUnit.count().unitDivided(by: .minute())
        let totalHeartRate = heartRateData.reduce(0.0) { $0 + $1.quantity.doubleValue(for: unit) }
        dailyHeartRateAverage = totalHeartRate / Double(heartRateData.count)
    }
    
    // 计算每日心率变异性平均值
    private func calculateDailyHRVAverage() {
        guard !hrvData.isEmpty else {
            dailyHRVAverage = 0
            return
        }
        
        let unit = HKUnit.secondUnit(with: .milli)
        let totalHRV = hrvData.reduce(0.0) { $0 + $1.quantity.doubleValue(for: unit) }
        dailyHRVAverage = totalHRV / Double(hrvData.count)
    }
    
    // 计算每日步数
    private func calculateDailyStepCount() {
        let unit = HKUnit.count()
        dailyStepCount = Int(stepCountData.reduce(0.0) { $0 + $1.quantity.doubleValue(for: unit) })
    }
    
    // 计算每日活动能量
    private func calculateDailyActiveEnergy() {
        let unit = HKUnit.kilocalorie()
        dailyActiveEnergy = activeEnergyData.reduce(0.0) { $0 + $1.quantity.doubleValue(for: unit) }
    }
    
    // 计算昨晚睡眠时间
    private func calculateLastNightSleepHours() {
        // 只计算核心睡眠时间
        let inBedSamples = sleepData.filter { $0.value == HKCategoryValueSleepAnalysis.inBed.rawValue }
        
        var totalSleepTime = 0.0
        
        for sample in inBedSamples {
            let sleepTime = sample.endDate.timeIntervalSince(sample.startDate) / 3600 // 转换为小时
            totalSleepTime += sleepTime
        }
        
        lastNightSleepHours = totalSleepTime
    }
    
    // 同步健康数据
    func syncHealthData() -> Operation {
        let operation = BlockOperation {
            self.fetchLatestHealthData()
        }
        
        return operation
    }
    
    // 停止所有查询
    func stopAllQueries() {
        for query in queries {
            healthStore.stop(query)
        }
        queries.removeAll()
    }
    
    // 析构函数
    deinit {
        stopAllQueries()
    }
} 