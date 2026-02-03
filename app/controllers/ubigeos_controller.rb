class UbigeosController < ApplicationController
  def index
    query = params[:q].to_s.strip

    @ubigeos = if query.present?
      Ubigeo.where("LOWER(name) LIKE :query OR code LIKE :query", query: "%#{query.downcase}%")
            .order(Arel.sql("CASE level WHEN 'district' THEN 1 WHEN 'province' THEN 2 ELSE 3 END"))
            .limit(20)
    else
      Ubigeo.districts.order(:name).limit(20)
    end
  end
end
