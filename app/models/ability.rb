class Ability
  include CanCan::Ability

  # Course
  #   create            admin, some_teacher
  #   read              any
  #   update            admin, teacher
  #   delete            admin
  #   read_headlines    dynamic, teacher, admin
  #   read_feedback     dynamic, teacher, admin
  #   write_feedback    dynamic, teacher, admin
  # CourseInstance
  #   create            admin, teacher
  #   read              any
  #   update            admin, teacher
  #   delete            admin, teacher
  # Topic
  #   create            admin, teacher, dynamic
  #   read              admin, teacher, dynamic
  #   update            admin, teacher
  #   delete            admin
  # User
  #   create            admin


  def initialize(user)
    # All users, including unauthenticated
    can :read, [Course, CourseInstance]

    # Dynamic permissions
    can :read_headlines, Course do |course|
      course_headlines_permission?(course, user)
    end

    can :read_feedback, Course do |course|
      course_read_permission?(course, user)
    end

    can :write_feedback, Course do |course|
      course_write_permission?(course, user)
    end

    can :read, Topic do |topic|
      topic.moderation_status == 'published' && course_read_permission?(topic.course_instance.course, user)
    end

    can :create, Topic do |topic|
      topic.course_instance.active && course_write_permission?(topic.course_instance.course, user)
    end

    can :update, User do |target|
      target == user
    end

    if user
      can [:create], Course do |course|
        Courserole.exists?(:user_login => user.login, :role => 'teacher')
      end

      can [:update, :read_headlines, :read_feedback, :write_feedback, :manage], Course do |course|
        Courserole.exists?(:user_login => user.login, :course_id => course.id, :role => 'teacher')
      end

      can [:create, :update, :delete, :manage], CourseInstance do |course_instance|
        Courserole.exists?(:user_login => user.login, :course_id => course_instance.course.id, :role => 'teacher')
      end

      can [:create, :read, :update], Topic do |topic|
        Courserole.exists?(:user_login => user.login, :course_id => topic.course_instance.course.id, :role => 'teacher')
      end

      # Admin
      if user.admin?
        can [:create, :read, :update, :delete, :read_headlines], Course
        can [:create, :read, :update, :delete], CourseInstance
        can [:create, :read, :update, :delete], Topic
        can [:create, :update, :delete], User
      end
    end
  end


  def is_teacher?(user, course)
    Courserole.exists?(:user_login => user.login, :course_id => course.id, :role => 'teacher')
  end

  def course_headlines_permission?(course, user)
    case course.headlines_read_permission
    when 'public'
      return true
    when 'ip'
      return !!user || trusted_ip_range?()
    when 'authenticated'
      !!user
    when 'enrolled'
      return false
    when 'staff'
      !!user && Courserole.exists?(:user_login => user.login, :course_id => course.id, :role => 'teacher')
    else
      false
    end
  end

  def course_read_permission?(course, user)
    case course.feedback_read_permission
    when 'public'
      return true
    when 'ip'
      return !!user || trusted_ip_range?()
    when 'authenticated'
      !!user
    when 'enrolled'
      return false
    when 'staff'
      !!user && Courserole.exists?(:user_login => user.login, :course_id => course.id, :role => 'teacher')
    else
      false
    end
  end

  def course_write_permission?(course, user)
    case course.feedback_write_permission
    when 'public'
      return true
    when 'ip'
      return !!user || trusted_ip_range?()
    when 'authenticated'
      !!user
    when 'enrolled'
      return false
    when 'staff'
      !!user && Courserole.exists?(:user_login => user.login, :course_id => course.id, :role => 'teacher')
    else
      false
    end
  end

  def trusted_ip_range?
    return false unless NETWORK_RANGE

    remote_ip = request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip
    address = IPAddr.new(remote_ip.split(',').first.strip)

    IPAddr.new('127.0.0.0/8').include?(address) || IPAddr.new(NETWORK_RANGE).include?(address)
  end

end

