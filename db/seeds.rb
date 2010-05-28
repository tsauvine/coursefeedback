# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

# Create admin user
user = User.new(:login => 'admin', :password => 'admin', :password_confirmation => 'admin', :firstname => 'Admin', :lastname => 'User', :email => 'tzauvine@cs.helsinki.fi')
user.admin = true
user.save

# Create other users
User.create(:login => 'teacher1', :password => 'teacher1', :password_confirmation => 'teacher1', :firstname => 'Teacher', :lastname => '1', :email => 'teacher1@cs.helsinki.fi')
User.create(:login => 'student1', :password => 'student1', :password_confirmation => 'student1', :firstname => 'Student', :lastname => '1', :email => 'student1@cs.helsinki.fi')

# Create courses
course = Course.create(:code => '58123', :name => 'Perusteet')
CourseInstance.create(:name => 'Syksy 2009', :path => 's2009', :active => false, :course => course)
CourseInstance.create(:name => 'Kevät 2010', :path => 'k2010', :active => true, :course => course)
