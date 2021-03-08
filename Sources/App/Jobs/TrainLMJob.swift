import Foundation
import Fluent
import Queues
import Vapor
import RQTFoundation

let pathToLM = "trained/"

struct TrainLMJob: ScheduledJob {
  func run(context: QueueContext) -> EventLoopFuture<Void> {
    RequirementVersionModel.query(on: context.application.db).all().mapEach { $0.convertToDTO() }.flatMap { (reqs: [RequirementVersionImpl]) -> EventLoopFuture<Void> in
        do {
            return try reqs.computeEmbedding(queueContext: context, pathToExistingLM: pathToLM, pathToTrainedLM: pathToLM)
        }
        catch {
            print("Error computing language models")
            return context.eventLoop.future()
        }
    }
  }
}
