class BulkImport < ApplicationRecord
  # Associations
  belongs_to :enterprise
  belongs_to :user
  has_one_attached :file

  # Validations
  validates :resource_type, presence: true, inclusion: { in: %w[Product Provider Customer] }
  validates :status, presence: true
  validate :validate_file_type, if: -> { file.attached? }

  # Enums
  enum :status, {
    pending: "pending",
    processing: "processing",
    completed: "completed",
    failed: "failed"
  }

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :for_resource, ->(type) { where(resource_type: type) }

  # Constants
  ALLOWED_CONTENT_TYPES = %w[
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
    application/vnd.ms-excel
    text/csv
  ].freeze

  MAX_FILE_SIZE = 10.megabytes

  # Instance methods
  def mark_as_processing!
    update!(status: :processing, started_at: Time.current)
  end

  def mark_as_completed!(successful:, failed:, errors: [])
    update!(
      status: :completed,
      completed_at: Time.current,
      successful_rows: successful,
      failed_rows: failed,
      results: { errors: errors }
    )
  end

  def mark_as_failed!(error_message)
    update!(
      status: :failed,
      completed_at: Time.current,
      results: { error: error_message }
    )
  end

  def duration
    return nil unless started_at && completed_at
    completed_at - started_at
  end

  def formatted_duration
    return "-" unless duration
    "#{duration.round(2)} segundos"
  end

  def error_details
    results["errors"] || []
  end

  def general_error
    results["error"]
  end

  private

  def validate_file_type
    unless file.content_type.in?(ALLOWED_CONTENT_TYPES)
      errors.add(:file, "debe ser un archivo Excel (.xlsx, .xls) o CSV")
    end

    if file.blob.byte_size > MAX_FILE_SIZE
      errors.add(:file, "no debe superar los 10MB")
    end
  end
end
