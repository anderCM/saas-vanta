data_file = Rails.root.join("db/seeds/ubigeo_data.json")

unless File.exist?(data_file)
  return
end

if Ubigeo.exists?
  return
end

data = JSON.parse(File.read(data_file))

ActiveRecord::Base.transaction do
  departments_map = {}

  data["departments"].each do |dept|
    ubigeo = Ubigeo.create!(
      code: dept["code"],
      name: dept["name"],
      level: "department"
    )
    departments_map[dept["code"][0..1]] = ubigeo
  end
  provinces_map = {}

  data["provinces"].each do |prov|
    dept_prefix = prov["code"][0..1]
    parent = departments_map[dept_prefix]

    ubigeo = Ubigeo.create!(
      code: prov["code"],
      name: prov["name"],
      level: "province",
      parent: parent
    )
    provinces_map[prov["code"][0..3]] = ubigeo
  end

  data["districts"].each do |dist|
    prov_prefix = dist["code"][0..3]
    parent = provinces_map[prov_prefix]

    Ubigeo.create!(
      code: dist["code"],
      name: dist["name"],
      level: "district",
      parent: parent
    )
  end
end
