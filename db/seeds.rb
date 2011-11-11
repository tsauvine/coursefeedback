# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

# Users
puts('Creating users')

user = User.new(:password => 'admin', :name => 'Admin', :email => 'admin@example.com')
user.studentnumber = '12345'
user.login = 'admin'
user.admin = true
user.save

# Create teachers
for i in 1..10 do
  r = User.new
  r.studentnumber = '1' + i.to_s.rjust(4, '0')
  r.login = r.studentnumber
  r.password = "teacher#{i}"
  #r.password_confirmation = "teacher#{i}"
  r.name = "Teacher #{i}"
  r.email = "teacher#{i}@example.com"
  r.save
end

# Create students
for i in 1..10 do
  r = User.new
  r.studentnumber = i.to_s.rjust(5, '0')
  r.login = r.studentnumber
  r.password = "student#{i}"
  #r.password_confirmation = "student#{i}"
  r.name = "Student #{i}"
  r.email = "student#{i}@example.com"
  r.save
end


# Create courses
puts('Creating courses')
course = Course.create(:code => 'X-0.101', :name => 'Basics')
CourseInstance.create(:name => 'Fall 2010', :path => 'f2010', :active => true, :course => course)
CourseInstance.create(:name => 'Spring 2011', :path => 's2011', :active => false, :course => course)
