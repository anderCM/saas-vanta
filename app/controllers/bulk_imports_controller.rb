class BulkImportsController < ApplicationController
  before_action :require_enterprise_selected
  before_action :set_bulk_import, only: [ :show ]

  def index
    authorize BulkImport
    @resource_type = params[:resource_type] || "Product"
    imports = current_enterprise.bulk_imports
                                .for_resource(@resource_type)
                                .recent
                                .includes(:user)
    @pagy, @bulk_imports = pagy(imports, items: 10)
  end

  def show
    authorize @bulk_import
  end

  def new
    authorize BulkImport
    @resource_type = params[:resource_type] || "Product"
  end

  def create
    authorize BulkImport

    @bulk_import = current_enterprise.bulk_imports.build(bulk_import_params)
    @bulk_import.user = Current.user

    if @bulk_import.save
      BulkImportJob.perform_later(@bulk_import.id)

      redirect_to @bulk_import, notice: "Importacion iniciada. No es necesario que te quedes esperando, puedes continuar con otras tareas. Te avisaremos cuando la importacion haya terminado."
    else
      @resource_type = @bulk_import.resource_type
      render :new, status: :unprocessable_entity
    end
  end

  def template
    authorize BulkImport, :create?
    resource_type = params[:resource_type] || "Product"

    generator = BulkImports::TemplateGenerator.new(resource_type: resource_type)
    generator.call

    unless generator.valid?
      redirect_to new_bulk_import_path(resource_type: resource_type),
                  alert: generator.errors.join(", ")
      return
    end

    filename = "plantilla_#{resource_type.underscore.pluralize}_#{Date.current}.xlsx"

    send_data generator.package.to_stream.read,
              filename: filename,
              type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  private

  def require_enterprise_selected
    return if current_enterprise.present?

    redirect_to enterprises_path, alert: "Debes seleccionar una empresa primero."
  end

  def set_bulk_import
    @bulk_import = current_enterprise.bulk_imports.find(params[:id])
  end

  def bulk_import_params
    params.require(:bulk_import).permit(:resource_type, :file).tap do |p|
      p[:original_filename] = p[:file]&.original_filename
    end
  end
end
