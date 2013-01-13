class QuestionnairesController < ApplicationController

  before_filter :load_questionnaire #, :only => [:show, :answer, :edit, :update]

  def load_questionnaire
    if params[:id]
      @questionnaire = Questionnaire.find(params[:id])
      @instance = @questionnaire.course_instance
    else
      @instance = CourseInstance.find(params[:course_instance_id])
    end
    
    @course = @instance.course
  end

  # GET /questionnaires
  # GET /questionnaires.json
  def index
    @questionnaires = @instance.questionnaires

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @questionnaires }
    end
  end

  # GET /questionnaires/1
  # GET /questionnaires/1.json
  def show
    authorize! :answer, @questionnaire

    respond_to do |format|
      format.html {
        @answer_set = AnswerSet.new()
        @answer_set.questionnaire_id = @questionnaire.id
        @answer_set.init_questionnaire(@questionnaire)
      }
      format.json { render :json => @questionnaire.questions.to_json }
    end
  end


  # GET /questionnaires/new
  # GET /questionnaires/new.json
  def new
    @questionnaire = Questionnaire.new
    @questionnaire.course_instance = @instance
    
    authorize! :create, @questionnaire

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @questionnaire }
    end
  end

  # GET /questionnaires/1/edit
  def edit
    authorize! :edit, @questionnaire
  end

  # POST /questionnaires
  # POST /questionnaires.json
  def create
    @questionnaire = Questionnaire.new(params[:questionnaire])
    @questionnaire.course_instance = @instance
    
    authorize! :create, @questionnaire

    respond_to do |format|
      if @questionnaire.save
        format.html { redirect_to [@instance, @questionnaire], notice: 'Kysymyslomakkeen luominen onnistui.' }
        format.json { render json: @questionnaire, status: :created, location: @questionnaire }
      else
        format.html { render action: "new" }
        format.json { render json: @questionnaire.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /questionnaires/1
  # PUT /questionnaires/1.json
  def update
    authorize! :edit, @questionnaire

    @questionnaire.load_JSON(params[:questionnaire], current_user)

    respond_to do |format|
#       if @questionnaire.update_attributes(params[:questionnaire])
        format.html { redirect_to @questionnaire, notice: 'Kysymyslomakkeen muokkaaminen onnistui.' }
        format.json { head :no_content }
#       else
#         format.html { render action: "edit" }
#         format.json { render json: @questionnaire.errors, status: :unprocessable_entity }
#       end

    end
  end

  # DELETE /questionnaires/1
  # DELETE /questionnaires/1.json
  def destroy
    @questionnaire = Questionnaire.find(params[:id])
    authorize! :destroy, @questionnaire

    @questionnaire.destroy

    respond_to do |format|
      format.html { redirect_to questionnaires_url }
      format.json { head :no_content }
    end
  end
  
    # GET /questionnaires
  # GET /questionnaires.json
  def questions
    # Get a list of questionnaires that belong to instances of the current race
    if @course
      questionnaire_ids = @course.questionnaire_ids
    elsif @instance
      questionnaire_ids = @instance.questionnaire_ids
    else
      questionnaire_ids = []
    end

    # Collect question_ids that are used in those questionnaires
    question_ids = Set.new
    Questionnaire.where(:id => questionnaire_ids).find_each do |questionnaire|
      question_ids.merge(questionnaire.question_ids)
    end

    @questions = Question.find(question_ids.to_a)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @questions.to_json }
    end
  end
end
