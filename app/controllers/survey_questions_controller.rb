class SurveyQuestionsController < ApplicationController
  
  def load_survey
    if @question
      #@survey = @question.survey
      @survey = Survey.find(@question.survey_id)
    else
      @survey = Survey.find(params[:survey_id])
    end
    
    unless @survey
      head :bad_request

      return false
    end
    
    @instance = @survey.course_instance
    @course = @instance.course

    @is_teacher = is_teacher?(current_user, @course)
    @is_admin = is_admin?(current_user)
  end
  
  def show
    @question = SurveyQuestion.find(params[:id])
    
    if request.xhr?
      render :update do |page|
        page.replace "question#{@question.id}", :partial => "survey_question_editable", :locals => {:question => @question}
      end
    end
  end

  # GET /surveys/1/edit
  def edit
    @question = SurveyQuestion.find(params[:id])
    
    load_survey
    authorize_teacher or return
  
    if request.xhr?
      render :update do |page|
        page.replace "question#{@question.id}", :partial => "survey_question_editor", :locals => {:question => @question}
      end
    end
  end

  # POST /surveys
  # POST /surveys.xml
  def create
    load_survey
    authorize_teacher or return
  
    @question = SurveyQuestion.new(params[:survey_question])
    @question.survey_id = @survey.id
    @question.type = params[:survey_question][:type]  # type is protected from mass assign
    
    # Position
    if @survey.survey_questions.empty?
      @question.position = 1
    else
      @question.position = @survey.survey_questions.last.position + 1
    end

    if @question.save
      if request.xhr?
        render :partial => "survey_question_editor", :locals => {:question => @question}
      end
    end
  end

  # PUT /surveys/1
  # PUT /surveys/1.xml
  def update
    load_survey
    authorize_teacher or return
  
    @question = SurveyQuestion.find(params[:id])
    @question.update_payload(params)
    @question.attributes = params[:question]

    if @question.save
      render :update do |page|
        page.replace "question#{@question.id}", :partial => "survey_question_editable", :locals => {:question => @question}
      end
    else
      
    end
  end

  # DELETE /surveys/1
  # DELETE /surveys/1.xml
  def destroy
    @question = SurveyQuestion.find(params[:id])
    
    load_survey
    authorize_teacher or return
    
    @question.destroy

    render :update do |page|
      page.remove "question#{@question.id}"
    end
  end
  
  def move
    @question = SurveyQuestion.find(params[:id])

    load_survey
    authorize_teacher or return
    
    if params[:offset].to_i > 0
      @question.move_lower
    else
      @question.move_higher
    end
    
    render :partial => 'survey_question_editable', :collection => @survey.survey_questions, :as => :question
  end
end
