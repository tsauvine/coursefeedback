# encoding: utf-8

class AnswerSetsController < ApplicationController

  def load_race_instance
    return unless params[:instance_path]

    if params[:instance_path] =~ /^\d+$/
      # Find by id
      @race_instance = RaceInstance.find(params[:instance_path])
    else
      # Find by path
      @race_instance = RaceInstance.find_by_path(params[:instance_path])
    end

    @questionnaire = @race_instance.questionnaire
  end

  # GET /answer_sets
  # GET /answer_sets.json
  def index
    @answer_sets = AnswerSet.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @answer_sets }
    end
  end

  # GET /answer_sets/1
  # GET /answer_sets/1.json
  def show
    @answer_set = AnswerSet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @answer_set }
    end
  end

  # GET /answer_sets/new
  # GET /answer_sets/new.json
  def new
    load_race_instance

    authorize! :rate, @race_instance

    @answer_set = AnswerSet.new(:questionnaire_id => @questionnaire.id)
    #@answer_set.init_questionnaire(@questionnaire)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @answer_set }
    end
  end

  # GET /answer_sets/1/edit
  def edit
    @answer_set = AnswerSet.find(params[:id])
  end

  # POST /answer_sets
  # POST /answer_sets.json
  def create
    load_race_instance

    authorize! :rate, @race_instance

    @answer_set = AnswerSet.new(params[:answer_set])
    @answer_set.user_id = current_user.id if current_user
    #@answer_set.init_questionnaire(@questionnaire)

    if @answer_set.save
      redirect_to @race_instance, notice: 'Kiitos vastauksesta.'
    else
      render action: "new"
    end
  end

  # PUT /answer_sets/1
  # PUT /answer_sets/1.json
  def update
    @answer_set = AnswerSet.find(params[:id])

    respond_to do |format|
      if @answer_set.update_attributes(params[:answer_set])
        format.html { redirect_to @answer_set, notice: 'Vastausryhmän päivittäminen onnistui.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @answer_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /answer_sets/1
  # DELETE /answer_sets/1.json
  def destroy
    @answer_set = AnswerSet.find(params[:id])
    @answer_set.destroy

    respond_to do |format|
      format.html { redirect_to answer_sets_url }
      format.json { head :no_content }
    end
  end
end
