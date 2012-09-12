# encoding: UTF-8

class CitizensQuestionsController < ApplicationController
  def new
    if !current_user
      session[:return_url] = request.fullpath
      redirect_to main_app.new_session_path, notice: 'Pro řešení otázky musíte být přihlášen(a).'
    else
      @question = Refinery::Questions::Question.find(params[:question_id])
      @citizens_question = CitizensQuestion.new(citizen_id: current_user.id, question_id: @question.id)    
    end      
  end

  def create    
    @citizens_question = CitizensQuestion.new(params[:citizens_question])
    @question = Refinery::Questions::Question.find(@citizens_question.question_id)
    if @citizens_question.valid?      
      redirect_to @citizens_question.paypal_url('www.google.com')
    else
      render 'new'
    end

"""
    if @citizens_question.save
      redirect_to main_app.citizen_path(current_user.id), notice: 'Otazka pridana' 
    else
      render 'new'
    end
"""
  end

  def edit    
    @citizens_question = CitizensQuestion.find(params[:id])
    redirect_to citizen_path(@citizens_question.citizen_id), notice: 'Pro přidáni hodin musíte vyčerpat přislíbené.'
  end

  def update
    @citizens_question = CitizensQuestion.find(params[:id])
    redirect_to citizen_path(@citizens_question.citizen_id), notice: 'Pro přidáni hodin musíte vyčerpat přislíbené.'
    
    params[:citizens_question][:hours] = params[:citizens_question][:hours].to_i + @citizens_question.hours

    if @citizens_question.update_attributes(params[:citizens_question])
      redirect_to citizen_path(@citizens_question.citizen_id), notice: 'Počet hodin upraven.' 
    else
      render 'edit'
    end
  end

  def move
    @current_citizens_question = CitizensQuestion.find(params[:id])
    @current_question = Refinery::Questions::Question.find(@current_citizens_question.question_id)
    @new_citizens_question = CitizensQuestion.new    
  end

  def relocate_hours
    @from_citizens_question = CitizensQuestion.find(params[:id])
    @to_citizens_question = CitizensQuestion.new
    @to_citizens_question.citizen_id = params[:citizen_id]
    @to_citizens_question.question_id = params[:citizens_question][:question_id]
    @to_citizens_question.hours = params[:citizens_question][:hours]

    from_question_hours = @from_citizens_question.hours - @to_citizens_question.hours    
    
    if @from_citizens_question.update_attributes(hours: from_question_hours) &&
      @to_citizens_question.save
      redirect_to citizen_path(@to_citizens_question.citizen_id)
    else
      render 'move'
    end
  end

  def payment

  end
end