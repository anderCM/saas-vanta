# Ubigeo model for Peru's official geographic coding system (INEI)
#
class Ubigeo < ApplicationRecord
  # Self-referential association for hierarchy
  belongs_to :parent, class_name: "Ubigeo", optional: true
  has_many :children, class_name: "Ubigeo", foreign_key: :parent_id, dependent: :restrict_with_error

  # Associations for related models
  has_many :providers, dependent: :restrict_with_error
  has_many :customers, dependent: :restrict_with_error

  # Validations
  validates :code, presence: true, uniqueness: true, length: { is: 6 }
  validates :name, presence: true
  validates :level, presence: true, inclusion: { in: %w[department province district] }

  # Scopes
  scope :departments, -> { where(level: "department") }
  scope :provinces, -> { where(level: "province") }
  scope :districts, -> { where(level: "district") }
  scope :by_level, ->(level) { where(level: level) }

  # Get provinces for a department
  scope :provinces_of, ->(department) { where(level: "province", parent: department) }

  # Get districts for a province
  scope :districts_of, ->(province) { where(level: "district", parent: province) }

  # Class methods
  def self.find_by_code(code)
    find_by(code: code.to_s.rjust(6, "0"))
  end

  # Instance methods
  def department?
    level == "department"
  end

  def province?
    level == "province"
  end

  def district?
    level == "district"
  end

  # Returns the full location path (e.g., "Chiclayo, Chiclayo, Lambayeque")
  def full_path
    ancestors = []
    current = self

    while current
      ancestors.unshift(current.name)
      current = current.parent
    end

    ancestors.join(", ")
  end

  # Returns the department this ubigeo belongs to
  def department
    return self if department?
    return parent if province?
    parent&.parent if district?
  end

  # Returns the province this ubigeo belongs to (nil for departments)
  def province
    return nil if department?
    return self if province?
    parent if district?
  end

  # Display name with level indicator
  def display_name
    "#{name} (#{level.humanize})"
  end

  # Display for combobox autocomplete (shows full path)
  def combobox_display
    full_path
  end
end
