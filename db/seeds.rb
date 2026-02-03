# Skip seeds in test environment - tests should manage their own data
return if Rails.env.test?

# Load all seed files from db/seeds/ directory
seeds_path = Rails.root.join('db', 'seeds', '*.rb')
seed_files = Dir[seeds_path].sort

if seed_files.any?
  seed_files.each do |seed_file|
    puts "\n📦 Loading: #{File.basename(seed_file)}"
    load seed_file
  end

  puts "\n" + "=" * 80
  puts "✅ Seed process completed successfully!"
  puts "=" * 80
else
  puts "\nℹ️  No seed files found in db/seeds/"
  puts "=" * 80
end
