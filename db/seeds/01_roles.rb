roles = [
    {
        name: 'Administrador',
        slug: 'admin',
        description: 'Acceso completo a todas las funcionalidades de la empresa'
    }
]

roles.each do |role|
    next if Role.exists?(slug: role[:slug])

    Role.create!(role)
end
