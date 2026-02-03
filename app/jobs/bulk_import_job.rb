class BulkImportJob < ApplicationJob
  queue_as :default

  # Retry with exponential backoff
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  # Discard if the import was deleted
  discard_on ActiveRecord::RecordNotFound

  def perform(bulk_import_id)
    bulk_import = BulkImport.find(bulk_import_id)

    # Skip if already processed
    return if bulk_import.completed? || bulk_import.failed?

    orchestrator = orchestrator_for(bulk_import)

    unless orchestrator
      bulk_import.mark_as_failed!("Tipo de recurso no soportado: #{bulk_import.resource_type}")
      broadcast_notification(bulk_import, :error, "Importación fallida: tipo no soportado")
      return
    end

    orchestrator.call

    # Log result and broadcast notification
    if orchestrator.valid?
      Rails.logger.info("[BulkImportJob] Import #{bulk_import_id} completed successfully")
      broadcast_notification(
        bulk_import,
        :success,
        "Importación completada: #{bulk_import.successful_rows} registros procesados"
      )
    else
      Rails.logger.warn("[BulkImportJob] Import #{bulk_import_id} completed with errors: #{orchestrator.errors}")
      broadcast_notification(
        bulk_import,
        :warning,
        "Importación completada con #{bulk_import.failed_rows} errores"
      )
    end
  end

  private

  def orchestrator_for(bulk_import)
    case bulk_import.resource_type
    when "Product"
      Products::ImportOrchestrator.new(bulk_import: bulk_import)
    when "Provider"
      Providers::ImportOrchestrator.new(bulk_import: bulk_import)
    when "Customer"
      Customers::ImportOrchestrator.new(bulk_import: bulk_import)
    else
      nil
    end
  end

  def broadcast_notification(bulk_import, type, message)
    ActionCable.server.broadcast(
      "notifications_user_#{bulk_import.user_id}",
      {
        type: type.to_s,
        message: message,
        duration: 6000
      }
    )
  end
end
