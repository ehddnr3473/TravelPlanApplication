//
//  TravelPlanRepository.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/24.
//

import Foundation
import FirebaseFirestore
import CoreLocation

enum TravelPlanRepositoryError: String, Error {
    case uploadError = "계획 업로드를 실패했습니다."
    case readError = "계획 다운로드를 실패했습니다."
    case deleteError = "계획 삭제를 실패했습니다."
    case swapError = "계획 순서 변경을 실패했습니다."
}

protocol AbstractTravelPlanRepository {
    func upload(at index: Int, travelPlanDTO: TravelPlanDTO) async throws
    func read() async throws -> [TravelPlan]
    func delete(at index: Int) async throws
}

/// Plan 관련 Firebase Firestore 연동
struct TravelPlanRepository: AbstractTravelPlanRepository {
    private var database = Firestore.firestore()
    
    // create & update
    func upload(at index: Int, travelPlanDTO: TravelPlanDTO) async throws {
        do {
            try await database.collection(DatabasePath.plans).document("\(index)").setData([
                Key.title: travelPlanDTO.title,
                Key.description: travelPlanDTO.description
            ])
            
            for scheduleIndex in travelPlanDTO.schedules.indices {
                let coordinate = GeoPoint(
                    latitude: travelPlanDTO.schedules[scheduleIndex].coordinate.latitude,
                    longitude: travelPlanDTO.schedules[scheduleIndex].coordinate.longitude
                )
                try await database.collection(DatabasePath.plans)
                    .document("\(index)").collection(DocumentConstants.schedulesCollection).document("\(scheduleIndex)")
                    .setData([
                        // Key-Value Pair
                        Key.title:
                            travelPlanDTO.schedules[scheduleIndex].title,
                        Key.description:
                            travelPlanDTO.schedules[scheduleIndex].description,
                        Key.fromDate:
                            DateConverter.dateToString(travelPlanDTO.schedules[scheduleIndex].fromDate),
                        Key.toDate:
                            DateConverter.dateToString(travelPlanDTO.schedules[scheduleIndex].toDate),
                        Key.coordinate:
                            coordinate
                    ])
            }
        } catch {
            throw TravelPlanRepositoryError.uploadError
        }
    }
    
    // read
    // Firebase에서 다운로드한 데이터로 TravelPlanDTO를 생성해서 반환
    func read() async throws -> [TravelPlan] {
        var travelPlans = [TravelPlanDTO]()
        
        do {
            let travelPlansSnapshot = try await database.collection(DatabasePath.plans).getDocuments()
            var documentIndex = NumberConstants.zero
            
            for document in travelPlansSnapshot.documents {
                let data = document.data()
                let scheduleSnapshot = try await database.collection(DatabasePath.plans)
                    .document("\(documentIndex)").collection(DocumentConstants.schedulesCollection).getDocuments()
                var schedules = [ScheduleDTO]()
                
                for documentation in scheduleSnapshot.documents {
                    schedules.append(self.createSchedule(documentation.data()))
                }
                travelPlans.append(self.createTravelPlan(data, schedules))
                documentIndex += NumberConstants.one
            }
            return travelPlans.map { $0.toDomain() }
        } catch {
            throw TravelPlanRepositoryError.readError
        }
    }
    
    // delete
    func delete(at index: Int) async throws {
        do {
            try await database.collection(DatabasePath.plans).document("\(index)").delete()
        } catch {
            throw TravelPlanRepositoryError.deleteError
        }
    }
    
    // Firebase에서 다운로드한 데이터로 TravelPlan을 생성해서 반환
    private func createTravelPlan(_ data: Dictionary<String, Any>, _ schedules: [ScheduleDTO]) -> TravelPlanDTO {
        TravelPlanDTO(
            title: data[Key.title] as! String,
            description: data[Key.description] as! String,
            schedules: schedules
        )
    }
    
    // Firebase에서 다운로드한 데이터로 Schedule을 생성해서 반환
    private func createSchedule(_ data: Dictionary<String, Any>) -> ScheduleDTO {
        guard let coordinate = data[Key.coordinate] as? GeoPoint else { fatalError() }
        if let fromDate = data[Key.fromDate] as? String,
           let toDate = data[Key.toDate] as? String {
            return ScheduleDTO(
                title: data[Key.title] as! String,
                description: data[Key.description] as! String,
                coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
                fromDate: DateConverter.stringToDate(fromDate),
                toDate: DateConverter.stringToDate(toDate)
            )
        } else {
            return ScheduleDTO(
                title: data[Key.title] as! String,
                description: data[Key.description] as! String,
                coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
                fromDate: nil,
                toDate: nil
            )
        }
    }
}

private enum NumberConstants {
    static let zero = 0
    static let one = 1
}
private enum DocumentConstants {
    static let schedulesCollection = "schedules"
}

private enum Key {
    static let title = "title"
    static let description = "description"
    static let fromDate = "fromDate"
    static let toDate = "toDate"
    static let coordinate = "coordinate"
}
