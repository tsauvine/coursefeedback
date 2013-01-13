require 'set'

class QuestionsController < ApplicationController

  before_filter :load_race

  def load_race
    if params[:race_id]
      @race = Race.find(params[:race_id])
    elsif params[:race_instance_id]
      @race_instance = RaceInstance.find(params[:race_instance_id])
      @race = @race_instance.race
    end
  end

  # GET /questionnaires
  # GET /questionnaires.json
  def index
    # Get a list of questionnaires that belong to instances of the current race
    if @race
      questionnaire_ids = @race.questionnaire_ids
    elsif @race_instance
      questionnaire_ids = [@race_instance.questionnaire.id]
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
      format.json { render :json => @questions.to_json
#       (
#         :only => [:id, :type, :text, :hint],
#         :methods => [:content, :params]
#       )
      }
    end
  end

  def comments
    # sleep 1 if ENV['RAILS_ENV'] == "development"

    questionnaire = Questionnaire.find(params[:questionnaire_id])

    respond_to do |format|
      #format.html # index.html.erb
      format.json { render :json => questionnaire.comments(params[:id]).to_json }
    end
  end
end
