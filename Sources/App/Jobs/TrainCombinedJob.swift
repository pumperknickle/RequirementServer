import Foundation
import Fluent
import Queues
import Vapor
import RQTFoundation

struct TrainCombinedJob: ScheduledJob {
  func run(context: QueueContext) -> EventLoopFuture<Void> {
    RequirementVersionModel.query(on: context.application.db).all().mapEach { $0.convertToDTO() }.flatMap { (reqs: [RequirementVersionImpl]) -> EventLoopFuture<Void> in
        TagModel.query(on: context.application.db).all().mapEach { $0.convertToDTO() }.flatMap { (tags: [RequirementTagImpl]) -> EventLoopFuture<Void> in
            do {
                print("Finished Querying for Jobs")
                if tags.isEmpty || reqs.isEmpty || tags.count < 100 || reqs.count < 100 { return context.eventLoop.future() }
                try reqs.computeEmbedding(queueContext: context, pathToExistingLM: pathToLM, pathToTrainedLM: pathToLM)
                return try reqs.computeAllModels(queueContext: context, tags: tags, pathsToLMs: [pathToLM], testSplit: 0.1, devSplit: 0.1)
            }
            catch {
                print("Error computing inference models")
                return context.eventLoop.future()
            }
        }
    }
  }
}
