class SurveysController < ApplicationController
  before_filter :load_course
  
  def load_course
    @course = Course.find_by_code(params[:course_code])
    @instance = CourseInstance.find_by_path_and_course_id(params[:instance_path], @course.id) if @course

    unless @course
      flash[:error] = t(:course_not_found)
      redirect_to root_path
      return
    end
    
    unless @instance
      flash[:error] = t(:instance_not_found)
      redirect_to @course
      return
    end

    @is_teacher = is_teacher?(current_user, @course)
    @is_admin = is_admin?(current_user)
  end
  
  # GET /surveys
  # GET /surveys.xml
  def index
    @surveys = @instance.surveys
    
    @allow_edit = is_teacher?(current_user, @course) || is_admin?(current_user)
  end

  # GET /surveys/1
  # GET /surveys/1.xml
  def show
    @survey = Survey.find(params[:id])
    
    authorize_level(@survey.answer_permission)
    
    unless @survey.open?
      flash[:warning] = t(:survey_closed)
    end
  end
  
  def results
    @survey = Survey.find(params[:id])
    
    @show_studentnumbers = is_teacher?(current_user, @course)
    @show_numeric = authorized_level?(current_user, @course, @survey.read_numeric_permission)
    @show_text = authorized_level?(current_user, @course, @survey.read_text_permission)
    
    # Load questions into a hash map
    #questions = Hash.new
    #@survey.questions.each do |question|
      #answers = SurveyAnswers.find_by_survey_answer_set_id()
    #  questions[question.id] = question
    #end
    
    # Iterate throgh all answers and update statistics
#     @survey.answer_sets.each do |answerset|
#       answerset.answers.each do |answer|
#         
#         questions[answer.question_id].load_answer(answer)
#       end
#       
#     end
    
    
  end

  # GET /surveys/new
  # GET /surveys/new.xml
  def new
    authorize_teacher or return
  
    @survey = Survey.new(:course_instance_id => @instance.id)
    @survey.name = t(:survey_default_name)
  end

  # GET /surveys/1/edit
  def edit
    authorize_teacher or return
  
    @survey = Survey.find(params[:id])
  end

  # POST /surveys
  # POST /surveys.xml
  def create
    authorize_teacher or return
  
    @survey = Survey.new(params[:survey])

    if @survey.save
      flash[:success] = t(:survey_created)
      redirect_to edit_survey_path(@course.code, @instance.path, @survey)
    else
      render :action => "new"
    end
  end

  # PUT /surveys/1
  # PUT /surveys/1.xml
  def update
    authorize_teacher or return
  
    @survey = Survey.find(params[:id])

    if @survey.update_attributes(params[:survey])
      flash[:success] = t(:survey_updated)
      redirect_to edit_survey_url(@course.code, @instance.path, @survey)
    else
      render :action => "edit"
    end
  end

  # DELETE /surveys/1
  # DELETE /surveys/1.xml
  def destroy
    authorize_teacher or return
    
    @survey = Survey.find(params[:id])
    @survey.destroy

    respond_to do |format|
      format.html { redirect_to surveys_url(@course.code, @instance.path) }
      format.xml  { head :ok }
    end
  end
  
  def answer
    @survey = Survey.find(params[:id])
    authorize_level @survey.answer_permission
    
    @answerset = SurveyAnswerSet.new(:survey_id => @survey.id)
    
    # Check that survey is open
    unless @survey.open?
      flash[:error] = t(:survey_closed)
      render :action => 'show'
      return
    end
    

    incomplete = false
    @missing = Hash.new
    @answers = Hash.new

    # Answers
    @survey.survey_questions.each do |question|
      answer = SurveyAnswer.new(:survey_question_id => question.id)
      question.update_answer(answer, params[question.id.to_s])
      @answers[question.id] = answer 

      if question.mandatory && answer.blank?
        @missing[question.id] = true
        incomplete = true
      end
    end

    # Validate
#     if incomplete
#       flash[:error] = t(:survey_incomplete)
#       render :action => "show"
#       return
#     end

    # Save answerset so that we get the id
    unless @answerset.save
       render :action => "new"
       return
    end
    
    # Save answers
    @answers.each_value do |answer|
      answer.survey_answer_set = @answerset
      answer.save!
    end

    render :action => 'thanks'
  end
end
