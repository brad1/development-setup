require 'services/worker_items'

worker = Services::WorkerItems.new
worker.run(30)
